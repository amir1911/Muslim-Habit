import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/prayer_alarm_model.dart';
import '../models/prayer_schedule.dart';
import '../services/prayer_time_service.dart';
import '../services/storage_service.dart';
import '../services/widget_update_service.dart';
import '../services/adzan_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  final StorageService _storageService;
  late final PrayerTimeService _prayerTimeService;

  PrayerSchedule? _schedule;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCity = 'Palembang';

  PrayerTimeProvider(this._storageService, [PrayerTimeService? prayerTimeService]) {
    _prayerTimeService = prayerTimeService ?? PrayerTimeService(_storageService);
    _currentCity = _storageService.getSavedPrayerCity();
    AdzanService().init(_storageService);
    loadTodayPrayer();
  }

  PrayerSchedule get schedule => _schedule ?? PrayerSchedule.defaultSchedule(_currentCity);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;

  /// Mendapatkan waktu sholat berikutnya secara dinamis
  Map<String, String> get nextPrayer => schedule.getNextPrayer(DateTime.now());

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ── Rekaman Sholat Tercatat ──
  String? getRecordedPrayerTime(String prayerKey) {
    return _storageService.getPrayerRecordedTime(_dateKey(_selectedDate), prayerKey);
  }

  bool isPrayerDone(String prayerKey) {
    return getRecordedPrayerTime(prayerKey) != null;
  }

  Future<void> togglePrayerRecord(String prayerKey) async {
    final dKey = _dateKey(_selectedDate);
    final existing = _storageService.getPrayerRecordedTime(dKey, prayerKey);
    if (existing != null) {
      await _storageService.setPrayerRecordedTime(dKey, prayerKey, null);
    } else {
      final now = DateTime.now();
      final timeFormatted =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? "PM" : "AM"}';
      await _storageService.setPrayerRecordedTime(dKey, prayerKey, timeFormatted);
    }
    notifyListeners();
  }

  // ── Pengaturan Alarm Per Sholat ──
  PrayerAlarmModel getAlarmModel(String prayerKey, String defaultScheduleTime) {
    final raw = _storageService.getPrayerAlarmConfig(prayerKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return PrayerAlarmModel.fromJson(decoded);
      } catch (_) {}
    }

    String prayerName = 'Subuh';
    switch (prayerKey.toLowerCase()) {
      case 'subuh':
        prayerName = 'Subuh';
        break;
      case 'dzuhur':
        prayerName = 'Dzuhur';
        break;
      case 'ashar':
        prayerName = 'Ashar';
        break;
      case 'maghrib':
        prayerName = 'Maghrib';
        break;
      case 'isya':
        prayerName = 'Isya';
        break;
      default:
        prayerName = prayerKey;
    }

    return PrayerAlarmModel(
      prayerKey: prayerKey,
      name: prayerName,
      customTime: defaultScheduleTime,
    );
  }

  Future<void> saveAlarmModel(PrayerAlarmModel model) async {
    await _storageService.savePrayerAlarmConfig(model.prayerKey, jsonEncode(model.toJson()));
    notifyListeners();
  }

  Future<void> loadTodayPrayer({String? city}) async {
    final targetCity = city ?? _currentCity;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _prayerTimeService.fetchTodaySchedule(cityName: targetCity);
      _schedule = result;
      _currentCity = result.city;
      _errorMessage = null;

      // ── Update Home Screen Widget dengan data terbaru ──
      final now = DateTime.now();
      final current = result.getCurrentPrayer(now);
      final next = result.getNextPrayer(now);
      await WidgetUpdateService.updatePrayerData(
        subuh:              result.subuh,
        dzuhur:             result.dzuhur,
        ashar:              result.ashar,
        maghrib:            result.maghrib,
        isya:               result.isya,
        currentLabel:       current['label'] ?? 'Sekarang',
        currentPrayerName:  current['name'] ?? 'Subuh',
        currentPrayerTime:  current['time'] ?? result.subuh,
        nextPrayerName:     next['name'] ?? 'Salat',
        nextPrayerTime:     next['time'] ?? '--:--',
        timezone:           'WIB',
      );

      // ── Sinkronkan jadwal dengan AdzanService untuk pemutaran otomatis ──
      AdzanService().updateScheduleAndSyncAlarms(result, _storageService);
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal sholat: $e';
      // Tetap gunakan fallback jika belum ada schedule
      _schedule ??= PrayerSchedule.defaultSchedule(targetCity);
      AdzanService().updateScheduleAndSyncAlarms(_schedule!, _storageService);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeCity(String newCity) async {
    if (newCity.trim().isEmpty) return;
    _currentCity = newCity.trim();
    await _storageService.setSavedPrayerCity(_currentCity);
    await loadTodayPrayer(city: _currentCity);
  }
}
