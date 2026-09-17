import 'package:flutter/foundation.dart';
import '../models/prayer_schedule.dart';
import '../services/prayer_time_service.dart';
import '../services/storage_service.dart';

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
    loadTodayPrayer();
  }

  PrayerSchedule get schedule => _schedule ?? PrayerSchedule.defaultSchedule(_currentCity);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;

  /// Mendapatkan waktu sholat berikutnya secara dinamis
  Map<String, String> get nextPrayer => schedule.getNextPrayer(DateTime.now());

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
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal sholat: $e';
      // Tetap gunakan fallback jika belum ada schedule
      _schedule ??= PrayerSchedule.defaultSchedule(targetCity);
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
