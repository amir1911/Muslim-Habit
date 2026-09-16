import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHabitsPrefix = 'habits_data_';
  static const String _keyUserPoints = 'user_points';
  static const String _keyUserLevel = 'user_level';
  static const String _keyStreakCount = 'streak_count';
  static const String _keyLastActiveDate = 'last_active_date';
  static const String _keyBadges = 'unlocked_badges';
  static const String _keyTilawahPage = 'tilawah_current_page';
  static const String _keyTilawahJuz = 'tilawah_current_juz';
  static const String _keyDhikrStats = 'dhikr_stats';
  static const String _keyUserName = 'user_display_name';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Date key format YYYY-MM-DD
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Habits persistence
  Future<void> saveDailyHabits(String dateKey, Map<String, dynamic> data) async {
    await _prefs.setString('$_keyHabitsPrefix$dateKey', jsonEncode(data));
  }

  Map<String, dynamic>? getDailyHabits(String dateKey) {
    final str = _prefs.getString('$_keyHabitsPrefix$dateKey');
    if (str != null) {
      try {
        return jsonDecode(str) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  // User Profile Stats
  int getUserPoints() => _prefs.getInt(_keyUserPoints) ?? 150;
  Future<void> setUserPoints(int points) => _prefs.setInt(_keyUserPoints, points);

  int getUserLevel() => _prefs.getInt(_keyUserLevel) ?? 1;
  Future<void> setUserLevel(int level) => _prefs.setInt(_keyUserLevel, level);

  int getStreakCount() => _prefs.getInt(_keyStreakCount) ?? 3;
  Future<void> setStreakCount(int streak) => _prefs.setInt(_keyStreakCount, streak);

  String getLastActiveDate() => _prefs.getString(_keyLastActiveDate) ?? _todayKey();
  Future<void> setLastActiveDate(String date) => _prefs.setString(_keyLastActiveDate, date);

  String getUserName() => _prefs.getString(_keyUserName) ?? 'Sahabat Muslim';
  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  // Badges
  List<String> getUnlockedBadges() => _prefs.getStringList(_keyBadges) ?? ['pejuang_subuh'];
  Future<void> setUnlockedBadges(List<String> badges) => _prefs.setStringList(_keyBadges, badges);

  // Tilawah
  int getTilawahPage() => _prefs.getInt(_keyTilawahPage) ?? 45;
  Future<void> setTilawahPage(int page) => _prefs.setInt(_keyTilawahPage, page);

  int getTilawahJuz() => _prefs.getInt(_keyTilawahJuz) ?? 3;
  Future<void> setTilawahJuz(int juz) => _prefs.setInt(_keyTilawahJuz, juz);

  // Dhikr
  int getDhikrTotal() => _prefs.getInt(_keyDhikrStats) ?? 99;
  Future<void> setDhikrTotal(int count) => _prefs.setInt(_keyDhikrStats, count);
}
