import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification_model.dart';

/// Provider Pengelola Notifikasi Muslim Habit
/// Terintegrasi dengan SharedPreferences lokal & Cloud Firestore
class NotificationProvider extends ChangeNotifier {
  static const String _keyNotifications = 'muslim_habit_notifications_v1';
  List<AppNotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider() {
    _loadNotifications();
  }

  List<AppNotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Inisialisasi & Muat notifikasi dari SharedPreferences dan Firestore
  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString(_keyNotifications);

      if (localJson != null && localJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(localJson) as List<dynamic>;
        _notifications = list
            .map((item) => AppNotificationModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        // Seed default notifikasi ibadah & habit awal yang ramah
        _notifications = _generateInitialNotifications();
        await _saveLocal();
      }

      // Urutkan dari yang terbaru
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();

      // Sinkronkan dengan Firestore di background
      _syncFromFirestore();
    } catch (e) {
      debugPrint('[NotificationProvider] Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah notifikasi baru
  Future<void> addNotification({
    required String title,
    required String message,
    required AppNotificationCategory category,
    String? route,
    Map<String, dynamic>? data,
  }) async {
    final notif = AppNotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      category: category,
      timestamp: DateTime.now(),
      isRead: false,
      route: route,
      data: data,
    );

    _notifications.insert(0, notif);
    notifyListeners();
    await _saveLocal();
    await _syncToFirestore(notif);
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
      await _saveLocal();
      await _updateFirestoreReadStatus(id, true);
    }
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    bool hasUnread = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }

    if (hasUnread) {
      notifyListeners();
      await _saveLocal();
      await _updateAllFirestoreReadStatus();
    }
  }

  /// Hapus satu notifikasi
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    await _saveLocal();
    await _deleteFromFirestore(id);
  }

  /// Hapus seluruh notifikasi
  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    await _saveLocal();
    await _deleteAllFirestore();
  }

  // ── PENYIMPANAN LOKAL ──
  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_notifications.map((n) => n.toMap()).toList());
      await prefs.setString(_keyNotifications, jsonStr);
    } catch (e) {
      debugPrint('[NotificationProvider] Error saving local notifications: $e');
    }
  }

  // ── INTEGRASI FIRESTORE ──
  String? get _userUid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _syncFromFirestore() async {
    final uid = _userUid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      if (snap.docs.isNotEmpty) {
        final cloudNotifs = snap.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return AppNotificationModel.fromMap(data);
        }).toList();

        // Gabungkan dengan notifikasi lokal tanpa duplikat
        final Map<String, AppNotificationModel> map = {};
        for (final n in _notifications) {
          map[n.id] = n;
        }
        for (final n in cloudNotifs) {
          map[n.id] = n;
        }

        _notifications = map.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        notifyListeners();
        await _saveLocal();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Firestore sync error: $e');
    }
  }

  Future<void> _syncToFirestore(AppNotificationModel notif) async {
    final uid = _userUid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notif.id)
          .set(notif.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[NotificationProvider] Firestore write error: $e');
    }
  }

  Future<void> _updateFirestoreReadStatus(String id, bool isRead) async {
    final uid = _userUid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(id)
          .set({'isRead': isRead}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[NotificationProvider] Firestore update status error: $e');
    }
  }

  Future<void> _updateAllFirestoreReadStatus() async {
    final uid = _userUid;
    if (uid == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications');

      final snap = await collection.where('isRead', isEqualTo: false).get();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[NotificationProvider] Firestore batch mark error: $e');
    }
  }

  Future<void> _deleteFromFirestore(String id) async {
    final uid = _userUid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('[NotificationProvider] Firestore delete error: $e');
    }
  }

  Future<void> _deleteAllFirestore() async {
    final uid = _userUid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[NotificationProvider] Firestore clear error: $e');
    }
  }

  List<AppNotificationModel> _generateInitialNotifications() {
    final now = DateTime.now();
    return [
      AppNotificationModel(
        id: 'seed_1',
        title: 'Selamat Datang di Muslim Habit! 🌟',
        message: 'Awali harimu dengan niat ibadah dan kembangkan kebiasaan baik setiap hari bersama Nunu.',
        category: AppNotificationCategory.info,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      AppNotificationModel(
        id: 'seed_2',
        title: 'Pengingat Sholat & Dzikir Harian',
        message: 'Jaga keistiqamahan sholat 5 waktu dan dzikir harianmu agar hatimu selalu tenang.',
        category: AppNotificationCategory.ibadah,
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      AppNotificationModel(
        id: 'seed_3',
        title: 'Jaga Streak Ibadahmu! 🔥',
        message: 'Selesaikan minimal 1 target ibadah hari ini agar streak-mu terus bertambah.',
        category: AppNotificationCategory.streak,
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
      ),
    ];
  }
}
