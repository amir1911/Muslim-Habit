import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/ai_model_service.dart';
import '../services/chat_repository.dart';
import '../services/habit_context_service.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/prayer_time_provider.dart';

class AIChatProvider extends ChangeNotifier {
  final AIModelService _aiModelService;
  final ChatRepository _chatRepository;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  String _currentCompanionId = 'teen';
  String _currentUserId = '';

  AIChatProvider({
    AIModelService? aiModelService,
    ChatRepository? chatRepository,
  })  : _aiModelService = aiModelService ?? AIModelService(),
        _chatRepository = chatRepository ?? ChatRepository();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String get currentCompanionId => _currentCompanionId;

  /// Inisialisasi percakapan untuk user & companion tertentu
  void initializeChat({
    required String userId,
    required String companionId,
    required String companionName,
    required String initialGreeting,
  }) {
    if (_currentUserId == userId &&
        _currentCompanionId == companionId &&
        _messages.isNotEmpty) {
      return;
    }

    _currentUserId = userId;
    _currentCompanionId = companionId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _chatSubscription?.cancel();
    _chatSubscription = _chatRepository
        .watchMessages(userId: userId, companionId: companionId)
        .listen(
      (loadedMessages) {
        if (loadedMessages.isEmpty) {
          // Buat sambutan awal yang sesuai persona companion
          final welcomeChips = _getWelcomeChips(companionId);
          final welcomeMsg = ChatMessage(
            id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            companionId: companionId,
            content: initialGreeting,
            sender: ChatMessageSender.companion,
            timestamp: DateTime.now(),
            actionChips: welcomeChips,
          );
          _messages = [welcomeMsg];
        } else {
          _messages = loadedMessages;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error watching messages: $e');
        // Jika Firestore gagal (misalnya offline), tetap izinkan chatting
        if (_messages.isEmpty) {
          final welcomeMsg = ChatMessage(
            id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            companionId: companionId,
            content: initialGreeting,
            sender: ChatMessageSender.companion,
            timestamp: DateTime.now(),
            actionChips: _getWelcomeChips(companionId),
          );
          _messages = [welcomeMsg];
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Mengirim pesan baru ke AI Companion
  Future<void> sendMessage({
    required String text,
    required HabitProvider habitProvider,
    required PrayerTimeProvider prayerProvider,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    final userMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final userMessage = ChatMessage(
      id: userMsgId,
      userId: _currentUserId,
      companionId: _currentCompanionId,
      content: trimmed,
      sender: ChatMessageSender.user,
      timestamp: DateTime.now(),
      status: MessageDeliveryStatus.sending,
    );

    // Ambil riwayat percakapan sebelumnya SEBELUM pesan user baru ditambahkan
    final priorHistory = List<ChatMessage>.from(_messages.reversed);

    // Update list lokal secara optimis
    _messages = [userMessage, ..._messages];
    notifyListeners();

    // Simpan ke Firestore (tidak menunggu — fire & forget supaya tidak blocking)
    _chatRepository
        .saveMessage(
            userMessage.copyWith(status: MessageDeliveryStatus.sent))
        .catchError((e) {
      debugPrint('Save user message error (non-fatal): $e');
    });

    // Ambil context habit & sholat
    final habitSummary = HabitContextService.buildHabitSummary(habitProvider);
    final activePrayer =
        HabitContextService.getActivePrayerContext(prayerProvider);

    // Kirim ke Google Gemini via Google AI Studio
    final aiResult = await _aiModelService.sendMessage(
      userMessage: trimmed,
      conversationHistory: priorHistory,
      companionId: _currentCompanionId,
      userName: habitProvider.userName,
      habitSummary: habitSummary,
      activePrayer: activePrayer,
    );

    final aiMsgId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    final companionMessage = ChatMessage(
      id: aiMsgId,
      userId: _currentUserId,
      companionId: _currentCompanionId,
      content: aiResult.text,
      sender: ChatMessageSender.companion,
      timestamp: DateTime.now(),
      actionChips: aiResult.actionChips,
      status: aiResult.isSuccess
          ? MessageDeliveryStatus.sent
          : MessageDeliveryStatus.failed,
    );

    _messages = [companionMessage, ..._messages];
    _isSending = false;

    if (!aiResult.isSuccess) {
      _errorMessage = aiResult.errorMessage;
    }

    notifyListeners();

    // Simpan respons AI ke Firestore (fire & forget)
    if (aiResult.isSuccess) {
      _chatRepository.saveMessage(companionMessage).catchError((e) {
        debugPrint('Save AI message error (non-fatal): $e');
      });
    }
  }

  /// Membersihkan riwayat percakapan saat ini
  Future<void> clearHistory() async {
    if (_currentUserId.isNotEmpty) {
      await _chatRepository.clearChatHistory(
        userId: _currentUserId,
        companionId: _currentCompanionId,
      );
      _messages.clear();
      notifyListeners();
    }
  }

  /// Mendapatkan welcome action chips yang sesuai persona companion
  List<ChatActionChip> _getWelcomeChips(String companionId) {
    switch (companionId.toLowerCase()) {
      case 'kid':
      case 'lulu':
        return const [
          ChatActionChip(
              label: '🤲 Doa Harian',
              actionPayload: 'Ajari aku doa sehari-hari'),
          ChatActionChip(
              label: '🕌 Belajar Sholat',
              actionPayload: 'Bagaimana cara sholat yang benar?'),
        ];
      case 'adult':
      case 'riri':
        return const [
          ChatActionChip(
              label: '📊 Evaluasi Ibadah',
              actionPayload: 'Bagaimana evaluasi ibadah saya hari ini?'),
          ChatActionChip(
              label: '🤲 Doa Ketenangan',
              actionPayload: 'Rekomendasikan doa penenang hati'),
          ChatActionChip(
              label: '🌙 Qiyamul Lail',
              actionPayload: 'Beri tips agar istiqomah qiyamul lail'),
        ];
      default: // teen / nunu
        return const [
          ChatActionChip(
              label: '📊 Evaluasi Ibadah',
              actionPayload: 'Bagaimana evaluasi ibadah saya hari ini?'),
          ChatActionChip(
              label: '🤲 Doa Ketenangan',
              actionPayload: 'Rekomendasikan doa penenang hati'),
        ];
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}
