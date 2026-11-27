import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Status Kunci Fokus Habit (Aturan Minimal 1 Bulan)
class HabitFocusLockStatus {
  final bool canChange;
  final int remainingDays;
  final DateTime lastUpdatedAt;
  final String currentFocusId;

  const HabitFocusLockStatus({
    required this.canChange,
    required this.remainingDays,
    required this.lastUpdatedAt,
    required this.currentFocusId,
  });

  String get lockMessage {
    if (canChange) {
      return 'Fokus habit dapat diperbarui sekarang.';
    }
    return 'Fokus habit dapat diubah kembali dalam $remainingDays hari.';
  }
}

/// Service untuk mengelola aturan penguncian Ubah Fokus Habit minimal 1 bulan
/// dan sinkronisasi Cloud Firestore berbasis UID pengguna.
class HabitFocusService {
  static const String _keyFocusUpdatedAt = 'habit_focus_updated_at_iso';
  static const String _keySelectedFocusId = 'habit_selected_focus_id';
  static const int lockPeriodDays = 30; // 1 bulan = 30 hari

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static String? get _uid => _auth.currentUser?.uid;

  /// Memeriksa status penguncian fokus habit pengguna secara dinamis
  static Future<HabitFocusLockStatus> getLockStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cek penyimpanan lokal
    String? localIso = prefs.getString(_keyFocusUpdatedAt);
    String focusId = prefs.getString(_keySelectedFocusId) ?? 'teen';

    DateTime? lastUpdate;
    if (localIso != null && localIso.isNotEmpty) {
      lastUpdate = DateTime.tryParse(localIso);
    }

    // 2. Sinkronkan dengan Firestore jika user login dan lokal belum ada / perlu verifikasi
    final uid = _uid;
    if (uid != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('chatbot')
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['habit_focus_updated_at'] != null) {
            DateTime? cloudDate;
            if (data['habit_focus_updated_at'] is Timestamp) {
              cloudDate = (data['habit_focus_updated_at'] as Timestamp).toDate();
            } else if (data['habit_focus_updated_at'] is String) {
              cloudDate = DateTime.tryParse(data['habit_focus_updated_at'] as String);
            }

            if (cloudDate != null) {
              // Jika lokal null atau tanggal cloud lebih baru, pakai cloud
              if (lastUpdate == null || cloudDate.isAfter(lastUpdate)) {
                lastUpdate = cloudDate;
                await prefs.setString(_keyFocusUpdatedAt, cloudDate.toIso8601String());
              }
            }
          }

          if (data['selected_focus_id'] != null) {
            focusId = data['selected_focus_id'] as String;
            await prefs.setString(_keySelectedFocusId, focusId);
          }
        }
      } catch (e) {
        debugPrint('[HabitFocusService] Error fetching cloud focus status: $e');
      }
    }

    final now = DateTime.now();

    // Jika pengguna baru dan belum pernah tercatat, tetapkan tanggal pertama kali hari ini
    if (lastUpdate == null) {
      lastUpdate = now;
      await saveInitialFocusDate(now, focusId);
    }

    // Hitung selisih hari
    final difference = now.difference(lastUpdate);
    final daysPassed = difference.inDays;

    final bool canChange = daysPassed >= lockPeriodDays;
    final int remainingDays = (lockPeriodDays - daysPassed).clamp(1, lockPeriodDays);

    return HabitFocusLockStatus(
      canChange: canChange,
      remainingDays: remainingDays,
      lastUpdatedAt: lastUpdate,
      currentFocusId: focusId,
    );
  }

  /// Simpan tanggal pertama kali pemilihan fokus (pengguna baru)
  static Future<void> saveInitialFocusDate(DateTime date, String focusId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFocusUpdatedAt, date.toIso8601String());
    await prefs.setString(_keySelectedFocusId, focusId);

    final uid = _uid;
    if (uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('chatbot')
            .set({
          'habit_focus_updated_at': Timestamp.fromDate(date),
          'selected_focus_id': focusId,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[HabitFocusService] Error saving initial focus date: $e');
      }
    }
  }

  /// Memperbarui fokus habit baru dan memulai kembali periode kunci 1 bulan
  static Future<bool> updateHabitFocus(String newFocusId) async {
    final status = await getLockStatus();
    if (!status.canChange) {
      debugPrint('[HabitFocusService] Fokus habit masih terkunci: ${status.remainingDays} hari tersisa.');
      return false;
    }

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // 1. Simpan lokal
    await prefs.setString(_keyFocusUpdatedAt, now.toIso8601String());
    await prefs.setString(_keySelectedFocusId, newFocusId);

    // 2. Simpan Firestore (terhubung ke UID pengguna)
    final uid = _uid;
    if (uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('chatbot')
            .set({
          'habit_focus_updated_at': Timestamp.fromDate(now),
          'selected_focus_id': newFocusId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Catat riwayat perubahan fokus di Firestore
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('focus_history')
            .add({
          'focus_id': newFocusId,
          'changed_at': Timestamp.fromDate(now),
        });
      } catch (e) {
        debugPrint('[HabitFocusService] Error updating focus in Firestore: $e');
      }
    }

    return true;
  }
}
