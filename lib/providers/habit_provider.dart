import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_item.dart';
import '../models/badge_item.dart';
import '../models/ai_assistant_model.dart';
import '../services/storage_service.dart';
import '../services/smart_notification_service.dart';
import '../core/utils/streak_helper.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storageService;

  HabitProvider(this._storageService) {
    _loadState();
  }

  int _userPoints = 10;
  int _userLevel = 1;
  int _streakCount = 17;
  Set<String> _activeDates = {};
  String _selectedCategory = 'all'; // all, wajib, sunnah
  String _userName = 'Sahabat Muslim';
  String _selectedAIId = 'teen';
  bool _hasCompletedOnboarding = false;

  int get userPoints => _userPoints;
  int get userLevel => _userLevel;
  int get streakCount => _streakCount;
  Set<String> get activeDates => _activeDates;
  String get selectedCategory => _selectedCategory;
  String get userName => _userName;
  String get selectedAIId => _selectedAIId;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  AIAssistantModel get currentAssistant => AIAssistantModel.getById(_selectedAIId);

  Future<void> setSelectedAI(String aiId) async {
    _selectedAIId = aiId;
    await _storageService.setSelectedAIId(aiId);
    notifyListeners();
  }

  Future<void> completeOnboarding(String aiId) async {
    _selectedAIId = aiId;
    _hasCompletedOnboarding = true;
    await _storageService.setSelectedAIId(aiId);
    await _storageService.setCompletedOnboarding(true);
    notifyListeners();
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  final List<HabitItem> _habits = [
    // ── HABIT PAGI (04:00 - 10:00) ──
    HabitItem(
      id: 'subuh',
      title: 'Sholat Wajib Shubuh',
      subtitle: '2 Rakaat tepat waktu',
      category: HabitCategory.wajib,
      categoryGroup: 'Sholat Wajib',
      icon: Icons.mosque_rounded,
      points: 25,
      timeSuggestion: '04:45 WIB',
      timeSlot: 'pagi',
      scheduledTime: '04:45 AM',
      recordedTime: '05:10 AM',
      frequency: '1x Setiap Hari',
      isCompleted: true,
      streak: 17,
    ),
    HabitItem(
      id: 'dhuha',
      title: 'Sholat Sunnah Dhuha',
      subtitle: 'Pintu rezeki & sedekah persendian',
      category: HabitCategory.sunnah,
      categoryGroup: 'Sholat Sunnah',
      icon: Icons.mosque_rounded,
      points: 20,
      timeSuggestion: '10:15 WIB',
      timeSlot: 'pagi',
      scheduledTime: '10:15 AM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 5,
    ),
    HabitItem(
      id: 'dzikir_pagi',
      title: 'Dzikir Pagi',
      subtitle: 'Benteng perlindungan seorang muslim',
      category: HabitCategory.sunnah,
      categoryGroup: 'Dzikir',
      icon: Icons.mosque_rounded,
      points: 15,
      timeSuggestion: '10:30 WIB',
      timeSlot: 'pagi',
      scheduledTime: '10:30 AM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      isMuted: true,
      streak: 3,
    ),
    HabitItem(
      id: 'doa_pagi',
      title: 'Doa Pagi',
      subtitle: 'Memohon berkah hari ini',
      category: HabitCategory.sunnah,
      categoryGroup: 'Doa',
      icon: Icons.mosque_rounded,
      points: 15,
      timeSuggestion: '10:45 WIB',
      timeSlot: 'pagi',
      scheduledTime: '10:45 AM',
      frequency: '1x Setiap Kali Ada',
      isCompleted: false,
      isMuted: true,
      streak: 2,
    ),

    // ── HABIT SIANG ──
    HabitItem(
      id: 'dzuhur',
      title: 'Sholat Wajib Dzuhur',
      subtitle: '4 Rakaat berjamaah',
      category: HabitCategory.wajib,
      categoryGroup: 'Sholat Wajib',
      icon: Icons.mosque_rounded,
      points: 20,
      timeSuggestion: '12:05 WIB',
      timeSlot: 'siang',
      scheduledTime: '12:05 PM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 7,
    ),
    HabitItem(
      id: 'dzikir_siang',
      title: 'Dzikir Siang',
      subtitle: 'Penyegar hati di sela kesibukan',
      category: HabitCategory.sunnah,
      categoryGroup: 'Dzikir',
      icon: Icons.mosque_rounded,
      points: 15,
      timeSuggestion: '12:30 WIB',
      timeSlot: 'siang',
      scheduledTime: '12:30 PM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 4,
    ),

    // ── HABIT SORE ──
    HabitItem(
      id: 'ashar',
      title: 'Sholat Wajib Ashar',
      subtitle: '4 Rakaat tepat waktu',
      category: HabitCategory.wajib,
      categoryGroup: 'Sholat Wajib',
      icon: Icons.mosque_rounded,
      points: 20,
      timeSuggestion: '15:15 WIB',
      timeSlot: 'sore',
      scheduledTime: '03:15 PM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 6,
    ),
    HabitItem(
      id: 'puasa',
      title: 'Puasa Senin-Kamis',
      subtitle: 'Amalan sunnah penuh keutamaan',
      category: HabitCategory.sunnah,
      categoryGroup: 'Puasa',
      icon: Icons.mosque_rounded,
      points: 30,
      timeSuggestion: 'Setiap Senin/Kamis',
      timeSlot: 'sore',
      scheduledTime: '05:45 PM',
      frequency: '2x 1 bulan',
      isCompleted: false,
      streak: 2,
    ),

    // ── HABIT MALAM ──
    HabitItem(
      id: 'maghrib',
      title: 'Sholat Wajib Maghrib',
      subtitle: '3 Rakaat di awal waktu',
      category: HabitCategory.wajib,
      categoryGroup: 'Sholat Wajib',
      icon: Icons.mosque_rounded,
      points: 20,
      timeSuggestion: '18:10 WIB',
      timeSlot: 'malam',
      scheduledTime: '06:10 PM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 8,
    ),
    HabitItem(
      id: 'isya',
      title: 'Sholat Wajib Isya',
      subtitle: '4 Rakaat sebelum tidur',
      category: HabitCategory.wajib,
      categoryGroup: 'Sholat Wajib',
      icon: Icons.mosque_rounded,
      points: 20,
      timeSuggestion: '19:20 WIB',
      timeSlot: 'malam',
      scheduledTime: '07:20 PM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 9,
    ),
    HabitItem(
      id: 'tahajjud',
      title: 'Sholat Sunnah Tahajjud',
      subtitle: 'Bermunajat di sepertiga malam',
      category: HabitCategory.sunnah,
      categoryGroup: 'Sholat Sunnah',
      icon: Icons.mosque_rounded,
      points: 35,
      timeSuggestion: '03:30 WIB',
      timeSlot: 'malam',
      scheduledTime: '03:30 AM',
      frequency: '1x Setiap Hari',
      isCompleted: false,
      streak: 4,
    ),
    HabitItem(
      id: 'doa_malam',
      title: 'Doa Malam',
      subtitle: 'Doa masuk masjid & sebelum tidur',
      category: HabitCategory.sunnah,
      categoryGroup: 'Doa',
      icon: Icons.mosque_rounded,
      points: 15,
      timeSuggestion: '20:30 WIB',
      timeSlot: 'malam',
      scheduledTime: '08:30 PM',
      frequency: '1x Setiap Masuk Masjid',
      isCompleted: false,
      streak: 3,
    ),
    HabitItem(
      id: 'target_baca',
      title: 'Target Baca',
      subtitle: 'Tilawah harian istiqomah',
      category: HabitCategory.sunnah,
      categoryGroup: 'Target Baca Al-Qur\'an',
      icon: Icons.mosque_rounded,
      points: 30,
      timeSuggestion: 'Malam Hari',
      timeSlot: 'malam',
      scheduledTime: '09:00 PM',
      frequency: '14 Ayat Setiap Hari',
      isCompleted: false,
      streak: 11,
    ),
  ];

  final List<BadgeItem> _badges = [
    BadgeItem(
      id: 'pejuang_subuh',
      title: 'Pejuang Subuh',
      description: 'Konsisten bangun dan shalat Subuh berjamaah tepat waktu.',
      icon: Icons.wb_twilight_rounded,
      accentColor: const Color(0xFFEAA639),
      requiredStreak: 3,
      category: 'Ibadah Wajib',
      isUnlocked: true,
    ),
    BadgeItem(
      id: 'ahli_sedekah',
      title: 'Ahli Sedekah',
      description: 'Menyisihkan rezeki berturut-turut tanpa jeda.',
      icon: Icons.favorite_rounded,
      accentColor: const Color(0xFFE57373),
      requiredStreak: 3,
      category: 'Amalan Sunnah',
      isUnlocked: true,
    ),
    BadgeItem(
      id: 'quran_lover',
      title: 'Pencinta Qur\'an',
      description: 'Membaca Al-Qur\'an setiap hari minimal 1 juz.',
      icon: Icons.auto_stories_rounded,
      accentColor: const Color(0xFF81C784),
      requiredStreak: 5,
      category: 'Al-Qur\'an',
      isUnlocked: true,
    ),
    BadgeItem(
      id: 'istiqomah_7',
      title: 'Istiqomah 7 Hari',
      description: 'Mencapai streak ibadah berturut-turut selama 1 pekan penuh.',
      icon: Icons.local_fire_department_rounded,
      accentColor: const Color(0xFFFF7043),
      requiredStreak: 7,
      category: 'Konsistensi',
      isUnlocked: true,
    ),
    BadgeItem(
      id: 'penjaga_fardhu',
      title: 'Penjaga 5 Waktu',
      description: 'Menuntaskan seluruh shalat fardhu dalam sehari.',
      icon: Icons.verified_rounded,
      accentColor: const Color(0xFF64B5F6),
      requiredStreak: 5,
      category: 'Ibadah Wajib',
      isUnlocked: false,
    ),
  ];

  List<HabitItem> get allHabits => List.unmodifiable(_habits);

  List<HabitItem> get habits {
    if (_selectedCategory == 'wajib') {
      return _habits.where((h) => h.category == HabitCategory.wajib).toList();
    } else if (_selectedCategory == 'sunnah') {
      return _habits.where((h) => h.category == HabitCategory.sunnah).toList();
    }
    return _habits;
  }

  List<BadgeItem> get badges => _badges;

  // Filter per slot waktu
  List<HabitItem> get pagiHabits => _habits.where((h) => h.timeSlot == 'pagi').toList();
  List<HabitItem> get siangHabits => _habits.where((h) => h.timeSlot == 'siang').toList();
  List<HabitItem> get soreHabits => _habits.where((h) => h.timeSlot == 'sore').toList();
  List<HabitItem> get malamHabits => _habits.where((h) => h.timeSlot == 'malam').toList();

  String get pagiRatio => '${pagiHabits.where((h) => h.isCompleted).length}/${pagiHabits.length}';
  String get siangRatio => '${siangHabits.where((h) => h.isCompleted).length}/${siangHabits.length}';
  String get soreRatio => '${soreHabits.where((h) => h.isCompleted).length}/${soreHabits.length}';
  String get malamRatio => '${malamHabits.where((h) => h.isCompleted).length}/${malamHabits.length}';

  List<HabitItem> get todayHabits => _habits;
  int get todayCompletedHabitsCount => completedHabitsCount;
  int get completedHabitsCount => _habits.where((h) => h.isCompleted).length;
  int get totalHabitsCount => _habits.length;
  double get progressFraction => totalHabitsCount == 0 ? 0.0 : (completedHabitsCount / totalHabitsCount);
  int get dailyProgressPercent => (progressFraction * 100).round();

  List<HabitItem> get upcomingHabits {
    final uncompleted = _habits.where((h) => !h.isCompleted).toList();
    if (uncompleted.isNotEmpty) {
      return uncompleted.take(3).toList();
    }
    return _habits.take(3).toList();
  }

  List<HabitItem> habitsByCategory(String categoryGroup) {
    return _habits.where((h) => h.categoryGroup.toLowerCase() == categoryGroup.toLowerCase()).toList();
  }

  // Toggle Centang Selesai Habit
  void toggleHabit(String id, {bool is2xBooster = false}) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final current = _habits[index];
      final newStatus = !current.isCompleted;
      final newStreak = newStatus ? current.streak + 1 : (current.streak > 0 ? current.streak - 1 : 0);
      final nowFormatted = DateFormat('hh:mm a').format(DateTime.now());

      _habits[index] = current.copyWith(
        isCompleted: newStatus,
        recordedTime: newStatus ? nowFormatted : null,
        streak: newStreak,
      );

      final todayStr = StreakHelper.formatDate(DateTime.now());

      final pointsToAward = is2xBooster ? current.points * 2 : current.points;
      if (newStatus) {
        _userPoints += pointsToAward;
      } else {
        _userPoints = (_userPoints - pointsToAward).clamp(0, 999999);
      }

      final completedHabitIds = _habits.where((h) => h.isCompleted).map((h) => h.id).toList();

      if (completedHabitIds.isNotEmpty) {
        _activeDates.add(todayStr);
      } else {
        _activeDates.remove(todayStr);
      }

      _storageService.setDailyCompletedHabitIds(todayStr, completedHabitIds);
      _storageService.setActiveDates(_activeDates.toList());
      _storageService.setLastActiveDate(todayStr);
      _storageService.setUserPoints(_userPoints);
      _saveState();

      // Trigger Smart Notification Evaluation
      _triggerSmartNotificationSync();

      notifyListeners();
    }
  }

  /// Mengurangi saldo bintang (untuk pembelian di toko maskot)
  bool deductPoints(int points) {
    if (points <= 0) return true;
    if (_userPoints >= points) {
      _userPoints -= points;
      _storageService.setUserPoints(_userPoints);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Toggle Lonceng Notifikasi (Mute/Unmute)
  void toggleMute(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final current = _habits[index];
      _habits[index] = current.copyWith(isMuted: !current.isMuted);
      notifyListeners();
    }
  }

  // Tambah Habit Baru
  void addHabit(HabitItem item) {
    _habits.add(item);
    notifyListeners();
  }

  // Update Habit
  void updateHabit(HabitItem item) {
    final index = _habits.indexWhere((h) => h.id == item.id);
    if (index != -1) {
      _habits[index] = item;
      _triggerSmartNotificationSync();
      notifyListeners();
    }
  }

  /// Sinkronisasi pintar evaluasi habit dengan SmartNotificationService
  void _triggerSmartNotificationSync() {
    try {
      final dzikirPagiDone = _habits.any((h) => (h.id == 'dzikir_pagi' || h.title.toLowerCase().contains('dzikir pagi')) && h.isCompleted);
      final dzikirPetangDone = _habits.any((h) => (h.id == 'dzikir_petang' || h.title.toLowerCase().contains('dzikir petang')) && h.isCompleted);
      final quranDone = _habits.any((h) => (h.id == 'tilawah' || h.title.toLowerCase().contains('qur')) && h.isCompleted);
      final doaDone = _habits.any((h) => h.title.toLowerCase().contains('doa') && h.isCompleted);

      SmartNotificationService().syncSmartHabitReminders(
        habits: _habits,
        streakCount: _streakCount,
        hasReadQuranToday: quranDone,
        hasReadDzikirPagiToday: dzikirPagiDone,
        hasReadDzikirPetangToday: dzikirPetangDone,
        hasReadDoaToday: doaDone,
      );
    } catch (e) {
      debugPrint('Error triggering smart notifications: $e');
    }
  }

  void addPoints(int points, {String? reason}) {
    if (points <= 0) return;
    _userPoints += points;
    _storageService.setUserPoints(_userPoints);
    notifyListeners();
  }

  void markFeatureHabitCompleted(String habitId, {bool completed = true}) {
    String targetId = habitId.toLowerCase();
    if (targetId == 'quran') targetId = 'target_baca';
    if (targetId == 'maghrib') targetId = 'magrib';
    final index = _habits.indexWhere((h) => h.id.toLowerCase() == targetId);
    if (index != -1 && _habits[index].isCompleted != completed) {
      toggleHabit(_habits[index].id);
    }
  }

  /// Mengambil daftar habit untuk tanggal tertentu.
  /// Jika hari ini: mengembalikan habit saat ini.
  /// Jika tanggal lain: membaca riwayat dari StorageService untuk tanggal tersebut tanpa mengubah status hari ini.
  List<HabitItem> getHabitsForDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return _habits;

    final dateKey = StreakHelper.formatDate(date);
    final completedIds = _storageService.getDailyCompletedHabitIds(dateKey);

    return _habits.map((h) {
      final done = completedIds.contains(h.id);
      return h.copyWith(isCompleted: done);
    }).toList();
  }

  /// Menghitung persentase progres untuk tanggal tertentu
  int getProgressForDate(DateTime date) {
    final habits = getHabitsForDate(date);
    if (habits.isEmpty) return 0;
    final completed = habits.where((h) => h.isCompleted).length;
    return ((completed / habits.length) * 100).round();
  }

  /// Toggle habit untuk tanggal tertentu
  void toggleHabitForDate(String id, DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      toggleHabit(id);
      return;
    }

    final dateKey = StreakHelper.formatDate(date);
    final completedIds = _storageService.getDailyCompletedHabitIds(dateKey).toList();
    if (completedIds.contains(id)) {
      completedIds.remove(id);
    } else {
      completedIds.add(id);
    }
    _storageService.setDailyCompletedHabitIds(dateKey, completedIds);
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    _storageService.setUserName(name);
    notifyListeners();
  }

  void _loadState() {
    _userPoints = _storageService.getUserPoints() > 0 ? _storageService.getUserPoints() : 10;
    _userLevel = _storageService.getUserLevel();
    _userName = _storageService.getUserName();
    _selectedAIId = _storageService.getSelectedAIId();
    _hasCompletedOnboarding = _storageService.hasCompletedOnboarding();

    final todayStr = StreakHelper.formatDate(DateTime.now());
    _activeDates = _storageService.getActiveDates().toSet();

    final savedStreak = _storageService.getStreakCount();
    if (savedStreak > 0) {
      _streakCount = savedStreak;
    } else {
      _streakCount = 17;
    }

    final completedToday = _storageService.getDailyCompletedHabitIds(todayStr);
    if (completedToday.isNotEmpty) {
      for (int i = 0; i < _habits.length; i++) {
        final h = _habits[i];
        final done = completedToday.contains(h.id);
        if (done) {
          _habits[i] = h.copyWith(isCompleted: true, recordedTime: h.recordedTime ?? '05:10 AM');
        }
      }
    }
  }

  void _saveState() {
    _storageService.setUserPoints(_userPoints);
    _storageService.setUserLevel(_userLevel);
  }
}
