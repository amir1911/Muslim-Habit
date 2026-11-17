import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_verse.dart';
import '../models/surah_item.dart';
import '../models/surah_detail.dart';
import 'storage_service.dart';

/// Service resmi Al-Qur'an menggunakan API Equran.id v2 (https://equran.id/api/v2)
/// Menyediakan teks mushaf Kemenag, terjemahan resmi, audio 5 qari ternama, dan tafsir lengkap.
class QuranService {
  static const String _equranBaseUrl = 'https://equran.id/api/v2';
  static const String _surahListUrl = '$_equranBaseUrl/surat';
  static const String _tafsirUrl = '$_equranBaseUrl/tafsir';

  final StorageService? _storageService;

  QuranService([this._storageService]);

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'User-Agent': 'MuslimHabitApp/2.0',
      };

  /// Ambil ayat harian / random verse
  Future<QuranVerse> fetchRandomVerse() async {
    try {
      // Ambil salah satu surah inspiratif harian dari Equran.id
      final sampleSurahs = [1, 2, 3, 14, 18, 55, 67, 93, 94];
      final randomSurah = sampleSurahs[DateTime.now().second % sampleSurahs.length];
      final detail = await fetchSurahDetail(randomSurah);
      if (detail != null && detail.ayahs.isNotEmpty) {
        final idx = DateTime.now().minute % detail.ayahs.length;
        final randomAyah = detail.ayahs[idx];
        final verse = QuranVerse(
          id: randomAyah.ayahNumber,
          surahNumber: detail.number,
          surahName: detail.nameLatin,
          ayahNumber: randomAyah.ayahNumber,
          arabicText: randomAyah.arabicText,
          translation: randomAyah.translation,
          tafsirShort: randomAyah.tafsir,
          audioUrl: randomAyah.audioUrl,
        );
        if (_storageService != null) {
          _storageService.saveVerse(jsonEncode(verse.toJson()));
        }
        return verse;
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

  /// Ambil daftar 114 Surat Al-Qur'an lengkap dari Equran.id v2 (https://equran.id/api/v2/surat)
  Future<List<SurahItem>> fetchSurahList() async {
    try {
      final uri = Uri.parse(_surahListUrl);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 14));

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

    // Fallback dari cache lokal
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

  /// Ambil ayat-ayat lengkap surat tertentu beserta audio per ayat untuk seluruh surah
  /// dari Equran.id v2 (https://equran.id/api/v2/surat/{nomor})
  Future<SurahDetail?> fetchSurahDetail(int surahNumber) async {
    try {
      final uri = Uri.parse('$_equranBaseUrl/surat/$surahNumber');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['code'] == 200 && decoded['data'] is Map) {
          final detail = SurahDetail.fromJson(decoded);
          if (detail.ayahs.isNotEmpty) {
            if (_storageService != null) {
              _storageService.saveSurahDetail(surahNumber, response.body);
            }
            return detail;
          }
        }
      }
    } catch (_) {}

    // Fallback dari cache lokal
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

  /// Ambil tafsir lengkap surat tertentu dari Equran.id v2 (https://equran.id/api/v2/tafsir/{nomor})
  Future<Map<String, dynamic>?> fetchSurahTafsir(int surahNumber) async {
    try {
      final uri = Uri.parse('$_tafsirUrl/$surahNumber');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['code'] == 200 && decoded['data'] is Map) {
          return decoded['data'] as Map<String, dynamic>;
        }
      }
    } catch (_) {}

    return null;
  }
}
