import 'package:flutter/material.dart';
import '../models/fasting_plan.dart';
import '../services/fasting_service.dart';
import '../services/fasting_alarm_service.dart';
import 'prayer_time_provider.dart';

class FastingProvider extends ChangeNotifier {
  final FastingService _fastingService;
  final FastingAlarmService _alarmService = FastingAlarmService();
  PrayerTimeProvider? _prayerProvider;

  List<FastingPlan> _plans = [];
  FastingAlarmConfig _alarmConfig = const FastingAlarmConfig();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isLoading = true;

  FastingProvider({FastingService? fastingService})
      : _fastingService = fastingService ?? FastingService() {
    loadData();
  }

  void updatePrayerProvider(PrayerTimeProvider prayerProvider) {
    _prayerProvider = prayerProvider;
  }

  List<FastingPlan> get plans => _plans;
  FastingAlarmConfig get alarmConfig => _alarmConfig;
  DateTime get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _plans = await _fastingService.getPlans();
    _alarmConfig = await _fastingService.getAlarmConfig();
    _isLoading = false;
    notifyListeners();

    _syncAlarms();
  }

  void setMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    notifyListeners();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }

  List<FastingPlan> getPlansForCurrentMonth() {
    return _plans.where((p) {
      return p.date.year == _currentMonth.year && p.date.month == _currentMonth.month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  FastingPlan? getPlanForDate(DateTime date) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return _plans.firstWhere((p) => p.dateKey == key);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPlan(FastingPlan plan) async {
    await _fastingService.addOrUpdatePlan(plan);
    _plans = await _fastingService.getPlans();
    notifyListeners();
    _syncAlarms();
  }

  Future<void> addPlans(List<FastingPlan> newPlans) async {
    for (final plan in newPlans) {
      await _fastingService.addOrUpdatePlan(plan);
    }
    _plans = await _fastingService.getPlans();
    notifyListeners();
    _syncAlarms();
  }

  Future<void> removePlan(String id) async {
    await _fastingService.removePlan(id);
    _plans = await _fastingService.getPlans();
    notifyListeners();
    _syncAlarms();
  }

  Future<void> markCompleted(String id) async {
    await _fastingService.markCompleted(id);
    _plans = await _fastingService.getPlans();
    notifyListeners();
  }

  Future<void> markSkipped({
    required String id,
    required SkippedReason reason,
    String? notes,
  }) async {
    await _fastingService.markSkipped(
      id: id,
      reason: reason,
      notes: notes,
    );
    _plans = await _fastingService.getPlans();
    notifyListeners();
    _syncAlarms();
  }

  Future<void> updateAlarmConfig(FastingAlarmConfig config) async {
    _alarmConfig = config;
    await _fastingService.saveAlarmConfig(config);
    notifyListeners();
    _syncAlarms();
  }

  void _syncAlarms() {
    final imsak = _prayerProvider?.schedule.imsak ?? '04:29';
    final maghrib = _prayerProvider?.schedule.maghrib ?? '18:05';

    _alarmService.scheduleAlarmsForPlans(
      plans: _plans,
      config: _alarmConfig,
      imsakTimeStr: imsak,
      maghribTimeStr: maghrib,
    );
  }
}
