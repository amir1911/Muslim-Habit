import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prayer_alarm_model.dart';
import '../models/prayer_schedule.dart';
import '../services/prayer_time_service.dart';
import '../services/habit_progress_service.dart';
import '../services/storage_service.dart';
import '../services/widget_update_service.dart';
import '../services/adzan_service.dart';
import '../services/smart_notification_service.dart';

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

  /// Memvalidasi apakah waktu sholat sudah tiba berdasarkan jadwal aktif
  bool isPrayerTimeArrived(String prayerKey, {String? customSchedTime}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // Tanggal lampau: izinkan pencatatan
    if (targetDay.isBefore(today)) {
      return true;
    }
    // Tanggal mendatang: belum masuk
    if (targetDay.isAfter(today)) {
      return false;
    }

    // Hari ini: periksa berdasarkan jam jadwal sholat
    String schedTime = customSchedTime ?? '';
    if (schedTime.isEmpty && _schedule != null) {
      switch (prayerKey.toLowerCase()) {
        case 'subuh':
          schedTime = _schedule!.subuh;
          break;
        case 'dzuhur':
          schedTime = _schedule!.dzuhur;
          break;
        case 'ashar':
          schedTime = _schedule!.ashar;
          break;
        case 'maghrib':
          schedTime = _schedule!.maghrib;
          break;
        case 'isya':
          schedTime = _schedule!.isya;
          break;
        case 'dhuha':
          schedTime = _schedule!.dhuha.isNotEmpty ? _schedule!.dhuha : '07:00';
          break;
        default:
          schedTime = '00:00';
      }
    }

    try {
      final parts = schedTime.trim().split(':');
      if (parts.length >= 2) {
        final schedHour = int.parse(parts[0].trim());
        final schedMin = int.parse(parts[1].trim().split(' ')[0]);
        final currentMinutes = now.hour * 60 + now.minute;
        final prayerMinutes = schedHour * 60 + schedMin;
        return currentMinutes >= prayerMinutes;
      }
    } catch (_) {}

    return true;
  }

  /// Mencatat atau membatalkan status sholat dengan validasi waktu & sinkronisasi Firestore
  Future<bool> togglePrayerRecord(String prayerKey, {String? customSchedTime}) async {
    final dKey = _dateKey(_selectedDate);
    final existing = _storageService.getPrayerRecordedTime(dKey, prayerKey);

    if (existing != null) {
      // Jika sudah dicatat, pertahankan catatan pelaksanaan
      return true;
    }

    // Validasi apakah waktu sholat sudah masuk
    if (!isPrayerTimeArrived(prayerKey, customSchedTime: customSchedTime)) {
      return false;
    }

    final now = DateTime.now();
    final timeFormatted =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
    await _storageService.setPrayerRecordedTime(dKey, prayerKey, timeFormatted);
    await HabitProgressService.markShalatActivityToday();

    // Sinkronisasi ke Cloud Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('prayer_records')
            .doc('${dKey}_$prayerKey')
            .set({
          'date': dKey,
          'prayer': prayerKey,
          'completed': true,
          'recordedTime': timeFormatted,
          'timestamp': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[PrayerTimeProvider] Gagal simpan rekam sholat ke Firestore: $e');
    }

    notifyListeners();
    return true;
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
        city:               result.city.isNotEmpty ? result.city : 'Palembang',
        timezone:           'WIB',
      );

      // ── Sinkronkan jadwal dengan AdzanService & SmartNotificationService ──
      AdzanService().updateScheduleAndSyncAlarms(result, _storageService);
      SmartNotificationService().syncSmartPrayerNotifications(
        schedule: result,
        isAlarmActive: (key) => _storageService.getAdzanPrayerEnabled(key),
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal sholat: $e';
      // Tetap gunakan fallback jika belum ada schedule
      _schedule ??= PrayerSchedule.defaultSchedule(targetCity);
      AdzanService().updateScheduleAndSyncAlarms(_schedule!, _storageService);
      SmartNotificationService().syncSmartPrayerNotifications(
        schedule: _schedule!,
        isAlarmActive: (key) => _storageService.getAdzanPrayerEnabled(key),
      );
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
