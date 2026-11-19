import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPostModel {
  final String postId;
  final String communityId;
  final String userId;
  final String userName;
  final String userPhoto;
  final String content;
  final String imageUrl;
  final List<String> likes;
  final int commentCount;
  final DateTime createdAt;

  CommunityPostModel({
    required this.postId,
    required this.communityId,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.content,
    this.imageUrl = '',
    List<String>? likes,
    this.commentCount = 0,
    DateTime? createdAt,
  })  : likes = likes ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool isLikedBy(String uid) => likes.contains(uid);

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'communityId': communityId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return CommunityPostModel(
      postId: json['postId'] as String? ?? '',
      communityId: json['communityId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Pengguna',
      userPhoto: json['userPhoto'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      likes: (json['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      commentCount: json['commentCount'] as int? ?? 0,
      createdAt: parseDate(json['createdAt']),
    );
  }

  CommunityPostModel copyWith({
    List<String>? likes,
    int? commentCount,
  }) {
    return CommunityPostModel(
      postId: postId,
      communityId: communityId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      content: content,
      imageUrl: imageUrl,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
    );
  }
}

class CommunityCommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String userPhoto;
  final String content;
  final DateTime createdAt;

  CommunityCommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return CommunityCommentModel(
      commentId: json['commentId'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Pengguna',
      userPhoto: json['userPhoto'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
