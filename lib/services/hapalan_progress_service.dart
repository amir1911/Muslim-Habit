import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model pencatatan progres per ayat
class AyahHafalanRecord {
  final int surahNumber;
  final int ayahNumber;
  final double lastScore;
  final double bestScore;
  final int attemptCount;
  final DateTime lastTestedDate;
  final bool isPassed; // Dianggap tuntas jika score >= 80%

  AyahHafalanRecord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.lastScore,
    required this.bestScore,
    required this.attemptCount,
    required this.lastTestedDate,
    required this.isPassed,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'lastScore': lastScore,
        'bestScore': bestScore,
        'attemptCount': attemptCount,
        'lastTestedDate': lastTestedDate.toIso8601String(),
        'isPassed': isPassed,
      };

  factory AyahHafalanRecord.fromJson(Map<String, dynamic> json) =>
      AyahHafalanRecord(
        surahNumber: json['surahNumber'] as int,
        ayahNumber: json['ayahNumber'] as int,
        lastScore: (json['lastScore'] as num).toDouble(),
        bestScore: (json['bestScore'] as num).toDouble(),
        attemptCount: json['attemptCount'] as int,
        lastTestedDate: DateTime.parse(json['lastTestedDate'] as String),
        isPassed: json['isPassed'] as bool? ?? false,
      );
}

/// Service untuk menyimpan dan mengelola riwayat serta progres hafalan pengguna
class HapalanProgressService {
  static const String _keyPrefix = 'hapalan_progress_';
  static const String _keyRecentSurah = 'hapalan_recent_surah';
  static const String _keyRecentAyah = 'hapalan_recent_ayah';
  static const String _keyMethod = 'hapalan_selected_method';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

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
  }

  /// Ambil surah terakhir (default 2 / Al-Baqarah)
  static Future<int> getRecentSurah() async {
    final sp = await _prefs;
    return sp.getInt(_keyRecentSurah) ?? 2;
  }

  /// Ambil ayat terakhir (default 7)
  static Future<int> getRecentAyah() async {
    final sp = await _prefs;
    return sp.getInt(_keyRecentAyah) ?? 7;
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
        record = AyahHafalanRecord(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          lastScore: score,
          bestScore: newBest,
          attemptCount: prev.attemptCount + 1,
          lastTestedDate: DateTime.now(),
          isPassed: prev.isPassed || score >= 80.0,
        );
      } catch (_) {
        record = AyahHafalanRecord(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          lastScore: score,
          bestScore: score,
          attemptCount: 1,
          lastTestedDate: DateTime.now(),
          isPassed: score >= 80.0,
        );
      }
    } else {
      record = AyahHafalanRecord(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        lastScore: score,
        bestScore: score,
        attemptCount: 1,
        lastTestedDate: DateTime.now(),
        isPassed: score >= 80.0,
      );
    }

    await sp.setString(key, jsonEncode(record.toJson()));
    await saveRecentPosition(surahNumber, ayahNumber);
    return record;
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
}
