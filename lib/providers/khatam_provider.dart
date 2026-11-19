import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/khatam/khatam_plan_model.dart';
import '../models/surah_detail.dart';
import '../services/khatam_service.dart';
import '../services/khatam_reminder_service.dart';
import '../services/quran_service.dart';
import 'habit_provider.dart';
import 'prayer_time_provider.dart';

/// Kelompok surah dalam satu Juz
class JuzSurahGroup {
  final int surahNumber;
  final String surahNameLatin;
  final String surahNameArabic;
  final String surahTranslation;
  final int totalAyahsInJuz;
  final List<JuzAyahEntry> ayahs;

  JuzSurahGroup({
    required this.surahNumber,
    required this.surahNameLatin,
    required this.surahNameArabic,
    required this.surahTranslation,
    required this.totalAyahsInJuz,
    required this.ayahs,
  });
}

/// Item ayat lengkap dengan konteks surah dan urutan dalam Juz
class JuzAyahEntry {
  final int surahNumber;
  final String surahNameLatin;
  final SurahAyah ayah;
  final int globalIndexInJuz;

  JuzAyahEntry({
    required this.surahNumber,
    required this.surahNameLatin,
    required this.ayah,
    required this.globalIndexInJuz,
  });

  String get uniqueKey => '$surahNumber:${ayah.ayahNumber}';
}

class KhatamProvider extends ChangeNotifier {
  final KhatamService _khatamService;
  final QuranService _quranService;
  final KhatamReminderService _reminderService;

  HabitProvider? _habitProvider;
  PrayerTimeProvider? _prayerProvider;

  KhatamPlanModel? _activePlan;
  bool _isLoading = true;

  // State Membaca Juz
  int _viewingJuz = 1;
  List<JuzSurahGroup> _currentJuzGroups = [];
  List<JuzAyahEntry> _flattenedAyahs = [];
  bool _isLoadingAyahs = false;
  int _currentAyahIndex = 0;

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  String? _playingAyahKey; // format: 'surah:ayah'

  KhatamProvider({
    KhatamService? khatamService,
    QuranService? quranService,
    KhatamReminderService? reminderService,
  })  : _khatamService = khatamService ?? KhatamService(),
        _quranService = quranService ?? QuranService(),
        _reminderService = reminderService ?? KhatamReminderService() {
    init();
  }

  void updateDependencies(HabitProvider habitProv, PrayerTimeProvider prayerProv) {
    _habitProvider = habitProv;
    _prayerProvider = prayerProv;
    _syncReminders();
  }

  bool get isLoading => _isLoading;
  bool get hasActivePlan => _activePlan != null && _activePlan!.status == 'active';
  KhatamPlanModel? get activePlan => _activePlan;

  int get viewingJuz => _viewingJuz;
  List<JuzSurahGroup> get currentJuzGroups => _currentJuzGroups;
  List<JuzAyahEntry> get flattenedAyahs => _flattenedAyahs;
  bool get isLoadingAyahs => _isLoadingAyahs;
  int get currentAyahIndex => _currentAyahIndex;

  bool get isPlayingAudio => _isPlayingAudio;
  String? get playingAyahKey => _playingAyahKey;

  /// Jumlah ayat yang sudah dibaca dalam Juz yang sedang dibuka
  int get readCountInViewingJuz {
    if (_activePlan == null) return 0;
    int count = 0;
    for (final entry in _flattenedAyahs) {
      if (_activePlan!.readAyahKeys.contains(entry.uniqueKey)) {
        count++;
      }
    }
    return count;
  }

  /// Total ayat dalam Juz yang sedang dibuka
  int get totalAyahsInViewingJuz => _flattenedAyahs.length;

  /// Persentase progres Juz yang sedang dibuka (0.0 .. 1.0)
  double get viewingJuzProgressRatio =>
      totalAyahsInViewingJuz > 0 ? (readCountInViewingJuz / totalAyahsInViewingJuz).clamp(0.0, 1.0) : 0.0;

  /// Persentase progres Juz dalam angka bulat (0 .. 100)
  int get viewingJuzProgressPercent => (viewingJuzProgressRatio * 100).round();

  /// Inisialisasi data khatam dari penyimpanan lokal
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _activePlan = await _khatamService.getActivePlan();
    if (_activePlan != null) {
      _viewingJuz = _activePlan!.currentJuz;
    }

    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing && state.processingState != ProcessingState.completed;
      if (_isPlayingAudio != playing) {
        _isPlayingAudio = playing;
        notifyListeners();
      }
      if (state.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });

    _isLoading = false;
    notifyListeners();

    if (_activePlan != null) {
      loadAyahsForJuz(_viewingJuz);
    }
  }

  /// Membuat atau memperbarui Rencana Khatam
  Future<void> startOrUpdatePlan({
    required DateTime startDate,
    required int targetDuration,
    required int targetQuantity,
    required String targetUnit,
    required String targetPeriod,
    required bool reminderMaghrib,
    required bool reminderFajr,
  }) async {
    final dailyJuz = _khatamService.calculateDailyJuzTarget(
      quantity: targetQuantity,
      unit: targetUnit,
      period: targetPeriod,
    );

    final plan = KhatamPlanModel(
      planId: _activePlan?.planId ?? 'plan_${DateTime.now().millisecondsSinceEpoch}',
      startDate: startDate,
      targetDuration: targetDuration,
      targetQuantity: targetQuantity,
      targetUnit: targetUnit,
      targetPeriod: targetPeriod,
      dailyJuzTarget: dailyJuz,
      currentJuz: _activePlan?.currentJuz ?? 1,
      currentSurah: _activePlan?.currentSurah ?? 1,
      currentAyah: _activePlan?.currentAyah ?? 1,
      progressPercentage: _activePlan?.progressPercentage ?? 0.0,
      completedJuzList: _activePlan?.completedJuzList ?? <int>{},
      readAyahKeys: _activePlan?.readAyahKeys ?? <String>{},
      reminderMaghrib: reminderMaghrib,
      reminderFajr: reminderFajr,
    );

    _activePlan = plan;
    await _khatamService.savePlan(plan);
    _syncReminders();
    notifyListeners();

    loadAyahsForJuz(plan.currentJuz);
  }

  // In-memory cache agar surah yang sudah pernah diunduh terbuka instan tanpa delay
  static final Map<int, SurahDetail> _surahMemoryCache = {};

  /// Memuat ayat-ayat resmi dari API untuk Juz tertentu, dikelompokkan per surah secara cepat
  Future<void> loadAyahsForJuz(int juzNumber) async {
    _viewingJuz = juzNumber.clamp(1, 30);
    _isLoadingAyahs = true;
    _currentJuzGroups = [];
    _flattenedAyahs = [];
    notifyListeners();

    try {
      final meta = JuzMetadata.getByJuzNumber(_viewingJuz);
      final List<JuzSurahGroup> groups = [];
      final List<JuzAyahEntry> flat = [];
      int globalIdx = 0;

      // 1. Ambil detail semua surah yang terlibat secara paralel / dari cache
      final surahNumbers = <int>[];
      for (int s = meta.startSurah; s <= meta.endSurah; s++) {
        surahNumbers.add(s);
      }

      final surahDetails = await Future.wait(
        surahNumbers.map((s) async {
          if (_surahMemoryCache.containsKey(s)) {
            return _surahMemoryCache[s]!;
          }
          final d = await _quranService.fetchSurahDetail(s);
          if (d != null) {
            _surahMemoryCache[s] = d;
          }
          return d;
        }),
      );

      // 2. Ekstrak ayat-ayat sesuai batas Juz
      for (final detail in surahDetails) {
        if (detail != null && detail.ayahs.isNotEmpty) {
          final s = detail.number;
          final List<JuzAyahEntry> surahAyahs = [];

          for (final ayah in detail.ayahs) {
            bool inRange = true;
            if (s == meta.startSurah && ayah.ayahNumber < meta.startAyah) {
              inRange = false;
            }
            if (s == meta.endSurah && ayah.ayahNumber > meta.endAyah) {
              inRange = false;
            }

            if (inRange) {
              final entry = JuzAyahEntry(
                surahNumber: detail.number,
                surahNameLatin: detail.nameLatin,
                ayah: ayah,
                globalIndexInJuz: globalIdx++,
              );
              surahAyahs.add(entry);
              flat.add(entry);
            }
          }

          if (surahAyahs.isNotEmpty) {
            groups.add(JuzSurahGroup(
              surahNumber: detail.number,
              surahNameLatin: detail.nameLatin,
              surahNameArabic: detail.nameArabic,
              surahTranslation: detail.translation,
              totalAyahsInJuz: surahAyahs.length,
              ayahs: surahAyahs,
            ));
          }
        }
      }

      _currentJuzGroups = groups;
      _flattenedAyahs = flat;

      // Temukan index ayat terakhir yang tersimpan untuk Juz ini
      if (_activePlan != null && _flattenedAyahs.isNotEmpty) {
        final idx = _flattenedAyahs.indexWhere(
          (e) => e.surahNumber == _activePlan!.currentSurah && e.ayah.ayahNumber == _activePlan!.currentAyah,
        );
        _currentAyahIndex = idx != -1 ? idx : 0;
      }
    } catch (e) {
      debugPrint('Error loading ayahs for juz $_viewingJuz: $e');
    }

    _isLoadingAyahs = false;
    notifyListeners();
  }

  /// Menandai satu ayat sebagai telah dibaca
  Future<void> markAyahRead(JuzAyahEntry entry) async {
    // Jika belum ada plan, buat plan default otomatis
    if (_activePlan == null) {
      _activePlan = KhatamPlanModel(
        planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
        startDate: DateTime.now(),
        targetDuration: 30,
        dailyJuzTarget: 1.0,
        currentJuz: _viewingJuz,
        currentSurah: entry.surahNumber,
        currentAyah: entry.ayah.ayahNumber,
      );
    }

    final key = entry.uniqueKey;
    final updatedKeys = Set<String>.from(_activePlan!.readAyahKeys)..add(key);

    // Hitung jumlah ayat yang sudah dibaca di Juz ini
    int readInThisJuz = 0;
    for (final a in _flattenedAyahs) {
      if (updatedKeys.contains(a.uniqueKey)) {
        readInThisJuz++;
      }
    }

    final updatedCompletedJuz = Set<int>.from(_activePlan!.completedJuzList);
    // Jika semua ayat dalam Juz ini sudah dibaca, tandai Juz selesai
    if (readInThisJuz >= _flattenedAyahs.length && _flattenedAyahs.isNotEmpty) {
      updatedCompletedJuz.add(_viewingJuz);
    }

    // Hitung total progres 30 Juz
    final totalJuzFinished = updatedCompletedJuz.length;
    final double juzPart = _flattenedAyahs.isNotEmpty
        ? (readInThisJuz / _flattenedAyahs.length)
        : 0.0;
    final totalProgress = ((totalJuzFinished + (updatedCompletedJuz.contains(_viewingJuz) ? 0 : juzPart)) / 30.0 * 100)
        .clamp(0.0, 100.0);

    final updatedPlan = _activePlan!.copyWith(
      currentJuz: _viewingJuz,
      currentSurah: entry.surahNumber,
      currentAyah: entry.ayah.ayahNumber,
      progressPercentage: totalProgress,
      readAyahKeys: updatedKeys,
      completedJuzList: updatedCompletedJuz,
    );

    _activePlan = updatedPlan;
    await _khatamService.savePlan(updatedPlan);

    // ── INTEGRASI DENGAN HABIT MUSLIM HABBIT ──
    // Habit tilawah selesai jika progres harian terpenuhi
    if (_habitProvider != null) {
      _habitProvider!.markFeatureHabitCompleted('tilawah');
    }

    notifyListeners();
  }

  /// Pindah ke Ayat Berikutnya
  void nextAyah() {
    if (_currentAyahIndex < _flattenedAyahs.length - 1) {
      _currentAyahIndex++;
      markAyahRead(_flattenedAyahs[_currentAyahIndex]);
      notifyListeners();
    } else {
      // Jika di akhir Juz, lanjut ke Juz berikutnya jika ada
      if (_viewingJuz < 30) {
        loadAyahsForJuz(_viewingJuz + 1);
      }
    }
  }

  /// Pindah ke Ayat Sebelumnya
  void previousAyah() {
    if (_currentAyahIndex > 0) {
      _currentAyahIndex--;
      notifyListeners();
    } else {
      if (_viewingJuz > 1) {
        loadAyahsForJuz(_viewingJuz - 1);
      }
    }
  }

  /// Pindah ke Juz Sebelumnya
  void previousJuz() {
    if (_viewingJuz > 1) {
      stopAudio();
      loadAyahsForJuz(_viewingJuz - 1);
    }
  }

  /// Pindah ke Juz Selanjutnya
  void nextJuz() {
    if (_viewingJuz < 30) {
      stopAudio();
      loadAyahsForJuz(_viewingJuz + 1);
    }
  }

  /// Toggle Audio Play / Pause untuk Ayat
  Future<void> toggleAudio(JuzAyahEntry? entry) async {
    final target = entry ?? (_flattenedAyahs.isNotEmpty && _currentAyahIndex < _flattenedAyahs.length
        ? _flattenedAyahs[_currentAyahIndex]
        : null);

    if (target == null || target.ayah.audioUrl == null) return;

    final targetKey = target.uniqueKey;

    if (_isPlayingAudio && _playingAyahKey == targetKey) {
      await _audioPlayer.pause();
      _isPlayingAudio = false;
    } else {
      try {
        _playingAyahKey = targetKey;
        _currentAyahIndex = target.globalIndexInJuz;
        await _audioPlayer.setUrl(target.ayah.audioUrl!);
        await _audioPlayer.play();
        _isPlayingAudio = true;
      } catch (e) {
        debugPrint('Error playing Quran audio: $e');
      }
    }
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _playingAyahKey = null;
    _isPlayingAudio = false;
    notifyListeners();
  }

  void _onAudioCompleted() {
    // Mode putar otomatis: lanjut ke ayat berikutnya secara berurutan
    if (_currentAyahIndex < _flattenedAyahs.length - 1) {
      nextAyah();
      final next = _flattenedAyahs[_currentAyahIndex];
      toggleAudio(next);
    } else {
      stopAudio();
    }
  }

  void _syncReminders() {
    if (_activePlan == null || _prayerProvider == null) return;

    final maghrib = _prayerProvider!.schedule.maghrib;
    final subuh = _prayerProvider!.schedule.subuh;

    if (_activePlan!.reminderMaghrib && maghrib.isNotEmpty) {
      _reminderService.scheduleMaghribReminder(
        maghribTimeStr: maghrib,
        currentJuz: _activePlan!.currentJuz,
      );
    } else {
      _reminderService.cancelMaghribReminder();
    }

    if (_activePlan!.reminderFajr && subuh.isNotEmpty) {
      _reminderService.scheduleFajrReminder(
        subuhTimeStr: subuh,
        currentJuz: _activePlan!.currentJuz,
      );
    } else {
      _reminderService.cancelFajrReminder();
    }
  }

  Future<void> endPlan() async {
    await stopAudio();
    await _khatamService.clearActivePlan();
    await _reminderService.cancelAll();
    _activePlan = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
