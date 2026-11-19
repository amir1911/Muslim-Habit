import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityRole { admin, moderator, member }

class CommunityMemberModel {
  final String userId;
  final String username;
  final String displayName;
  final String photoUrl;
  final CommunityRole role;
  final DateTime joinedAt;

  CommunityMemberModel({
    required this.userId,
    required this.username,
    required this.displayName,
    this.photoUrl = '',
    this.role = CommunityRole.member,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final roleStr = json['role'] as String? ?? 'member';
    final role = CommunityRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => CommunityRole.member,
    );

    return CommunityMemberModel(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? 'user',
      displayName: json['displayName'] as String? ?? 'Pengguna',
      photoUrl: json['photoUrl'] as String? ?? '',
      role: role,
      joinedAt: parseDate(json['joinedAt']),
    );
  }
}

class CommunityModel {
  final String communityId;
  final String name;
  final String description;
  final String imageUrl;
  final String coverUrl;
  final String category;
  final bool isPrivate;
  final String adminId;
  final int memberCount;
  final String rules;
  final List<String> memberIds;
  final DateTime createdAt;

  CommunityModel({
    required this.communityId,
    required this.name,
    required this.description,
    this.imageUrl = '',
    this.coverUrl = '',
    this.category = 'Umum',
    this.isPrivate = false,
    required this.adminId,
    this.memberCount = 1,
    this.rules = 'Saling menghormati dan menjaga adab Islami.',
    List<String>? memberIds,
    DateTime? createdAt,
  })  : memberIds = memberIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get privacyLabel => isPrivate ? 'Invite Only Community 🔒' : 'Public Community';

  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverUrl': coverUrl,
      'category': category,
      'isPrivate': isPrivate,
      'adminId': adminId,
      'memberCount': memberCount,
      'rules': rules,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return CommunityModel(
      communityId: json['communityId'] as String? ?? '',
      name: json['name'] as String? ?? 'Komunitas',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'Umum',
      isPrivate: json['isPrivate'] as bool? ?? false,
      adminId: json['adminId'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 1,
      rules: json['rules'] as String? ?? 'Saling menghormati dan menjaga adab Islami.',
      memberIds: (json['memberIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: parseDate(json['createdAt']),
    );
  }

  CommunityModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? coverUrl,
    String? category,
    bool? isPrivate,
    int? memberCount,
    String? rules,
    List<String>? memberIds,
  }) {
    return CommunityModel(
      communityId: communityId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      isPrivate: isPrivate ?? this.isPrivate,
      adminId: adminId,
      memberCount: memberCount ?? this.memberCount,
      rules: rules ?? this.rules,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt,
    );
  }
}
