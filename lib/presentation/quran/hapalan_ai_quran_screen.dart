import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../models/surah_detail.dart';
import '../../services/quran_service.dart';
import '../../services/arabic_matching_service.dart';
import '../../services/hapalan_progress_service.dart';
import 'widgets/hapalan_result_sheet.dart';
import 'widgets/hapalan_method_sheet.dart';

class HapalanAiQuranScreen extends StatefulWidget {
  final int initialSurahNumber;
  final int initialAyahNumber;

  const HapalanAiQuranScreen({
    super.key,
    this.initialSurahNumber = 2,
    this.initialAyahNumber = 7,
  });

  @override
  State<HapalanAiQuranScreen> createState() => _HapalanAiQuranScreenState();
}

class _HapalanAiQuranScreenState extends State<HapalanAiQuranScreen>
    with SingleTickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // State navigasi dan data ayat
  late int _currentSurahNumber;
  late int _currentAyahNumber;
  String _currentSurahName = 'Al-Baqarah';
  List<SurahAyah> _ayahList = [];
  bool _isLoading = true;

  // State Metode Hafalan
  HafalanMethodType _currentMethod = HafalanMethodType.perAyat;
  int _rangeStartAyah = 7;
  int _rangeEndAyah = 7;

  // State UI & Sembunyikan Teks
  bool _isTextHidden = false;
  bool _isListening = false;
  bool _speechInitialized = false;
  String _selectedLocaleId = 'ar-SA';
  String _liveSpokenText = '';
  String _lastEvaluatedTranscript = '';
  AyahHafalanRecord? _currentAyahRecord;

  // Animasi Waveform saat mendengarkan
  late AnimationController _waveController;

  // Fallback awal Al-Baqarah ayat 7
  static final SurahAyah _defaultAyah = SurahAyah(
    ayahNumber: 7,
    arabicText: 'خَتَمَ اللَّهُ عَلَىٰ قُلُوبِهِمْ وَعَلَىٰ سَمْعِهِمْ ۖ وَعَلَىٰ أَبْصَارِهِمْ غِشَاوَةٌ ۖ وَلَهُمْ عَذَابٌ عَظِيمٌ',
    latinText: 'khatamallâhu ‘alâ qulûbihim wa ‘alâ sam‘ihim, wa ‘alâ abshârihim ghisyâwatuw wa lahum ‘adzâbun ‘adhîm',
    translation: 'Allah telah mengunci hati dan pendengaran mereka. Pada penglihatan mereka ada penutup, dan bagi mereka azab yang sangat berat.',
  );

  @override
  void initState() {
    super.initState();
    _currentSurahNumber = widget.initialSurahNumber;
    _currentAyahNumber = widget.initialAyahNumber;
    _rangeStartAyah = widget.initialAyahNumber;
    _rangeEndAyah = widget.initialAyahNumber;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _initSavedPreferences();
    _loadSurahData();
    _initSpeechRecognizer();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSavedPreferences() async {
    final methodStr = await HapalanProgressService.getSelectedMethod();
    if (mounted) {
      setState(() {
        if (methodStr == 'beberapa_ayat') {
          _currentMethod = HafalanMethodType.beberapaAyat;
        } else if (methodStr == 'per_surah') {
          _currentMethod = HafalanMethodType.perSurah;
        } else {
          _currentMethod = HafalanMethodType.perAyat;
        }
      });
    }
  }

  Future<void> _loadAyahRecord() async {
    final rec = await HapalanProgressService.getRecord(
      _currentSurahNumber,
      _currentAyahNumber,
    );
    if (mounted) {
      setState(() {
        _currentAyahRecord = rec;
      });
    }
  }

  Future<void> _initSpeechRecognizer() async {
    try {
      final available = await _speech.initialize(
        onError: (val) {
          debugPrint('Speech error: ${val.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'notListening' || status == 'done') {
            if (mounted && _isListening) {
              _finishListeningAndEvaluate();
            }
          }
        },
      );

      if (available) {
        final locales = await _speech.locales();
        String chosen = 'ar-SA';
        final hasArSA = locales.any((l) => l.localeId.toLowerCase().startsWith('ar'));
        if (hasArSA) {
          final arLocale = locales.firstWhere(
            (l) => l.localeId.toLowerCase().startsWith('ar'),
            orElse: () => locales.first,
          );
          chosen = arLocale.localeId;
        }
        if (mounted) {
          setState(() {
            _speechInitialized = true;
            _selectedLocaleId = chosen;
          });
        }
      } else {
        if (mounted) {
          setState(() => _speechInitialized = false);
        }
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  Future<void> _loadSurahData() async {
    setState(() => _isLoading = true);
    try {
      final detail = await _quranService.fetchSurahDetail(_currentSurahNumber);
      if (detail != null && detail.ayahs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _ayahList = detail.ayahs;
            _currentSurahName = detail.nameLatin;
            _rangeStartAyah = _currentAyahNumber;
            _rangeEndAyah = _currentAyahNumber;
            _isLoading = false;
          });
          _loadAyahRecord();
        }
        return;
      }
    } catch (e) {
      debugPrint('Error loading surah for hapalan: $e');
    }

    if (mounted) {
      setState(() {
        _ayahList = [_defaultAyah];
        _isLoading = false;
      });
      _loadAyahRecord();
    }
  }

  SurahAyah get _currentAyah {
    if (_ayahList.isEmpty) return _defaultAyah;
    final found = _ayahList.firstWhere(
      (a) => a.ayahNumber == _currentAyahNumber,
      orElse: () => _ayahList.first,
    );
    return found;
  }

  String get _targetArabicText {
    if (_currentMethod == HafalanMethodType.beberapaAyat) {
      final selected = _ayahList.where(
        (a) => a.ayahNumber >= _rangeStartAyah && a.ayahNumber <= _rangeEndAyah,
      );
      if (selected.isNotEmpty) {
        return selected.map((a) => a.arabicText).join(' ');
      }
    } else if (_currentMethod == HafalanMethodType.perSurah) {
      if (_ayahList.isNotEmpty) {
        return _ayahList.map((a) => a.arabicText).join(' ');
      }
    }
    return _currentAyah.arabicText;
  }

  void _nextAyah() {
    if (_ayahList.isEmpty) return;
    final currentIndex = _ayahList.indexWhere((a) => a.ayahNumber == _currentAyahNumber);
    if (currentIndex >= 0 && currentIndex < _ayahList.length - 1) {
      setState(() {
        _currentAyahNumber = _ayahList[currentIndex + 1].ayahNumber;
        _isTextHidden = false;
        _liveSpokenText = '';
      });
      _loadAyahRecord();
    }
  }

  void _prevAyah() {
    if (_ayahList.isEmpty) return;
    final currentIndex = _ayahList.indexWhere((a) => a.ayahNumber == _currentAyahNumber);
    if (currentIndex > 0) {
      setState(() {
        _currentAyahNumber = _ayahList[currentIndex - 1].ayahNumber;
        _isTextHidden = false;
        _liveSpokenText = '';
      });
      _loadAyahRecord();
    }
  }

  /// Memulai atau menghentikan mikrofon
  void _toggleMic() async {
    if (_isListening) {
      // Hentikan proses mendengar dan lakukan evaluasi
      await _speech.stop();
      _finishListeningAndEvaluate();
      return;
    }

    // 1. Cek ketersediaan dan inisialisasi permission
    if (!_speechInitialized) {
      await _initSpeechRecognizer();
    }

    final hasPerm = await _speech.hasPermission;
    if (!hasPerm) {
      _showPermissionDialog();
      return;
    }

    // 2. Mulai mendengarkan bacaan pengguna
    setState(() {
      _isListening = true;
      _liveSpokenText = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _liveSpokenText = result.recognizedWords;
            });
          }
        },
        localeId: _selectedLocaleId,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: false,
        partialResults: true,
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      if (mounted) {
        setState(() => _isListening = false);
        _showErrorSnackBar('Gagal mengaktifkan mikrofon: $e');
      }
    }
  }

  /// Selesai mendengar -> Jalankan Evaluasi AI
  Future<void> _finishListeningAndEvaluate() async {
    setState(() {
      _isListening = false;
    });

    final transcript = _liveSpokenText.trim();
    _lastEvaluatedTranscript = transcript;

    // Jika suara kosong atau tidak terdeteksi
    if (transcript.isEmpty) {
      _showEmptySpeechDialog();
      return;
    }

    // Jalankan algoritma evaluasi AI kecocokan teks Arab
    final targetArabic = _targetArabicText;
    final startAyah = _currentMethod == HafalanMethodType.beberapaAyat
        ? _rangeStartAyah
        : (_currentMethod == HafalanMethodType.perSurah ? 1 : _currentAyahNumber);
    final endAyah = _currentMethod == HafalanMethodType.beberapaAyat
        ? _rangeEndAyah
        : (_currentMethod == HafalanMethodType.perSurah ? _ayahList.length : _currentAyahNumber);

    final result = ArabicMatchingService.evaluate(
      surahNumber: _currentSurahNumber,
      surahName: _currentSurahName,
      startAyah: startAyah,
      endAyah: endAyah,
      targetOriginalArabic: targetArabic,
      recognizedTranscript: transcript,
    );

    // Simpan progres jika berhasil dites
    final updatedRecord = await HapalanProgressService.recordEvaluation(
      surahNumber: _currentSurahNumber,
      ayahNumber: _currentAyahNumber,
      score: result.matchPercentage,
    );

    if (mounted) {
      setState(() {
        _currentAyahRecord = updatedRecord;
      });

      // Tampilkan bottom sheet hasil pengujian AI
      HapalanResultSheet.show(
        context: context,
        result: result,
        hasNextAyah: _currentAyahNumber < _ayahList.length,
        onRetry: () {
          setState(() {
            _liveSpokenText = '';
          });
        },
        onNextAyah: () {
          _nextAyah();
        },
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mic_off_rounded, color: Color(0xFFC62828)),
            const SizedBox(width: 8),
            Text(
              'Izin Mikrofon Diperlukan',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Fitur Penguji Hafalan Al-Quran memerlukan izin mikrofon agar sistem AI dapat mendengarkan dan mencocokkan bacaan ayat Anda.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _initSpeechRecognizer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF518427),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Berikan Izin',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmptySpeechDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.volume_mute_rounded, color: Color(0xFFEF6C00)),
            const SizedBox(width: 8),
            Text(
              'Suara Belum Terdeteksi',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Sistem belum dapat mendengar bacaan dengan jelas. Pastikan mikrofon dekat dan ucapkan ayat Al-Quran dengan artikulasi yang jelas, lalu coba lagi.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF518427),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Mengerti',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openMethodSelector() {
    HafalanMethodSheet.show(
      context: context,
      initialMethod: _currentMethod,
      totalAyahsInSurah: _ayahList.isNotEmpty ? _ayahList.length : 286,
      currentStartAyah: _rangeStartAyah,
      currentEndAyah: _rangeEndAyah,
      onApply: (method, startAyah, endAyah) {
        setState(() {
          _currentMethod = method;
          _rangeStartAyah = startAyah;
          _rangeEndAyah = endAyah;
          if (method == HafalanMethodType.beberapaAyat) {
            _currentAyahNumber = startAyah;
          }
        });
        final methodKey = method == HafalanMethodType.beberapaAyat
            ? 'beberapa_ayat'
            : (method == HafalanMethodType.perSurah ? 'per_surah' : 'per_ayah');
        HapalanProgressService.saveSelectedMethod(methodKey);
      },
    );
  }

  void _showInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle atas
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header bar: Judul & tombol Tutup (X)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Informasi Hapalan',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Informasi
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Color(0xFF518427),
                          width: 4.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ikon sparkle di kotak hijau muda
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCE7BF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF386641),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Teks deskripsi informasi
                        Text(
                          'Jika sudah hafal, tekan Sembunyikan Teks lalu aktifkan mikrofon untuk mulai menguji hafalan.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF374151),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _methodLabel {
    switch (_currentMethod) {
      case HafalanMethodType.perAyat:
        return 'Per Ayat';
      case HafalanMethodType.beberapaAyat:
        return 'Ayat $_rangeStartAyah–$_rangeEndAyah';
      case HafalanMethodType.perSurah:
        return 'Per Surah';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ayah = _currentAyah;
    final totalAyahs = _ayahList.isNotEmpty ? _ayahList.length : 1;
    final currentAyahIndex = _ayahList.isNotEmpty
        ? (_ayahList.indexWhere((a) => a.ayahNumber == _currentAyahNumber).clamp(0, totalAyahs - 1))
        : 0;
    final progressValue = totalAyahs > 0 ? (currentAyahIndex + 1) / totalAyahs : 0.28;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF518427),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F8F2),
        body: Column(
          children: [
            // ── 1. HEADER HALAMAN (HIJAU #4F8426) ──
            Container(
              color: const Color(0xFF518427),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Container(
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Tombol kembali (lingkaran hijau muda)
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFF84B74E),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),

                          // Judul Hapalan AI Quran & Chip Metode
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hapalan AI Quran',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                // Selector Metode Hafalan (Chip Halus)
                                GestureDetector(
                                  onTap: _openMethodSelector,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Metode: $_methodLabel',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFE8F2E2),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 14,
                                          color: Color(0xFFE8F2E2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Ikon informasi (i) lingkaran outline putih
                          GestureDetector(
                            onTap: _showInfoBottomSheet,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Center(
                                child: Text(
                                  'i',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Horizontal Progress Indicator tepat di bawah header
                    ClipRRect(
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B432C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. BODY KONTEN (Card Ayat & Tips) ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 24),
                child: Column(
                  children: [
                    // KARTU UTAMA AYAT AL-QURAN
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isTextHidden ? const Color(0xFFE2E6DF) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // AREA TEKS AYAT DENGAN EFEK BLUR / OVERLAY KETIKA DISEMBUNYIKAN
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Teks Ayat (Arab, Latin, Terjemahan)
                              Column(
                                children: [
                                  // A. Teks Arab
                                  Text(
                                    ayah.arabicText,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.amiri(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A1A),
                                      height: 1.9,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // B. Transliterasi Latin
                                  if (ayah.latinText.isNotEmpty) ...[
                                    Text(
                                      ayah.latinText,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFB5894B),
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  // C. Terjemahan Indonesia
                                  Text(
                                    ayah.translation,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),

                              // OVERLAY BLUR KETIKA MODE SEMBUNYIKAN TEKS AKTIF (Sesuai Screenshot 2)
                              if (_isTextHidden)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                      child: Container(
                                        color: const Color(0xFFE2E6DF).withValues(alpha: 0.88),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // D. TOMBOL SEMBUNYIKAN / TAMPILKAN TEKS (PILL SHAPE)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isTextHidden = !_isTextHidden;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _isTextHidden ? const Color(0xFF84B74E) : const Color(0xFFCCD7C9),
                                  width: 1.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isTextHidden ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined,
                                    size: 19,
                                    color: _isTextHidden ? const Color(0xFF386641) : const Color(0xFFB5894B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isTextHidden ? 'Tampilkan Teks' : 'Sembunyikan Teks',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _isTextHidden ? const Color(0xFF386641) : const Color(0xFF2D3728),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── 3. INDIKATOR STATUS TERAKHIR / RIWAYAT AYAT INI ──
                    if (_currentAyahRecord != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _currentAyahRecord!.isPassed
                              ? const Color(0xFFF1F8E9)
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _currentAyahRecord!.isPassed
                                ? const Color(0xFFC5E1A5)
                                : const Color(0xFFFFE082),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentAyahRecord!.isPassed
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              size: 18,
                              color: _currentAyahRecord!.isPassed
                                  ? const Color(0xFF388E3C)
                                  : const Color(0xFFF57C00),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Skor Terakhir: ${_currentAyahRecord!.lastScore.toInt()}% • Terbaik: ${_currentAyahRecord!.bestScore.toInt()}% (${_currentAyahRecord!.attemptCount}x percobaan)',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _currentAyahRecord!.isPassed
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── 4. BAGIAN TIPS HAFALAN ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFDCE2D4),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ikon lampu hijau
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Color(0xFF3E7B27),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Teks Tips
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tips Hafalan',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E5A1C),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Ulangi ayat ini 7 kali sebelum melanjutkan ke ayat berikutnya untuk memperkuat memori jangka pendek.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF4B5563),
                                    height: 1.38,
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
              ),
            ),

            // ── 5. LIVE RECOGNITION PANEL SAAT MIKROFON AKTIF ──
            if (_isListening)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3E1B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A3E1B).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animasi audio waveform pulse
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return Row(
                              children: List.generate(4, (i) {
                                final h = 8.0 + (12.0 * ((i + _waveController.value) % 1.0));
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 3.5,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mendengarkan bacaan Anda...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Tombol Selesai Membaca
                        GestureDetector(
                          onTap: _toggleMic,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF84B74E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Selesai',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_liveSpokenText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _liveSpokenText,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 15,
                            color: const Color(0xFFE8F5E9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // ── 6. TOMBOL NAVIGASI & MIKROFON (DI BAWAH HALAMAN) ──
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Sebelumnya (Hijau Tua)
                    GestureDetector(
                      onTap: _prevAyah,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF124A18),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF124A18).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Tombol Mikrofon (Tengah, lebih besar)
                    GestureDetector(
                      onTap: _toggleMic,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: (_isListening || _isTextHidden)
                              ? const Color(0xFF0A3E1B)
                              : const Color(0xFFB0B5B3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening || _isTextHidden)
                                  ? const Color(0xFF0A3E1B).withValues(alpha: 0.45)
                                  : Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isListening)
                              AnimatedBuilder(
                                animation: _waveController,
                                builder: (ctx, child) {
                                  return Container(
                                    width: 58 + (_waveController.value * 8),
                                    height: 58 + (_waveController.value * 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            Icon(
                              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Tombol Berikutnya (Hijau Tua)
                    GestureDetector(
                      onTap: _nextAyah,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF124A18),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF124A18).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
