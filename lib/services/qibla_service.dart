import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/qibla_info.dart';
import 'storage_service.dart';

class QiblaService {
  final StorageService? _storageService;
  static const String _baseUrl = 'https://api.myquran.com/v3/qibla';

  QiblaService({StorageService? storageService}) : _storageService = storageService;

  Future<QiblaInfo> getQiblaDirection(double latitude, double longitude) async {
    final latStr = latitude.toStringAsFixed(6);
    final lonStr = longitude.toStringAsFixed(6);
    final uri = Uri.parse('$_baseUrl/$latStr,$lonStr');

    final headers = {
      'Accept': 'application/json',
      'User-Agent': 'MuslimHabitApp/1.0',
    };

    try {
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final qibla = QiblaInfo.fromJson(decoded, latitude, longitude);
          if (_storageService != null) {
            await _storageService.saveQibla(jsonEncode(qibla.toJson()));
          }
          return qibla;
        }
      }
    } catch (_) {
      // Fallback on network failure
    }

    // Try reading cached data
    if (_storageService != null) {
      final cachedStr = _storageService.getSavedQibla();
      if (cachedStr != null) {
        try {
          final cachedJson = jsonDecode(cachedStr) as Map<String, dynamic>;
          return QiblaInfo.fromCache(cachedJson);
        } catch (_) {}
      }
    }

    return QiblaInfo.defaultInfo();
  }
}
