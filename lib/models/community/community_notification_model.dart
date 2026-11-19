import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  friendRequest,
  friendAccepted,
  newChat,
  communityInvite,
  communityJoined,
  postComment,
  postLike,
  announcement,
}

class CommunityNotificationModel {
  final String notificationId;
  final String receiverId;
  final NotificationType type;
  final String senderId;
  final String senderName;
  final String senderPhoto;
  final String referenceId; // chatId, postId, or communityId
  final String message;
  final bool isRead;
  final DateTime createdAt;

  CommunityNotificationModel({
    required this.notificationId,
    required this.receiverId,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.senderPhoto = '',
    this.referenceId = '',
    required this.message,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'receiverId': receiverId,
      'type': type.name,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'referenceId': referenceId,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final typeStr = json['type'] as String? ?? 'friendRequest';
    final type = NotificationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NotificationType.friendRequest,
    );

    return CommunityNotificationModel(
      notificationId: json['notificationId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      type: type,
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'Teman',
      senderPhoto: json['senderPhoto'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
    );
  }

  CommunityNotificationModel copyWith({bool? isRead}) {
    return CommunityNotificationModel(
      notificationId: notificationId,
      receiverId: receiverId,
      type: type,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      referenceId: referenceId,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
