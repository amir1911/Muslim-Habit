import 'package:flutter/material.dart';
import '../models/habit_item.dart';
import '../models/badge_item.dart';
import '../services/storage_service.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storageService;

  HabitProvider(this._storageService) {
    _loadState();
  }

  int _userPoints = 150;
  int _userLevel = 1;
  int _streakCount = 3;
  String _selectedCategory = 'all'; // all, wajib, sunnah
  String _userName = 'Sahabat Muslim';

  int get userPoints => _userPoints;
  int get userLevel => _userLevel;
  int get streakCount => _streakCount;
  String get selectedCategory => _selectedCategory;
  String get userName => _userName;

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  final List<HabitItem> _habits = [
    // Wajib
    HabitItem(
      id: 'subuh',
      title: 'Shalat Subuh',
      subtitle: '2 Rakaat tepat waktu',
      category: HabitCategory.wajib,
      icon: Icons.wb_twilight_rounded,
      points: 25,
      timeSuggestion: '04:45 WIB',
      isCompleted: true,
      streak: 4,
    ),
    HabitItem(
      id: 'dzuhur',
      title: 'Shalat Dzuhur',
      subtitle: '4 Rakaat berjamaah',
      category: HabitCategory.wajib,
      icon: Icons.wb_sunny_rounded,
      points: 20,
      timeSuggestion: '12:05 WIB',
      isCompleted: true,
      streak: 3,
    ),
    HabitItem(
      id: 'ashar',
      title: 'Shalat Ashar',
      subtitle: '4 Rakaat tepat waktu',
      category: HabitCategory.wajib,
      icon: Icons.cloud_queue_rounded,
      points: 20,
      timeSuggestion: '15:15 WIB',
      isCompleted: false,
      streak: 2,
    ),
    HabitItem(
      id: 'maghrib',
      title: 'Shalat Maghrib',
      subtitle: '3 Rakaat di masjid/awal waktu',
      category: HabitCategory.wajib,
      icon: Icons.nights_stay_outlined,
      points: 20,
      timeSuggestion: '18:10 WIB',
      isCompleted: false,
      streak: 3,
    ),
    HabitItem(
      id: 'isya',
      title: 'Shalat Isya',
      subtitle: '4 Rakaat sebelum tidur',
      category: HabitCategory.wajib,
      icon: Icons.bedtime_rounded,
      points: 20,
      timeSuggestion: '19:20 WIB',
      isCompleted: false,
      streak: 3,
    ),

    // Sunnah
    HabitItem(
      id: 'tahajud',
      title: 'Shalat Tahajud',
      subtitle: 'Bermunajat di sepertiga malam',
      category: HabitCategory.sunnah,
      icon: Icons.stars_rounded,
      points: 35,
      timeSuggestion: '03:30 WIB',
      isCompleted: true,
      streak: 2,
    ),
    HabitItem(
      id: 'dhuha',
      title: 'Shalat Dhuha',
      subtitle: 'Pintu rezeki dan sedekah persendian',
      category: HabitCategory.sunnah,
      icon: Icons.light_mode_rounded,
      points: 25,
      timeSuggestion: '08:30 WIB',
      isCompleted: false,
      streak: 1,
    ),
    HabitItem(
      id: 'tilawah',
      title: 'Tilawah Al-Qur\'an',
      subtitle: 'Minimal 1-2 lembar hari ini',
      category: HabitCategory.sunnah,
      icon: Icons.menu_book_rounded,
      points: 30,
      timeSuggestion: 'Ba\'da Maghrib',
      isCompleted: true,
      streak: 5,
    ),
    HabitItem(
      id: 'sedekah',
      title: 'Sedekah Subuh / Harian',
      subtitle: 'Menolak bala dan melipatgandakan berkah',
      category: HabitCategory.sunnah,
      icon: Icons.volunteer_activism_rounded,
      points: 30,
      timeSuggestion: 'Pagi Hari',
      isCompleted: true,
      streak: 3,
    ),
    HabitItem(
      id: 'dzikir',
      title: 'Dzikir Pagi & Petang',
      subtitle: 'Benteng perlindungan seorang muslim',
      category: HabitCategory.sunnah,
      icon: Icons.spa_rounded,
      points: 20,
      timeSuggestion: 'Pagi & Sore',
      isCompleted: false,
      streak: 2,
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
      isUnlocked: false,
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
    BadgeItem(
      id: 'tahajud_warrior',
      title: 'Pengetuk Langit Malam',
      description: 'Bangun shalat tahajud 3 malam beruntun.',
      icon: Icons.nightlight_round,
      accentColor: const Color(0xFF9575CD),
      requiredStreak: 3,
      category: 'Amalan Sunnah',
      isUnlocked: false,
    ),
  ];

  List<HabitItem> get habits {
    if (_selectedCategory == 'wajib') {
      return _habits.where((h) => h.category == HabitCategory.wajib).toList();
    } else if (_selectedCategory == 'sunnah') {
      return _habits.where((h) => h.category == HabitCategory.sunnah).toList();
    }
    return _habits;
  }

  List<BadgeItem> get badges => _badges;

  int get completedHabitsCount => _habits.where((h) => h.isCompleted).length;
  int get totalHabitsCount => _habits.length;
  double get progressFraction => totalHabitsCount == 0 ? 0.0 : (completedHabitsCount / totalHabitsCount);

  // Dynamic Camel Mascot Speech & Mood
  String get mascotMessage {
    final pct = progressFraction;
    if (pct == 1.0) {
      return "Maa Syaa Allah! 🎉 Semua target habit hari ini tuntas! Kamu luar biasa!";
    } else if (pct >= 0.7) {
      return "Alhamdulillah! Tinggal sedikit lagi target harianmu tercapai. Semangat terus!";
    } else if (pct >= 0.4) {
      return "Bagus sekali! Sudah $completedHabitsCount ibadah selesai. Ayo jaga api istiqomahmu!";
    } else if (pct > 0) {
      return "Langkah awal yang baik! Yuk lanjutkan dengan amalan berikutnya bersama Jamal Si Unta!";
    } else {
      return "Assalamu'alaikum Sahabat! Awali harimu dengan niat ikhlas & senyuman berkah ya!";
    }
  }

  String get mascotStatusTitle {
    final pct = progressFraction;
    if (pct == 1.0) return "Sangat Bahagia & Bangga!";
    if (pct >= 0.5) return "Semangat Menyala!";
    return "Menemani Harimu";
  }

  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final current = _habits[index];
      final newStatus = !current.isCompleted;
      final newStreak = newStatus ? current.streak + 1 : (current.streak > 0 ? current.streak - 1 : 0);

      _habits[index] = current.copyWith(
        isCompleted: newStatus,
        streak: newStreak,
      );

      if (newStatus) {
        _userPoints += current.points;
        _checkLevelUp();
        _checkBadges();
      } else {
        _userPoints = (_userPoints - current.points).clamp(0, 99999);
      }

      _saveState();
      notifyListeners();
    }
  }

  void _checkLevelUp() {
    final requiredPointsForNextLevel = _userLevel * 200;
    if (_userPoints >= requiredPointsForNextLevel) {
      _userLevel++;
    }
  }

  void _checkBadges() {
    // Check 7 days streak badge
    if (_streakCount >= 7) {
      _unlockBadge('istiqomah_7');
    }
    // Check 5 waktu
    final fardhuDone = _habits.where((h) => h.category == HabitCategory.wajib && h.isCompleted).length;
    if (fardhuDone == 5) {
      _unlockBadge('penjaga_fardhu');
    }
  }

  void _unlockBadge(String badgeId) {
    final idx = _badges.indexWhere((b) => b.id == badgeId);
    if (idx != -1 && !_badges[idx].isUnlocked) {
      _badges[idx].isUnlocked = true;
      _userPoints += 50;
    }
  }

  void setUserName(String name) {
    _userName = name;
    _storageService.setUserName(name);
    notifyListeners();
  }

  void _loadState() {
    _userPoints = _storageService.getUserPoints();
    _userLevel = _storageService.getUserLevel();
    _streakCount = _storageService.getStreakCount();
    _userName = _storageService.getUserName();

    final savedBadges = _storageService.getUnlockedBadges();
    for (var b in _badges) {
      if (savedBadges.contains(b.id)) {
        b.isUnlocked = true;
      }
    }
    notifyListeners();
  }

  void _saveState() {
    _storageService.setUserPoints(_userPoints);
    _storageService.setUserLevel(_userLevel);
    _storageService.setStreakCount(_streakCount);

    final unlockedIds = _badges.where((b) => b.isUnlocked).map((b) => b.id).toList();
    _storageService.setUnlockedBadges(unlockedIds);
  }
}
