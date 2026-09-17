import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_verse.dart';
import '../models/surah_item.dart';
import '../models/surah_detail.dart';
import 'storage_service.dart';

class QuranService {
  static const String _randomUrl = 'https://api.myquran.com/v3/quran/random';
  static const String _surahListUrl = 'https://api.myquran.com/v2/quran/surat/semua';
  static const String _surahDetailUrl = 'https://api.myquran.com/v3/quran';

  final StorageService? _storageService;

  QuranService([this._storageService]);

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'User-Agent': 'MuslimHabitApp/1.0',
      };

  Future<QuranVerse> fetchRandomVerse() async {
    try {
      final uri = Uri.parse(_randomUrl);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == true && decoded['data'] is Map) {
          final data = decoded['data'] as Map<String, dynamic>;
          final verse = QuranVerse.fromJson(data);

          if (_storageService != null) {
            _storageService.saveVerse(jsonEncode(verse.toJson()));
          }
          return verse;
        }
      }
    } catch (_) {}

    // Fallback: baca dari cache lokal jika ada
    if (_storageService != null) {
      try {
        final cached = _storageService.getSavedVerse();
        if (cached != null) {
          return QuranVerse.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    return QuranVerse.defaultVerse();
  }

  /// Ambil daftar 114 Surat Al-Qur'an lengkap
  Future<List<SurahItem>> fetchSurahList() async {
    try {
      final uri = Uri.parse(_surahListUrl);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = <SurahItem>[];

        final rawList = decoded is Map && decoded['data'] is List
            ? decoded['data'] as List
            : (decoded is List ? decoded : null);

        if (rawList != null) {
          for (final item in rawList) {
            if (item is Map<String, dynamic>) {
              list.add(SurahItem.fromJson(item));
            }
          }
        }

        if (list.isNotEmpty) {
          if (_storageService != null) {
            _storageService.saveSurahList(response.body);
          }
          return list;
        }
      }
    } catch (_) {}

    // Fallback dari cache
    if (_storageService != null) {
      try {
        final cachedStr = _storageService.getSavedSurahList();
        if (cachedStr != null) {
          final decoded = jsonDecode(cachedStr);
          final rawList = decoded is Map && decoded['data'] is List
              ? decoded['data'] as List
              : (decoded is List ? decoded : null);

          if (rawList != null) {
            final list = <SurahItem>[];
            for (final item in rawList) {
              if (item is Map<String, dynamic>) {
                list.add(SurahItem.fromJson(item));
              }
            }
            if (list.isNotEmpty) return list;
          }
        }
      } catch (_) {}
    }

    return SurahItem.fallbackSurahList;
  }

  /// Ambil ayat-ayat lengkap surat tertentu
  Future<SurahDetail?> fetchSurahDetail(int surahNumber) async {
    try {
      final uri = Uri.parse('$_surahDetailUrl/$surahNumber');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == true && decoded['data'] is Map) {
          final detail = SurahDetail.fromJson(decoded);
          if (_storageService != null) {
            _storageService.saveSurahDetail(surahNumber, response.body);
          }
          return detail;
        }
      }
    } catch (_) {}

    // Fallback dari cache
    if (_storageService != null) {
      try {
        final cachedStr = _storageService.getSavedSurahDetail(surahNumber);
        if (cachedStr != null) {
          final decoded = jsonDecode(cachedStr) as Map<String, dynamic>;
          return SurahDetail.fromJson(decoded);
        }
      } catch (_) {}
    }

    return null;
  }
}
