import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fasting_plan.dart';
import '../core/utils/streak_helper.dart';

/// Data model untuk sistem streak pengguna
class StreakData {
  final int currentStreak;
  final int bestStreak;
  final String lastActivityDate; // YYYY-MM-DD
  final int totalActiveDays;
  final Set<String> activeDates;

  const StreakData({
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActivityDate,
    required this.totalActiveDays,
    required this.activeDates,
  });

  factory StreakData.empty() => const StreakData(
        currentStreak: 0,
        bestStreak: 0,
        lastActivityDate: '',
        totalActiveDays: 0,
        activeDates: {},
      );

  Map<String, dynamic> toMap() => {
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastActivityDate': lastActivityDate,
        'totalActiveDays': totalActiveDays,
        'activeDates': activeDates.toList(),
      };

  factory StreakData.fromMap(Map<String, dynamic> map) {
    final activeList = (map['activeDates'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {};
    return StreakData(
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
      lastActivityDate: map['lastActivityDate'] as String? ?? '',
      totalActiveDays: (map['totalActiveDays'] as num?)?.toInt() ?? activeList.length,
      activeDates: activeList,
    );
  }
}

/// Service terpadu untuk kalkulasi 5 Progress Habit, Sistem Streak,
/// dan Sinkronisasi Pengaturan Al-Qur'an ke Firebase Firestore.
class HabitProgressService {
  static const String _keyStreakData = 'muslim_habit_streak_data_v2';
  static const String _keyQuranReadToday = 'muslim_habit_quran_read_date_';
  static const String _keyFastingPlans = 'muslim_habit_fasting_plans';
  static const String _keyDzikirCountPrefix = 'dzikir_daily_count_';
  static const String _keyReadDoaDate = 'read_doa_date';
  static const String _keyReadDoaIds = 'read_doa_ids_today';
  static const String _keyPrayerDonePrefix = 'prayer_done_record_';

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static String? get _uid => _auth.currentUser?.uid;

  static String get todayKey => StreakHelper.formatDate(DateTime.now());
  static String get yesterdayKey =>
      StreakHelper.formatDate(DateTime.now().subtract(const Duration(days: 1)));

  // ════════════════════════════════════════════════════════════════════════════
  // 1. SINKRONISASI PENGATURAN BACA AL-QUR'AN KE FIREBASE
  // ════════════════════════════════════════════════════════════════════════════

  /// Simpan pengaturan pembaca Quran ke Firestore
  static Future<void> syncReaderSettingsToCloud({
    required double arabicFontSize,
    required double translationFontSize,
    required bool showTajwid,
    required bool showTranslation,
    required String readerTheme,
    required double audioSpeed,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('quran_reader')
          .set({
        'arabicFontSize': arabicFontSize,
        'translationFontSize': translationFontSize,
        'showTajwid': showTajwid,
        'showTranslation': showTranslation,
        'readerTheme': readerTheme,
        'audioSpeed': audioSpeed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[HabitProgressService] Error sync reader settings: $e');
    }
  }

  /// Ambil pengaturan pembaca Quran dari Firestore
  static Future<Map<String, dynamic>?> fetchReaderSettingsFromCloud() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('quran_reader')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('[HabitProgressService] Error fetch reader settings: $e');
    }
    return null;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 2. STATUS 5 KATEGORI HABIT HARI INI
  // ════════════════════════════════════════════════════════════════════════════

  /// Memeriksa status ke-5 kategori habit secara real-time
  static Future<Map<String, bool>> checkTodayHabitCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final today = todayKey;

    // 1. Shalat: Minimal 1 sholat (wajib / sunnah) tercatat hari ini
    bool shalatDone = false;
    final prayers = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya', 'dhuha', 'tahajjud'];
    for (final p in prayers) {
      final record = prefs.getString('$_keyPrayerDonePrefix${today}_$p');
      if (record != null && record.isNotEmpty) {
        shalatDone = true;
        break;
      }
    }

    // 2. Al-Qur'an: Ada aktivitas baca ayat / tilawah / hafalan hari ini
    final quranDate = prefs.getString('$_keyQuranReadToday$today');
    final recentSurahDate = prefs.getString('recent_reading_date');
    bool quranDone = (quranDate != null && quranDate.isNotEmpty) || (recentSurahDate == today);

    // 3. Doa: Ada doa yang ditandai dibaca hari ini
    final doaDate = prefs.getString(_keyReadDoaDate);
    final doaIds = prefs.getStringList(_keyReadDoaIds) ?? [];
    bool doaDone = (doaDate == today && doaIds.isNotEmpty);

    // 4. Dzikir: Total hitungan dzikir hari ini > 0
    final dzikirCount = prefs.getInt('$_keyDzikirCountPrefix$today') ?? 0;
    bool dzikirDone = dzikirCount > 0;

    // 5. Puasa: Ada jadwal puasa hari ini atau tercatat puasa hari ini
    bool puasaDone = false;
    bool puasaScheduled = false;
    final fastingJson = prefs.getString(_keyFastingPlans);
    if (fastingJson != null && fastingJson.isNotEmpty) {
      try {
        final list = jsonDecode(fastingJson) as List;
        for (final item in list) {
          final plan = FastingPlan.fromJson(item as Map<String, dynamic>);
          if (plan.dateKey == today) {
            puasaScheduled = true;
            if (plan.status == FastingStatus.completed) {
              puasaDone = true;
            }
            break;
          }
        }
      } catch (_) {}
    }

    final puasaDirect = prefs.getBool('puasa_completed_$today') ?? false;
    if (puasaDirect) {
      puasaDone = true;
      puasaScheduled = true;
    }

    return {
      'Shalat': shalatDone,
      'Al-Qur\'an': quranDone,
      'Doa': doaDone,
      'Dzikir': dzikirDone,
      'Puasa': puasaDone,
      '_PuasaScheduled': puasaScheduled,
    };
  }

  /// Catat aktivitas Al-Qur'an hari ini
  static Future<void> markQuranActivityToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyQuranReadToday$todayKey', DateTime.now().toIso8601String());
    await prefs.setString('recent_reading_date', todayKey);
    await recordHabitActivityCompleted('Al-Qur\'an');
  }

  /// Catat aktivitas Shalat hari ini
  static Future<void> markShalatActivityToday() async {
    await recordHabitActivityCompleted('Shalat');
  }

  /// Catat aktivitas Doa hari ini
  static Future<void> markDoaActivityToday() async {
    await recordHabitActivityCompleted('Doa');
  }

  /// Catat aktivitas Dzikir hari ini
  static Future<void> markDzikirActivityToday() async {
    await recordHabitActivityCompleted('Dzikir');
  }

  /// Catat aktivitas Puasa hari ini dan simpan riwayat ke Firebase Firestore
  static Future<void> markPuasaActivityToday([String? type]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('puasa_completed_$todayKey', true);
    await recordHabitActivityCompleted('Puasa');

    // Sinkronkan ke Firebase Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('fasting_history')
            .doc(todayKey)
            .set({
          'date': todayKey,
          'status': 'completed',
          'type': type ?? 'puasa_sunnah',
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[HabitProgressService] Gagal simpan riwayat puasa ke Firestore: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 3. SISTEM STREAK RESMI
  // ════════════════════════════════════════════════════════════════════════════

  /// Mengambil data streak saat ini (dari cache lokal)
  static Future<StreakData> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyStreakData);

    StreakData data;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        data = StreakData.fromMap(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {
        data = StreakData.empty();
      }
    } else {
      // Ambil fallback dari StorageService streak jika ada
      final legacyStreak = prefs.getInt('streak_count') ?? 0;
      data = StreakData(
        currentStreak: legacyStreak,
        bestStreak: legacyStreak,
        lastActivityDate: prefs.getString('last_active_date') ?? '',
        totalActiveDays: legacyStreak,
        activeDates: (prefs.getStringList('active_streak_dates_v2') ?? []).toSet(),
      );
    }

    // Evaluasi jika kemarin terlewat dan hari ini belum ada aktivitas
    final today = todayKey;
    final yesterday = yesterdayKey;
    if (data.lastActivityDate.isNotEmpty &&
        data.lastActivityDate != today &&
        data.lastActivityDate != yesterday) {
      // Lebih dari 1 hari terlewat tanpa aktivitas -> streak aktif sekarang 0 (menunggu aksi hari ini)
      data = StreakData(
        currentStreak: 0,
        bestStreak: data.bestStreak,
        lastActivityDate: data.lastActivityDate,
        totalActiveDays: data.totalActiveDays,
        activeDates: data.activeDates,
      );
    }

    return data;
  }

  /// Dipanggil setiap kali ada aktivitas habit valid yang diselesaikan
  ///
  /// Aturan Streak:
  /// - Minimal 1 aktivitas valid per hari.
  /// - Tidak bertambah berulang kali pada hari yang sama.
  /// - Bertambah +1 jika kemarin aktif.
  /// - Reset ke 1 jika hari sebelumnya terlewat.
  static Future<StreakData> recordHabitActivityCompleted(String categoryName) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = await getStreakData();
    final today = todayKey;
    final yesterday = yesterdayKey;

    // Jika hari ini sudah tercatat aktivitas, jangan tambah streak lagi (idempotent harian)
    if (currentData.lastActivityDate == today) {
      return currentData;
    }

    int newStreak;
    if (currentData.lastActivityDate == yesterday) {
      // Hari berturut-turut konsisten -> tambah 1
      newStreak = currentData.currentStreak + 1;
    } else {
      // Hari pertama atau sempat terlewat -> mulai dari 1
      newStreak = 1;
    }

    final newActiveDates = Set<String>.from(currentData.activeDates)..add(today);
    final newBest = newStreak > currentData.bestStreak ? newStreak : currentData.bestStreak;

    final updatedData = StreakData(
      currentStreak: newStreak,
      bestStreak: newBest,
      lastActivityDate: today,
      totalActiveDays: newActiveDates.length,
      activeDates: newActiveDates,
    );

    // Simpan ke SharedPreferences
    await prefs.setString(_keyStreakData, jsonEncode(updatedData.toMap()));
    await prefs.setInt('streak_count', newStreak);
    await prefs.setString('last_active_date', today);
    await prefs.setStringList('active_streak_dates_v2', newActiveDates.toList());

    // Sinkronkan ke Firebase Firestore
    _syncStreakToFirestore(updatedData);

    return updatedData;
  }

  /// Sinkronisasi streak ke Firebase Firestore
  static Future<void> _syncStreakToFirestore(StreakData data) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('habit_state')
          .doc('streak')
          .set({
        'currentStreak': data.currentStreak,
        'bestStreak': data.bestStreak,
        'lastActivityDate': data.lastActivityDate,
        'totalActiveDays': data.totalActiveDays,
        'activeDates': data.activeDates.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[HabitProgressService] Error sync streak to Firestore: $e');
    }
  }

  /// Sinkronisasi data streak dari Cloud ke lokal saat user login / startup
  static Future<StreakData?> syncStreakFromCloud() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('habit_state')
          .doc('streak')
          .get();

      if (doc.exists && doc.data() != null) {
        final cloudData = StreakData.fromMap(doc.data()!);
        final localData = await getStreakData();

        // Ambil yang paling tinggi / terbaru
        final resolvedStreak = cloudData.currentStreak > localData.currentStreak
            ? cloudData.currentStreak
            : localData.currentStreak;
        final resolvedBest = cloudData.bestStreak > localData.bestStreak
            ? cloudData.bestStreak
            : localData.bestStreak;
        final resolvedActiveDates = Set<String>.from(localData.activeDates)
          ..addAll(cloudData.activeDates);

        final merged = StreakData(
          currentStreak: resolvedStreak,
          bestStreak: resolvedBest,
          lastActivityDate: cloudData.lastActivityDate.isNotEmpty
              ? cloudData.lastActivityDate
              : localData.lastActivityDate,
          totalActiveDays: resolvedActiveDates.length,
          activeDates: resolvedActiveDates,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyStreakData, jsonEncode(merged.toMap()));
        await prefs.setInt('streak_count', resolvedStreak);
        await prefs.setStringList('active_streak_dates_v2', resolvedActiveDates.toList());

        return merged;
      }
    } catch (e) {
      debugPrint('[HabitProgressService] Error download streak from Firestore: $e');
    }
    return null;
  }
}
