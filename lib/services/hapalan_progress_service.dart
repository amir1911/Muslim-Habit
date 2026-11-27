import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_progress_service.dart';
import 'last_session_service.dart';

/// Status hafalan untuk setiap ayat
enum HafalanStatus {
  belumDipelajari,
  sedangDipelajari,
  memerlukanLatihan,
  sudahDikuasai,
}

extension HafalanStatusExtension on HafalanStatus {
  String get key {
    switch (this) {
      case HafalanStatus.belumDipelajari:
        return 'belum_dipelajari';
      case HafalanStatus.sedangDipelajari:
        return 'sedang_dipelajari';
      case HafalanStatus.memerlukanLatihan:
        return 'memerlukan_latihan';
      case HafalanStatus.sudahDikuasai:
        return 'sudah_dikuasai';
    }
  }

  String get displayName {
    switch (this) {
      case HafalanStatus.belumDipelajari:
        return 'Belum Dipelajari';
      case HafalanStatus.sedangDipelajari:
        return 'Sedang Dipelajari';
      case HafalanStatus.memerlukanLatihan:
        return 'Memerlukan Latihan';
      case HafalanStatus.sudahDikuasai:
        return 'Sudah Dikuasai';
    }
  }

  static HafalanStatus fromKey(String? key) {
    switch (key) {
      case 'sedang_dipelajari':
        return HafalanStatus.sedangDipelajari;
      case 'memerlukan_latihan':
        return HafalanStatus.memerlukanLatihan;
      case 'sudah_dikuasai':
        return HafalanStatus.sudahDikuasai;
      case 'belum_dipelajari':
      default:
        return HafalanStatus.belumDipelajari;
    }
  }
}

/// Model pencatatan progres per ayat lengkap dengan integrasi Firestore
class AyahHafalanRecord {
  final int surahNumber;
  final int ayahNumber;
  final double lastScore;
  final double bestScore;
  final int attemptCount;
  final int repetitionCount; // Jumlah pengulangan mandiri via counter
  final HafalanStatus status;
  final DateTime startDate;
  final DateTime lastTestedDate;
  final bool isPassed; // Dianggap tuntas jika score >= 80% atau status sudahDikuasai

  AyahHafalanRecord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.lastScore,
    required this.bestScore,
    required this.attemptCount,
    this.repetitionCount = 0,
    this.status = HafalanStatus.belumDipelajari,
    DateTime? startDate,
    required this.lastTestedDate,
    required this.isPassed,
  }) : startDate = startDate ?? lastTestedDate;

  AyahHafalanRecord copyWith({
    int? surahNumber,
    int? ayahNumber,
    double? lastScore,
    double? bestScore,
    int? attemptCount,
    int? repetitionCount,
    HafalanStatus? status,
    DateTime? startDate,
    DateTime? lastTestedDate,
    bool? isPassed,
  }) {
    return AyahHafalanRecord(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      lastScore: lastScore ?? this.lastScore,
      bestScore: bestScore ?? this.bestScore,
      attemptCount: attemptCount ?? this.attemptCount,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      lastTestedDate: lastTestedDate ?? this.lastTestedDate,
      isPassed: isPassed ?? this.isPassed,
    );
  }

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'lastScore': lastScore,
        'bestScore': bestScore,
        'attemptCount': attemptCount,
        'repetitionCount': repetitionCount,
        'status': status.key,
        'startDate': startDate.toIso8601String(),
        'lastTestedDate': lastTestedDate.toIso8601String(),
        'isPassed': isPassed,
      };

  factory AyahHafalanRecord.fromJson(Map<String, dynamic> json) =>
      AyahHafalanRecord(
        surahNumber: json['surahNumber'] as int,
        ayahNumber: json['ayahNumber'] as int,
        lastScore: (json['lastScore'] as num?)?.toDouble() ?? 0.0,
        bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
        attemptCount: json['attemptCount'] as int? ?? 0,
        repetitionCount: json['repetitionCount'] as int? ?? 0,
        status: HafalanStatusExtension.fromKey(json['status'] as String?),
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        lastTestedDate: json['lastTestedDate'] != null
            ? DateTime.tryParse(json['lastTestedDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        isPassed: json['isPassed'] as bool? ?? false,
      );
}

/// Service untuk menyimpan dan mengelola riwayat serta progres hafalan pengguna
/// Tersinkronisasi dua arah: SharedPreferences (offline/cepat) & Firebase Firestore (cloud)
class HapalanProgressService {
  static const String _keyPrefix = 'hapalan_progress_';
  static const String _keyRecentSurah = 'hapalan_recent_surah';
  static const String _keyRecentAyah = 'hapalan_recent_ayah';
  static const String _keyMethod = 'hapalan_selected_method';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  /// Simpan metode hafalan yang dipilih ('per_ayah', 'range_ayah', 'per_surah')
  static Future<void> saveSelectedMethod(String method) async {
    final sp = await _prefs;
    await sp.setString(_keyMethod, method);
  }

  /// Ambil metode hafalan terakhir (default: 'per_ayah')
  static Future<String> getSelectedMethod() async {
    final sp = await _prefs;
    return sp.getString(_keyMethod) ?? 'per_ayah';
  }

  /// Simpan ayat dan surah terakhir yang dibuka
  static Future<void> saveRecentPosition(int surahNumber, int ayahNumber) async {
    final sp = await _prefs;
    await sp.setInt(_keyRecentSurah, surahNumber);
    await sp.setInt(_keyRecentAyah, ayahNumber);

    // Otomatis sinkronkan ke Sesi Aktivitas Terakhir
    LastSessionService.recordSession(
      LastSessionData(
        type: SessionType.hafalan,
        title: 'Hafalan Surah ke-$surahNumber, Ayat $ayahNumber',
        subtitle: 'Sedang Dihafalkan',
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        progress: 0.5,
        timestamp: DateTime.now(),
      ),
    );

    // Sync cloud jika login
    final uid = _uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).collection('hafalan_state').doc('recent').set({
          'recentSurah': surahNumber,
          'recentAyah': ayahNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[HapalanProgressService] Sync recent position error: $e');
      }
    }
  }

  /// Ambil surah terakhir (default 2 / Al-Baqarah)
  static Future<int> getRecentSurah() async {
    final sp = await _prefs;
    return sp.getInt(_keyRecentSurah) ?? 2;
  }

  /// Ambil ayat terakhir (default 1)
  static Future<int> getRecentAyah() async {
    final sp = await _prefs;
    return sp.getInt(_keyRecentAyah) ?? 1;
  }

  /// Catat hasil evaluasi tes hafalan yang baru saja dilakukan
  static Future<AyahHafalanRecord> recordEvaluation({
    required int surahNumber,
    required int ayahNumber,
    required double score,
  }) async {
    final sp = await _prefs;
    final key = '$_keyPrefix${surahNumber}_$ayahNumber';

    final existingJson = sp.getString(key);
    AyahHafalanRecord record;

    if (existingJson != null) {
      try {
        final decoded = jsonDecode(existingJson) as Map<String, dynamic>;
        final prev = AyahHafalanRecord.fromJson(decoded);
        final newBest = score > prev.bestScore ? score : prev.bestScore;
        final passed = prev.isPassed || score >= 80.0;
        final newStatus = passed ? HafalanStatus.sudahDikuasai : HafalanStatus.memerlukanLatihan;

        record = AyahHafalanRecord(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          lastScore: score,
          bestScore: newBest,
          attemptCount: prev.attemptCount + 1,
          repetitionCount: prev.repetitionCount,
          status: newStatus,
          startDate: prev.startDate,
          lastTestedDate: DateTime.now(),
          isPassed: passed,
        );
      } catch (_) {
        final passed = score >= 80.0;
        record = AyahHafalanRecord(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          lastScore: score,
          bestScore: score,
          attemptCount: 1,
          repetitionCount: 0,
          status: passed ? HafalanStatus.sudahDikuasai : HafalanStatus.memerlukanLatihan,
          lastTestedDate: DateTime.now(),
          isPassed: passed,
        );
      }
    } else {
      final passed = score >= 80.0;
      record = AyahHafalanRecord(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        lastScore: score,
        bestScore: score,
        attemptCount: 1,
        repetitionCount: 0,
        status: passed ? HafalanStatus.sudahDikuasai : HafalanStatus.memerlukanLatihan,
        lastTestedDate: DateTime.now(),
        isPassed: passed,
      );
    }

    await sp.setString(key, jsonEncode(record.toJson()));
    await saveRecentPosition(surahNumber, ayahNumber);
    HabitProgressService.markQuranActivityToday();
    _syncToFirestore(record);
    return record;
  }

  /// Update status dan jumlah pengulangan latihan mandiri
  static Future<AyahHafalanRecord> updatePracticeProgress({
    required int surahNumber,
    required int ayahNumber,
    int? repetitionCount,
    HafalanStatus? status,
  }) async {
    final sp = await _prefs;
    final key = '$_keyPrefix${surahNumber}_$ayahNumber';
    final existingJson = sp.getString(key);

    AyahHafalanRecord record;
    if (existingJson != null) {
      try {
        final decoded = jsonDecode(existingJson) as Map<String, dynamic>;
        final prev = AyahHafalanRecord.fromJson(decoded);
        record = prev.copyWith(
          repetitionCount: repetitionCount ?? prev.repetitionCount,
          status: status ?? prev.status,
          lastTestedDate: DateTime.now(),
          isPassed: (status == HafalanStatus.sudahDikuasai) ? true : prev.isPassed,
        );
      } catch (_) {
        record = AyahHafalanRecord(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          lastScore: 0.0,
          bestScore: 0.0,
          attemptCount: 0,
          repetitionCount: repetitionCount ?? 1,
          status: status ?? HafalanStatus.sedangDipelajari,
          lastTestedDate: DateTime.now(),
          isPassed: status == HafalanStatus.sudahDikuasai,
        );
      }
    } else {
      record = AyahHafalanRecord(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        lastScore: 0.0,
        bestScore: 0.0,
        attemptCount: 0,
        repetitionCount: repetitionCount ?? 1,
        status: status ?? HafalanStatus.sedangDipelajari,
        lastTestedDate: DateTime.now(),
        isPassed: status == HafalanStatus.sudahDikuasai,
      );
    }

    await sp.setString(key, jsonEncode(record.toJson()));
    await saveRecentPosition(surahNumber, ayahNumber);
    HabitProgressService.markQuranActivityToday();
    _syncToFirestore(record);
    return record;
  }

  /// Tambah satu kali pengulangan (saat tombol 'Ketuk untuk hitung' ditekan)
  static Future<AyahHafalanRecord> incrementRepetition({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final existing = await getRecord(surahNumber, ayahNumber);
    final count = (existing?.repetitionCount ?? 0) + 1;
    final newStatus = (existing?.status == HafalanStatus.belumDipelajari)
        ? HafalanStatus.sedangDipelajari
        : (existing?.status ?? HafalanStatus.sedangDipelajari);

    return updatePracticeProgress(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      repetitionCount: count,
      status: newStatus,
    );
  }

  /// Ambil record tes untuk ayat tertentu
  static Future<AyahHafalanRecord?> getRecord(int surahNumber, int ayahNumber) async {
    final sp = await _prefs;
    final key = '$_keyPrefix${surahNumber}_$ayahNumber';
    final existingJson = sp.getString(key);
    if (existingJson == null) return null;
    try {
      final decoded = jsonDecode(existingJson) as Map<String, dynamic>;
      return AyahHafalanRecord.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Ambil semua record untuk surah tertentu
  static Future<Map<int, AyahHafalanRecord>> getSurahRecords(int surahNumber) async {
    final sp = await _prefs;
    final result = <int, AyahHafalanRecord>{};
    final prefix = '$_keyPrefix${surahNumber}_';

    final keys = sp.getKeys().where((k) => k.startsWith(prefix));
    for (final key in keys) {
      final raw = sp.getString(key);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final rec = AyahHafalanRecord.fromJson(decoded);
          result[rec.ayahNumber] = rec;
        } catch (_) {}
      }
    }
    return result;
  }

  /// Ambil semua record di seluruh surah
  static Future<List<AyahHafalanRecord>> getAllRecords() async {
    final sp = await _prefs;
    final result = <AyahHafalanRecord>[];
    final keys = sp.getKeys().where((k) => k.startsWith(_keyPrefix));

    for (final key in keys) {
      final raw = sp.getString(key);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          result.add(AyahHafalanRecord.fromJson(decoded));
        } catch (_) {}
      }
    }
    return result;
  }

  /// Sinkronisasi background ke Firestore
  static void _syncToFirestore(AyahHafalanRecord record) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('hafalan_progress')
          .doc('${record.surahNumber}_${record.ayahNumber}');

      await docRef.set({
        'uid': uid,
        'surahNumber': record.surahNumber,
        'ayahNumber': record.ayahNumber,
        'repetitionCount': record.repetitionCount,
        'lastScore': record.lastScore,
        'bestScore': record.bestScore,
        'status': record.status.key,
        'startDate': Timestamp.fromDate(record.startDate),
        'lastTestedDate': Timestamp.fromDate(record.lastTestedDate),
        'isPassed': record.isPassed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[HapalanProgressService] Error sync to Firestore: $e');
    }
  }

  /// Download progres dari Firestore saat user login / startup
  static Future<void> syncFromCloud() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('hafalan_progress')
          .get();

      final sp = await _prefs;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final surahNumber = data['surahNumber'] as int? ?? 1;
        final ayahNumber = data['ayahNumber'] as int? ?? 1;
        final key = '$_keyPrefix${surahNumber}_$ayahNumber';

        final record = AyahHafalanRecord(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          lastScore: (data['lastScore'] as num?)?.toDouble() ?? 0.0,
          bestScore: (data['bestScore'] as num?)?.toDouble() ?? 0.0,
          attemptCount: data['attemptCount'] as int? ?? 0,
          repetitionCount: data['repetitionCount'] as int? ?? 0,
          status: HafalanStatusExtension.fromKey(data['status'] as String?),
          startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastTestedDate: (data['lastTestedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isPassed: data['isPassed'] as bool? ?? false,
        );

        await sp.setString(key, jsonEncode(record.toJson()));
      }
      debugPrint('[HapalanProgressService] Berhasil sync dari cloud (${snapshot.docs.length} ayat)');
    } catch (e) {
      debugPrint('[HapalanProgressService] Error syncFromCloud: $e');
    }
  }
}
