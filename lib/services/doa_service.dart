import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_item.dart';
import 'storage_service.dart';

class DoaService {
  static const String _apiUrl = 'https://equran.id/api/doa';
  final StorageService? _storageService;

  DoaService([this._storageService]);

  Future<List<DoaItem>> fetchAllDoa({bool forceRefresh = false}) async {
    // 1. Cek cache offline terlebih dahulu jika tidak force refresh
    if (!forceRefresh && _storageService != null) {
      final cached = _storageService.getSavedDoaList();
      if (cached != null && cached.isNotEmpty) {
        try {
          final decoded = jsonDecode(cached);
          final items = _parseDoaList(decoded);
          if (items.isNotEmpty) return items;
        } catch (_) {}
      }
    }

    // 2. Fetch dari API https://equran.id/api/doa
    try {
      final uri = Uri.parse(_apiUrl);
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'MuslimHabitApp/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = _parseDoaList(decoded);
        if (list.isNotEmpty) {
          if (_storageService != null) {
            _storageService.saveDoaList(jsonEncode(list.map((e) => e.toJson()).toList()));
          }
          return list;
        }
      }
    } catch (_) {}

    // 3. Fallback ke cache jika internet bermasalah
    if (_storageService != null) {
      final cached = _storageService.getSavedDoaList();
      if (cached != null && cached.isNotEmpty) {
        try {
          final decoded = jsonDecode(cached);
          final items = _parseDoaList(decoded);
          if (items.isNotEmpty) return items;
        } catch (_) {}
      }
    }

    return [];
  }

  List<DoaItem> _parseDoaList(dynamic decoded) {
    List<dynamic>? rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        rawList = decoded['data'] as List;
      }
    }

    if (rawList == null) return [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => DoaItem.fromJson(e))
        .toList();
  }
}
