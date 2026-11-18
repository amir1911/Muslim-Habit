import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/utils/tajwid_engine.dart';
import '../../models/surah_item.dart';
import '../../models/surah_detail.dart';
import '../../services/quran_service.dart';
import 'widgets/surah_picker_sheet.dart';
import 'widgets/ayah_picker_sheet.dart';

enum PracticeMode { perAyat, perSurah }

enum RecordingState { idle, listening, processing, done }

class PendeteksiBacaanScreen extends StatefulWidget {
  final int initialSurahNumber;
  final int initialAyahNumber;

  const PendeteksiBacaanScreen({
    super.key,
    this.initialSurahNumber = 1,
    this.initialAyahNumber = 1,
  });

  @override
  State<PendeteksiBacaanScreen> createState() => _PendeteksiBacaanScreenState();
}

class _PendeteksiBacaanScreenState extends State<PendeteksiBacaanScreen>
    with TickerProviderStateMixin {
  // ── Services ──────────────────────────────────────────
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // ── Mode State ─────────────────────────────────────────
  PracticeMode _mode = PracticeMode.perAyat;

  // ── Surah & Ayah Data ──────────────────────────────────
  int _currentSurahNumber = 1;
  int _currentAyahNumber = 1;
  SurahItem? _currentSurahItem;
  SurahDetail? _currentSurahDetail;
  bool _isLoadingSurah = true;
  String? _errorMessage;

  // ── Speech Recording State ─────────────────────────────
  RecordingState _recordingState = RecordingState.idle;
  bool _speechInitialized = false;
  String _currentLocaleId = 'ar_SA';
  String _liveTranscription = '';

  // ── Per Ayat Analysis State ────────────────────────────
  TajwidAnalysisResult? _currentAnalysis;
  bool _isPlayingAudio = false;

  // ── Per Surah State ────────────────────────────────────
  bool _isAutoplayActive = false;
  int _autoplayAyahIndex = 0;
  final Map<int, TajwidAnalysisResult> _surahPerAyahResults = {};
  final ScrollController _surahScrollController = ScrollController();
  StreamSubscription<PlayerState>? _playerStateSub;

  // ── Wave Animation ─────────────────────────────────────
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _currentSurahNumber = widget.initialSurahNumber;
    _currentAyahNumber = widget.initialAyahNumber;

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _initSpeech();
    _initAudioListeners();
    _loadSurahData(_currentSurahNumber, initialAyah: _currentAyahNumber);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _audioPlayer.dispose();
    _playerStateSub?.cancel();
    _surahScrollController.dispose();
    super.dispose();
  }

  // ── Audio Listeners ────────────────────────────────────
  void _initAudioListeners() {
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        if (_mode == PracticeMode.perSurah && _isAutoplayActive) {
          _advanceAutoplay();
        } else {
          setState(() => _isPlayingAudio = false);
        }
      }
    });
  }

  // ── Speech Recognizer Init ─────────────────────────────
  Future<void> _initSpeech() async {
    try {
      _speechInitialized = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            if (_recordingState == RecordingState.listening) {
              _finishRecording();
            }
          }
        },
        onError: (err) {
          if (!mounted) return;
          if (_recordingState == RecordingState.listening) {
            _finishRecording();
          }
        },
      );

      if (_speechInitialized) {
        final locales = await _speech.locales();
        final hasArabic = locales.any((l) => l.localeId.startsWith('ar'));
        if (hasArabic) {
          final arLocale = locales.firstWhere(
            (l) => l.localeId == 'ar_SA' || l.localeId.startsWith('ar'),
          );
          _currentLocaleId = arLocale.localeId;
        }
      }
    } catch (_) {
      _speechInitialized = false;
    }
  }

  // ── Load Surah Data From API ───────────────────────────
  Future<void> _loadSurahData(int surahNumber, {int? initialAyah}) async {
    setState(() {
      _isLoadingSurah = true;
      _errorMessage = null;
      _isPlayingAudio = false;
      _isAutoplayActive = false;
    });

    try {
      await _audioPlayer.stop();

      final surahList = await _quranService.fetchSurahList();
      final surahItem = surahList.firstWhere(
        (s) => s.number == surahNumber,
        orElse: () => surahList.isNotEmpty ? surahList.first : SurahItem.fallbackSurahList.first,
      );

      final detail = await _quranService.fetchSurahDetail(surahNumber);
      if (!mounted) return;

      if (detail == null || detail.ayahs.isEmpty) {
        setState(() {
          _errorMessage = 'Gagal memuat ayat Al-Qur\'an dari API. Periksa koneksi internet.';
          _isLoadingSurah = false;
        });
        return;
      }

      final targetAyah = initialAyah != null && initialAyah <= detail.ayahs.length
          ? initialAyah
          : 1;

      setState(() {
        _currentSurahNumber = surahNumber;
        _currentSurahItem = surahItem;
        _currentSurahDetail = detail;
        _currentAyahNumber = targetAyah;
        _isLoadingSurah = false;
        _recordingState = RecordingState.idle;
        _liveTranscription = '';
        _currentAnalysis = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
        _isLoadingSurah = false;
      });
    }
  }

  SurahAyah? get _activeAyah {
    if (_currentSurahDetail == null || _currentSurahDetail!.ayahs.isEmpty) return null;
    final idx = _currentAyahNumber - 1;
    if (idx >= 0 && idx < _currentSurahDetail!.ayahs.length) {
      return _currentSurahDetail!.ayahs[idx];
    }
    return _currentSurahDetail!.ayahs.first;
  }

  // ── Audio Playback ─────────────────────────────────────
  Future<void> _togglePlayCurrentAyah() async {
    final ayah = _activeAyah;
    if (ayah == null) return;

    if (_isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() => _isPlayingAudio = false);
      return;
    }

    final url = ayah.audioUrl;
    if (url == null || url.isEmpty) {
      _showToast('Audio untuk ayat ini tidak tersedia');
      return;
    }

    try {
      setState(() => _isPlayingAudio = true);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
        _showToast('Gagal memutar audio: $e');
      }
    }
  }

  // ── Autoplay Per Surah ─────────────────────────────────
  Future<void> _startAutoplay() async {
    if (_currentSurahDetail == null || _currentSurahDetail!.ayahs.isEmpty) return;

    if (_isAutoplayActive) {
      await _audioPlayer.stop();
      setState(() {
        _isAutoplayActive = false;
        _isPlayingAudio = false;
      });
      return;
    }

    setState(() {
      _isAutoplayActive = true;
      _autoplayAyahIndex = 0;
    });

    _playAutoplayAyah(_autoplayAyahIndex);
  }

  Future<void> _playAutoplayAyah(int index) async {
    if (!_isAutoplayActive || _currentSurahDetail == null) return;
    if (index >= _currentSurahDetail!.ayahs.length) {
      setState(() {
        _isAutoplayActive = false;
        _isPlayingAudio = false;
      });
      return;
    }

    final ayah = _currentSurahDetail!.ayahs[index];
    final url = ayah.audioUrl;
    if (url == null || url.isEmpty) {
      _advanceAutoplay();
      return;
    }

    try {
      setState(() {
        _autoplayAyahIndex = index;
        _isPlayingAudio = true;
      });

      _scrollToAyah(index);

      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {
      _advanceAutoplay();
    }
  }

  void _advanceAutoplay() {
    if (!_isAutoplayActive || _currentSurahDetail == null) return;
    final nextIdx = _autoplayAyahIndex + 1;
    if (nextIdx < _currentSurahDetail!.ayahs.length) {
      _playAutoplayAyah(nextIdx);
    } else {
      setState(() {
        _isAutoplayActive = false;
        _isPlayingAudio = false;
      });
    }
  }

  void _scrollToAyah(int index) {
    if (_surahScrollController.hasClients) {
      final targetOffset = index * 180.0;
      _surahScrollController.animateTo(
        targetOffset.clamp(0.0, _surahScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Recording Process ──────────────────────────────────
  Future<void> _toggleRecording({int? specificAyahNumber}) async {
    if (_recordingState == RecordingState.listening) {
      await _speech.stop();
      _finishRecording();
      return;
    }

    if (!_speechInitialized) {
      await _initSpeech();
      if (!_speechInitialized) {
        _showMicPermissionDialog();
        return;
      }
    }

    // Hentikan audio murottal jika sedang menyala
    if (_isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() => _isPlayingAudio = false);
    }

    if (specificAyahNumber != null && specificAyahNumber != _currentAyahNumber) {
      setState(() => _currentAyahNumber = specificAyahNumber);
    }

    setState(() {
      _recordingState = RecordingState.listening;
      _liveTranscription = '';
      _currentAnalysis = null;
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _liveTranscription = result.recognizedWords;
          });
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: _currentLocaleId,
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 4),
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (_) {
      _finishRecording();
    }
  }

  void _finishRecording() {
    if (!mounted) return;

    setState(() {
      _recordingState = RecordingState.processing;
    });

    // Jalankan analisis bacaan
    final ayah = _activeAyah;
    if (ayah != null) {
      final result = TajwidEngine.analyzeRecitation(
        arabicVerse: ayah.arabicText,
        transcribedText: _liveTranscription,
      );

      setState(() {
        _currentAnalysis = result;
        _recordingState = RecordingState.done;
        if (_mode == PracticeMode.perSurah) {
          _surahPerAyahResults[ayah.ayahNumber] = result;
        }
      });
    } else {
      setState(() {
        _recordingState = RecordingState.idle;
      });
    }
  }

  void _repeatCurrentAyah() {
    setState(() {
      _recordingState = RecordingState.idle;
      _liveTranscription = '';
      _currentAnalysis = null;
    });
  }

  void _goToPreviousAyah() {
    if (_currentAyahNumber > 1) {
      _audioPlayer.stop();
      setState(() {
        _currentAyahNumber--;
        _recordingState = RecordingState.idle;
        _liveTranscription = '';
        _currentAnalysis = null;
        _isPlayingAudio = false;
      });
    }
  }

  void _goToNextAyah() {
    if (_currentSurahDetail != null && _currentAyahNumber < _currentSurahDetail!.ayahs.length) {
      _audioPlayer.stop();
      setState(() {
        _currentAyahNumber++;
        _recordingState = RecordingState.idle;
        _liveTranscription = '';
        _currentAnalysis = null;
        _isPlayingAudio = false;
      });
    }
  }

  // ── Dialogs & Pickers ──────────────────────────────────
  Future<void> _openSurahPicker() async {
    final selected = await SurahPickerSheet.show(
      context,
      selectedSurahNumber: _currentSurahNumber,
    );

    if (selected != null && selected.number != _currentSurahNumber) {
      _loadSurahData(selected.number, initialAyah: 1);
    }
  }

  Future<void> _openAyahPicker() async {
    if (_currentSurahDetail == null) return;

    final selected = await AyahPickerSheet.show(
      context,
      surahNumber: _currentSurahNumber,
      surahName: _currentSurahItem?.nameLatin ?? 'Surah',
      totalAyahs: _currentSurahDetail!.ayahs.length,
      selectedAyahNumber: _currentAyahNumber,
    );

    if (selected != null && selected != _currentAyahNumber) {
      _audioPlayer.stop();
      setState(() {
        _currentAyahNumber = selected;
        _recordingState = RecordingState.idle;
        _liveTranscription = '';
        _currentAnalysis = null;
        _isPlayingAudio = false;
      });
    }
  }

  void _showMicPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mic_off_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 10),
            Text('Izin Mikrofon', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Aplikasi membutuhkan izin akses mikrofon untuk mendengarkan bacaan Al-Qur\'an Anda secara langsung.\n\nSilakan izinkan mikrofon melalui pengaturan aplikasi Android.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initSpeech();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── BUILD UI ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _mode == PracticeMode.perAyat ? _buildPerAyatBottomNav() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4A7C59),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Pendeteksi Bacaan & Tajwid',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          tooltip: 'Panduan Tajwid',
          onPressed: _showTajwidGuideDialog,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: const Color(0xFF4A7C59),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_mode != PracticeMode.perAyat) {
                        _audioPlayer.stop();
                        setState(() {
                          _mode = PracticeMode.perAyat;
                          _isAutoplayActive = false;
                          _isPlayingAudio = false;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _mode == PracticeMode.perAyat ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Mode Per Ayat',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _mode == PracticeMode.perAyat ? const Color(0xFF2E7D32) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_mode != PracticeMode.perSurah) {
                        _audioPlayer.stop();
                        setState(() {
                          _mode = PracticeMode.perSurah;
                          _isAutoplayActive = false;
                          _isPlayingAudio = false;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _mode == PracticeMode.perSurah ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Mode Per Surah',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _mode == PracticeMode.perSurah ? const Color(0xFF2E7D32) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingSurah) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF4A7C59)),
            SizedBox(height: 16),
            Text('Mengambil data ayat dari API Al-Qur\'an...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadSurahData(_currentSurahNumber),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _mode == PracticeMode.perAyat ? _buildPerAyatView() : _buildPerSurahView();
  }

  // ══════════════════════════════════════════════════════════
  // MODE 1: PER AYAT VIEW
  // ══════════════════════════════════════════════════════════
  Widget _buildPerAyatView() {
    final ayah = _activeAyah;
    if (ayah == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector Bar (Pilih Surah & Pilih Ayat)
          _buildSelectorHeader(),

          const SizedBox(height: 14),

          // Card Ayat Utama
          _buildAyahCard(ayah),

          const SizedBox(height: 20),

          // Tombol Perekaman & Live Feedback
          _buildRecordingSection(),

          const SizedBox(height: 20),

          // Hasil Analisis Dinamis (Jika Ada)
          if (_currentAnalysis != null) _buildAnalysisResultsSection(_currentAnalysis!),
        ],
      ),
    );
  }

  Widget _buildSelectorHeader() {
    final surah = _currentSurahItem;
    final totalAyahs = _currentSurahDetail?.ayahs.length ?? 7;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pilih Surah
          Expanded(
            child: InkWell(
              onTap: _openSurahPicker,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2E7D32), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah?.nameLatin ?? 'Pilih Surah',
                            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${surah?.revelation ?? ''} • $totalAyahs Ayat',
                            style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          Container(height: 30, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 8)),

          // Pilih Ayat
          InkWell(
            onTap: _openAyahPicker,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'Ayat $_currentAyahNumber',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCard(SurahAyah ayah) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ayat & Action Audio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ayat ${ayah.ayahNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
              Row(
                children: [
                  // Dengarkan Contoh Murottal
                  OutlinedButton.icon(
                    onPressed: _togglePlayCurrentAyah,
                    icon: Icon(
                      _isPlayingAudio ? Icons.pause_rounded : Icons.volume_up_rounded,
                      size: 16,
                      color: const Color(0xFF2E7D32),
                    ),
                    label: Text(
                      _isPlayingAudio ? 'Jeda' : 'Dengarkan Contoh',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFFC8E6C9)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Teks Arab Utsmani Lengkap dengan Highlight
          _buildArabicHighlightedText(ayah.arabicText),

          const SizedBox(height: 14),

          // Transliterasi Latin
          if (ayah.latinText.isNotEmpty) ...[
            Text(
              ayah.latinText,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF334155),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Terjemahan Bahasa Indonesia
          Text(
            ayah.translation,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.grey.shade700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArabicHighlightedText(String fullArabic) {
    // Jika belum ada hasil analisis, tampilkan teks Arab Utsmani default
    if (_currentAnalysis == null || _currentAnalysis!.words.isEmpty) {
      return Text(
        fullArabic,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
          height: 1.9,
        ),
      );
    }

    // Jika sudah ada analisis, highlight per kata
    final words = _currentAnalysis!.words;

    return Wrap(
      alignment: WrapAlignment.end,
      textDirection: TextDirection.rtl,
      spacing: 6,
      runSpacing: 10,
      children: words.map((w) {
        Color bgColor;
        Color textColor;
        Border? border;

        switch (w.status) {
          case WordRecitationStatus.correct:
            bgColor = const Color(0xFFE8F5E9);
            textColor = const Color(0xFF1B5E20);
            border = Border.all(color: const Color(0xFFA5D6A7));
            break;
          case WordRecitationStatus.needsAttention:
            bgColor = const Color(0xFFFFF3E0);
            textColor = const Color(0xFFE65100);
            border = Border.all(color: const Color(0xFFFFCC80));
            break;
          case WordRecitationStatus.incorrect:
          case WordRecitationStatus.missed:
            bgColor = const Color(0xFFFFEBEE);
            textColor = const Color(0xFFC62828);
            border = Border.all(color: const Color(0xFFEF9A9A));
            break;
          case WordRecitationStatus.pending:
            bgColor = Colors.transparent;
            textColor = const Color(0xFF1E293B);
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: border,
          ),
          child: Text(
            w.arabicText,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordingSection() {
    String buttonText;
    Color buttonColor;
    IconData buttonIcon;

    switch (_recordingState) {
      case RecordingState.idle:
        buttonText = 'Sentuh untuk mulai';
        buttonColor = const Color(0xFF4A7C59);
        buttonIcon = Icons.mic_rounded;
        break;
      case RecordingState.listening:
        buttonText = 'Sedang mendengarkan...';
        buttonColor = const Color(0xFFDC2626);
        buttonIcon = Icons.stop_rounded;
        break;
      case RecordingState.processing:
        buttonText = 'Menganalisis bacaan...';
        buttonColor = const Color(0xFFE65100);
        buttonIcon = Icons.hourglass_top_rounded;
        break;
      case RecordingState.done:
        buttonText = 'Lihat hasil analisis';
        buttonColor = const Color(0xFF2E7D32);
        buttonIcon = Icons.check_rounded;
        break;
    }

    return Column(
      children: [
        // Live Sound Wave visualizer saat merekam
        if (_recordingState == RecordingState.listening) ...[
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (ctx, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(12, (index) {
                  final scale = (index % 2 == 0)
                      ? _waveCtrl.value * 0.8 + 0.3
                      : (1.0 - _waveCtrl.value) * 0.8 + 0.3;
                  return Container(
                    width: 3.5,
                    height: 28 * scale,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            _liveTranscription.isNotEmpty
                ? 'Suara terdeteksi: "$_liveTranscription"'
                : 'Bacakan ayat dengan tartil...',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Tombol Mikrofon Utama
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _recordingState == RecordingState.processing
                    ? null
                    : () => _toggleRecording(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 3,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _recordingState == RecordingState.processing
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Icon(buttonIcon, color: Colors.white, size: 34),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                buttonText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: buttonColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisResultsSection(TajwidAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card Ringkasan Skor Dinamis
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 3 Skor Utama
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'AKURASI',
                      value: '${result.accuracy}%',
                      color: result.accuracy >= 80 ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      icon: Icons.speed_rounded,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'TAJWID BENAR',
                      value: '${result.tajwidBenar}',
                      color: const Color(0xFF2E7D32),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'PERBAIKAN',
                      value: '${result.perbaikan}',
                      color: result.perbaikan > 0 ? const Color(0xFFDC2626) : Colors.grey.shade600,
                      icon: Icons.build_circle_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Pesan Evaluasi
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology_alt_rounded, color: Color(0xFF4A7C59), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.feedbackMessage,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Judul Daftar Hukum Tajwid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detail Pemeriksaan Tajwid',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              '${result.rules.length} Hukum Terdeteksi',
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey.shade600),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Daftar Hukum Tajwid
        if (result.rules.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Tidak ditemukan hukum tajwid kompleks pada ayat ini (ayat pendek berharakat dasar).',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
            ),
          )
        else
          ...result.rules.map((rule) => _buildTajwidDetailCard(rule)),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTajwidDetailCard(TajwidRule rule) {
    Color cardBg;
    Color borderColor;
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (rule.status) {
      case TajwidStatus.correct:
        cardBg = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        statusColor = const Color(0xFF16A34A);
        statusLabel = 'Sesuai';
        statusIcon = Icons.check_circle_rounded;
        break;
      case TajwidStatus.needsAttention:
        cardBg = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        statusColor = const Color(0xFFD97706);
        statusLabel = 'Perlu Diperhatikan';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case TajwidStatus.needsImprovement:
        cardBg = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        statusColor = const Color(0xFFDC2626);
        statusLabel = 'Perlu Perbaikan';
        statusIcon = Icons.cancel_rounded;
        break;
      case TajwidStatus.uncertain:
        cardBg = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFE2E8F0);
        statusColor = const Color(0xFF64748B);
        statusLabel = 'Belum Yakin';
        statusIcon = Icons.help_outline_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cuplikan Teks Arab
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  rule.arabicSnippet,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nama Hukum & Status Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Penjelasan Suara
          Text(
            rule.explanation,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF334155),
              height: 1.4,
            ),
          ),

          // Tips Perbaikan (Jika Perlu)
          if (rule.status != TajwidStatus.correct) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_outlined, size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rule.improvementTip,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Bottom Nav for Per Ayat Mode ───────────────────────
  Widget _buildPerAyatBottomNav() {
    final totalAyahs = _currentSurahDetail?.ayahs.length ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Ayat Sebelumnya
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentAyahNumber > 1 ? _goToPreviousAyah : null,
                icon: const Icon(Icons.skip_previous_rounded, size: 18),
                label: const Text('Sebelumnya'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Ulangi Ayat
            IconButton(
              onPressed: _repeatCurrentAyah,
              tooltip: 'Ulangi Ayat',
              icon: const Icon(Icons.replay_rounded, color: Color(0xFF4A7C59)),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),

            // Ayat Selanjutnya
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentAyahNumber < totalAyahs ? _goToNextAyah : null,
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                label: const Text('Berikutnya'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // MODE 2: PER SURAH VIEW
  // ══════════════════════════════════════════════════════════
  Widget _buildPerSurahView() {
    final ayahs = _currentSurahDetail?.ayahs ?? [];

    return Column(
      children: [
        // Top Bar: Info Surah & Tombol Autoplay
        _buildSurahAutoplayHeader(),

        // Rekap Progres Membaca Surah
        _buildSurahProgressSummary(),

        // List Seluruh Ayat Dari Awal Sampai Akhir
        Expanded(
          child: ListView.separated(
            controller: _surahScrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: ayahs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final ayah = ayahs[idx];
              final isAutoplayTarget = _isAutoplayActive && _autoplayAyahIndex == idx;
              final result = _surahPerAyahResults[ayah.ayahNumber];

              return _buildSurahAyahTile(
                ayah: ayah,
                isHighlight: isAutoplayTarget,
                result: result,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurahAutoplayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _openSurahPicker,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _currentSurahItem?.nameLatin ?? 'Surah',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                  Text(
                    '${_currentSurahDetail?.ayahs.length ?? 0} Ayat • ${_currentSurahItem?.revelation ?? ''}',
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Putar Seluruh Surah
          ElevatedButton.icon(
            onPressed: _startAutoplay,
            icon: Icon(
              _isAutoplayActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 18,
            ),
            label: Text(_isAutoplayActive ? 'Stop' : 'Putar Surah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAutoplayActive ? const Color(0xFFDC2626) : const Color(0xFF4A7C59),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahProgressSummary() {
    final totalAyahs = _currentSurahDetail?.ayahs.length ?? 1;
    final completedCount = _surahPerAyahResults.length;
    final avgAccuracy = completedCount > 0
        ? (_surahPerAyahResults.values.map((r) => r.accuracy).reduce((a, b) => a + b) / completedCount).round()
        : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                'Latihan: $completedCount / $totalAyahs Ayat',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          if (completedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Rata-rata: $avgAccuracy%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSurahAyahTile({
    required SurahAyah ayah,
    required bool isHighlight,
    required TajwidAnalysisResult? result,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? const Color(0xFF4A7C59) : const Color(0xFFE2E8F0),
          width: isHighlight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris Nomor & Aksi Audio & Rekam
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Nomor Ayat
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isHighlight ? const Color(0xFF4A7C59) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${ayah.ayahNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isHighlight ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  // Skor jika sudah dinilai
                  if (result != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: result.accuracy >= 80 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Akurasi ${result.accuracy}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: result.accuracy >= 80 ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],

                  // Tombol Putar Audio Ayat
                  IconButton(
                    icon: Icon(
                      (_isPlayingAudio && _currentAyahNumber == ayah.ayahNumber)
                          ? Icons.pause_circle_rounded
                          : Icons.play_circle_outline_rounded,
                      color: const Color(0xFF4A7C59),
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() => _currentAyahNumber = ayah.ayahNumber);
                      _togglePlayCurrentAyah();
                    },
                  ),

                  // Tombol Rekam Ayat Ini
                  IconButton(
                    icon: Icon(
                      (_recordingState == RecordingState.listening && _currentAyahNumber == ayah.ayahNumber)
                          ? Icons.stop_circle_rounded
                          : Icons.mic_rounded,
                      color: (_recordingState == RecordingState.listening && _currentAyahNumber == ayah.ayahNumber)
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF4A7C59),
                      size: 24,
                    ),
                    onPressed: () => _toggleRecording(specificAyahNumber: ayah.ayahNumber),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Teks Arab Utsmani
          Text(
            ayah.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              height: 1.8,
            ),
          ),

          const SizedBox(height: 8),

          // Transliterasi
          if (ayah.latinText.isNotEmpty) ...[
            Text(
              ayah.latinText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Terjemahan
          Text(
            ayah.translation,
            style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Panduan Tajwid Modal ───────────────────────────────
  void _showTajwidGuideDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Panduan 17 Hukum Tajwid',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Sistem menganalisis suara pengguna terhadap hukum tajwid berikut:',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: const [
                  _TajwidGuideItem(name: '1. Ikhfa Haqiqi', desc: 'Nun sukun/tanwin bertemu 15 huruf ikhfa (samar 2 harakat).'),
                  _TajwidGuideItem(name: '2. Ikhfa Syafawi', desc: 'Mim sukun bertemu Ba (samar di bibir berdengung).'),
                  _TajwidGuideItem(name: '3. Idgham Bighunnah', desc: 'Nun sukun/tanwin bertemu Yanmu (ي ن م و) dilebur dengan dengung.'),
                  _TajwidGuideItem(name: '4. Idgham Bilaghunnah', desc: 'Nun sukun/tanwin bertemu Lam atau Ra (lebur tanpa dengung).'),
                  _TajwidGuideItem(name: '5. Idgham Mimi', desc: 'Mim sukun bertemu Mim (lebur dengung 2 harakat).'),
                  _TajwidGuideItem(name: '6. Iqlab', desc: 'Nun sukun/tanwin bertemu Ba diubah menjadi suara Mim berdengung.'),
                  _TajwidGuideItem(name: '7. Izhar Halqi', desc: 'Nun sukun/tanwin bertemu huruf tenggorokan (dibaca jelas).'),
                  _TajwidGuideItem(name: '8. Izhar Syafawi', desc: 'Mim sukun bertemu selain Mim dan Ba (dibaca jelas di bibir).'),
                  _TajwidGuideItem(name: '9. Ghunnah Musyaddadah', desc: 'Nun atau Mim bertasydid (dengung 2 harakat wajib).'),
                  _TajwidGuideItem(name: '10. Qalqalah', desc: 'Huruf Qutub Jad memantul ringan (sughra) atau tebal saat waqaf (kubra).'),
                  _TajwidGuideItem(name: '11. Mad Thabi\'i', desc: 'Panjang dasar 2 harakat (Alif, Wawu, Ya).'),
                  _TajwidGuideItem(name: '12. Mad Wajib Muttashil', desc: 'Mad bertemu hamzah satu kata (panjang 4-5 harakat).'),
                  _TajwidGuideItem(name: '13. Mad Jaiz Munfashil', desc: 'Mad bertemu hamzah lain kata (panjang 2, 4, atau 5 harakat).'),
                  _TajwidGuideItem(name: '14. Mad Lazim', desc: 'Mad bertemu sukun asli atau tasydid (panjang 6 harakat).'),
                  _TajwidGuideItem(name: '15. Mad \'Aridh Lissukun', desc: 'Mad sebelum waqaf di akhir ayat (2, 4, atau 6 harakat).'),
                  _TajwidGuideItem(name: '16. Alif Lam Syamsiyah', desc: 'Lam melebur ke huruf syamsiyah bertasydid.'),
                  _TajwidGuideItem(name: '17. Alif Lam Qamariyah', desc: 'Lam dibaca jelas (izhar) pada huruf qamariyah.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TajwidGuideItem extends StatelessWidget {
  final String name;
  final String desc;

  const _TajwidGuideItem({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32))),
          const SizedBox(height: 2),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
        ],
      ),
    );
  }
}
