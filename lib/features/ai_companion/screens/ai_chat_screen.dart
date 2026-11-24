import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/habit_provider.dart';
import '../../../providers/prayer_time_provider.dart';
import '../models/chat_message.dart';
import '../providers/ai_chat_provider.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/typing_indicator.dart';
import '../../../models/ai_assistant_model.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initChat();
    }
  }

  void _initChat() {
    final habitProvider = context.read<HabitProvider>();
    final aiChatProvider = context.read<AIChatProvider>();
    final companion = habitProvider.currentAssistant;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    aiChatProvider.initializeChat(
      userId: userId,
      companionId: companion.id,
      companionName: companion.name,
      initialGreeting: companion.homeMotivationDefault,
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    final habitProvider = context.read<HabitProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();
    final aiChatProvider = context.read<AIChatProvider>();

    aiChatProvider.sendMessage(
      text: text,
      habitProvider: habitProvider,
      prayerProvider: prayerProvider,
    );
  }

  void _sendChipMessage(String payload) {
    final habitProvider = context.read<HabitProvider>();
    final prayerProvider = context.read<PrayerTimeProvider>();
    final aiChatProvider = context.read<AIChatProvider>();

    aiChatProvider.sendMessage(
      text: payload,
      habitProvider: habitProvider,
      prayerProvider: prayerProvider,
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDate).inDays;
    if (diff == 0) return 'HARI INI';
    if (diff == 1) return 'KEMARIN';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitProvider, AIChatProvider>(
      builder: (context, habitProvider, aiChatProvider, _) {
        final companion = habitProvider.currentAssistant;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F8F2),
          appBar: _buildAppBar(companion, context),
          body: Column(
            children: [
              Expanded(child: _buildMessageList(aiChatProvider, companion)),
              if (aiChatProvider.isSending) const TypingIndicator(),
              _buildInputBar(aiChatProvider),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      AIAssistantModel companion, BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF4A7220),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            companion.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Maskot Pendamping-mu',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.graphic_eq_rounded, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur audio segera hadir'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(
      AIChatProvider aiChatProvider, AIAssistantModel companion) {
    if (aiChatProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF518427)),
      );
    }

    final messages = aiChatProvider.messages;
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(companion.imagePath, width: 100, height: 100),
            const SizedBox(height: 16),
            Text(
              'Mulai percakapan dengan ${companion.name}!',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Build display list: messages (newest first) with date separators
    final displayItems = _buildDisplayItems(messages);

    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        if (item is String) {
          return DateSeparatorWidget(label: item);
        }
        final msg = item as ChatMessage;
        return ChatBubbleWidget(
          message: msg,
          onChipSelected: _sendChipMessage,
        );
      },
    );
  }

  /// Build display list from newest→oldest (for reverse ListView).
  /// Each date label appears once before its group of messages (in display order).
  List<dynamic> _buildDisplayItems(List<ChatMessage> messages) {
    // messages is already newest-first (from AIChatProvider)
    // We need: for reverse ListView, index 0 = bottom of screen = newest message
    // Insert date separators between groups
    final items = <dynamic>[];
    String? lastLabel;

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final label = _getDateLabel(msg.timestamp);
      items.add(msg);
      if (label != lastLabel) {
        // Insert separator after the last message of each date group
        // Because list is reversed, separator goes below the group
        items.add(label);
        lastLabel = label;
      }
    }
    return items;
  }

  Widget _buildInputBar(AIChatProvider aiChatProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan apa saja',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.mic_none_rounded,
                      color: Colors.grey.shade500, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: aiChatProvider.isSending ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: aiChatProvider.isSending
                    ? Colors.grey.shade300
                    : const Color(0xFF3D6B1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
