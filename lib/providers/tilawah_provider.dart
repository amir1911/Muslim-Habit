import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class TilawahProvider extends ChangeNotifier {
  final StorageService _storageService;

  TilawahProvider(this._storageService) {
    _currentPage = _storageService.getTilawahPage();
    _currentJuz = _storageService.getTilawahJuz();
  }

  int _currentPage = 45;
  int _currentJuz = 3;
  int _dailyTargetPages = 20; // 1 Juz = ~20 pages
  int _pagesReadToday = 8;

  int get currentPage => _currentPage;
  int get currentJuz => _currentJuz;
  int get dailyTargetPages => _dailyTargetPages;
  int get pagesReadToday => _pagesReadToday;
  double get todayProgress => (_pagesReadToday / _dailyTargetPages).clamp(0.0, 1.0);
  double get overallProgress => (_currentPage / 604).clamp(0.0, 1.0);

  int get remainingDaysToKhatam {
    final remainingPages = 604 - _currentPage;
    if (_dailyTargetPages <= 0) return 30;
    return (remainingPages / _dailyTargetPages).ceil();
  }

  void addPagesRead(int count) {
    _pagesReadToday = (_pagesReadToday + count).clamp(0, 100);
    _currentPage = (_currentPage + count).clamp(1, 604);
    _currentJuz = ((_currentPage - 1) ~/ 20 + 1).clamp(1, 30);

    _storageService.setTilawahPage(_currentPage);
    _storageService.setTilawahJuz(_currentJuz);
    notifyListeners();
  }

  void setTargetPages(int target) {
    _dailyTargetPages = target;
    notifyListeners();
  }

  void updateCurrentPage(int page) {
    _currentPage = page.clamp(1, 604);
    _currentJuz = ((_currentPage - 1) ~/ 20 + 1).clamp(1, 30);
    _storageService.setTilawahPage(_currentPage);
    _storageService.setTilawahJuz(_currentJuz);
    notifyListeners();
  }
}
