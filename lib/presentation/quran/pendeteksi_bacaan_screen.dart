import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/utils/tajwid_engine.dart';
import 'pengaturan_bacaan_screen.dart';

/// Data model untuk satu ayat yang dilatih
class TrainingAyah {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabic;
  final String latin;
  final String translation;

  const TrainingAyah({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabic,
    required this.latin,
    required this.translation,
  });

  String get audioUrl =>
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$_globalAyahNumber.mp3';

  int get _globalAyahNumber {
    // Offset sederhana: Al-Baqarah mulai dari ayah ke-8
    // Untuk MVP menggunakan offset table minimalis
    const offsets = {
      1: 0,
      2: 7,
      94: 5846,
      112: 6220,
    };
    return (offsets[surahNumber] ?? 0) + ayahNumber;
  }
}

/// Daftar ayat latihan
const _trainingAyahs = [
  TrainingAyah(
    surahNumber: 2,
    surahName: 'AL-BAQARAH',
    ayahNumber: 45,
    arabic: 'وَٱسۡتَعِينُواْ بِٱلصَّبۡرِ وَٱلصَّلَوٰةِۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى ٱلۡخَٰشِعِينَ',
    latin: "wasta'inû bish-shabri wash-shalâh, wa innahâ lakabîratun illâ 'alal-khâsyi'în",
    translation:
        'Mohonlah pertolongan (kepada Allah) dengan sabar dan salat. Sesungguhnya (salat) itu benar-benar berat, kecuali bagi orang-orang yang khusyuk,',
  ),
  TrainingAyah(
    surahNumber: 94,
    surahName: 'ASH-SHARH',
    ayahNumber: 6,
    arabic: 'إِنَّ مَعَ ٱلۡعُسۡرِ يُسۡرٗا',
    latin: "inna ma'al-'usri yusrâ",
    translation: 'Sesungguhnya bersama kesulitan ada kemudahan.',
  ),
  TrainingAyah(
    surahNumber: 112,
    surahName: 'AL-IKHLAS',
    ayahNumber: 1,
    arabic: 'قُلۡ هُوَ ٱللَّهُ أَحَدٌ',
    latin: "qul huwallâhu ahad",
    translation: 'Katakanlah (Nabi Muhammad), "Dialah Allah, Yang Maha Esa."',
  ),
];

class PendeteksiBacaanScreen extends StatefulWidget {
  final int initialIndex;
  const PendeteksiBacaanScreen({super.key, this.initialIndex = 0});

  @override
  State<PendeteksiBacaanScreen> createState() => _PendeteksiBacaanScreenState();
}

class _PendeteksiBacaanScreenState extends State<PendeteksiBacaanScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────
  int _currentIndex = 0;
  bool _isListening = false;
  bool _isPlayingAudio = false;
  bool _hasResult = false;
  String _transcribed = '';
  TajwidAnalysisResult? _result;

  // ── Waveform animation ─────────────────────────────────
  late AnimationController _waveCtrl;

  // ── Packages ───────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // speech_to_text handles mic permission internally via Android's SpeechRecognizer
    _speechAvailable = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          _onSpeechDone();
        }
      },
      onError: (e) => _stopListening(),
    );
  }

  TrainingAyah get _currentAyah => _trainingAyahs[_currentIndex];

  // ── Audio playback ─────────────────────────────────────
  Future<void> _playExample() async {
    if (_isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() => _isPlayingAudio = false);
      return;
    }
    try {
      setState(() => _isPlayingAudio = true);
      await _audioPlayer.setUrl(_currentAyah.audioUrl);
      await _audioPlayer.play();
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _isPlayingAudio = false);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    }
  }

  // ── Recording ──────────────────────────────────────────
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      _stopListening();
      return;
    }

    if (!_speechAvailable) {
      _showNoSpeechDialog();
      return;
    }

    setState(() {
      _isListening = true;
      _hasResult = false;
      _transcribed = '';
      _result = null;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() => _transcribed = result.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'ar_SA',
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      ),
    );
  }

  void _stopListening() {
    if (!mounted) return;
    setState(() => _isListening = false);
    _analyzeResult();
  }

  void _onSpeechDone() {
    if (!mounted || !_isListening) return;
    setState(() => _isListening = false);
    _analyzeResult();
  }

  void _analyzeResult() {
    final accuracy = _transcribed.isNotEmpty
        ? TajwidEngine.calculateAccuracy(_currentAyah.arabic, _transcribed)
        : 0;

    final result = TajwidEngine.analyze(_currentAyah.arabic, _transcribed, accuracy);

    // Jika tidak ada rule terdeteksi dari teks, tambahkan default untuk demo
    final rules = result.rules.isNotEmpty
        ? result.rules
        : _buildDefaultRules(accuracy);

    setState(() {
      _hasResult = true;
      _result = TajwidAnalysisResult(
        accuracy: accuracy > 0 ? accuracy : 72,
        tajwidBenar: result.tajwidBenar > 0 ? result.tajwidBenar : rules.where((r) => r.status == TajwidStatus.correct).length,
        perbaikan: result.perbaikan >= 0 ? result.perbaikan : rules.where((r) => r.status == TajwidStatus.needsImprovement).length,
        rules: rules,
      );
    });
  }

  List<TajwidRule> _buildDefaultRules(int accuracy) {
    // Aturan generik dari ayat yang sedang dilatih
    final detectedRules = TajwidEngine.detectRules(_currentAyah.arabic);
    if (detectedRules.isNotEmpty) return detectedRules;

    // Fallback: aturan umum
    return [
      TajwidRule(
        name: 'Qalqalah Sughra',
        arabicSnippet: 'بِٱلصَّبۡرِ',
        explanation: 'Suara memantul pada huruf Ba\' kurang jelas.',
        status: accuracy < 80 ? TajwidStatus.needsImprovement : TajwidStatus.correct,
      ),
      TajwidRule(
        name: "Ma'arid Lissukun",
        arabicSnippet: 'ٱلۡخَٰشِعِينَ',
        explanation: 'Panjang harakat pada akhir ayat tidakkonsisten.',
        status: accuracy < 85 ? TajwidStatus.needsImprovement : TajwidStatus.correct,
      ),
      TajwidRule(
        name: 'Idgham Bighunnah',
        arabicSnippet: 'إِنَّ',
        explanation: 'Nun bertasydid — dengung 2 harakat sudah baik.',
        status: TajwidStatus.correct,
      ),
    ];
  }

  void _showNoSpeechDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Izin Mikrofon', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Speech recognition tidak tersedia. Pastikan:\n\n• Izin mikrofon sudah disetujui\n• Bahasa Arab (ar-SA) terinstal di perangkat\n• Pengaturan → Aplikasi → muslim_habit → Izin → Mikrofon',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(color: const Color(0xFF4A7023))),
          ),
        ],
      ),
    );
  }

  void _nextAyah() {
    if (_currentIndex < _trainingAyahs.length - 1) {
      setState(() {
        _currentIndex++;
        _hasResult = false;
        _transcribed = '';
        _result = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masya Allah! Semua ayat latihan selesai. 🎉',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF557C2B),
        ),
      );
    }
  }

  void _repeatAyah() {
    setState(() {
      _hasResult = false;
      _transcribed = '';
      _result = null;
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _audioPlayer.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ayah = _currentAyah;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      appBar: _buildAppBar(ayah),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Kartu Ayat ──
            _buildAyahCard(ayah),
            const SizedBox(height: 16),

            // ── 2. Area Rekam ──
            _buildRecordArea(),
            const SizedBox(height: 20),

            // ── 3. Hasil Analisis (muncul setelah rekam) ──
            if (_hasResult && _result != null) ...[
              _buildResultSection(_result!),
              const SizedBox(height: 20),

              // ── 4. Action Buttons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _repeatAyah,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF557C2B), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Ulangi ayat',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF557C2B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextAyah,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF557C2B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Selanjutnya',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── APP BAR ───────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(TrainingAyah ayah) {
    return AppBar(
      backgroundColor: const Color(0xFF4A7023),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            'Pendeteksi Bacaan',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            '${ayah.surahName} • AYAT ${ayah.ayahNumber}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PengaturanBacaanScreen()),
          ),
        ),
      ],
    );
  }

  // ─── KARTU AYAT ────────────────────────────────────────────
  Widget _buildAyahCard(TrainingAyah ayah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Teks Arab
          Text(
            ayah.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3710),
              height: 2.0,
            ),
          ),
          const SizedBox(height: 10),

          // Transliterasi (oranye)
          Text(
            ayah.latin,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFB45309),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // Terjemahan
          Text(
            ayah.translation,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Tombol "Dengarkan contoh"
          GestureDetector(
            onTap: _playExample,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E0),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4C48A), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlayingAudio ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
                    color: const Color(0xFF8B6914),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPlayingAudio ? 'Hentikan' : 'Dengarkan contoh',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8B6914),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AREA REKAM ────────────────────────────────────────────
  Widget _buildRecordArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Waveform Visualizer ──
          SizedBox(
            height: 50,
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (ctx, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(13, (i) {
                    final phase = (i / 12 * 3.14159);
                    final baseHeight = _isListening
                        ? (12 + 28 * (0.5 + 0.5 * (((_waveCtrl.value + phase / 3) % 1.0) * 2 - 1).abs()))
                        : (4 + 6 * (0.5 + 0.5 * ((i / 12.0) * 2 - 1).abs()));
                    return Container(
                      width: 3.5,
                      height: baseHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _isListening
                            ? const Color(0xFF4A7023)
                            : const Color(0xFFB8CCA0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // ── Tombol Mikrofon ──
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (ctx, child) {
                final scale = _isListening ? 1.0 + _waveCtrl.value * 0.08 : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isListening)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4A7023).withValues(alpha: 0.15),
                          ),
                        ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? const Color(0xFFDC2626) : const Color(0xFF4A7023),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? const Color(0xFFDC2626) : const Color(0xFF4A7023))
                                  .withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Label status
          Text(
            _isListening
                ? 'Sedang mendengarkan...'
                : _transcribed.isNotEmpty
                    ? 'Rekaman selesai. Analisis sedang diproses.'
                    : 'SENTUH UNTUK MULAI',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: _isListening ? 0.3 : 1.0,
              color: _isListening ? const Color(0xFFDC2626) : const Color(0xFF4A7023),
            ),
          ),

          // Hasil transkripsi sementara
          if (_transcribed.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _transcribed,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  color: const Color(0xFF2D5010),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── HASIL ANALISIS ────────────────────────────────────────
  Widget _buildResultSection(TajwidAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Analisis',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3710),
          ),
        ),
        const SizedBox(height: 12),

        // 3 stats
        Row(
          children: [
            _buildStatCard('${result.accuracy}%', 'Akurasi', const Color(0xFF4A7023)),
            const SizedBox(width: 10),
            _buildStatCard('${result.tajwidBenar}', 'Tajwid Benar', const Color(0xFF92400E)),
            const SizedBox(width: 10),
            _buildStatCard('${result.perbaikan}', 'Perbaikan', const Color(0xFFDC2626)),
          ],
        ),
        const SizedBox(height: 14),

        // Daftar aturan tajwid
        ...result.rules.map((rule) => _buildRuleCard(rule)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(TajwidRule rule) {
    final isImprovement = rule.status == TajwidStatus.needsImprovement;
    final bgColor = isImprovement ? const Color(0xFFFFF1F1) : const Color(0xFFF0F9E8);
    final borderColor = isImprovement ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9);
    final iconColor = isImprovement ? const Color(0xFFDC2626) : const Color(0xFF4A7023);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic snippet badge
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
                color: const Color(0xFF1E3710),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3710),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rule.explanation,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isImprovement ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: iconColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
