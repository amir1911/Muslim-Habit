import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith_item.dart';
import 'storage_service.dart';

class HadithService {
  static const String _url = 'https://api.myquran.com/v3/hadis/enc/random';
  final StorageService? _storageService;

  HadithService([this._storageService]);

  Future<HadithItem> fetchRandomHadith() async {
    try {
      final uri = Uri.parse(_url);
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MuslimHabitApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == true && decoded['data'] is Map) {
          final data = decoded['data'] as Map<String, dynamic>;
          final hadith = HadithItem.fromJson(data);

          // Simpan ke cache offline
          if (_storageService != null) {
            _storageService.saveHadith(jsonEncode(hadith.toJson()));
          }
          return hadith;
        }
      }
    } catch (_) {}

    // Fallback: baca dari cache lokal jika ada
    if (_storageService != null) {
      try {
        final cached = _storageService.getSavedHadith();
        if (cached != null) {
          return HadithItem.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    return HadithItem.defaultHadith();
  }
}
