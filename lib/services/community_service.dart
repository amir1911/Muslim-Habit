import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community/user_profile_model.dart';
import '../models/community/community_model.dart';
import '../models/community/community_post_model.dart';
import '../models/community/chat_message_model.dart';
import '../models/community/community_notification_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _prefKeyFriends = 'community_friends_v1';
  static const String _prefKeyCommunities = 'community_list_v1';
  static const String _prefKeyJoinedCommunities = 'community_joined_ids_v1';
  static const String _prefKeyPosts = 'community_posts_v1';
  static const String _prefKeyComments = 'community_comments_v1';
  static const String _prefKeyChats = 'community_chats_v1';
  static const String _prefKeyNotifications = 'community_notifications_v1';
  static const String _prefKeyUserProfile = 'community_user_profile_v1';
  static const String _prefKeyFriendRequests = 'community_friend_requests_v1';

  UserProfileModel? _currentUserProfile;

  UserProfileModel get currentUserProfile {
    if (_currentUserProfile != null) return _currentUserProfile!;
    final fbUser = _auth.currentUser;
    return UserProfileModel(
      userId: fbUser?.uid ?? 'my_user_001',
      username: fbUser?.displayName?.toLowerCase().replaceAll(' ', '_') ?? 'ahmad_muslim',
      displayName: fbUser?.displayName ?? 'Ahmad Santoso',
      photoUrl: fbUser?.photoURL ?? '',
      bio: 'Istiqomah dalam ibadah dan kebaikan 🌿',
      phoneOrEmail: fbUser?.email ?? 'ahmad@muslimhabit.app',
      isOnline: true,
      lastActive: DateTime.now(),
    );
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString(_prefKeyUserProfile);
    if (profileStr != null) {
      try {
        _currentUserProfile = UserProfileModel.fromJson(jsonDecode(profileStr));
      } catch (_) {}
    }
    if (_currentUserProfile == null) {
      final fbUser = _auth.currentUser;
      _currentUserProfile = UserProfileModel(
        userId: fbUser?.uid ?? 'my_user_001',
        username: fbUser?.displayName?.toLowerCase().replaceAll(' ', '_') ?? 'ahmad_muslim',
        displayName: fbUser?.displayName ?? 'Ahmad Santoso',
        photoUrl: fbUser?.photoURL ?? '',
        bio: 'Istiqomah dalam ibadah dan kebaikan 🌿',
        phoneOrEmail: fbUser?.email ?? 'ahmad@muslimhabit.app',
        isOnline: true,
        lastActive: DateTime.now(),
      );
      await prefs.setString(_prefKeyUserProfile, jsonEncode(_currentUserProfile!.toJson()));
    }

    // Seed data default jika belum ada
    await _seedInitialDataIfNeeded(prefs);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. DATA TEMAN (FRIENDS)
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<UserProfileModel>> getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_prefKeyFriends);
    if (dataStr != null) {
      try {
        final list = (jsonDecode(dataStr) as List<dynamic>)
            .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      } catch (e) {
        debugPrint('Error parsing local friends: $e');
      }
    }
    return _getDefaultFriends();
  }

  Future<void> addFriend(UserProfileModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFriends();
    if (!current.any((f) => f.userId == user.userId)) {
      current.add(user);
      await prefs.setString(
        _prefKeyFriends,
        jsonEncode(current.map((e) => e.toJson()).toList()),
      );
    }
  }

  Future<List<UserProfileModel>> getRecommendedFriends() async {
    return [
      UserProfileModel(
        userId: 'rec_01',
        username: 'rama_dani',
        displayName: 'Rama Ramadhani',
        bio: 'Penuntut ilmu syari & penghafal Quran',
        phoneOrEmail: '0851627388639',
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      UserProfileModel(
        userId: 'rec_02',
        username: 'aji_haji',
        displayName: 'Aji (Haji)',
        bio: 'Alhamdulillah sudah menunaikan ibadah haji',
        phoneOrEmail: '081298471203',
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      UserProfileModel(
        userId: 'rec_03',
        username: 'firaaa_s',
        displayName: 'Firaaa Salsabila',
        bio: 'Belajar istiqomah tahajud & dhuha',
        phoneOrEmail: '087819238475',
        lastActive: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      UserProfileModel(
        userId: 'rec_04',
        username: 'bintang_al',
        displayName: 'Bintang Al-Fatih',
        bio: 'Keluarga pecinta masjid',
        phoneOrEmail: '085234918274',
        lastActive: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      UserProfileModel(
        userId: 'rec_05',
        username: 'maulana_adiatma_2',
        displayName: 'Maulana Adiatma',
        bio: 'Sahabat hijrah & tilawah',
        phoneOrEmail: '0851627388639',
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  Future<List<UserProfileModel>> getFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyFriendRequests);
    if (data != null) {
      try {
        return (jsonDecode(data) as List<dynamic>)
            .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return [
      UserProfileModel(
        userId: 'req_01',
        username: 'rama_dani',
        displayName: 'Rama Ramadhani',
        phoneOrEmail: '0851627388639',
        bio: 'Ingin berteman sesama pejuang subuh',
      ),
      UserProfileModel(
        userId: 'req_02',
        username: 'aji_haji',
        displayName: 'Aji (Haji)',
        phoneOrEmail: '081298471203',
        bio: 'Menjalin silaturahmi ukhuwah Islamiyah',
      ),
      UserProfileModel(
        userId: 'req_03',
        username: 'firaaa_s',
        displayName: 'Firaaa Salsabila',
        phoneOrEmail: '087819238475',
        bio: 'Saling mengingatkan dalam kebaikan',
      ),
    ];
  }

  Future<void> acceptFriendRequest(UserProfileModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getFriendRequests();
    requests.removeWhere((r) => r.userId == user.userId);
    await prefs.setString(
      _prefKeyFriendRequests,
      jsonEncode(requests.map((e) => e.toJson()).toList()),
    );
    await addFriend(user);

    // Tambahkan notifikasi
    await addNotification(CommunityNotificationModel(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      receiverId: currentUserProfile.userId,
      type: NotificationType.friendAccepted,
      senderId: user.userId,
      senderName: user.displayName,
      senderPhoto: user.photoUrl,
      message: 'Kamu dan ${user.displayName} sekarang berteman.',
    ));
  }

  Future<void> rejectFriendRequest(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getFriendRequests();
    requests.removeWhere((r) => r.userId == userId);
    await prefs.setString(
      _prefKeyFriendRequests,
      jsonEncode(requests.map((e) => e.toJson()).toList()),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. DATA KOMUNITAS (COMMUNITIES)
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<CommunityModel>> getAllCommunities() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyCommunities);
    if (data != null) {
      try {
        return (jsonDecode(data) as List<dynamic>)
            .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return _getDefaultCommunities();
  }

  Future<List<CommunityModel>> getJoinedCommunities() async {
    final all = await getAllCommunities();
    final currentUid = currentUserProfile.userId;
    return all.where((c) => c.memberIds.contains(currentUid)).toList();
  }

  Future<void> joinCommunity(String communityId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllCommunities();
    final index = all.indexWhere((c) => c.communityId == communityId);
    if (index != -1) {
      final c = all[index];
      final currentUid = currentUserProfile.userId;
      if (!c.memberIds.contains(currentUid)) {
        final updatedMembers = List<String>.from(c.memberIds)..add(currentUid);
        all[index] = c.copyWith(
          memberIds: updatedMembers,
          memberCount: c.memberCount + 1,
        );
        await prefs.setString(_prefKeyCommunities, jsonEncode(all.map((e) => e.toJson()).toList()));
      }
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllCommunities();
    final index = all.indexWhere((c) => c.communityId == communityId);
    if (index != -1) {
      final c = all[index];
      final currentUid = currentUserProfile.userId;
      final updatedMembers = List<String>.from(c.memberIds)..remove(currentUid);
      all[index] = c.copyWith(
        memberIds: updatedMembers,
        memberCount: (c.memberCount > 1) ? c.memberCount - 1 : 1,
      );
      await prefs.setString(_prefKeyCommunities, jsonEncode(all.map((e) => e.toJson()).toList()));
    }
  }

  Future<void> createCommunity(CommunityModel community) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllCommunities();
    all.insert(0, community);
    await prefs.setString(_prefKeyCommunities, jsonEncode(all.map((e) => e.toJson()).toList()));

    // Tambah notifikasi
    await addNotification(CommunityNotificationModel(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      receiverId: currentUserProfile.userId,
      type: NotificationType.communityJoined,
      senderId: currentUserProfile.userId,
      senderName: currentUserProfile.displayName,
      referenceId: community.communityId,
      message: 'Komunitas "${community.name}" berhasil dibuat!',
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. POSTINGAN & DISKUSI KOMUNITAS
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<CommunityPostModel>> getPostsForCommunity(String communityId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyPosts);
    if (data != null) {
      try {
        final all = (jsonDecode(data) as List<dynamic>)
            .map((e) => CommunityPostModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final filtered = all.where((p) => p.communityId == communityId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return filtered;
      } catch (_) {}
    }
    return _getDefaultPosts(communityId);
  }

  Future<void> addPost(CommunityPostModel post) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _getAllPostsRaw(prefs);
    all.insert(0, post);
    await prefs.setString(_prefKeyPosts, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> toggleLikePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _getAllPostsRaw(prefs);
    final index = all.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final p = all[index];
      final currentUid = currentUserProfile.userId;
      final updatedLikes = List<String>.from(p.likes);
      if (updatedLikes.contains(currentUid)) {
        updatedLikes.remove(currentUid);
      } else {
        updatedLikes.add(currentUid);
      }
      all[index] = p.copyWith(likes: updatedLikes);
      await prefs.setString(_prefKeyPosts, jsonEncode(all.map((e) => e.toJson()).toList()));
    }
  }

  Future<List<CommunityCommentModel>> getCommentsForPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyComments);
    if (data != null) {
      try {
        final all = (jsonDecode(data) as List<dynamic>)
            .map((e) => CommunityCommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return all.where((c) => c.postId == postId).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } catch (_) {}
    }
    return _getDefaultComments(postId);
  }

  Future<void> addComment(CommunityCommentModel comment) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyComments);
    List<CommunityCommentModel> allComments = [];
    if (data != null) {
      try {
        allComments = (jsonDecode(data) as List<dynamic>)
            .map((e) => CommunityCommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    allComments.add(comment);
    await prefs.setString(_prefKeyComments, jsonEncode(allComments.map((e) => e.toJson()).toList()));

    // Perbarui jumlah komentar di postingan
    final allPosts = await _getAllPostsRaw(prefs);
    final postIndex = allPosts.indexWhere((p) => p.postId == comment.postId);
    if (postIndex != -1) {
      final p = allPosts[postIndex];
      allPosts[postIndex] = p.copyWith(commentCount: p.commentCount + 1);
      await prefs.setString(_prefKeyPosts, jsonEncode(allPosts.map((e) => e.toJson()).toList()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. CHAT DENGAN TEMAN (MESSAGES)
  // ─────────────────────────────────────────────────────────────────────────────
  String getChatId(String otherUserId) {
    final myId = currentUserProfile.userId;
    final ids = [myId, otherUserId]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  Future<List<ChatMessageModel>> getMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_messages_$chatId';
    final data = prefs.getString(key);
    if (data != null) {
      try {
        return (jsonDecode(data) as List<dynamic>)
            .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } catch (_) {}
    }
    return _getDefaultChatMessages(chatId);
  }

  Future<void> sendMessage({
    required String otherUserId,
    required String text,
    String imageUrl = '',
  }) async {
    final chatId = getChatId(otherUserId);
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_messages_$chatId';
    final messages = await getMessages(chatId);

    final newMsg = ChatMessageModel(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: currentUserProfile.userId,
      senderName: currentUserProfile.displayName,
      senderPhoto: currentUserProfile.photoUrl,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    messages.add(newMsg);
    await prefs.setString(key, jsonEncode(messages.map((e) => e.toJson()).toList()));

    // Update percakapan terakhir
    await _updateConversation(
      chatId: chatId,
      otherUserId: otherUserId,
      lastMessage: text,
      time: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. NOTIFIKASI
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<CommunityNotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyNotifications);
    if (data != null) {
      try {
        return (jsonDecode(data) as List<dynamic>)
            .map((e) => CommunityNotificationModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (_) {}
    }
    return _getDefaultNotifications();
  }

  Future<void> addNotification(CommunityNotificationModel notif) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getNotifications();
    all.insert(0, notif);
    await prefs.setString(_prefKeyNotifications, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> markAllNotificationsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getNotifications();
    final updated = all.map((n) => n.copyWith(isRead: true)).toList();
    await prefs.setString(_prefKeyNotifications, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER & DEFAULT SEED DATA (Sesuai Screenshot Figma)
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<CommunityPostModel>> _getAllPostsRaw(SharedPreferences prefs) async {
    final data = prefs.getString(_prefKeyPosts);
    if (data != null) {
      try {
        return (jsonDecode(data) as List<dynamic>)
            .map((e) => CommunityPostModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return _getDefaultPosts('comm_01');
  }

  Future<void> _updateConversation({
    required String chatId,
    required String otherUserId,
    required String lastMessage,
    required DateTime time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKeyChats);
    List<ChatConversationModel> convs = [];
    if (data != null) {
      try {
        convs = (jsonDecode(data) as List<dynamic>)
            .map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final friends = await getFriends();
    final friend = friends.firstWhere(
      (f) => f.userId == otherUserId,
      orElse: () => UserProfileModel(userId: otherUserId, username: 'teman', displayName: 'Teman'),
    );

    final idx = convs.indexWhere((c) => c.chatId == chatId);
    final conv = ChatConversationModel(
      chatId: chatId,
      participants: [currentUserProfile.userId, otherUserId],
      lastMessage: lastMessage,
      lastMessageTime: time,
      otherUserId: otherUserId,
      otherUserName: friend.displayName,
      otherUserPhoto: friend.photoUrl,
      otherUserOnline: friend.isOnline,
    );

    if (idx != -1) {
      convs[idx] = conv;
    } else {
      convs.insert(0, conv);
    }

    await prefs.setString(_prefKeyChats, jsonEncode(convs.map((e) => e.toJson()).toList()));
  }

  Future<void> _seedInitialDataIfNeeded(SharedPreferences prefs) async {
    if (!prefs.containsKey(_prefKeyFriends)) {
      await prefs.setString(
        _prefKeyFriends,
        jsonEncode(_getDefaultFriends().map((e) => e.toJson()).toList()),
      );
    }
    if (!prefs.containsKey(_prefKeyCommunities)) {
      await prefs.setString(
        _prefKeyCommunities,
        jsonEncode(_getDefaultCommunities().map((e) => e.toJson()).toList()),
      );
    }
    if (!prefs.containsKey(_prefKeyNotifications)) {
      await prefs.setString(
        _prefKeyNotifications,
        jsonEncode(_getDefaultNotifications().map((e) => e.toJson()).toList()),
      );
    }
  }

  List<UserProfileModel> _getDefaultFriends() {
    return [
      UserProfileModel(
        userId: 'user_maulana',
        username: 'maulana_adiatma',
        displayName: 'Maulana Adiatma',
        bio: 'Hati yang senantiasa berdzikir adalah hati yang tenang 🌿',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      UserProfileModel(
        userId: 'user_fatimah',
        username: 'fatimah_dwi',
        displayName: 'Fatimah Dwi Fitri',
        bio: 'Semangat tilawah satu juz setiap hari 📖',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      UserProfileModel(
        userId: 'user_alya',
        username: 'alya_fahira',
        displayName: 'Alya Fahira',
        bio: 'Menjaga sholat tepat waktu di awal waktu 🕌',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(minutes: 43)),
      ),
      UserProfileModel(
        userId: 'user_ikhsan',
        username: 'ikhsan_nur',
        displayName: 'Ikhsan Nur Saputra',
        bio: 'Semangat bangun tahajud demi ridho Ilahi ✨',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UserProfileModel(
        userId: 'user_bagus',
        username: 'bagus_harimurti',
        displayName: 'Bagus Harimurti',
        bio: 'Menebar kebaikan dan senyuman sedekah',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      UserProfileModel(
        userId: 'user_naila',
        username: 'naila_kirana',
        displayName: 'Naila Kirana',
        bio: 'Belajar istiqomah dan tawakkal',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserProfileModel(
        userId: 'user_hana',
        username: 'hana_rahayu',
        displayName: 'Hana Rahayu',
        bio: 'Alhamdulillah atas setiap nikmat yang ada',
        isOnline: true,
        lastActive: DateTime.now(),
      ),
      UserProfileModel(
        userId: 'user_rayyan',
        username: 'm_rayyan',
        displayName: 'M.Rayyan',
        bio: 'Pecinta majelis ilmu dan hadits',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  List<CommunityModel> _getDefaultCommunities() {
    final currentUid = currentUserProfile.userId;
    return [
      CommunityModel(
        communityId: 'comm_01',
        name: '7 Ukhti, 1 Langkah Kebaikan',
        description: 'Komunitas akhwat pejuang kebaikan, saling mengingatkan dalam tilawah dan sedekah harian.',
        category: 'Al-Qur\'an',
        isPrivate: true,
        adminId: 'user_fatimah',
        memberCount: 71,
        rules: 'Khusus akhwat, menjaga adab berbicara Islami, dan tidak membagikan konten di luar tema dakwah.',
        memberIds: [currentUid, 'user_fatimah', 'user_alya', 'user_naila', 'user_hana'],
      ),
      CommunityModel(
        communityId: 'comm_02',
        name: 'Ayo Dhuha',
        description: 'Dhuha kecil, manfaatnya besar. Saling mengingatkan dan menyemangati sholat Dhuha setiap pagi.',
        category: 'Dhuha',
        isPrivate: false,
        adminId: 'user_maulana',
        memberCount: 21,
        rules: 'Saling menyapa di waktu Dhuha, berbagi motivasi ibadah pagi.',
        memberIds: [currentUid, 'user_maulana', 'user_bagus', 'user_ikhsan'],
      ),
      CommunityModel(
        communityId: 'comm_03',
        name: 'Grup Pecinta Tahlil',
        description: 'Ruang silaturahmi zikir bersama dan doa keberkahan untuk orang tua dan keluarga.',
        category: 'Kajian Islam',
        isPrivate: true,
        adminId: 'user_rayyan',
        memberCount: 50,
        rules: 'Menjaga ukhuwah dan saling mendoakan keselamatan umat.',
        memberIds: [currentUid, 'user_rayyan', 'user_ikhsan'],
      ),
      CommunityModel(
        communityId: 'comm_04',
        name: 'Komunitas Pecinta Al-Qur\'an',
        description: 'Khatam bersama, tadabbur ayat, dan bimbingan tajwid bersama ustadz dan sahabat quran.',
        category: 'Al-Qur\'an',
        isPrivate: false,
        adminId: 'admin_center',
        memberCount: 120,
        rules: 'Fokus tilawah, murojaah hafalan, dan menjaga kesucian Al-Quran.',
        memberIds: [currentUid, 'user_maulana', 'user_fatimah'],
      ),
      CommunityModel(
        communityId: 'comm_05',
        name: 'Grup Pecinta Tahajud',
        description: 'Alarm sepertiga malam terakhir, bangkit bermunajat kepada Allah SWT.',
        category: 'Tahajud',
        isPrivate: false,
        adminId: 'admin_center',
        memberCount: 85,
        rules: 'Saling membangunkan di jam 03:00 dini hari untuk qiyamullail.',
        memberIds: [currentUid, 'user_ikhsan', 'user_bagus'],
      ),
      CommunityModel(
        communityId: 'comm_06',
        name: 'Muslim Produktif',
        description: 'Menggabungkan ibadah terbaik dan kerja profesional demi keberkahan dunia akhirat.',
        category: 'Muslim Produktif',
        isPrivate: false,
        adminId: 'admin_center',
        memberCount: 94,
        rules: 'Berbagi tips time management Islami, buku bermanfaat, dan motivasi kerja.',
        memberIds: [currentUid, 'user_maulana'],
      ),
    ];
  }

  List<CommunityPostModel> _getDefaultPosts(String communityId) {
    return [
      CommunityPostModel(
        postId: 'post_01',
        communityId: communityId,
        userId: 'user_maulana',
        userName: 'Maulana Adiatma',
        content: 'Alhamdulillah, target tilawah 1 juz hari ini telah selesai di Surah Al-Kahfi. Jangan lupa perbanyak sholawat di hari yang berkah ini ya sahabat! 🌿',
        likes: ['my_user_001', 'user_fatimah', 'user_bagus'],
        commentCount: 4,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommunityPostModel(
        postId: 'post_02',
        communityId: communityId,
        userId: 'user_fatimah',
        userName: 'Fatimah Dwi Fitri',
        content: '“Barangsiapa yang menempuh jalan untuk menuntut ilmu, maka Allah mudahkan jalannya menuju surga.” (HR. Muslim). Semangat kajian nanti malam jam 20.00 WIB ya ikhwah!',
        likes: ['my_user_001', 'user_alya'],
        commentCount: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  List<CommunityCommentModel> _getDefaultComments(String postId) {
    return [
      CommunityCommentModel(
        commentId: 'comm_c1',
        postId: postId,
        userId: 'user_fatimah',
        userName: 'Fatimah Dwi Fitri',
        content: 'Masya Allah tabarakallah, semoga kita senantiasa istiqomah!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      CommunityCommentModel(
        commentId: 'comm_c2',
        postId: postId,
        userId: 'user_bagus',
        userName: 'Bagus Harimurti',
        content: 'Aamiin ya Rabbal alamin. Terima kasih atas pengingatnya saudaraku.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ];
  }

  List<ChatMessageModel> _getDefaultChatMessages(String chatId) {
    final now = DateTime.now();
    return [
      ChatMessageModel(
        messageId: 'msg_01',
        chatId: chatId,
        senderId: 'user_maulana',
        senderName: 'Maulana Adiatma',
        text: 'Assalamu\'alaikum akhi! Bagaimana kabar ibadah dan harimu hari ini?',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessageModel(
        messageId: 'msg_02',
        chatId: chatId,
        senderId: currentUserProfile.userId,
        senderName: currentUserProfile.displayName,
        text: 'Wa\'alaikumsalam. Saya ingin mencari ketenangan hari ini. Bisakah kamu merekomendasikan doa untuk menenangkan pikiran yang sedang gelisah?',
        createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 40)),
      ),
      ChatMessageModel(
        messageId: 'msg_03',
        chatId: chatId,
        senderId: 'user_maulana',
        senderName: 'Maulana Adiatma',
        text: 'Tentu saudaraku, amalkan doa ini: “Allahumma inni a\'udzubika minal hammi wal hazan, wa a\'udzubika minal \'ajzi wal kasal...”. Sangat menyejukkan hati jika dibaca sesudah sholat fardhu.',
        createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 35)),
      ),
      ChatMessageModel(
        messageId: 'msg_04',
        chatId: chatId,
        senderId: currentUserProfile.userId,
        senderName: currentUserProfile.displayName,
        text: 'Alhamdulillah, terima kasih banyak sarannya saudaraku. Sangat membantu sekali. Semoga Allah membalas dengan kebaikan melimpah.',
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
      ChatMessageModel(
        messageId: 'msg_05',
        chatId: chatId,
        senderId: 'user_maulana',
        senderName: 'Maulana Adiatma',
        text: 'Aamiin ya Rabbal \'Alamin. Sama-sama akhi, mari saling mendoakan dalam kebaikan ya! 🌿',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  List<CommunityNotificationModel> _getDefaultNotifications() {
    return [
      CommunityNotificationModel(
        notificationId: 'notif_01',
        receiverId: currentUserProfile.userId,
        type: NotificationType.friendRequest,
        senderId: 'user_bagus',
        senderName: 'Bagus Harimurti',
        message: 'Bagus Harimurti mengirimkan permintaan pertemanan.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      CommunityNotificationModel(
        notificationId: 'notif_02',
        receiverId: currentUserProfile.userId,
        type: NotificationType.postComment,
        senderId: 'user_fatimah',
        senderName: 'Fatimah Dwi Fitri',
        referenceId: 'post_01',
        message: 'Fatimah Dwi Fitri mengomentari postinganmu di Komunitas Al-Qur\'an.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommunityNotificationModel(
        notificationId: 'notif_03',
        receiverId: currentUserProfile.userId,
        type: NotificationType.communityJoined,
        senderId: 'comm_02',
        senderName: 'Ayo Dhuha',
        referenceId: 'comm_02',
        message: 'Kamu telah berhasil bergabung ke dalam komunitas "Ayo Dhuha".',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CommunityNotificationModel(
        notificationId: 'notif_04',
        receiverId: currentUserProfile.userId,
        type: NotificationType.postLike,
        senderId: 'user_maulana',
        senderName: 'Maulana Adiatma',
        referenceId: 'post_01',
        message: 'Maulana Adiatma menyukai postingan tilawahmu.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
