import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fasting_plan.dart';
import 'storage_service.dart';

class FastingService {
  static const String _keyFastingPlans = 'muslim_habit_fasting_plans';
  static const String _keyAlarmConfig = 'muslim_habit_fasting_alarm_config';

  final StorageService? _storageService;

  FastingService([this._storageService]);

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  /// Mengambil semua daftar rencana puasa pengguna
  Future<List<FastingPlan>> getPlans() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyFastingPlans);
    if (jsonStr == null || jsonStr.isEmpty) {
      return _generateDefaultInitialPlans();
    }

    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((item) => FastingPlan.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return _generateDefaultInitialPlans();
    }
  }

  /// Menyimpan seluruh daftar rencana puasa
  Future<void> savePlans(List<FastingPlan> plans) async {
    final prefs = await _prefs;
    final listMap = plans.map((p) => p.toJson()).toList();
    await prefs.setString(_keyFastingPlans, jsonEncode(listMap));

    // Sinkronisasi otomatis ke Cloud Firestore jika user telah login
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('fasting')
            .doc('plans')
            .set({
          'plans': listMap,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[FastingService] Gagal sync ke Firestore: $e');
    }
  }

  /// Sinkronisasi rencana puasa dari Cloud Firestore
  Future<void> syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('fasting')
          .doc('plans')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final cloudPlansRaw = data['plans'] as List?;
        if (cloudPlansRaw != null && cloudPlansRaw.isNotEmpty) {
          final cloudPlans = cloudPlansRaw
              .map((item) => FastingPlan.fromJson(item as Map<String, dynamic>))
              .toList();

          final localPlans = await getPlans();
          final mergedMap = <String, FastingPlan>{};
          for (final p in localPlans) {
            mergedMap[p.id] = p;
          }
          for (final p in cloudPlans) {
            mergedMap[p.id] = p;
          }

          final mergedList = mergedMap.values.toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          final prefs = await _prefs;
          final listMap = mergedList.map((p) => p.toJson()).toList();
          await prefs.setString(_keyFastingPlans, jsonEncode(listMap));
        }
      }
    } catch (e) {
      debugPrint('[FastingService] syncFromCloud error: $e');
    }
  }

  /// Menambah atau memperbarui satu rencana puasa
  Future<void> addOrUpdatePlan(FastingPlan plan) async {
    final current = await getPlans();
    final idx = current.indexWhere((p) => p.id == plan.id || p.dateKey == plan.dateKey);

    if (idx != -1) {
      current[idx] = plan;
    } else {
      current.add(plan);
    }

    await savePlans(current);
  }

  /// Menghapus rencana puasa berdasarkan ID
  Future<void> removePlan(String id) async {
    final current = await getPlans();
    current.removeWhere((p) => p.id == id);
    await savePlans(current);
  }

  /// Menandai puasa telah selesai
  Future<void> markCompleted(String id) async {
    final current = await getPlans();
    final idx = current.indexWhere((p) => p.id == id);
    if (idx != -1) {
      current[idx] = current[idx].copyWith(
        status: FastingStatus.completed,
        completedAt: DateTime.now(),
      );
      await savePlans(current);
    }
  }

  /// Menandai tidak berpuasa beserta alasan
  Future<void> markSkipped({
    required String id,
    required SkippedReason reason,
    String? notes,
  }) async {
    final current = await getPlans();
    final idx = current.indexWhere((p) => p.id == id);
    if (idx != -1) {
      current[idx] = current[idx].copyWith(
        status: FastingStatus.skipped,
        skippedReason: reason,
        skippedNotes: notes,
      );
      await savePlans(current);
    }
  }

  /// Mengambil konfigurasi alarm sahur & iftar
  Future<FastingAlarmConfig> getAlarmConfig() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_keyAlarmConfig);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const FastingAlarmConfig();
    }

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FastingAlarmConfig.fromJson(map);
    } catch (_) {
      return const FastingAlarmConfig();
    }
  }

  /// Menyimpan konfigurasi alarm
  Future<void> saveAlarmConfig(FastingAlarmConfig config) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAlarmConfig, jsonEncode(config.toJson()));
  }

  /// Data default awal jika pengguna baru membuka fitur puasa
  List<FastingPlan> _generateDefaultInitialPlans() {
    final now = DateTime.now();
    // Berikan contoh terencana untuk Senin & Kamis terdekat
    final nextMonday = now.add(Duration(days: (DateTime.monday - now.weekday + 7) % 7));
    final nextThursday = now.add(Duration(days: (DateTime.thursday - now.weekday + 7) % 7));

    return [
      FastingPlan(
        id: 'plan_${nextMonday.millisecondsSinceEpoch}',
        date: DateTime(nextMonday.year, nextMonday.month, nextMonday.day),
        type: FastingType.seninKamis,
        status: FastingStatus.planned,
      ),
      FastingPlan(
        id: 'plan_${nextThursday.millisecondsSinceEpoch}',
        date: DateTime(nextThursday.year, nextThursday.month, nextThursday.day),
        type: FastingType.seninKamis,
        status: FastingStatus.planned,
      ),
    ];
  }
}
