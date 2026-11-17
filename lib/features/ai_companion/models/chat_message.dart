enum ChatMessageSender {
  user,
  companion,
}

enum MessageDeliveryStatus {
  sending,
  sent,
  failed,
}

class ChatActionChip {
  final String label;
  final String actionPayload;

  const ChatActionChip({
    required this.label,
    required this.actionPayload,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'actionPayload': actionPayload,
    };
  }

  factory ChatActionChip.fromMap(Map<String, dynamic> map) {
    return ChatActionChip(
      label: map['label'] as String? ?? '',
      actionPayload: map['actionPayload'] as String? ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String companionId; // 'kid'/'lulu', 'teen'/'nunu', 'adult'/'riri'
  final String content;
  final ChatMessageSender sender;
  final DateTime timestamp;
  final MessageDeliveryStatus status;
  final List<ChatActionChip> actionChips;
  final String? audioUrl;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.companionId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.status = MessageDeliveryStatus.sent,
    this.actionChips = const [],
    this.audioUrl,
  });

  ChatMessage copyWith({
    String? content,
    MessageDeliveryStatus? status,
    List<ChatActionChip>? actionChips,
    String? audioUrl,
  }) {
    return ChatMessage(
      id: id,
      userId: userId,
      companionId: companionId,
      content: content ?? this.content,
      sender: sender,
      timestamp: timestamp,
      status: status ?? this.status,
      actionChips: actionChips ?? this.actionChips,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'companionId': companionId,
      'content': content,
      'sender': sender == ChatMessageSender.user ? 'user' : 'companion',
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'actionChips': actionChips.map((c) => c.toMap()).toList(),
      if (audioUrl != null) 'audioUrl': audioUrl,
    };
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> map) {
    final senderStr = map['sender'] as String? ?? 'user';
    final statusStr = map['status'] as String? ?? 'sent';
    final rawChips = map['actionChips'] as List<dynamic>? ?? [];

    return ChatMessage(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      companionId: map['companionId'] as String? ?? 'teen',
      content: map['content'] as String? ?? '',
      sender: senderStr == 'companion' ? ChatMessageSender.companion : ChatMessageSender.user,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      status: MessageDeliveryStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => MessageDeliveryStatus.sent,
      ),
      actionChips: rawChips
          .map((c) => ChatActionChip.fromMap(c as Map<String, dynamic>))
          .toList(),
      audioUrl: map['audioUrl'] as String?,
    );
  }
}

