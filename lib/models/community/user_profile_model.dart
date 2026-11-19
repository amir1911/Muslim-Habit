import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String userId;
  final String username;
  final String displayName;
  final String photoUrl;
  final String bio;
  final String phoneOrEmail;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime createdAt;

  UserProfileModel({
    required this.userId,
    required this.username,
    required this.displayName,
    this.photoUrl = '',
    this.bio = 'Semoga hari ini penuh berkah 🌿',
    this.phoneOrEmail = '',
    this.isOnline = false,
    DateTime? lastActive,
    DateTime? createdAt,
  })  : lastActive = lastActive ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'phoneOrEmail': phoneOrEmail,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? 'user',
      displayName: json['displayName'] as String? ?? 'Pengguna Muslim Habit',
      photoUrl: json['photoUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? 'Semoga hari ini penuh berkah 🌿',
      phoneOrEmail: json['phoneOrEmail'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastActive: parseDate(json['lastActive']),
      createdAt: parseDate(json['createdAt']),
    );
  }

  String get activeStatusString {
    if (isOnline) return 'Online';
    final diff = DateTime.now().difference(lastActive);
    if (diff.inMinutes < 1) return 'Aktif barusan';
    if (diff.inMinutes < 60) return 'Aktif ${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return 'Aktif ${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return 'Aktif ${diff.inDays} hari yang lalu';
  }
}

enum FriendshipStatus { pending, accepted, rejected, blocked }

class FriendshipModel {
  final String friendshipId;
  final String senderId;
  final String receiverId;
  final FriendshipStatus status;
  final DateTime createdAt;

  FriendshipModel({
    required this.friendshipId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'friendshipId': friendshipId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final s = json['status'] as String? ?? 'pending';
    final status = FriendshipStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => FriendshipStatus.pending,
    );

    return FriendshipModel(
      friendshipId: json['friendshipId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      status: status,
      createdAt: parseDate(json['createdAt']),
    );
  }
}
