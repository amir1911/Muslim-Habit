import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHabitsPrefix = 'habits_data_';
  static const String _keyUserPoints = 'user_points';
  static const String _keyUserLevel = 'user_level';
  static const String _keyStreakCount = 'streak_count';
  static const String _keyLastActiveDate = 'last_active_date';
  static const String _keyActiveDates = 'active_streak_dates_v2';
  static const String _keyCompletedHabitsPrefix = 'completed_habits_';
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

  List<String> getActiveDates() => _prefs.getStringList(_keyActiveDates) ?? [];
  Future<void> setActiveDates(List<String> dates) => _prefs.setStringList(_keyActiveDates, dates);

  List<String> getDailyCompletedHabitIds(String dateKey) =>
      _prefs.getStringList('$_keyCompletedHabitsPrefix$dateKey') ?? [];
  Future<void> setDailyCompletedHabitIds(String dateKey, List<String> habitIds) =>
      _prefs.setStringList('$_keyCompletedHabitsPrefix$dateKey', habitIds);

  String getUserName() => _prefs.getString(_keyUserName) ?? 'Sahabat Muslim';
  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  static const String _keyUserEmail = 'user_email_address';
  static const String _keyUserPassword = 'user_auth_password';
  static const String _keyUserAvatarPath = 'user_avatar_path';
  static const String _keyHabitRemindersEnabled = 'user_habit_reminders_enabled';
  static const String _keyChatbotTone = 'chatbot_tone_preference';

  String getUserEmail() => _prefs.getString(_keyUserEmail) ?? 'ahmad.husain@email.com';
  Future<void> setUserEmail(String email) => _prefs.setString(_keyUserEmail, email);

  String? getUserPassword() => _prefs.getString(_keyUserPassword);
  Future<void> setUserPassword(String password) => _prefs.setString(_keyUserPassword, password);

  String? getUserAvatarPath() => _prefs.getString(_keyUserAvatarPath);
  Future<void> setUserAvatarPath(String path) => _prefs.setString(_keyUserAvatarPath, path);

  bool getHabitRemindersEnabled() => _prefs.getBool(_keyHabitRemindersEnabled) ?? true;
  Future<void> setHabitRemindersEnabled(bool enabled) => _prefs.setBool(_keyHabitRemindersEnabled, enabled);

  String getChatbotTone() => _prefs.getString(_keyChatbotTone) ?? 'Ramah & Islami';
  Future<void> setChatbotTone(String tone) => _prefs.setString(_keyChatbotTone, tone);

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

  // Prayer Schedule Cache
  static const String _keyPrayerSchedule = 'cached_prayer_schedule_v3';
  static const String _keyPrayerCity = 'saved_prayer_city';

  String? getSavedPrayerSchedule() => _prefs.getString(_keyPrayerSchedule);
  Future<void> savePrayerSchedule(String jsonStr) => _prefs.setString(_keyPrayerSchedule, jsonStr);

  String getSavedPrayerCity() => _prefs.getString(_keyPrayerCity) ?? 'Palembang';
  Future<void> setSavedPrayerCity(String city) => _prefs.setString(_keyPrayerCity, city);

  // Quran Verse Cache
  static const String _keyCachedVerse = 'cached_random_verse';
  String? getSavedVerse() => _prefs.getString(_keyCachedVerse);
  Future<void> saveVerse(String jsonStr) => _prefs.setString(_keyCachedVerse, jsonStr);

  // Hadith Cache
  static const String _keyCachedHadith = 'cached_random_hadith';
  String? getSavedHadith() => _prefs.getString(_keyCachedHadith);
  Future<void> saveHadith(String jsonStr) => _prefs.setString(_keyCachedHadith, jsonStr);

  // Qibla Cache
  static const String _keyCachedQibla = 'cached_qibla_info';
  String? getSavedQibla() => _prefs.getString(_keyCachedQibla);
  Future<void> saveQibla(String jsonStr) => _prefs.setString(_keyCachedQibla, jsonStr);

  // Full Surah List Cache
  static const String _keyCachedSurahList = 'cached_all_surahs_list';
  String? getSavedSurahList() => _prefs.getString(_keyCachedSurahList);
  Future<void> saveSurahList(String jsonStr) => _prefs.setString(_keyCachedSurahList, jsonStr);

  // Surah Detail Cache (keyed by surah number)
  static const String _keySurahDetailPrefix = 'cached_surah_detail_';
  String? getSavedSurahDetail(int number) => _prefs.getString('$_keySurahDetailPrefix$number');
  Future<void> saveSurahDetail(int number, String jsonStr) => _prefs.setString('$_keySurahDetailPrefix$number', jsonStr);

  // Recent Reading State
  static const String _keyRecentSurahNum = 'recent_reading_surah_num';
  static const String _keyRecentSurahName = 'recent_reading_surah_name';
  static const String _keyRecentAyahNum = 'recent_reading_ayah_num';
  static const String _keyRecentProgress = 'recent_reading_progress';

  int getRecentSurahNumber() => _prefs.getInt(_keyRecentSurahNum) ?? 2;
  String getRecentSurahName() => _prefs.getString(_keyRecentSurahName) ?? 'Al-Baqarah';
  int getRecentAyahNumber() => _prefs.getInt(_keyRecentAyahNum) ?? 10;
  double getRecentProgress() => _prefs.getDouble(_keyRecentProgress) ?? 0.56;

  Future<void> saveRecentReading({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required double progress,
  }) async {
    await _prefs.setInt(_keyRecentSurahNum, surahNumber);
    await _prefs.setString(_keyRecentSurahName, surahName);
    await _prefs.setInt(_keyRecentAyahNum, ayahNumber);
    await _prefs.setDouble(_keyRecentProgress, progress);
  }

  // ── Baca Al-Qur'an Progress & Settings ──
  static const String _keyProgressPrefix = 'reading_progress_surah_';
  static const String _keyBookmarks = 'quran_bookmarked_verses';
  static const String _keyArabicFontSize = 'reader_arabic_font_size';
  static const String _keyTransFontSize = 'reader_trans_font_size';
  static const String _keyShowTajwid = 'reader_show_tajwid';
  static const String _keyShowTranslation = 'reader_show_translation';
  static const String _keyReaderTheme = 'reader_theme_mode'; // 'light', 'dark', 'sepia'
  static const String _keyAudioSpeed = 'reader_audio_speed';

  String? getReadingProgress(int surahId) => _prefs.getString('$_keyProgressPrefix$surahId');
  Future<void> saveReadingProgress(int surahId, String jsonStr) =>
      _prefs.setString('$_keyProgressPrefix$surahId', jsonStr);

  List<String> getBookmarkedVerses() => _prefs.getStringList(_keyBookmarks) ?? [];
  Future<void> saveBookmarkedVerses(List<String> list) =>
      _prefs.setStringList(_keyBookmarks, list);

  double getArabicFontSize() => _prefs.getDouble(_keyArabicFontSize) ?? 24.0;
  Future<void> setArabicFontSize(double size) => _prefs.setDouble(_keyArabicFontSize, size);

  double getTranslationFontSize() => _prefs.getDouble(_keyTransFontSize) ?? 13.0;
  Future<void> setTranslationFontSize(double size) => _prefs.setDouble(_keyTransFontSize, size);

  bool getShowTajwid() => _prefs.getBool(_keyShowTajwid) ?? true;
  Future<void> setShowTajwid(bool show) => _prefs.setBool(_keyShowTajwid, show);

  bool getShowTranslation() => _prefs.getBool(_keyShowTranslation) ?? true;
  Future<void> setShowTranslation(bool show) => _prefs.setBool(_keyShowTranslation, show);

  String getReaderTheme() => _prefs.getString(_keyReaderTheme) ?? 'sepia';
  Future<void> setReaderTheme(String theme) => _prefs.setString(_keyReaderTheme, theme);

  double getAudioSpeed() => _prefs.getDouble(_keyAudioSpeed) ?? 1.0;
  Future<void> setAudioSpeed(double speed) => _prefs.setDouble(_keyAudioSpeed, speed);

  // ── Doa Cache ──
  static const String _keyCachedDoaList = 'cached_all_doa_list';
  static const String _keyFavoriteDoaIds = 'favorite_doa_ids';

  String? getSavedDoaList() => _prefs.getString(_keyCachedDoaList);
  Future<void> saveDoaList(String jsonStr) => _prefs.setString(_keyCachedDoaList, jsonStr);

  List<String> getFavoriteDoaIds() => _prefs.getStringList(_keyFavoriteDoaIds) ?? [];
  Future<void> saveFavoriteDoaIds(List<String> ids) => _prefs.setStringList(_keyFavoriteDoaIds, ids);

  static const String _keyReadDoaIds = 'read_doa_ids_today';
  static const String _keyReadDoaDate = 'read_doa_date';

  List<String> getTodayReadDoaIds() {
    final savedDate = _prefs.getString(_keyReadDoaDate);
    final today = _todayKey();
    if (savedDate != today) {
      return [];
    }
    return _prefs.getStringList(_keyReadDoaIds) ?? [];
  }

  Future<void> markDoaAsRead(int id) async {
    final today = _todayKey();
    final savedDate = _prefs.getString(_keyReadDoaDate);
    List<String> current = (savedDate == today) ? (_prefs.getStringList(_keyReadDoaIds) ?? []) : [];
    final idStr = id.toString();
    if (!current.contains(idStr)) {
      current.add(idStr);
      await _prefs.setString(_keyReadDoaDate, today);
      await _prefs.setStringList(_keyReadDoaIds, current);
    }
  }

  // ── Sholat & Alarm Settings ──
  static const String _keyPrayerAlarmPrefix = 'prayer_alarm_config_';
  static const String _keyPrayerDonePrefix = 'prayer_done_record_';

  String? getPrayerAlarmConfig(String prayerKey) => _prefs.getString('$_keyPrayerAlarmPrefix$prayerKey');
  Future<void> savePrayerAlarmConfig(String prayerKey, String jsonStr) =>
      _prefs.setString('$_keyPrayerAlarmPrefix$prayerKey', jsonStr);

  // Status sholat tercatat per tanggal (dateKey + prayerKey)
  String? getPrayerRecordedTime(String dateKey, String prayerKey) =>
      _prefs.getString('$_keyPrayerDonePrefix${dateKey}_$prayerKey');

  Future<void> setPrayerRecordedTime(String dateKey, String prayerKey, String? timeStr) async {
    final key = '$_keyPrayerDonePrefix${dateKey}_$prayerKey';
    if (timeStr == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, timeStr);
    }
  }

  // ── Adzan Otomatis Settings ──
  static const String _keyAdzanAutoEnabled = 'adzan_auto_enabled_global';
  static const String _keyAdzanPrayerPrefix = 'adzan_prayer_enabled_';
  static const String _keyAdzanVolume = 'adzan_playback_volume';
  static const String _keyPrayerPreReminder = 'prayer_pre_reminder_enabled';
  static const String _keyPrayerPreReminderMinutes = 'prayer_pre_reminder_minutes';
  static const String _keyAdzanPlayedPrefix = 'adzan_played_';

  bool getAdzanAutoEnabled() => _prefs.getBool(_keyAdzanAutoEnabled) ?? true;
  Future<void> setAdzanAutoEnabled(bool val) => _prefs.setBool(_keyAdzanAutoEnabled, val);

  bool getAdzanPrayerEnabled(String prayerKey) =>
      _prefs.getBool('$_keyAdzanPrayerPrefix${prayerKey.toLowerCase()}') ?? true;
  Future<void> setAdzanPrayerEnabled(String prayerKey, bool val) =>
      _prefs.setBool('$_keyAdzanPrayerPrefix${prayerKey.toLowerCase()}', val);

  double getAdzanVolume() => _prefs.getDouble(_keyAdzanVolume) ?? 1.0;
  Future<void> setAdzanVolume(double vol) => _prefs.setDouble(_keyAdzanVolume, vol);

  bool getPrayerPreReminderEnabled() => _prefs.getBool(_keyPrayerPreReminder) ?? false;
  Future<void> setPrayerPreReminderEnabled(bool val) => _prefs.setBool(_keyPrayerPreReminder, val);

  int getPrayerPreReminderMinutes() => _prefs.getInt(_keyPrayerPreReminderMinutes) ?? 10;
  Future<void> setPrayerPreReminderMinutes(int minutes) =>
      _prefs.setInt(_keyPrayerPreReminderMinutes, minutes);

  String? getAdzanLastPlayed(String dateKey, String prayerKey) =>
      _prefs.getString('$_keyAdzanPlayedPrefix${dateKey}_${prayerKey.toLowerCase()}');
  Future<void> setAdzanLastPlayed(String dateKey, String prayerKey, String timestamp) =>
      _prefs.setString('$_keyAdzanPlayedPrefix${dateKey}_${prayerKey.toLowerCase()}', timestamp);

  // ── Onboarding & Selected AI Assistant ──
  static const String _keySelectedAIId = 'selected_ai_assistant_id';
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';

  String getSelectedAIId() => _prefs.getString(_keySelectedAIId) ?? 'teen';
  Future<void> setSelectedAIId(String aiId) => _prefs.setString(_keySelectedAIId, aiId);

  bool hasCompletedOnboarding() => _prefs.getBool(_keyHasCompletedOnboarding) ?? false;
  Future<void> setCompletedOnboarding(bool completed) =>
      _prefs.setBool(_keyHasCompletedOnboarding, completed);

  // ── Gamifikasi & Maskot Nunu Persistence ──
  static const String _keyEquippedCostume = 'nunu_equipped_costume';
  static const String _keyOwnedCostumes = 'nunu_owned_costumes';
  static const String _keyFriendshipPoints = 'nunu_friendship_points';
  static const String _keyFriendshipLevel = 'nunu_friendship_level';
  static const String _keyBoosterExpiresAt = 'nunu_booster_expires_at';
  static const String _keyOwnedPotions = 'nunu_owned_potions_json';
  static const String _keyOwnedRewards = 'nunu_owned_rewards';

  String getEquippedCostume() => _prefs.getString(_keyEquippedCostume) ?? 'normal';
  Future<void> setEquippedCostume(String costumeId) =>
      _prefs.setString(_keyEquippedCostume, costumeId);

  List<String> getOwnedCostumes() =>
      _prefs.getStringList(_keyOwnedCostumes) ?? ['normal', 'sorban_emas'];
  Future<void> setOwnedCostumes(List<String> list) =>
      _prefs.setStringList(_keyOwnedCostumes, list);

  int getFriendshipPoints() => _prefs.getInt(_keyFriendshipPoints) ?? 75;
  Future<void> setFriendshipPoints(int pts) =>
      _prefs.setInt(_keyFriendshipPoints, pts);

  int getFriendshipLevel() => _prefs.getInt(_keyFriendshipLevel) ?? 4;
  Future<void> setFriendshipLevel(int lvl) =>
      _prefs.setInt(_keyFriendshipLevel, lvl);

  int? getBoosterExpiresAt() => _prefs.getInt(_keyBoosterExpiresAt);
  Future<void> setBoosterExpiresAt(int? timestampMs) async {
    if (timestampMs == null) {
      await _prefs.remove(_keyBoosterExpiresAt);
    } else {
      await _prefs.setInt(_keyBoosterExpiresAt, timestampMs);
    }
  }

  List<String> getOwnedRewards() =>
      _prefs.getStringList(_keyOwnedRewards) ?? [];
  Future<void> setOwnedRewards(List<String> list) =>
      _prefs.setStringList(_keyOwnedRewards, list);
}


