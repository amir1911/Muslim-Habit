import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipe Aktivitas Terakhir
enum SessionType {
  quran,
  hafalan,
  dzikir,
  doa,
  sholat,
}

/// Model Sesi Aktivitas Terakhir Muslim Habit
class LastSessionData {
  final SessionType type;
  final String title;
  final String subtitle;
  final int? surahNumber;
  final String? surahName;
  final int? ayahNumber;
  final String? dzikirId;
  final double progress;
  final DateTime timestamp;

  const LastSessionData({
    required this.type,
    required this.title,
    required this.subtitle,
    this.surahNumber,
    this.surahName,
    this.ayahNumber,
    this.dzikirId,
    this.progress = 0.0,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'dzikirId': dzikirId,
      'progress': progress,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LastSessionData.fromMap(Map<String, dynamic> map) {
    SessionType st = SessionType.quran;
    final tStr = map['type'] as String?;
    if (tStr != null) {
      for (final val in SessionType.values) {
        if (val.name == tStr) {
          st = val;
          break;
        }
      }
    }

    DateTime dt = DateTime.now();
    if (map['timestamp'] != null) {
      dt = DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now();
    }

    return LastSessionData(
      type: st,
      title: map['title'] as String? ?? 'Al-Qur\'an',
      subtitle: map['subtitle'] as String? ?? 'Terakhir dibaca',
      surahNumber: (map['surahNumber'] as num?)?.toInt(),
      surahName: map['surahName'] as String?,
      ayahNumber: (map['ayahNumber'] as num?)?.toInt(),
      dzikirId: map['dzikirId'] as String?,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      timestamp: dt,
    );
  }
}

/// Service Terpadu untuk Mencatat & Menyinkronkan Sesi Terakhir Pengguna
class LastSessionService {
  static const String _keyLastSession = 'muslim_habit_last_session_v1';
  static LastSessionData? _cachedSession;

  static LastSessionData? get cachedSession => _cachedSession;

  /// Simpan sesi aktivitas terakhir (ke SharedPreferences & Cloud Firestore)
  static Future<void> recordSession(LastSessionData session) async {
    _cachedSession = session;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSession, jsonEncode(session.toMap()));

      // Sinkronkan ke Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('user_state')
            .doc('last_session')
            .set({
              ...session.toMap(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[LastSessionService] Error recording session: $e');
    }
  }

  /// Ambil sesi terakhir dari cache lokal atau SharedPreferences
  static Future<LastSessionData?> getLastSession() async {
    if (_cachedSession != null) return _cachedSession;

    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyLastSession);
      if (str != null && str.isNotEmpty) {
        _cachedSession = LastSessionData.fromMap(jsonDecode(str) as Map<String, dynamic>);
        return _cachedSession;
      }

      // Fallback: periksa StorageService recent reading
      final recentSurahNum = prefs.getInt('recent_reading_surah_num');
      final recentSurahName = prefs.getString('recent_reading_surah_name');
      final recentAyahNum = prefs.getInt('recent_reading_ayah_num');
      final recentProgress = prefs.getDouble('recent_reading_progress');

      if (recentSurahNum != null && recentSurahName != null) {
        _cachedSession = LastSessionData(
          type: SessionType.quran,
          title: '$recentSurahName, Ayat ${recentAyahNum ?? 1}',
          subtitle: 'Terakhir dibaca',
          surahNumber: recentSurahNum,
          surahName: recentSurahName,
          ayahNumber: recentAyahNum ?? 1,
          progress: recentProgress ?? 0.5,
          timestamp: DateTime.now(),
        );
        return _cachedSession;
      }
    } catch (e) {
      debugPrint('[LastSessionService] Error getting last session: $e');
    }
    return null;
  }

  /// Sinkronkan sesi terakhir dari Firestore saat login / startup
  static Future<LastSessionData?> syncFromCloud() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return getLastSession();

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('user_state')
          .doc('last_session')
          .get();

      if (doc.exists && doc.data() != null) {
        final cloudSession = LastSessionData.fromMap(doc.data()!);
        _cachedSession = cloudSession;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyLastSession, jsonEncode(cloudSession.toMap()));
        return cloudSession;
      }
    } catch (e) {
      debugPrint('[LastSessionService] Cloud sync error: $e');
    }
    return getLastSession();
  }
}
