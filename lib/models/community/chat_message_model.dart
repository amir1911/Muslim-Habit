import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderPhoto;
  final String text;
  final String imageUrl;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.senderName = '',
    this.senderPhoto = '',
    required this.text,
    this.imageUrl = '',
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'text': text,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ChatMessageModel(
      messageId: json['messageId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderPhoto: json['senderPhoto'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class ChatConversationModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoto;
  final bool otherUserOnline;
  final int unreadCount;

  ChatConversationModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto = '',
    this.otherUserOnline = false,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserPhoto': otherUserPhoto,
      'otherUserOnline': otherUserOnline,
      'unreadCount': unreadCount,
    };
  }

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ChatConversationModel(
      chatId: json['chatId'] as String? ?? '',
      participants: (json['participants'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: parseDate(json['lastMessageTime']),
      otherUserId: json['otherUserId'] as String? ?? '',
      otherUserName: json['otherUserName'] as String? ?? 'Teman',
      otherUserPhoto: json['otherUserPhoto'] as String? ?? '',
      otherUserOnline: json['otherUserOnline'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
