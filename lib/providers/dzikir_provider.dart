import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dzikir/dzikir_item_model.dart';
import '../models/dzikir/dzikir_category_model.dart';
import '../services/dzikir_service.dart';
import '../core/utils/streak_helper.dart';
import '../core/utils/tasbih_feedback_helper.dart';
import '../services/habit_progress_service.dart';
import 'habit_provider.dart';

class DzikirProvider extends ChangeNotifier {
  final DzikirService _service;
  HabitProvider? _habitProvider;

  List<DzikirCategoryModel> _categories = [];
  DzikirCategoryModel? _selectedCategory;
  int _currentDzikirIndex = 0;

  int _sessionCount = 0;
  int _targetCount = 33;
  int _todayTotalCount = 0;
  int _dailyGoalTarget = 1000;

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  DzikirProvider({DzikirService? service}) : _service = service ?? DzikirService() {
    init();
  }

  void updateHabitProvider(HabitProvider habitProvider) {
    _habitProvider = habitProvider;
  }

  bool get isLoading => _isLoading;
  List<DzikirCategoryModel> get categories => _categories;
  DzikirCategoryModel? get selectedCategory => _selectedCategory;
  int get currentDzikirIndex => _currentDzikirIndex;

  DzikirItemModel? get currentDzikir {
    if (_selectedCategory == null || _selectedCategory!.items.isEmpty) return null;
    if (_currentDzikirIndex >= _selectedCategory!.items.length) {
      _currentDzikirIndex = 0;
    }
    return _selectedCategory!.items[_currentDzikirIndex];
  }

  int get sessionCount => _sessionCount;
  int get targetCount => _targetCount;
  int get todayTotalCount => _todayTotalCount;
  int get dailyGoalTarget => _dailyGoalTarget;
  double get dailyGoalFraction =>
      _dailyGoalTarget > 0 ? (_todayTotalCount / _dailyGoalTarget).clamp(0.0, 1.0) : 0.0;
  int get dailyGoalPercentage => (dailyGoalFraction * 100).round();

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  String get todayKey => StreakHelper.formatDate(DateTime.now());

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _categories = _service.getCategories();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }

    _dailyGoalTarget = await _service.getDailyGoalTarget();
    _todayTotalCount = await _service.getTodayTotalCount(todayKey);
    _soundEnabled = await _service.getSoundEnabled();
    _vibrationEnabled = await _service.getVibrationEnabled();

    // Inisialisasi audio feedback tasbih
    await TasbihFeedbackHelper().init();

    if (currentDzikir != null) {
      _sessionCount = await _service.getSessionCount(currentDzikir!.id);
      _targetCount = currentDzikir!.defaultTarget;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(DzikirCategoryModel category, {int initialIndex = 0}) async {
    _selectedCategory = category;
    _currentDzikirIndex = initialIndex.clamp(0, category.items.length - 1);
    if (currentDzikir != null) {
      _sessionCount = await _service.getSessionCount(currentDzikir!.id);
      _targetCount = currentDzikir!.defaultTarget;
    }
    notifyListeners();
  }

  void setDzikirIndex(int index) async {
    if (_selectedCategory == null) return;
    if (index >= 0 && index < _selectedCategory!.items.length) {
      _currentDzikirIndex = index;
      if (currentDzikir != null) {
        _sessionCount = await _service.getSessionCount(currentDzikir!.id);
        _targetCount = currentDzikir!.defaultTarget;
      }
      notifyListeners();
    }
  }

  void nextDzikir() {
    if (_selectedCategory == null) return;
    if (_currentDzikirIndex < _selectedCategory!.items.length - 1) {
      setDzikirIndex(_currentDzikirIndex + 1);
    }
  }

  void previousDzikir() {
    if (_selectedCategory == null) return;
    if (_currentDzikirIndex > 0) {
      setDzikirIndex(_currentDzikirIndex - 1);
    }
  }

  void setTarget(int newTarget) {
    if (newTarget > 0) {
      _targetCount = newTarget;
      notifyListeners();
    }
  }

  void toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _service.setSoundEnabled(_soundEnabled);
    notifyListeners();
  }

  void toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _service.setVibrationEnabled(_vibrationEnabled);
    notifyListeners();
  }

  Future<void> setDailyGoalTarget(int target) async {
    if (target > 0) {
      _dailyGoalTarget = target;
      await _service.setDailyGoalTarget(target);
      notifyListeners();
    }
  }

  /// Menambah hitungan tasbih digital secara nyata & aman dari double event
  bool incrementCount() {
    final dzikir = currentDzikir;
    if (dzikir == null) return false;

    // Trigger haptic & sound feedback secara reliabel
    TasbihFeedbackHelper().playTapFeedback(
      soundEnabled: _soundEnabled,
      vibrationEnabled: _vibrationEnabled,
    );

    _sessionCount++;
    _todayTotalCount++;
    HabitProgressService.markDzikirActivityToday();

    // Simpan hitungan sesi dan total harian
    _service.setSessionCount(dzikir.id, _sessionCount);
    _service.addDailyCount(todayKey, 1);

    // Cek apakah target sesi tercapai
    bool reachedSessionTarget = false;
    if (_targetCount > 0 && _sessionCount >= _targetCount) {
      reachedSessionTarget = true;
      TasbihFeedbackHelper().playTargetReachedFeedback(
        soundEnabled: _soundEnabled,
        vibrationEnabled: _vibrationEnabled,
      );
      _service.markDzikirCompleted(todayKey, dzikir.id);
      _service.addHistory(DzikirHistoryModel(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        dateKey: todayKey,
        categoryName: _selectedCategory?.name ?? 'Dzikir',
        dzikirName: dzikir.name,
        count: _sessionCount,
        target: _targetCount,
        isCompleted: true,
        timestamp: DateTime.now(),
      ));
    }

    // ── INTEGRASI OTOMATIS DENGAN HABIT DZIKIR ──
    // Habit Dzikir ditandai selesai jika pengguna mencapai target daily goal
    if (_todayTotalCount >= _dailyGoalTarget && _habitProvider != null) {
      _habitProvider!.markFeatureHabitCompleted('dzikir');
    }

    notifyListeners();
    return reachedSessionTarget;
  }

  void resetSessionCount() async {
    final dzikir = currentDzikir;
    if (dzikir != null) {
      _sessionCount = 0;
      await _service.setSessionCount(dzikir.id, 0);
      notifyListeners();
    }
  }

  List<DzikirItemModel> searchDzikir(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase().trim();

    final List<DzikirItemModel> results = [];
    for (final cat in _categories) {
      for (final item in cat.items) {
        if (item.name.toLowerCase().contains(q) ||
            item.transliteration.toLowerCase().contains(q) ||
            item.translation.toLowerCase().contains(q) ||
            item.arabic.contains(q) ||
            cat.name.toLowerCase().contains(q)) {
          results.add(item);
        }
      }
    }
    return results;
  }
}
