import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/reading_progress.dart';
import '../models/surah_detail.dart';
import '../models/surah_item.dart';
import '../models/verse_read_state.dart';
import '../services/quran_service.dart';
import '../services/storage_service.dart';

class BacaQuranProvider extends ChangeNotifier {
  final StorageService _storageService;
  late final QuranService _quranService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final SurahItem surah;
  SurahDetail? _surahDetail;
  bool _isLoading = true;
  String? _errorMessage;

  // Reading progress state
  late ReadingProgress _progress;
  int _activeVerseNumber = 1;
  int? _initialScrollToAyah;

  // Bookmarks for this surah (ayah numbers)
  final Set<int> _bookmarkedAyahs = {};

  // Reader display settings
  late double _arabicFontSize;
  late double _translationFontSize;
  late bool _showTajwid;
  late bool _showTranslation;
  late String _readerTheme; // 'light', 'sepia', 'dark'
  late double _audioSpeed;

  // Audio player state
  int _currentAudioAyah = 1;
  bool _isPlayingAudio = false;
  bool _isRepeatAudio = false;
  bool _isAutoNextAudio = true;
  String _selectedQari = 'Misyari Rasyid';
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  final List<String> qariList = [
    'Misyari Rasyid',
    'Saad Al-Ghamdi',
    'Abdurrahman As-Sudais',
  ];

  BacaQuranProvider({
    required this.surah,
    required StorageService storageService,
    QuranService? quranService,
    int? initialAyah,
  })  : _storageService = storageService,
        _initialScrollToAyah = initialAyah {
    _quranService = quranService ?? QuranService(storageService);

    // Inisialisasi progress awal
    _progress = ReadingProgress.empty(
      surahId: surah.number,
      surahName: surah.nameLatin,
      totalAyahs: surah.numberOfAyahs,
    );

    _initSettings();
    _loadSavedProgress();
    _loadBookmarks();
    _initAudioListeners();
    loadAyahs();
  }

  // Getters
  SurahDetail? get surahDetail => _surahDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReadingProgress get progress => _progress;
  int get activeVerseNumber => _activeVerseNumber;
  int? get initialScrollToAyah => _initialScrollToAyah;

  Set<int> get bookmarkedAyahs => _bookmarkedAyahs;
  bool isBookmarked(int ayahNumber) => _bookmarkedAyahs.contains(ayahNumber);

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  bool get showTajwid => _showTajwid;
  bool get showTranslation => _showTranslation;
  String get readerTheme => _readerTheme;
  double get audioSpeed => _audioSpeed;

  int get currentAudioAyah => _currentAudioAyah;
  bool get isPlayingAudio => _isPlayingAudio;
  bool get isRepeatAudio => _isRepeatAudio;
  bool get isAutoNextAudio => _isAutoNextAudio;
  String get selectedQari => _selectedQari;
  Duration get audioPosition => _audioPosition;
  Duration get audioDuration => _audioDuration;

  void clearInitialScroll() {
    _initialScrollToAyah = null;
  }

  void _initSettings() {
    _arabicFontSize = _storageService.getArabicFontSize();
    _translationFontSize = _storageService.getTranslationFontSize();
    _showTajwid = _storageService.getShowTajwid();
    _showTranslation = _storageService.getShowTranslation();
    _readerTheme = _storageService.getReaderTheme();
    _audioSpeed = _storageService.getAudioSpeed();
  }

  void _loadSavedProgress() {
    final savedJson = _storageService.getReadingProgress(surah.number);
    if (savedJson != null) {
      try {
        final decoded = jsonDecode(savedJson) as Map<String, dynamic>;
        _progress = ReadingProgress.fromJson(decoded);
        if (_progress.lastReadVerse > 0) {
          _activeVerseNumber = _progress.lastReadVerse;
        }
      } catch (_) {}
    }
  }

  void _loadBookmarks() {
    final list = _storageService.getBookmarkedVerses();
    for (final item in list) {
      // Format: "surah_ayah" e.g. "2_5"
      final parts = item.split('_');
      if (parts.length == 2 && int.tryParse(parts[0]) == surah.number) {
        final ayah = int.tryParse(parts[1]);
        if (ayah != null) _bookmarkedAyahs.add(ayah);
      }
    }
  }

  VerseReadState getVerseState(int ayahNumber) {
    if (_progress.isRead(ayahNumber)) {
      return VerseReadState.read;
    }
    if (ayahNumber == _activeVerseNumber) {
      return VerseReadState.active;
    }
    return VerseReadState.unread;
  }

  /// Ambil ayat-ayat dari API Al-Qur'an resmi MyQuran
  Future<void> loadAyahs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detail = await _quranService.fetchSurahDetail(surah.number);
      if (detail != null && detail.ayahs.isNotEmpty) {
        _surahDetail = detail;
        // Update total ayahs if needed
        if (detail.ayahs.length != _progress.totalAyahs) {
          _progress = _progress.copyWith(totalAyahs: detail.ayahs.length);
        }
        _errorMessage = null;
      } else {
        _errorMessage = 'Gagal memuat ayat dari server Al-Qur\'an.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// INTERAKSI UTAMA:
  /// Tap ayat -> Tandai Selesai Dibaca (idempotent, no double count)
  /// Return next verse number for smooth scrolling
  int markVerseAsRead(int ayahNumber) {
    // 1 & 2. Ubah status menjadi read (idempotent)
    _progress = _progress.markRead(ayahNumber);

    // 3 & 4. Simpan ke storage
    _saveProgressToStorage();

    // 5. Update global recent reading untuk dashboard aplikasi
    _storageService.saveRecentReading(
      surahNumber: surah.number,
      surahName: surah.nameLatin,
      ayahNumber: ayahNumber,
      progress: _progress.progress,
    );

    // 6. Hitung ayat berikutnya untuk dijadikan active
    final total = _surahDetail?.ayahs.length ?? surah.numberOfAyahs;
    final nextAyah = (ayahNumber < total) ? ayahNumber + 1 : ayahNumber;
    _activeVerseNumber = nextAyah;

    notifyListeners();
    return nextAyah;
  }

  void setActiveVerse(int ayahNumber) {
    _activeVerseNumber = ayahNumber;
    notifyListeners();
  }

  Future<void> _saveProgressToStorage() async {
    try {
      final str = jsonEncode(_progress.toJson());
      await _storageService.saveReadingProgress(surah.number, str);
    } catch (_) {}
  }

  // ── BOOKMARK ──
  Future<void> toggleBookmark(int ayahNumber) async {
    if (_bookmarkedAyahs.contains(ayahNumber)) {
      _bookmarkedAyahs.remove(ayahNumber);
    } else {
      _bookmarkedAyahs.add(ayahNumber);
    }
    notifyListeners();

    // Persist to storage
    final allBookmarks = _storageService.getBookmarkedVerses().toSet();
    final key = '${surah.number}_$ayahNumber';
    if (_bookmarkedAyahs.contains(ayahNumber)) {
      allBookmarks.add(key);
    } else {
      allBookmarks.remove(key);
    }
    await _storageService.saveBookmarkedVerses(allBookmarks.toList());
  }

  // ── SETTINGS UPDATE METHODS ──
  void setArabicFontSize(double size) {
    _arabicFontSize = size;
    _storageService.setArabicFontSize(size);
    notifyListeners();
  }

  void setTranslationFontSize(double size) {
    _translationFontSize = size;
    _storageService.setTranslationFontSize(size);
    notifyListeners();
  }

  void setShowTajwid(bool show) {
    _showTajwid = show;
    _storageService.setShowTajwid(show);
    notifyListeners();
  }

  void setShowTranslation(bool show) {
    _showTranslation = show;
    _storageService.setShowTranslation(show);
    notifyListeners();
  }

  void setReaderTheme(String theme) {
    _readerTheme = theme;
    _storageService.setReaderTheme(theme);
    notifyListeners();
  }

  void setAudioSpeed(double speed) {
    _audioSpeed = speed;
    _storageService.setAudioSpeed(speed);
    _audioPlayer.setSpeed(speed);
    notifyListeners();
  }

  // ── AUDIO CONTROLS ──
  void _initAudioListeners() {
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      _isPlayingAudio = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
      notifyListeners();
    });

    _positionSub = _audioPlayer.positionStream.listen((pos) {
      _audioPosition = pos;
      notifyListeners();
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      _audioDuration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  /// Audio selesai TIDAK otomatis membuat ayat menjadi read!
  /// Hanya lanjut memutar ayat berikutnya jika auto-next aktif.
  void _onAudioCompleted() {
    if (_isRepeatAudio) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (_isAutoNextAudio) {
      final total = _surahDetail?.ayahs.length ?? surah.numberOfAyahs;
      if (_currentAudioAyah < total) {
        playAyahAudio(_currentAudioAyah + 1);
      } else {
        _isPlayingAudio = false;
        notifyListeners();
      }
    } else {
      _isPlayingAudio = false;
      notifyListeners();
    }
  }

  String _getAudioUrlForAyah(int ayahNum) {
    final s = surah.number.toString().padLeft(3, '0');
    final a = ayahNum.toString().padLeft(3, '0');

    // 1. Cek dari audioMap data API jika ada
    final ayahs = _surahDetail?.ayahs;
    if (ayahs != null && ayahNum > 0 && ayahNum <= ayahs.length) {
      final currentAyahData = ayahs[ayahNum - 1];
      final map = currentAyahData.audioMap;
      if (map != null && map.isNotEmpty) {
        if (_selectedQari == 'Misyari Rasyid' && map['05'] != null) return map['05']!;
        if (_selectedQari == 'Abdurrahman As-Sudais' && map['03'] != null) return map['03']!;
        if (_selectedQari == 'Abdullah Al-Juhany' && map['01'] != null) return map['01']!;
      }
      if (currentAyahData.audioUrl != null && currentAyahData.audioUrl!.isNotEmpty) {
        return currentAyahData.audioUrl!;
      }
    }

    // 2. Fallback ke CDN resmi
    switch (_selectedQari) {
      case 'Abdurrahman As-Sudais':
        return 'https://cdn.equran.id/audio-partial/Abdurrahman-as-Sudais/$s$a.mp3';
      case 'Saad Al-Ghamdi':
        return 'https://everyayah.com/data/Ghamadi_40kbps/$s$a.mp3';
      case 'Misyari Rasyid':
      default:
        return 'https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/$s$a.mp3';
    }
  }

  String _getBackupAudioUrl(int ayahNum) {
    final s = surah.number.toString().padLeft(3, '0');
    final a = ayahNum.toString().padLeft(3, '0');
    switch (_selectedQari) {
      case 'Abdurrahman As-Sudais':
        return 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/$s$a.mp3';
      case 'Saad Al-Ghamdi':
        return 'https://everyayah.com/data/Ghamadi_40kbps/$s$a.mp3';
      case 'Misyari Rasyid':
      default:
        return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
    }
  }

  Future<void> playAyahAudio(int ayahNum) async {
    _currentAudioAyah = ayahNum;
    final primaryUrl = _getAudioUrlForAyah(ayahNum);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(primaryUrl);
      await _audioPlayer.setSpeed(_audioSpeed);
      await _audioPlayer.play();
      _isPlayingAudio = true;
    } catch (_) {
      // Coba fallback URL jika CDN pertama kendala jaringan
      try {
        final backupUrl = _getBackupAudioUrl(ayahNum);
        await _audioPlayer.setUrl(backupUrl);
        await _audioPlayer.setSpeed(_audioSpeed);
        await _audioPlayer.play();
        _isPlayingAudio = true;
      } catch (_) {
        _isPlayingAudio = false;
      }
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
      _isPlayingAudio = false;
    } else {
      if (_audioPlayer.processingState == ProcessingState.idle) {
        await playAyahAudio(_currentAudioAyah);
      } else {
        await _audioPlayer.play();
        _isPlayingAudio = true;
      }
    }
    notifyListeners();
  }

  void nextAudio() {
    final total = _surahDetail?.ayahs.length ?? surah.numberOfAyahs;
    if (_currentAudioAyah < total) {
      playAyahAudio(_currentAudioAyah + 1);
    }
  }

  void previousAudio() {
    if (_currentAudioAyah > 1) {
      playAyahAudio(_currentAudioAyah - 1);
    }
  }

  void toggleRepeat() {
    _isRepeatAudio = !_isRepeatAudio;
    notifyListeners();
  }

  void toggleAutoNext() {
    _isAutoNextAudio = !_isAutoNextAudio;
    notifyListeners();
  }

  void selectQari(String qari) {
    _selectedQari = qari;
    notifyListeners();
    if (_isPlayingAudio) {
      playAyahAudio(_currentAudioAyah);
    }
  }

  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
