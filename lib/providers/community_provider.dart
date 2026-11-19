import 'package:flutter/material.dart';
import '../models/community/user_profile_model.dart';
import '../models/community/community_model.dart';
import '../models/community/community_post_model.dart';
import '../models/community/chat_message_model.dart';
import '../models/community/community_notification_model.dart';
import '../services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _service;

  int _selectedTab = 0; // 0 = Teman, 1 = Komunitas
  bool _isLoading = true;

  List<UserProfileModel> _friends = [];
  List<CommunityModel> _allCommunities = [];
  List<CommunityModel> _joinedCommunities = [];
  List<UserProfileModel> _friendRequests = [];
  List<UserProfileModel> _recommendedFriends = [];
  List<CommunityNotificationModel> _notifications = [];

  Map<String, List<ChatMessageModel>> _chatCache = {};
  Map<String, List<CommunityPostModel>> _postsCache = {};

  CommunityProvider({CommunityService? service}) : _service = service ?? CommunityService() {
    init();
  }

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  UserProfileModel get currentUser => _service.currentUserProfile;

  List<UserProfileModel> get friends => _friends;
  List<CommunityModel> get allCommunities => _allCommunities;
  List<CommunityModel> get joinedCommunities => _joinedCommunities;
  List<UserProfileModel> get friendRequests => _friendRequests;
  List<UserProfileModel> get recommendedFriends => _recommendedFriends;
  List<CommunityNotificationModel> get notifications => _notifications;

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  int get friendsCount => _friends.length;
  int get joinedCommunitiesCount => _joinedCommunities.length;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _service.init();
    await refreshAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _friends = await _service.getFriends();
    _allCommunities = await _service.getAllCommunities();
    _joinedCommunities = await _service.getJoinedCommunities();
    _friendRequests = await _service.getFriendRequests();
    _recommendedFriends = await _service.getRecommendedFriends();
    _notifications = await _service.getNotifications();
    notifyListeners();
  }

  void switchTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }

  // ── Teman & Pertemanan ──
  Future<void> acceptFriendRequest(UserProfileModel user) async {
    await _service.acceptFriendRequest(user);
    await refreshAll();
  }

  Future<void> rejectFriendRequest(String userId) async {
    await _service.rejectFriendRequest(userId);
    await refreshAll();
  }

  Future<void> addFriendFromRecommendation(UserProfileModel user) async {
    await _service.addFriend(user);
    _recommendedFriends.removeWhere((u) => u.userId == user.userId);
    _friends = await _service.getFriends();
    notifyListeners();
  }

  List<UserProfileModel> searchFriends(String query) {
    if (query.trim().isEmpty) return _friends;
    final q = query.toLowerCase().trim();
    return _friends.where((f) {
      return f.displayName.toLowerCase().contains(q) || f.username.toLowerCase().contains(q);
    }).toList();
  }

  // ── Komunitas ──
  Future<void> joinCommunity(String communityId) async {
    await _service.joinCommunity(communityId);
    _allCommunities = await _service.getAllCommunities();
    _joinedCommunities = await _service.getJoinedCommunities();
    notifyListeners();
  }

  Future<void> leaveCommunity(String communityId) async {
    await _service.leaveCommunity(communityId);
    _allCommunities = await _service.getAllCommunities();
    _joinedCommunities = await _service.getJoinedCommunities();
    notifyListeners();
  }

  Future<void> createCommunity({
    required String name,
    required String description,
    required String category,
    required bool isPrivate,
    required String rules,
    String imageUrl = '',
    String coverUrl = '',
  }) async {
    final newComm = CommunityModel(
      communityId: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      category: category,
      isPrivate: isPrivate,
      rules: rules,
      imageUrl: imageUrl,
      coverUrl: coverUrl,
      adminId: currentUser.userId,
      memberCount: 1,
      memberIds: [currentUser.userId],
      createdAt: DateTime.now(),
    );

    await _service.createCommunity(newComm);
    await refreshAll();
  }

  List<CommunityModel> searchCommunities(String query, {String? category}) {
    List<CommunityModel> list = _allCommunities;
    if (category != null && category != 'Semua' && category.isNotEmpty) {
      list = list.where((c) => c.category == category).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((c) {
        return c.name.toLowerCase().contains(q) || c.description.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  // ── Postingan Komunitas ──
  Future<List<CommunityPostModel>> getPostsForCommunity(String communityId) async {
    final posts = await _service.getPostsForCommunity(communityId);
    _postsCache[communityId] = posts;
    return posts;
  }

  Future<void> createPost({
    required String communityId,
    required String content,
    String imageUrl = '',
  }) async {
    final newPost = CommunityPostModel(
      postId: 'post_${DateTime.now().millisecondsSinceEpoch}',
      communityId: communityId,
      userId: currentUser.userId,
      userName: currentUser.displayName,
      userPhoto: currentUser.photoUrl,
      content: content,
      imageUrl: imageUrl,
      likes: [],
      commentCount: 0,
      createdAt: DateTime.now(),
    );

    await _service.addPost(newPost);
    await getPostsForCommunity(communityId);
    notifyListeners();
  }

  Future<void> toggleLikePost(String communityId, String postId) async {
    await _service.toggleLikePost(postId);
    await getPostsForCommunity(communityId);
    notifyListeners();
  }

  Future<List<CommunityCommentModel>> getCommentsForPost(String postId) async {
    return await _service.getCommentsForPost(postId);
  }

  Future<void> addComment({
    required String communityId,
    required String postId,
    required String content,
  }) async {
    final comment = CommunityCommentModel(
      commentId: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: currentUser.userId,
      userName: currentUser.displayName,
      userPhoto: currentUser.photoUrl,
      content: content,
      createdAt: DateTime.now(),
    );

    await _service.addComment(comment);
    await getPostsForCommunity(communityId);
    notifyListeners();
  }

  // ── Chat Realtime ──
  List<ChatMessageModel> getCachedMessages(String otherUserId) {
    final chatId = _service.getChatId(otherUserId);
    return _chatCache[chatId] ?? [];
  }

  Future<List<ChatMessageModel>> loadMessages(String otherUserId) async {
    final chatId = _service.getChatId(otherUserId);
    final messages = await _service.getMessages(chatId);
    _chatCache[chatId] = messages;
    notifyListeners();
    return messages;
  }

  Future<void> sendMessage({
    required String otherUserId,
    required String text,
    String imageUrl = '',
  }) async {
    if (text.trim().isEmpty && imageUrl.isEmpty) return;
    await _service.sendMessage(
      otherUserId: otherUserId,
      text: text.trim(),
      imageUrl: imageUrl,
    );
    await loadMessages(otherUserId);
  }

  // ── Notifikasi ──
  Future<void> markAllNotificationsRead() async {
    await _service.markAllNotificationsRead();
    _notifications = await _service.getNotifications();
    notifyListeners();
  }
}
