import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dzikir/dzikir_item_model.dart';
import '../models/dzikir/dzikir_category_model.dart';

class DzikirService {
  static const String _keyDailyGoalTarget = 'dzikir_daily_goal_target_v1';
  static const String _keyDailyTotalCountPrefix = 'dzikir_daily_count_';
  static const String _keySoundEnabled = 'dzikir_sound_enabled_v1';
  static const String _keyVibrationEnabled = 'dzikir_vibration_enabled_v1';
  static const String _keyHistory = 'dzikir_history_list_v1';
  static const String _keySessionPrefix = 'dzikir_session_count_';
  static const String _keyCompletedDzikirIdsPrefix = 'dzikir_completed_ids_';

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. DATA MASTER BACAAN & KATEGORI DZIKIR OTENTIK
  // ─────────────────────────────────────────────────────────────────────────────
  List<DzikirCategoryModel> getCategories() {
    return [
      DzikirCategoryModel(
        id: 'thayyibah',
        name: 'Kalimat Thayyibah',
        subtitle: 'Awali harimu dengan keberkahan dan perlindungan dari Allah SWT.',
        items: _getKalimatThayyibahItems(),
      ),
      DzikirCategoryModel(
        id: 'shalat',
        name: 'Zikir Shalat',
        subtitle: 'Rangkaian tasbih, tahmid, dan takbir setelah shalat fardhu.',
        items: _getZikirShalatItems(),
      ),
      DzikirCategoryModel(
        id: 'pagi',
        name: 'Zikir Pagi',
        subtitle: 'Awali harimu dengan keberkahan dan perlindungan dari Allah SWT.',
        items: _getZikirPagiItems(),
      ),
      DzikirCategoryModel(
        id: 'petang',
        name: 'Zikir Petang',
        subtitle: 'Menutup hari dengan rasa syukur dan ketenangan batin.',
        items: _getZikirPetangItems(),
      ),
      DzikirCategoryModel(
        id: 'tidur',
        name: 'Zikir Sebelum Tidur',
        subtitle: '9 bacaan - Perlindungan malam',
        items: _getZikirTidurItems(),
      ),
      DzikirCategoryModel(
        id: 'penyembuh',
        name: 'Zikir Penyembuh',
        subtitle: '9 bacaan - Ikhtiar kesembuhan & perlindungan',
        items: _getZikirPenyembuhItems(),
      ),
      DzikirCategoryModel(
        id: 'perjalanan',
        name: 'Zikir Perjalanan',
        subtitle: '9 bacaan - Keselamatan dalam safar',
        items: _getZikirPerjalananItems(),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. PENYIMPANAN HITUNGAN & PREFERENSI (PERSISTENCE)
  // ─────────────────────────────────────────────────────────────────────────────
  Future<int> getDailyGoalTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyGoalTarget) ?? 1000;
  }

  Future<void> setDailyGoalTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyGoalTarget, target);
  }

  Future<int> getTodayTotalCount(String todayKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyDailyTotalCountPrefix$todayKey') ?? 0;
  }

  Future<void> addDailyCount(String todayKey, int increment) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTodayTotalCount(todayKey);
    await prefs.setInt('$_keyDailyTotalCountPrefix$todayKey', current + increment);
  }

  Future<int> getSessionCount(String dzikirId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keySessionPrefix$dzikirId') ?? 0;
  }

  Future<void> setSessionCount(String dzikirId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keySessionPrefix$dzikirId', count);
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrationEnabled, enabled);
  }

  Future<List<String>> getCompletedDzikirIds(String todayKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_keyCompletedDzikirIdsPrefix$todayKey') ?? [];
  }

  Future<void> markDzikirCompleted(String todayKey, String dzikirId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getCompletedDzikirIds(todayKey);
    if (!list.contains(dzikirId)) {
      list.add(dzikirId);
      await prefs.setStringList('$_keyCompletedDzikirIdsPrefix$todayKey', list);
    }
  }

  Future<List<DzikirHistoryModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistory);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => DzikirHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      } catch (e) {
        debugPrint('Error parsing dzikir history: $e');
      }
    }
    return [];
  }

  Future<void> addHistory(DzikirHistoryModel entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getHistory();
    list.insert(0, entry);
    // Batasi maksimum 100 catatan
    if (list.length > 100) list.removeLast();
    await prefs.setString(_keyHistory, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. DAFTAR DATA BACAAN OTENTIK LENGKAP DENGAN SANAD / HADIS
  // ─────────────────────────────────────────────────────────────────────────────
  List<DzikirItemModel> _getKalimatThayyibahItems() {
    return [
      DzikirItemModel(
        id: 'thay_1',
        categoryId: 'thayyibah',
        name: 'Subhanallah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Subhanallah',
        translation: 'Mahasuci Allah.',
        defaultTarget: 33,
        source: 'HR. Muslim no. 2726',
        note: 'Dua kalimat yang ringan di lisan, berat di timbangan.',
      ),
      DzikirItemModel(
        id: 'thay_2',
        categoryId: 'thayyibah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        translation: 'Segala puji bagi Allah.',
        defaultTarget: 33,
        source: 'HR. Muslim no. 223',
        note: 'Ucapan syukur yang memenuhi timbangan amal.',
      ),
      DzikirItemModel(
        id: 'thay_3',
        categoryId: 'thayyibah',
        name: 'Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        translation: 'Allah Mahabesar.',
        defaultTarget: 33,
        source: 'HR. Muslim no. 597',
        note: 'Pengagungan kebesaran Allah di atas segalanya.',
      ),
      DzikirItemModel(
        id: 'thay_4',
        categoryId: 'thayyibah',
        name: 'La Ilaha Illallah',
        arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
        transliteration: 'La ilaha illallah',
        translation: 'Tiada sesembahan yang berhak disembah selain Allah.',
        defaultTarget: 100,
        source: 'HR. Muslim no. 26',
        note: 'Sebaik-baik dzikir dan kunci surga.',
      ),
      DzikirItemModel(
        id: 'thay_5',
        categoryId: 'thayyibah',
        name: 'Astaghfirullah',
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        translation: 'Aku memohon ampun kepada Allah.',
        defaultTarget: 100,
        source: 'HR. Bukhari no. 6307',
        note: 'Rasulullah SAW beristighfar lebih dari 70-100 kali sehari.',
      ),
      DzikirItemModel(
        id: 'thay_6',
        categoryId: 'thayyibah',
        name: 'Subhanallahi wa Bihamdihi',
        arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        transliteration: 'Subhanallahi wa bihamdihi',
        translation: 'Mahasuci Allah dengan segala puji bagi-Nya.',
        defaultTarget: 33,
        source: 'HR. Bukhari no. 6405 & HR. Muslim no. 2691',
        note: 'Siapa membaca 100x sehari, diampuni dosanya meski sebanyak buih lautan.',
      ),
      DzikirItemModel(
        id: 'thay_7',
        categoryId: 'thayyibah',
        name: 'La Hawla wa La Quwwata Illa Billah',
        arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        transliteration: 'La hawla wa la quwwata illa billah',
        translation: 'Tiada daya dan upaya melainkan dengan pertolongan Allah.',
        defaultTarget: 33,
        source: 'HR. Bukhari no. 4205',
        note: 'Simpanan dari perbendaharaan surga.',
      ),
    ];
  }

  List<DzikirItemModel> _getZikirShalatItems() {
    return [
      DzikirItemModel(
        id: 'shlt_1',
        categoryId: 'shalat',
        name: 'Istighfar Setelah Salam',
        arabic: 'أَسْتَغْفِرُ اللَّهَ ، أَسْتَغْفِرُ اللَّهَ ، أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah, Astaghfirullah, Astaghfirullah',
        translation: 'Aku memohon ampun kepada Allah (3 kali).',
        defaultTarget: 3,
        source: 'HR. Muslim no. 591',
      ),
      DzikirItemModel(
        id: 'shlt_2',
        categoryId: 'shalat',
        name: 'Doa Keselamatan (Antas Salam)',
        arabic: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        transliteration: 'Allahumma antas-salamu wa minkas-salam, tabarakta ya dzal-jalali wal-ikram',
        translation: 'Ya Allah, Engkaulah As-Salam, dan dari-Mu keselamatan. Mahaberkah Engkau, wahai Dzat Pemilik Keagungan dan Kemuliaan.',
        defaultTarget: 1,
        source: 'HR. Muslim no. 591',
      ),
      DzikirItemModel(
        id: 'shlt_3',
        categoryId: 'shalat',
        name: 'Tahlil Setelah Shalat',
        arabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration: 'La ilaha illallahu wahdahu la syarika lahu, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli syai-in qadir',
        translation: 'Tiada sesembahan yang berhak disembah selain Allah semata, tidak ada sekutu bagi-Nya. Milik-Nya segala kerajaan dan bagi-Nya segala puji, dan Dia Mahakuasa atas segala sesuatu.',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 844 & HR. Muslim no. 593',
      ),
      DzikirItemModel(
        id: 'shlt_4',
        categoryId: 'shalat',
        name: 'Doa Bersyukur & Beribadah',
        arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        transliteration: 'Allahumma a\'inni \'ala dzikrika wa syukrika wa husni \'ibadatik',
        translation: 'Ya Allah, tolonglah aku untuk senantiasa mengingat-Mu, bersyukur kepada-Mu, dan beribadah dengan baik kepada-Mu.',
        defaultTarget: 1,
        source: 'HR. Abu Dawud no. 1522 & An-Nasa\'i no. 1303 (Shahih)',
      ),
      DzikirItemModel(
        id: 'shlt_5',
        categoryId: 'shalat',
        name: 'Tasbih Bakda Shalat',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Subhanallah',
        translation: 'Mahasuci Allah.',
        defaultTarget: 33,
        source: 'HR. Muslim no. 597',
      ),
      DzikirItemModel(
        id: 'shlt_6',
        categoryId: 'shalat',
        name: 'Tahmid Bakda Shalat',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        translation: 'Segala puji bagi Allah.',
        defaultTarget: 33,
        source: 'HR. Muslim no. 597',
      ),
      DzikirItemModel(
        id: 'shlt_7',
        categoryId: 'shalat',
        name: 'Takbir Bakda Shalat',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        translation: 'Allah Mahabesar.',
        defaultTarget: 33,
        source: 'HR. Muslim no. 597',
      ),
      DzikirItemModel(
        id: 'shlt_8',
        categoryId: 'shalat',
        name: 'Penyempurna Seratus (Tahlil)',
        arabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration: 'La ilaha illallahu wahdahu la syarika lahu...',
        translation: 'Penyempurna bilangan 100 setelah tasbih, tahmid, dan takbir 33x.',
        defaultTarget: 1,
        source: 'HR. Muslim no. 597',
      ),
      DzikirItemModel(
        id: 'shlt_9',
        categoryId: 'shalat',
        name: 'Ayat Kursi Bakda Shalat',
        arabic: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
        transliteration: 'Allahu la ilaha illa huwal-hayyul-qayyum...',
        translation: 'Siapa membaca Ayat Kursi setiap selesai shalat fardhu, tidak ada yang menghalanginya masuk surga selain kematian.',
        defaultTarget: 1,
        source: 'HR. An-Nasa\'i dalam Amalul Yaum wal Lailah no. 100 (Shahih)',
      ),
      DzikirItemModel(
        id: 'shlt_10',
        categoryId: 'shalat',
        name: 'Mu\'awwidzatain & Al-Ikhlas',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Surat Al-Ikhlas, Al-Falaq, An-Nas',
        translation: 'Membaca surat Al-Ikhlas, Al-Falaq, dan An-Nas setiap selesai shalat fardhu.',
        defaultTarget: 1,
        source: 'HR. Abu Dawud no. 1523',
      ),
    ];
  }

  List<DzikirItemModel> _getZikirPagiItems() {
    return [
      DzikirItemModel(
        id: 'pagi_1',
        categoryId: 'pagi',
        name: 'Ayat Kursi Pagi',
        arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...',
        transliteration: 'Allahu la ilaha illa huwal-hayyul-qayyum...',
        translation: 'Barangsiapa membacanya di pagi hari maka ia dilindungi dari gangguan jin hingga petang.',
        defaultTarget: 1,
        source: 'HR. Al-Hakim (1/562)',
      ),
      DzikirItemModel(
        id: 'pagi_2',
        categoryId: 'pagi',
        name: 'Sayyidul Istighfar',
        arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...',
        transliteration: 'Allahumma anta rabbi la ilaha illa anta, khalaqtani wa ana \'abduka...',
        translation: 'Pemimpin istighfar. Barangsiapa membacanya dengan penuh keyakinan di pagi hari lalu meninggal sebelum petang, ia termasuk penghuni surga.',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 6306',
      ),
      DzikirItemModel(
        id: 'pagi_3',
        categoryId: 'pagi',
        name: 'Ashbahna wa Ashbahal Mulku Lillah',
        arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ ، وَالْحَمْدُ لِلَّهِ ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
        transliteration: 'Ashbahna wa ashbahal-mulku lillah, wal-hamdu lillah, la ilaha illallahu wahdahu la syarika lah',
        translation: 'Kami telah memasuki waktu pagi dan kerajaan hanya milik Allah, segala puji bagi Allah...',
        defaultTarget: 1,
        source: 'HR. Muslim no. 2723',
      ),
      DzikirItemModel(
        id: 'pagi_4',
        categoryId: 'pagi',
        name: 'Allahumma Bika Ashbahna',
        arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا ، وَبِكَ أَمْسَيْنَا ، وَبِكَ نَحْيَا ، وَبِكَ نَمُوتُ ، وَإِلَيْكَ النُّشُورُ',
        transliteration: 'Allahumma bika ashbahna, wa bika amsayna, wa bika nahya, wa bika namutu, wa ilaikan-nusyur',
        translation: 'Ya Allah, dengan rahmat-Mu kami memasuki waktu pagi, dengan rahmat-Mu kami memasuki waktu petang...',
        defaultTarget: 1,
        source: 'HR. Tirmidzi no. 3391',
      ),
      DzikirItemModel(
        id: 'pagi_5',
        categoryId: 'pagi',
        name: 'Doa Afiat Jiwa & Raga',
        arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي ، اللَّهُمَّ عَافِنِي فِي سَمْعِي ، اللَّهُمَّ عَافِنِي فِي بَصَرِي ، لَا إِلَهَ إِلَّا أَنْتَ',
        transliteration: 'Allahumma \'afini fi badani, Allahumma \'afini fi sam\'i, Allahumma \'afini fi bashari, la ilaha illa anta',
        translation: 'Ya Allah, selamatkanlah tubuhku, pendengaranku, dan penglihatanku dari penyakit dan maksiat (dibaca 3x).',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5090',
      ),
      DzikirItemModel(
        id: 'pagi_6',
        categoryId: 'pagi',
        name: 'Bismillahilladzi La Yadhurru',
        arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Bismillahilladzi la yadhurru ma\'asmihi syai-un fil-ardhi wa la fis-sama-i wa huwas-sami\'ul-\'alim',
        translation: 'Dengan menyebut nama Allah yang dengan nama-Nya tidak ada sesuatu pun di bumi dan di langit yang dapat mendatangkan bahaya (dibaca 3x).',
        defaultTarget: 3,
        source: 'HR. Tirmidzi no. 3388',
      ),
      DzikirItemModel(
        id: 'pagi_7',
        categoryId: 'pagi',
        name: 'Radhitu Billahi Rabba',
        arabic: 'رَضِيتُ بِاللَّهِ رَبًّا ، وَبِالْإِسْلَامِ دِينًا ، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
        transliteration: 'Radhitu billahi rabba, wa bil-islami dina, wa bi muhammadin shallallahu \'alaihi wa sallama nabiyya',
        translation: 'Aku ridha Allah sebagai Rabbku, Islam sebagai agamaku, dan Muhammad SAW sebagai Nabiku (dibaca 3x).',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5074',
      ),
      DzikirItemModel(
        id: 'pagi_8',
        categoryId: 'pagi',
        name: 'Ya Hayyu Ya Qayyum',
        arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ ، أَصْلِحْ لِي شَأْنِي كُلَّهُ ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
        transliteration: 'Ya Hayyu Ya Qayyum bi rahmatika astaghits, ashlih li sya\'ni kullahu wa la takilni ila nafsi tharfata \'ain',
        translation: 'Wahai Dzat Yang Mahahidup dan Maha Berdiri Sendiri, dengan rahmat-Mu aku memohon pertolongan...',
        defaultTarget: 1,
        source: 'HR. Al-Hakim (1/545)',
      ),
      DzikirItemModel(
        id: 'pagi_9',
        categoryId: 'pagi',
        name: 'Surat Al-Ikhlas, Al-Falaq, An-Nas (Pagi)',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Surat Al-Ikhlas, Al-Falaq, An-Nas (3 kali)',
        translation: 'Membaca 3 surat ini 3x di pagi hari mencukupi dari segala keburukan.',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5082 & Tirmidzi no. 3575',
      ),
      DzikirItemModel(
        id: 'pagi_10',
        categoryId: 'pagi',
        name: 'Subhanallahi wa Bihamdihi 100x',
        arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        transliteration: 'Subhanallahi wa bihamdihi',
        translation: 'Mahasuci Allah dan dengan memuji-Nya (100 kali).',
        defaultTarget: 100,
        source: 'HR. Muslim no. 2692',
      ),
    ];
  }

  List<DzikirItemModel> _getZikirPetangItems() {
    return [
      DzikirItemModel(
        id: 'petang_1',
        categoryId: 'petang',
        name: 'Ayat Kursi Petang',
        arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
        transliteration: 'Allahu la ilaha illa huwal-hayyul-qayyum...',
        translation: 'Perlindungan dari jin dan godaan malam hingga subuh.',
        defaultTarget: 1,
        source: 'HR. Al-Hakim (1/562)',
      ),
      DzikirItemModel(
        id: 'petang_2',
        categoryId: 'petang',
        name: 'Sayyidul Istighfar (Petang)',
        arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ...',
        transliteration: 'Allahumma anta rabbi la ilaha illa anta, khalaqtani wa ana \'abduka...',
        translation: 'Pemimpin istighfar menjelang malam.',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 6306',
      ),
      DzikirItemModel(
        id: 'petang_3',
        categoryId: 'petang',
        name: 'Amsayna wa Amsal Mulku Lillah',
        arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ ، وَالْحَمْدُ لِلَّهِ ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
        transliteration: 'Amsayna wa amsal-mulku lillah, wal-hamdu lillah, la ilaha illallah...',
        translation: 'Kami telah memasuki waktu petang dan kerajaan hanya milik Allah...',
        defaultTarget: 1,
        source: 'HR. Muslim no. 2723',
      ),
      DzikirItemModel(
        id: 'petang_4',
        categoryId: 'petang',
        name: 'Allahumma Bika Amsayna',
        arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا ، وَبِكَ أَصْبَحْنَا ، وَبِكَ نَحْيَا ، وَبِكَ نَمُوتُ ، وَإِلَيْكَ الْمَصِيرُ',
        transliteration: 'Allahumma bika amsayna, wa bika ashbahna, wa bika nahya, wa bika namutu, wa ilaikal-mashir',
        translation: 'Ya Allah, dengan rahmat-Mu kami memasuki waktu petang...',
        defaultTarget: 1,
        source: 'HR. Abu Dawud no. 5068',
      ),
      DzikirItemModel(
        id: 'petang_5',
        categoryId: 'petang',
        name: 'A\'udzu Bikalimatillahit Tammati',
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        transliteration: 'A\'udzu bikalimatillahit-tammati min syarri ma khalaq',
        translation: 'Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang Dia ciptakan (dibaca 3x).',
        defaultTarget: 3,
        source: 'HR. Muslim no. 2709',
        note: 'Tidak ada sengatan racun dan kejahatan yang membahayakannya di malam itu.',
      ),
      DzikirItemModel(
        id: 'petang_6',
        categoryId: 'petang',
        name: 'Bismillahilladzi La Yadhurru (Petang)',
        arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Bismillahilladzi la yadhurru ma\'asmihi syai-un fil-ardhi...',
        translation: 'Dibaca 3 kali di petang hari untuk perlindungan hingga pagi hari.',
        defaultTarget: 3,
        source: 'HR. Tirmidzi no. 3388',
      ),
      DzikirItemModel(
        id: 'petang_7',
        categoryId: 'petang',
        name: 'Radhitu Billahi Rabba (Petang)',
        arabic: 'رَضِيتُ بِاللَّهِ رَبًّا ، وَبِالْإِسْلَامِ دِينًا ، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
        transliteration: 'Radhitu billahi rabba, wa bil-islami dina...',
        translation: 'Pernyataan keridhaan atas tauhid dan risalah Nabi (3 kali).',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5074',
      ),
      DzikirItemModel(
        id: 'petang_8',
        categoryId: 'petang',
        name: 'Doa Perlindungan Jiwa Petang',
        arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي ، اللَّهُمَّ عَافِنِي فِي سَمْعِي ، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
        transliteration: 'Allahumma \'afini fi badani, Allahumma \'afini fi sam\'i, Allahumma \'afini fi bashari',
        translation: 'Memohon kesehatan jasmani dan rohani menjelang istirahat malam (3 kali).',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5090',
      ),
      DzikirItemModel(
        id: 'petang_9',
        categoryId: 'petang',
        name: 'Surat Tiga Qul (Petang)',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Surat Al-Ikhlas, Al-Falaq, An-Nas (3 kali)',
        translation: 'Benteng utama perlindungan diri sepanjang malam.',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5082',
      ),
      DzikirItemModel(
        id: 'petang_10',
        categoryId: 'petang',
        name: 'Astaghfirullah wa Atubu Ilaih',
        arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
        transliteration: 'Astaghfirullah wa atubu ilaih',
        translation: 'Aku memohon ampunan kepada Allah dan bertobat kepada-Nya (100 kali).',
        defaultTarget: 100,
        source: 'HR. Bukhari no. 6307 & HR. Muslim no. 2702',
      ),
    ];
  }

  List<DzikirItemModel> _getZikirTidurItems() {
    return [
      DzikirItemModel(
        id: 'tdr_1',
        categoryId: 'tidur',
        name: 'Bismika Allahumma Amutu wa Ahya',
        arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        transliteration: 'Bismika Allahumma amutu wa ahya',
        translation: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 6324',
      ),
      DzikirItemModel(
        id: 'tdr_2',
        categoryId: 'tidur',
        name: 'Bismika Rabbi Wadha\'tu Janbi',
        arabic: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي ، وَبِكَ أَرْفَعُهُ ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا ، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
        transliteration: 'Bismika Rabbi wadha\'tu janbi wa bika arfa\'uh...',
        translation: 'Dengan nama-Mu wahai Tuhanku, aku meletakkan lambungku...',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 6320 & Muslim no. 2714',
      ),
      DzikirItemModel(
        id: 'tdr_3',
        categoryId: 'tidur',
        name: 'Ayat Kursi Sebelum Tidur',
        arabic: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        transliteration: 'Allahu la ilaha illa huwal-hayyul-qayyum...',
        translation: 'Penjaga dari setan sepanjang malam hingga waktu fajar tiba.',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 2311',
      ),
      DzikirItemModel(
        id: 'tdr_4',
        categoryId: 'tidur',
        name: 'Dua Ayat Terakhir Al-Baqarah',
        arabic: 'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ...',
        transliteration: 'Amanar-rasulu bima unzila ilaihi mir-rabbihi wal-mu\'minun...',
        translation: 'Siapa membaca dua ayat terakhir Al-Baqarah di malam hari, maka itu mencukupinya.',
        defaultTarget: 1,
        source: 'HR. Bukhari no. 5009 & Muslim no. 808',
      ),
      DzikirItemModel(
        id: 'tdr_5',
        categoryId: 'tidur',
        name: 'Tasbih Fatimah: Subhanallah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Subhanallah',
        translation: 'Mahasuci Allah (33 kali sebelum tidur).',
        defaultTarget: 33,
        source: 'HR. Bukhari no. 3705',
      ),
      DzikirItemModel(
        id: 'tdr_6',
        categoryId: 'tidur',
        name: 'Tasbih Fatimah: Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        translation: 'Segala puji bagi Allah (33 kali sebelum tidur).',
        defaultTarget: 33,
        source: 'HR. Bukhari no. 3705',
      ),
      DzikirItemModel(
        id: 'tdr_7',
        categoryId: 'tidur',
        name: 'Tasbih Fatimah: Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        translation: 'Allah Mahabesar (34 kali sebelum tidur).',
        defaultTarget: 34,
        source: 'HR. Bukhari no. 3705',
      ),
      DzikirItemModel(
        id: 'tdr_8',
        categoryId: 'tidur',
        name: 'Doa Perlindungan Siksa Kubur',
        arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        transliteration: 'Allahumma qini \'adzabaka yawma tab\'atsu \'ibadak',
        translation: 'Ya Allah, lindungilah aku dari siksaan-Mu pada hari Engkau membangkitkan hamba-hamba-Mu (dibaca 3x sambil meletakkan tangan di bawah pipi kanan).',
        defaultTarget: 3,
        source: 'HR. Abu Dawud no. 5045',
      ),
      DzikirItemModel(
        id: 'tdr_9',
        categoryId: 'tidur',
        name: 'Tiga Qul Ditiup ke Tangan',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Al-Ikhlas, Al-Falaq, An-Nas ditiupkan ke kedua telapak tangan lalu diusapkan ke seluruh tubuh yang terjangkau (3x).',
        translation: 'Kebiasaan Nabi SAW sebelum tidur.',
        defaultTarget: 3,
        source: 'HR. Bukhari no. 5017',
      ),
    ];
  }

  List<DzikirItemModel> _getZikirPenyembuhItems() {
    return [
      DzikirItemModel(
        id: 'sembuh_1',
        categoryId: 'penyembuh',
        name: 'Surat Al-Fatihah (Asy-Syifa)',
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ... الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...',
        transliteration: 'Surat Al-Fatihah (1-7)',
        translation: 'Surat pembuka yang merupakan sebaik-baik ruqyah dan penawar penyakit.',
        defaultTarget: 7,
        source: 'HR. Bukhari no. 5736 & Muslim no. 2201',
      ),
      DzikirItemModel(
        id: 'sembuh_2',
        categoryId: 'penyembuh',
        name: 'Doa Penghilang Penyakit',
        arabic: 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا',
        transliteration: 'Allahumma Rabban-nasi adzhibil-ba\'sa isyfi antasy-syafi la syifa-a illa syifa-uka syifa-an la yughadiru saqama',
        translation: 'Ya Allah Rabb pemelihara manusia, hilangkanlah kesusahan ini dan sembuhkanlah...',
        defaultTarget: 3,
        source: 'HR. Bukhari no. 5743 & Muslim no. 2191',
      ),
      DzikirItemModel(
        id: 'sembuh_3',
        categoryId: 'penyembuh',
        name: 'Bismillah & Ta\'awwudz Sakit Fisik',
        arabic: 'بِسْمِ اللَّهِ (٣×) ، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (٧×)',
        transliteration: 'Bismillah (3x), A\'udzu billahi wa qudratihi min syarri ma ajidu wa uhadziru (7x)',
        translation: 'Letakkan tangan pada bagian yang sakit lalu ucapkan Bismillah 3x dan doa ini 7x.',
        defaultTarget: 7,
        source: 'HR. Muslim no. 2202',
      ),
      DzikirItemModel(
        id: 'sembuh_4',
        categoryId: 'penyembuh',
        name: 'Doa Menjenguk Orang Sakit',
        arabic: 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
        transliteration: 'As-alullahal-\'Adzima Rabbal-\'Arsyil-\'Adzimi an yasyfiyak',
        translation: 'Aku memohon kepada Allah Yang Mahaagung, Rabb Pemilik Arsy yang agung, agar menyembuhkanmu (7 kali).',
        defaultTarget: 7,
        source: 'HR. Abu Dawud no. 3106 & Tirmidzi no. 2083',
      ),
      DzikirItemModel(
        id: 'sembuh_5',
        categoryId: 'penyembuh',
        name: 'Doa Nabi Ayyub AS',
        arabic: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنْتَ أَرْحَمُ الرَّاحِمِينَ',
        transliteration: 'Anni massaniyad-dhurru wa anta arhamur-rahimin',
        translation: '(Ya Tuhanku), sungguh aku telah ditimpa penyakit, dan Engkaulah Yang Maha Penyayang di antara semua penyayang.',
        defaultTarget: 33,
        source: 'QS. Al-Anbiya: 83',
      ),
      DzikirItemModel(
        id: 'sembuh_6',
        categoryId: 'penyembuh',
        name: 'Doa Nabi Yunus AS (Pengentas Kesulitan)',
        arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
        transliteration: 'La ilaha illa anta subhanaka inni kuntu minazh-zhalimin',
        translation: 'Tidak ada doa yang dibaca orang muslim ketika tertimpa musibah melainkan Allah akan mengabulkannya.',
        defaultTarget: 33,
        source: 'QS. Al-Anbiya: 87 & HR. Tirmidzi no. 3505',
      ),
      DzikirItemModel(
        id: 'sembuh_7',
        categoryId: 'penyembuh',
        name: 'Hasbunallah wa Ni\'mal Wakil',
        arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        transliteration: 'Hasbunallahu wa ni\'mal-wakil',
        translation: 'Cukuplah Allah menjadi penolong kami dan Allah adalah sebaik-baik pelindung.',
        defaultTarget: 33,
        source: 'QS. Ali \'Imran: 173 & HR. Bukhari no. 4563',
      ),
      DzikirItemModel(
        id: 'sembuh_8',
        categoryId: 'penyembuh',
        name: 'La Hawla wa La Quwwata',
        arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
        transliteration: 'La hawla wa la quwwata illa billahil-\'aliyyil-\'adzim',
        translation: 'Obat dari 99 penyakit, yang paling ringannya adalah kegelisahan hati.',
        defaultTarget: 33,
        source: 'HR. Ath-Thabrani',
      ),
      DzikirItemModel(
        id: 'sembuh_9',
        categoryId: 'penyembuh',
        name: 'Sholawat Thibil Qulub',
        arabic: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ طِبِّ الْقُلُوبِ وَدَوَائِهَا ، وَعَافِيَةِ الْأَبْدَانِ وَشِفَائِهَا ، وَنُورِ الْأَبْصَارِ وَضِيَائِهَا',
        transliteration: 'Allahumma shalli \'ala sayyidina Muhammadin thibbil-qulubi wa dawa-iha, wa \'afiyatil-abdani wa syifa-iha...',
        translation: 'Sholawat penyejuk hati dan kesehatan jasmani.',
        defaultTarget: 10,
        source: 'Sholawat Ma\'tsurah para ulama salaf',
      ),
    ];
  }

  List<DzikirItemModel> _getZikirPerjalananItems() {
    return [
      DzikirItemModel(
        id: 'safar_1',
        categoryId: 'perjalanan',
        name: 'Doa Naik Kendaraan',
        arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ ، وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ',
        transliteration: 'Subhanalladzi sakh-khara lana hadza wa ma kunna lahu muqrinin, wa inna ila rabbina lamunqalibun',
        translation: 'Mahasuci Allah yang telah menundukkan semua ini bagi kami padahal kami sebelumnya tidak mampu menguasainya...',
        defaultTarget: 1,
        source: 'QS. Az-Zukhruf: 13-14 & HR. Muslim no. 1342',
      ),
      DzikirItemModel(
        id: 'safar_2',
        categoryId: 'perjalanan',
        name: 'Doa Memulai Safar',
        arabic: 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَٰذَا الْبِرَّ وَالتَّقْوَىٰ ، وَمِنَ الْعَمَلِ مَا تَرْضَىٰ...',
        transliteration: 'Allahumma inna nas-aluka fi safarina hadzal-birra wat-taqwa, wa minal-\'amali ma tardha...',
        translation: 'Ya Allah, kami memohon kepada-Mu kebaikan dan takwa dalam safar kami ini...',
        defaultTarget: 1,
        source: 'HR. Muslim no. 1342',
      ),
      DzikirItemModel(
        id: 'safar_3',
        categoryId: 'perjalanan',
        name: 'Doa Keluar Rumah',
        arabic: 'بِسْمِ اللَّهِ ، تَوَكَّلْتُ عَلَى اللَّهِ ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        transliteration: 'Bismillahi tawakkaltu \'alallah, la hawla wa la quwwata illa billah',
        translation: 'Dengan nama Allah, aku bertawakkal kepada Allah. Tiada daya dan kekuatan melainkan dengan pertolongan Allah.',
        defaultTarget: 1,
        source: 'HR. Abu Dawud no. 5095 & Tirmidzi no. 3426',
      ),
      DzikirItemModel(
        id: 'safar_4',
        categoryId: 'perjalanan',
        name: 'Takbir Saat Jalan Menanjak',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        translation: 'Sunnah bertakbir ketika menaiki jalan menanjak atau mendaki.',
        defaultTarget: 33,
        source: 'HR. Bukhari no. 2993',
      ),
      DzikirItemModel(
        id: 'safar_5',
        categoryId: 'perjalanan',
        name: 'Tasbih Saat Jalan Menurun',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Subhanallah',
        translation: 'Sunnah bertasbih ketika jalan menurun.',
        defaultTarget: 33,
        source: 'HR. Bukhari no. 2993',
      ),
      DzikirItemModel(
        id: 'safar_6',
        categoryId: 'perjalanan',
        name: 'Doa Singgah di Suatu Tempat',
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        transliteration: 'A\'udzu bikalimatillahit-tammati min syarri ma khalaq',
        translation: 'Siapa yang singgah di suatu tempat lalu membaca doa ini, tidak ada sesuatu pun yang membahayakannya sampai ia beranjak.',
        defaultTarget: 1,
        source: 'HR. Muslim no. 2708',
      ),
      DzikirItemModel(
        id: 'safar_7',
        categoryId: 'perjalanan',
        name: 'Doa Masuk Kota atau Desa Tujuan',
        arabic: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ ... أَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ وَخَيْرَ أَهْلِهَا',
        transliteration: 'Allahumma Rabbas-samawatis-sab\'i wa ma adhlalna... as-aluka khaira hadzihil-qaryati wa khaira ahliha',
        translation: 'Ya Allah, kami memohon kebaikan negeri ini, kebaikan penduduknya, dan kebaikan apa yang ada di dalamnya.',
        defaultTarget: 1,
        source: 'HR. An-Nasa\'i & Ibnu Hibban (Shahih)',
      ),
      DzikirItemModel(
        id: 'safar_8',
        categoryId: 'perjalanan',
        name: 'Doa Kembali dari Safar',
        arabic: 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
        transliteration: 'Ayibuna ta-ibuna \'abiduna li rabbina hamidun',
        translation: 'Kami kembali dengan bertobat, beribadah, dan senantiasa memuji Rabb kami.',
        defaultTarget: 3,
        source: 'HR. Muslim no. 1342',
      ),
      DzikirItemModel(
        id: 'safar_9',
        categoryId: 'perjalanan',
        name: 'Sholawat Keselamatan Safar',
        arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
        transliteration: 'Allahumma shalli \'ala Muhammad wa \'ala ali Muhammad',
        translation: 'Sholawat mendatangkan ketenangan dan keselamatan dari Allah SWT.',
        defaultTarget: 10,
        source: 'HR. Muslim no. 408',
      ),
    ];
  }
}
