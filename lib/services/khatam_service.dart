import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/khatam/khatam_plan_model.dart';

class KhatamService {
  static const String _keyActiveKhatamPlan = 'khatam_active_plan_v1';
  static const String _keyKhatamHistory = 'khatam_history_plans_v1';

  /// Mengambil rencana khatam aktif (jika ada)
  Future<KhatamPlanModel?> getActivePlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyActiveKhatamPlan);
      if (str != null && str.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(str);
        return KhatamPlanModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error loading active khatam plan: $e');
    }
    return null;
  }

  /// Menyimpan rencana khatam aktif
  Future<void> savePlan(KhatamPlanModel plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(plan.toJson());
      await prefs.setString(_keyActiveKhatamPlan, str);
    } catch (e) {
      debugPrint('Error saving active khatam plan: $e');
    }
  }

  /// Menghapus / Menyelesaikan rencana khatam aktif
  Future<void> clearActivePlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyActiveKhatamPlan);
    } catch (e) {
      debugPrint('Error clearing active khatam plan: $e');
    }
  }

  /// Menghitung target Juz harian berdasarkan input target
  double calculateDailyJuzTarget({
    required int quantity,
    required String unit, // 'juz' atau 'ayat'
    required String period, // 'hari' atau 'minggu'
  }) {
    if (quantity <= 0) return 1.0;

    double juzPerPeriod;
    if (unit.toLowerCase() == 'ayat') {
      // Al-Qur'an memiliki ~6236 ayat, rata-rata ~208 ayat/Juz
      juzPerPeriod = quantity / 208.0;
    } else {
      juzPerPeriod = quantity.toDouble();
    }

    if (period.toLowerCase() == 'minggu') {
      return juzPerPeriod / 7.0;
    } else {
      return juzPerPeriod;
    }
  }

  /// Menghitung estimasi total hari khatam 30 Juz
  int calculateTotalDaysNeeded(double dailyJuzTarget) {
    if (dailyJuzTarget <= 0) return 30;
    return (30 / dailyJuzTarget).ceil();
  }
}
