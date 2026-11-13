import 'package:flutter/foundation.dart';
import '../models/doa_item.dart';
import '../services/doa_service.dart';
import '../services/storage_service.dart';

class DoaProvider extends ChangeNotifier {
  final StorageService _storageService;
  late final DoaService _doaService;

  List<DoaItem> _allDoa = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  DoaProvider(this._storageService, [DoaService? service]) {
    _doaService = service ?? DoaService(_storageService);
    _loadFavorites();
    loadDoaList();
  }

  List<DoaItem> get allDoa => _allDoa;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Set<int> get favoriteIds => _favoriteIds;

  void _loadFavorites() {
    final list = _storageService.getFavoriteDoaIds();
    _favoriteIds = list.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  bool isFavorite(int id) => _favoriteIds.contains(id);

  bool isReadToday(int id) {
    final list = _storageService.getTodayReadDoaIds();
    return list.contains(id.toString());
  }

  Future<void> markAsRead(int id) async {
    await _storageService.markDoaAsRead(id);
    notifyListeners();
  }

  List<String> get todayReadDoaIds => _storageService.getTodayReadDoaIds();

  // Ambil list doa favorit
  List<DoaItem> get favoriteDoaList {
    return _allDoa.where((d) => _favoriteIds.contains(d.id)).toList();
  }

  // Hitung jumlah doa per kategori
  int getCountForCategory(List<String> matchingGroups) {
    return _allDoa.where((d) => matchingGroups.contains(d.grup)).length;
  }

  // Ambil list doa per kumpulan grup kategori
  List<DoaItem> getDoaForCategory(List<String> matchingGroups) {
    return _allDoa.where((d) => matchingGroups.contains(d.grup)).toList();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _storageService.saveFavoriteDoaIds(_favoriteIds.map((e) => e.toString()).toList());
    notifyListeners();
  }

  // Categories list
  List<String> get categories {
    final groups = _allDoa
        .map((e) => e.grup.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();
    return ['Semua', 'Favorit', ...groups];
  }

  // Filtered list
  List<DoaItem> get filteredDoa {
    return _allDoa.where((item) {
      // Category filter
      if (_selectedCategory == 'Favorit') {
        if (!_favoriteIds.contains(item.id)) return false;
      } else if (_selectedCategory != 'Semua') {
        if (item.grup != _selectedCategory) return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchNama = item.nama.toLowerCase().contains(q);
        final matchIdn = item.idn.toLowerCase().contains(q);
        final matchTr = item.tr.toLowerCase().contains(q);
        final matchGrup = item.grup.toLowerCase().contains(q);
        final matchTag = item.tag.any((t) => t.toLowerCase().contains(q));
        if (!matchNama && !matchIdn && !matchTr && !matchGrup && !matchTag) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadDoaList({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _doaService.fetchAllDoa(forceRefresh: forceRefresh);
      _allDoa = list;
      _errorMessage = list.isEmpty ? 'Tidak ada data doa yang ditemukan.' : null;
    } catch (e) {
      _errorMessage = 'Gagal memuat doa: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
