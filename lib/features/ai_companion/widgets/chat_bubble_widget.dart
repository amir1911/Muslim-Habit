import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

/// Bubble chat untuk user (kanan, hijau tua) dan companion (kiri, putih/krem)
class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onActionChipTap;
  final Function(String payload)? onChipSelected;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.onActionChipTap,
    this.onChipSelected,
  });

  bool get isUser => message.sender == ChatMessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _buildCompanionIcon(),
              const SizedBox(width: 6),
              Flexible(child: _buildBubble()),
              if (isUser) const SizedBox(width: 6),
              if (isUser) _buildUserIcon(),
            ],
          ),
          if (message.actionChips.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildActionChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanionIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF557C2B)),
    );
  }

  Widget _buildUserIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF557C2B).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 16, color: Color(0xFF557C2B)),
    );
  }

  Widget _buildBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF3D6B1A) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              fontSize: 14,
              color: isUser ? Colors.white : const Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isUser
                    ? Colors.white.withValues(alpha: 0.65)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 34),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: message.actionChips.map((chip) {
          return GestureDetector(
            onTap: () => onChipSelected?.call(chip.actionPayload),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF88B342), width: 1),
              ),
              child: Text(
                chip.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF557C2B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Chip tanggal separator ("HARI INI", "KEMARIN", dll.)
class DateSeparatorWidget extends StatelessWidget {
  final String label;
  const DateSeparatorWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE0EDD0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF557C2B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

