import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/companion_prompts.dart';
import '../models/chat_message.dart';

class AIResponseResult {
  final String text;
  final List<ChatActionChip> actionChips;
  final bool isSuccess;
  final String? errorMessage;

  const AIResponseResult({
    required this.text,
    this.actionChips = const [],
    this.isSuccess = true,
    this.errorMessage,
  });

  factory AIResponseResult.error(String message) {
    return AIResponseResult(
      text: '',
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class AIModelService {
  // ─── Konfigurasi API & Backend ──────────────────────────────────────────────
  /// Backend proxy yang aman untuk lingkungan produksi agar tidak mengekspos
  /// kredensial rahasia di sisi aplikasi mobile.
  static String get _backendUrl {
    final envVal = dotenv.isInitialized ? dotenv.maybeGet('AI_BACKEND_URL') : null;
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('AI_BACKEND_URL');
  }

  /// Kunci API untuk lingkungan development / pengujian lokal.
  /// Dibaca otomatis dari file lokal `.env` atau argumen `--dart-define`.
  static String get _geminiApiKey {
    final envVal = dotenv.isInitialized ? dotenv.maybeGet('GEMINI_API_KEY') : null;
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('GEMINI_API_KEY');
  }

  static const String _apiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Model kandidat diurutkan dari yang paling ringan (cepat & hemat kuota)
  /// ke yang lebih besar. Jika model pertama mengembalikan 503 / 429,
  /// otomatis dicoba model berikutnya.
  static const List<String> _candidateModels = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-flash-lite-latest',
  ];

  final HttpClient _httpClient = HttpClient();

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Mengirim pesan pengguna ke Gemini dan mengembalikan respons AI Companion.
  Future<AIResponseResult> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required String companionId,
    required String userName,
    required String habitSummary,
    required String activePrayer,
  }) async {
    try {
      return await _executeSendMessage(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        companionId: companionId,
        userName: userName,
        habitSummary: habitSummary,
        activePrayer: activePrayer,
      );
    } catch (e, stackTrace) {
      debugPrint('AIModelService error: $e');
      debugPrint('Stack: $stackTrace');

      final errorStr = e.toString();
      final lowerError = errorStr.toLowerCase();

      String userFriendlyNotice;
      if (lowerError.contains('network') ||
          lowerError.contains('socket') ||
          lowerError.contains('offline') ||
          lowerError.contains('failed host lookup') ||
          lowerError.contains('connection refused') ||
          lowerError.contains('connection reset') ||
          lowerError.contains('connection abort')) {
        userFriendlyNotice =
            'Koneksi internet sedang tidak stabil. Silakan periksa jaringan dan coba lagi ya! 📶';
      } else if (lowerError.contains('timeout') ||
          lowerError.contains('timed out')) {
        userFriendlyNotice =
            'Permintaan memakan waktu terlalu lama. Coba lagi dalam beberapa saat ya!';
      } else {
        userFriendlyNotice =
            'Maaf, terjadi kendala saat memproses jawaban. Silakan coba lagi.';
      }

      return AIResponseResult(
        text: userFriendlyNotice,
        actionChips: const [
          ChatActionChip(
              label: 'Coba Lagi',
              actionPayload: 'Coba jawab pertanyaan sebelumnya'),
        ],
        isSuccess: false,
        errorMessage: errorStr,
      );
    }
  }

  // ─── Implementasi Internal ───────────────────────────────────────────────────

  Future<AIResponseResult> _executeSendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required String companionId,
    required String userName,
    required String habitSummary,
    required String activePrayer,
  }) async {
    // 1) Bangun system instruction sesuai persona companion (Lulu/Nunu/Riri)
    final systemInstructionText = CompanionPrompts.getPromptForCompanion(
      companionId: companionId,
      userName: userName,
      habitSummary: habitSummary,
      activePrayer: activePrayer,
    );

    // 2) Bangun riwayat percakapan multi-turn yang valid
    final historyContents =
        _buildSanitizedHistory(conversationHistory, userMessage);

    // 3) Tambahkan pesan terkini dari user di akhir
    historyContents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ]
    });

    // 4) Susun payload JSON lengkap
    final payload = {
      'system_instruction': {
        'parts': [
          {'text': systemInstructionText}
        ]
      },
      'contents': historyContents,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 600,
      },
      // Safety settings agar respons tetap aman & ramah
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
      ],
    };

    // 5) Jika backend proxy dikonfigurasikan (arsitektur produksi aman)
    if (_backendUrl.isNotEmpty) {
      return await _sendViaBackend(
        payload: payload,
        userMessage: userMessage,
        companionId: companionId,
      );
    }

    // 6) Validasi ketersediaan kredensial
    if (_geminiApiKey.isEmpty) {
      return AIResponseResult(
        text:
            'Assalamu\'alaikum! Layanan AI Companion saat ini belum terhubung ke backend atau API key. Silakan konfigurasikan endpoint backend atau variabel environment untuk mengaktifkan teman AI Muslim Habit. 🌿',
        actionChips: const [
          ChatActionChip(
            label: 'Info AI',
            actionPayload: 'Layanan AI Companion Muslim Habit',
          ),
        ],
        isSuccess: false,
        errorMessage: 'Backend URL / Gemini API Key belum dikonfigurasi.',
      );
    }

    String lastError = '';

    // 7) Coba model kandidat dengan auto-fallback
    for (final model in _candidateModels) {
      try {
        final uri = Uri.parse(
          '$_apiBaseUrl/models/$model:generateContent?key=$_geminiApiKey',
        );

        final req = await _httpClient.postUrl(uri);
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode(payload));

        final res = await req.close().timeout(
              const Duration(seconds: 30),
            );
        final body = await utf8.decodeStream(res);

        if (res.statusCode == 200) {
          final data = jsonDecode(body) as Map<String, dynamic>;
          final rawText = _extractTextFromResponse(data);

          if (rawText != null && rawText.isNotEmpty) {
            // Berhasil! Bangun action chips cerdas berdasarkan konten
            final chips = _generateSmartActionChips(
              rawText,
              userMessage,
              companionId,
            );

            return AIResponseResult(
              text: rawText,
              actionChips: chips,
              isSuccess: true,
            );
          }
        }

        // 503 (high demand) atau 429 (rate limit) → coba model berikutnya
        if (res.statusCode == 503 || res.statusCode == 429) {
          lastError = 'Model $model sedang sibuk (HTTP ${res.statusCode})';
          debugPrint(lastError);
          continue;
        }

        // Error lain → catat dan coba model berikutnya
        lastError = 'Model $model HTTP ${res.statusCode}: $body';
        debugPrint('Gemini API error: $lastError');
      } catch (e) {
        lastError = 'Exception on model $model: $e';
        debugPrint(lastError);
      }
    }

    // Semua model gagal
    return AIResponseResult(
      text: 'Maaf, layanan AI sedang sibuk. Silakan coba sesaat lagi ya! 🙏',
      actionChips: const [
        ChatActionChip(
            label: 'Coba Lagi',
            actionPayload: 'Coba jawab pertanyaan sebelumnya'),
      ],
      isSuccess: false,
      errorMessage: lastError,
    );
  }

  /// Memanggil endpoint backend yang aman
  Future<AIResponseResult> _sendViaBackend({
    required Map<String, dynamic> payload,
    required String userMessage,
    required String companionId,
  }) async {
    try {
      final uri = Uri.parse(_backendUrl);
      final req = await _httpClient.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(payload));

      final res = await req.close().timeout(
            const Duration(seconds: 30),
          );
      final body = await utf8.decodeStream(res);

      if (res.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final rawText = (data['text'] ?? data['reply'] ?? data['response']) as String?;

        if (rawText != null && rawText.isNotEmpty) {
          final chips = _generateSmartActionChips(
            rawText,
            userMessage,
            companionId,
          );
          return AIResponseResult(
            text: rawText,
            actionChips: chips,
            isSuccess: true,
          );
        }
      }

      return AIResponseResult(
        text: 'Maaf, terjadi kendala saat memproses respons dari server AI.',
        actionChips: const [
          ChatActionChip(
            label: 'Coba Lagi',
            actionPayload: 'Coba jawab pertanyaan sebelumnya',
          ),
        ],
        isSuccess: false,
        errorMessage: 'Backend HTTP ${res.statusCode}: $body',
      );
    } catch (e) {
      debugPrint('AI Backend Error: $e');
      return AIResponseResult(
        text: 'Tidak dapat terhubung ke server backend AI. Silakan coba beberapa saat lagi.',
        actionChips: const [
          ChatActionChip(
            label: 'Coba Lagi',
            actionPayload: 'Coba jawab pertanyaan sebelumnya',
          ),
        ],
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Ekstrak teks respons dari JSON response Gemini
  String? _extractTextFromResponse(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) return null;

      return (parts[0]['text'] as String?)?.trim();
    } catch (_) {
      return null;
    }
  }

  // ─── History Builder ─────────────────────────────────────────────────────────

  /// Membangun history percakapan multi-turn yang memenuhi spesifikasi Gemini:
  /// 1. History diawali oleh role 'user' (greeting awal maskot dilewati)
  /// 2. Role bergantian ketat: user → model → user → model
  /// 3. History diakhiri oleh role 'model' (karena pesan user baru ditambah setelahnya)
  List<Map<String, dynamic>> _buildSanitizedHistory(
    List<ChatMessage> conversationHistory,
    String currentMessage,
  ) {
    final List<Map<String, dynamic>> validHistory = [];

    // Filter pesan yang bukan pesan saat ini (menghindari duplikasi user turn)
    final pastMessages = conversationHistory
        .where((m) => m.content.trim() != currentMessage.trim())
        .toList();

    ChatMessageSender expectedSender = ChatMessageSender.user;

    for (final msg in pastMessages) {
      if (msg.sender == expectedSender) {
        if (msg.sender == ChatMessageSender.user) {
          validHistory.add({
            'role': 'user',
            'parts': [
              {'text': msg.content}
            ]
          });
          expectedSender = ChatMessageSender.companion;
        } else {
          validHistory.add({
            'role': 'model',
            'parts': [
              {'text': msg.content}
            ]
          });
          expectedSender = ChatMessageSender.user;
        }
      }
    }

    // History harus berakhir di 'model'; buang user terakhir jika perlu
    if (validHistory.isNotEmpty &&
        expectedSender == ChatMessageSender.companion) {
      validHistory.removeLast();
    }

    // Batasi ke 8 pesan terakhir (4 pasang user-model)
    if (validHistory.length > 8) {
      return validHistory.sublist(validHistory.length - 8);
    }

    return validHistory;
  }

  // ─── Smart Action Chips ──────────────────────────────────────────────────────

  /// Menghasilkan action chips cerdas berdasarkan konten respons AI dan pesan user
  /// serta persona companion yang aktif.
  List<ChatActionChip> _generateSmartActionChips(
    String aiText,
    String userText,
    String companionId,
  ) {
    final lowerAI = aiText.toLowerCase();
    final lowerUser = userText.toLowerCase();
    final List<ChatActionChip> chips = [];

    // ── Topik Doa ────────────────────────────────────────────────────
    if (lowerAI.contains('doa') || lowerUser.contains('doa')) {
      chips.add(const ChatActionChip(
          label: '📖 Jelaskan Maknanya',
          actionPayload: 'Jelaskan makna doa ini secara ringkas'));
      chips.add(const ChatActionChip(
          label: '🤲 Doa Lainnya',
          actionPayload: 'Rekomendasikan doa harian lainnya'));
    }

    // ── Topik Sholat ─────────────────────────────────────────────────
    else if (lowerAI.contains('sholat') ||
        lowerAI.contains('salat') ||
        lowerUser.contains('sholat') ||
        lowerUser.contains('salat') ||
        lowerUser.contains('shalat')) {
      chips.add(const ChatActionChip(
          label: '🕌 Jadwal Sholat',
          actionPayload: 'Kapan waktu sholat berikutnya?'));
      chips.add(const ChatActionChip(
          label: '💡 Tips Khusyuk',
          actionPayload: 'Beri aku tips agar lebih khusyuk saat sholat'));
    }

    // ── Topik Al-Qur'an & Tilawah ────────────────────────────────────
    else if (lowerAI.contains('quran') ||
        lowerAI.contains("qur'an") ||
        lowerAI.contains('tilawah') ||
        lowerUser.contains('quran') ||
        lowerUser.contains('tilawah')) {
      chips.add(const ChatActionChip(
          label: '📖 Target Tilawah',
          actionPayload: 'Berapa ayat target tilawahku hari ini?'));
      chips.add(const ChatActionChip(
          label: '✨ Keutamaan',
          actionPayload: "Ceritakan keutamaan membaca Al-Qur'an"));
    }

    // ── Topik Puasa ──────────────────────────────────────────────────
    else if (lowerAI.contains('puasa') ||
        lowerAI.contains('saum') ||
        lowerUser.contains('puasa')) {
      chips.add(const ChatActionChip(
          label: '📋 Niat Puasa',
          actionPayload: 'Bagaimana niat puasa yang benar?'));
      chips.add(const ChatActionChip(
          label: '🍽️ Tips Sahur',
          actionPayload: 'Tips sahur yang baik dan bergizi'));
    }

    // ── Topik Dzikir & Istighfar ─────────────────────────────────────
    else if (lowerAI.contains('dzikir') ||
        lowerAI.contains('zikir') ||
        lowerAI.contains('istighfar') ||
        lowerUser.contains('dzikir') ||
        lowerUser.contains('zikir')) {
      chips.add(const ChatActionChip(
          label: '📿 Dzikir Pagi',
          actionPayload: 'Apa saja dzikir pagi yang dianjurkan?'));
      chips.add(const ChatActionChip(
          label: '🌙 Dzikir Petang',
          actionPayload: 'Apa saja dzikir petang yang dianjurkan?'));
    }

    // ── Topik Evaluasi & Motivasi ────────────────────────────────────
    else if (lowerUser.contains('evaluasi') ||
        lowerUser.contains('progress') ||
        lowerUser.contains('progres') ||
        lowerAI.contains('evaluasi')) {
      chips.add(const ChatActionChip(
          label: '📊 Lihat Progres',
          actionPayload: 'Bagaimana progres ibadah saya hari ini?'));
      chips.add(const ChatActionChip(
          label: '💪 Motivasi',
          actionPayload: 'Beri aku semangat untuk beribadah hari ini'));
    }

    // ── Topik Sunnah & Qiyamul Lail (khusus Adult/Riri & Teen/Nunu) ─
    else if (lowerUser.contains('sunnah') ||
        lowerUser.contains('tahajud') ||
        lowerUser.contains('tahajjud') ||
        lowerUser.contains('qiyamul lail') ||
        lowerUser.contains('dhuha')) {
      chips.add(const ChatActionChip(
          label: '🌅 Sholat Dhuha',
          actionPayload: 'Kapan waktu sholat Dhuha dan berapa rakaatnya?'));
      chips.add(const ChatActionChip(
          label: '🌙 Tahajud',
          actionPayload: 'Bagaimana cara sholat Tahajud?'));
    }

    // ── Default: Sapaan / Obrolan Umum ───────────────────────────────
    else {
      // Berikan chips kontekstual sesuai level companion
      switch (companionId.toLowerCase()) {
        case 'kid':
        case 'lulu':
          chips.add(const ChatActionChip(
              label: '🤲 Doa Harian',
              actionPayload: 'Ajari aku doa sehari-hari'));
          chips.add(const ChatActionChip(
              label: '🕌 Belajar Sholat',
              actionPayload: 'Bagaimana cara sholat yang benar?'));
          break;
        case 'adult':
        case 'riri':
          chips.add(const ChatActionChip(
              label: '📊 Evaluasi Ibadah',
              actionPayload: 'Bagaimana evaluasi ibadah saya hari ini?'));
          chips.add(const ChatActionChip(
              label: '🤲 Doa Ketenangan',
              actionPayload: 'Rekomendasikan doa penenang hati'));
          chips.add(const ChatActionChip(
              label: '🌙 Qiyamul Lail',
              actionPayload: 'Beri tips agar istiqomah qiyamul lail'));
          break;
        default: // teen / nunu
          chips.add(const ChatActionChip(
              label: '📊 Evaluasi Ibadah',
              actionPayload: 'Bagaimana evaluasi ibadah saya hari ini?'));
          chips.add(const ChatActionChip(
              label: '🤲 Doa Ketenangan',
              actionPayload: 'Rekomendasikan doa penenang hati'));
          break;
      }
    }

    return chips;
  }
}
