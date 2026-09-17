import 'package:flutter/foundation.dart';
import '../models/quran_verse.dart';
import '../models/surah_item.dart';
import '../models/surah_detail.dart';
import '../services/quran_service.dart';
import '../services/storage_service.dart';

class QuranProvider extends ChangeNotifier {
  final StorageService _storageService;
  late final QuranService _quranService;

  // Random Verse State (untuk home widget)
  QuranVerse? _currentVerse;
  bool _isLoading = false;
  String? _errorMessage;

  // Surah List State
  List<SurahItem> _allSurahs = [];
  bool _isLoadingSurahs = false;
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0: Baca, 1: Belajar, 2: Bookmark
  String _viewFilter = 'Surah'; // 'Surah' atau 'Juz'

  // Surah Detail State
  SurahDetail? _currentSurahDetail;
  bool _isLoadingDetail = false;
  String? _detailErrorMessage;

  // Recent Reading State
  late int _recentSurahNumber;
  late String _recentSurahName;
  late int _recentAyahNumber;
  late double _recentProgress;

  QuranProvider(this._storageService, [QuranService? quranService]) {
    _quranService = quranService ?? QuranService(_storageService);

    // Inisialisasi recent reading dari storage
    _recentSurahNumber = _storageService.getRecentSurahNumber();
    _recentSurahName = _storageService.getRecentSurahName();
    _recentAyahNumber = _storageService.getRecentAyahNumber();
    _recentProgress = _storageService.getRecentProgress();

    loadRandomVerse();
    loadSurahList();
  }

  // Getters
  QuranVerse get currentVerse => _currentVerse ?? QuranVerse.defaultVerse();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SurahItem> get surahList {
    if (_searchQuery.trim().isEmpty) {
      return _allSurahs;
    }
    final q = _searchQuery.toLowerCase().trim();
    return _allSurahs.where((s) {
      return s.nameLatin.toLowerCase().contains(q) ||
          s.nameId.toLowerCase().contains(q) ||
          s.translation.toLowerCase().contains(q) ||
          s.number.toString() == q;
    }).toList();
  }

  bool get isLoadingSurahs => _isLoadingSurahs;
  int get selectedTabIndex => _selectedTabIndex;
  String get searchQuery => _searchQuery;
  String get viewFilter => _viewFilter;

  SurahDetail? get currentSurahDetail => _currentSurahDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailErrorMessage => _detailErrorMessage;

  int get recentSurahNumber => _recentSurahNumber;
  String get recentSurahName => _recentSurahName;
  int get recentAyahNumber => _recentAyahNumber;
  double get recentProgress => _recentProgress;

  void setTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void searchSurah(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setViewFilter(String filter) {
    _viewFilter = filter;
    notifyListeners();
  }

  Future<void> updateRecentReading({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required double progress,
  }) async {
    _recentSurahNumber = surahNumber;
    _recentSurahName = surahName;
    _recentAyahNumber = ayahNumber;
    _recentProgress = progress;
    await _storageService.saveRecentReading(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahNumber: ayahNumber,
      progress: progress,
    );
    notifyListeners();
  }

  Future<void> loadSurahList() async {
    _isLoadingSurahs = true;
    notifyListeners();

    try {
      final list = await _quranService.fetchSurahList();
      _allSurahs = list;
    } catch (_) {
      _allSurahs = SurahItem.fallbackSurahList;
    } finally {
      _isLoadingSurahs = false;
      notifyListeners();
    }
  }

  Future<void> loadSurahDetail(int surahNumber) async {
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    _currentSurahDetail = null;
    notifyListeners();

    try {
      final detail = await _quranService.fetchSurahDetail(surahNumber);
      if (detail != null) {
        _currentSurahDetail = detail;
        _detailErrorMessage = null;
      } else {
        _detailErrorMessage = 'Gagal memuat ayat surat $surahNumber';
      }
    } catch (e) {
      _detailErrorMessage = 'Error: $e';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadRandomVerse() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verse = await _quranService.fetchRandomVerse();
      _currentVerse = verse;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat ayat: $e';
      _currentVerse ??= QuranVerse.defaultVerse();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
