import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_schedule.dart';
import 'storage_service.dart';

class PrayerTimeService {
  static const String _baseUrl = 'https://api.myquran.com/v3/sholat';

  final StorageService? _storageService;

  PrayerTimeService([this._storageService]);

  // Cache ID kota umum untuk menghemat request
  static final Map<String, String> _knownCityIds = {
    'palembang': '1afa34a7f984eeabdbb0a7d494132ee5',
    'jakarta': '1afa34a7f984eeabdbb0a7d494132ee6', // default fallback lookup
  };

  /// Cari ID Kota berdasarkan nama (misal: "Palembang")
  Future<Map<String, String>?> searchCity(String cityName) async {
    final query = cityName.trim().toLowerCase();
    if (_knownCityIds.containsKey(query)) {
      return {
        'id': _knownCityIds[query]!,
        'lokasi': cityName,
      };
    }

    try {
      final uri = Uri.parse('$_baseUrl/kabkota/cari/${Uri.encodeComponent(cityName)}');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MuslimHabitApp/1.0',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == true && decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty) {
            final item = list.first as Map<String, dynamic>;
            final id = item['id'] as String;
            final lokasi = item['lokasi'] as String;
            _knownCityIds[query] = id;
            return {'id': id, 'lokasi': lokasi};
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Ambil jadwal sholat hari ini untuk kota tertentu
  Future<PrayerSchedule> fetchTodaySchedule({String cityName = 'Palembang'}) async {
    // 1. Dapatkan ID Kota
    String cityId = _knownCityIds[cityName.toLowerCase()] ?? '';
    String displayCity = cityName;

    if (cityId.isEmpty) {
      final cityInfo = await searchCity(cityName);
      if (cityInfo != null) {
        cityId = cityInfo['id']!;
        displayCity = cityInfo['lokasi']!;
      }
    }

    // Jika pencarian gagal, gunakan default Palembang
    if (cityId.isEmpty) {
      cityId = '1afa34a7f984eeabdbb0a7d494132ee5';
      displayCity = 'Palembang';
    }

    // 2. Request jadwal hari ini dari MyQuran v3
    try {
      final uri = Uri.parse('$_baseUrl/jadwal/$cityId/today');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MuslimHabitApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          final kabko = data['kabko'] as String? ?? displayCity;
          final jadwalMap = data['jadwal'] as Map<String, dynamic>? ?? {};

          if (jadwalMap.isNotEmpty) {
            // Nilai jadwal harian ada di key pertama (e.g. "2026-09-17")
            final todayData = jadwalMap.values.first as Map<String, dynamic>;
            final schedule = PrayerSchedule.fromMyQuran(
              cityName: kabko,
              jadwalData: todayData,
            );

            // Simpan cache lokal
            _saveToCache(schedule);
            return schedule;
          }
        }
      }
    } catch (_) {}

    // 3. Fallback: baca dari cache jika ada
    final cached = _loadFromCache();
    if (cached != null) {
      return cached;
    }

    // 4. Default fallback jika belum ada cache
    return PrayerSchedule.defaultSchedule(cityName);
  }

  void _saveToCache(PrayerSchedule schedule) {
    if (_storageService != null) {
      try {
        _storageService.savePrayerSchedule(jsonEncode(schedule.toJson()));
        _storageService.setSavedPrayerCity(schedule.city);
      } catch (_) {}
    }
  }

  PrayerSchedule? _loadFromCache() {
    if (_storageService != null) {
      try {
        final cached = _storageService.getSavedPrayerSchedule();
        if (cached != null) {
          return PrayerSchedule.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      } catch (_) {}
    }
    return null;
  }
}
