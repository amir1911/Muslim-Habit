import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/surah_detail.dart';
import '../../services/quran_service.dart';
import '../../services/hapalan_progress_service.dart';
import '../../services/adzan_service.dart';
import '../../core/widgets/custom_back_button.dart';

class HafalanPracticeScreen extends StatefulWidget {
  final int initialSurahNumber;
  final int initialAyahNumber;

  const HafalanPracticeScreen({
    super.key,
    required this.initialSurahNumber,
    required this.initialAyahNumber,
  });

  @override
  State<HafalanPracticeScreen> createState() => _HafalanPracticeScreenState();
}

class _HafalanPracticeScreenState extends State<HafalanPracticeScreen> {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late int _currentSurahNumber;
  late int _currentAyahNumber;
  String _currentSurahName = 'Al-Baqarah';
  List<SurahAyah> _ayahList = [];
  bool _isLoading = true;

  // Latihan & Pengulangan State
  int _repetitionCount = 0;
  HafalanStatus _currentStatus = HafalanStatus.belumDipelajari;
  bool _isTextHidden = false; // Mode sembunyikan teks Arab untuk uji ingatan

  // Audio Playback State
  bool _isPlaying = false;
  bool _isLooping = false;
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25];

  StreamSubscription? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _currentSurahNumber = widget.initialSurahNumber;
    _currentAyahNumber = widget.initialAyahNumber;

    _initAudioListeners();
    _loadSurahData();

    // Pause audio otomatis jika waktu adzan tiba
    AdzanService.registerAudioPauseCallback(_onAdzanPause);
  }

  @override
  void dispose() {
    AdzanService.unregisterAudioPauseCallback(_onAdzanPause);
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onAdzanPause() {
    if (mounted) {
      _audioPlayer.pause();
      setState(() => _isPlaying = false);
    }
  }

  void _initAudioListeners() {
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      final isPlaying = state.playing && state.processingState != ProcessingState.completed;
      setState(() {
        _isPlaying = isPlaying;
      });

      if (state.processingState == ProcessingState.completed) {
        if (_isLooping) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          setState(() => _isPlaying = false);
        }
      }
    });
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
            _isLoading = false;
          });
          _loadAyahProgress();
        }
        return;
      }
    } catch (e) {
      debugPrint('[HafalanPracticeScreen] Error loading surah data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAyahProgress() async {
    final record = await HapalanProgressService.getRecord(
      _currentSurahNumber,
      _currentAyahNumber,
    );

    if (mounted) {
      setState(() {
        _repetitionCount = record?.repetitionCount ?? 0;
        _currentStatus = record?.status ?? HafalanStatus.sedangDipelajari;
        _isTextHidden = false;
      });

      // Simpan posisi terakhir dipelajari
      HapalanProgressService.saveRecentPosition(_currentSurahNumber, _currentAyahNumber);
    }
  }

  SurahAyah get _currentAyah {
    if (_ayahList.isEmpty) {
      return SurahAyah(
        ayahNumber: _currentAyahNumber,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        latinText: 'Bismillāhir-raḥmānir-raḥīm',
        translation: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
      );
    }
    return _ayahList.firstWhere(
      (a) => a.ayahNumber == _currentAyahNumber,
      orElse: () => _ayahList.first,
    );
  }

  void _nextAyah() {
    if (_ayahList.isEmpty) return;
    _audioPlayer.stop();
    final currentIndex = _ayahList.indexWhere((a) => a.ayahNumber == _currentAyahNumber);
    if (currentIndex >= 0 && currentIndex < _ayahList.length - 1) {
      setState(() {
        _currentAyahNumber = _ayahList[currentIndex + 1].ayahNumber;
      });
      _loadAyahProgress();
    }
  }

  void _prevAyah() {
    if (_ayahList.isEmpty) return;
    _audioPlayer.stop();
    final currentIndex = _ayahList.indexWhere((a) => a.ayahNumber == _currentAyahNumber);
    if (currentIndex > 0) {
      setState(() {
        _currentAyahNumber = _ayahList[currentIndex - 1].ayahNumber;
      });
      _loadAyahProgress();
    }
  }

  Future<void> _togglePlayAudio() async {
    final audioUrl = _currentAyah.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio untuk ayat ini belum tersedia.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.setSpeed(_playbackSpeed);
        await _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('[HafalanPracticeScreen] Error play audio: $e');
    }
  }

  void _cycleSpeed() {
    final currentIndex = _speedOptions.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % _speedOptions.length;
    final nextSpeed = _speedOptions[nextIndex];
    setState(() {
      _playbackSpeed = nextSpeed;
    });
    _audioPlayer.setSpeed(nextSpeed);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
  }

  Future<void> _incrementRepetition() async {
    HapticFeedback.lightImpact();
    final rec = await HapalanProgressService.incrementRepetition(
      surahNumber: _currentSurahNumber,
      ayahNumber: _currentAyahNumber,
    );
    if (mounted) {
      setState(() {
        _repetitionCount = rec.repetitionCount;
        _currentStatus = rec.status;
      });
    }
  }

  Future<void> _setStatus(HafalanStatus status) async {
    HapticFeedback.mediumImpact();
    final rec = await HapalanProgressService.updatePracticeProgress(
      surahNumber: _currentSurahNumber,
      ayahNumber: _currentAyahNumber,
      status: status,
    );
    if (mounted) {
      setState(() {
        _currentStatus = rec.status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status ayat diubah menjadi: ${status.displayName}'),
          backgroundColor: const Color(0xFF518427),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ayah = _currentAyah;
    final currentIndex = _ayahList.indexWhere((a) => a.ayahNumber == _currentAyahNumber);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex >= 0 && currentIndex < _ayahList.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF518427),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CustomBackButton(
              popResult: true,
            ),
          ),
        ),
        title: Text(
          'Latihan Hafalan',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          // Info Info icon
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () {
              _showTutorialDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF518427)),
            )
          : Column(
              children: [
                // Top Status Badges Row
                _buildTopBadges(),

                // Main Memorization Card
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMemorizationCard(ayah),
                        const SizedBox(height: 16),
                        _buildStatusButtonsRow(),
                      ],
                    ),
                  ),
                ),

                // Bottom Counter Tap Button & Navigation Row
                _buildBottomControls(context, hasPrev, hasNext),
              ],
            ),
    );
  }

  Widget _buildTopBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Badge 1: Pengulangan (Orange pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_repetitionCount',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              ],
            ),
          ),

          // Badge 2: Status Hafalan (Green pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentStatus.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(HafalanStatus status) {
    switch (status) {
      case HafalanStatus.sudahDikuasai:
        return const Color(0xFF518427);
      case HafalanStatus.memerlukanLatihan:
        return const Color(0xFFE67E22);
      case HafalanStatus.sedangDipelajari:
        return const Color(0xFF2E7D32);
      case HafalanStatus.belumDipelajari:
      default:
        return const Color(0xFF78909C);
    }
  }

  Widget _buildMemorizationCard(SurahAyah ayah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF518427), // Kartu hijau khas Muslim Habit
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF518427).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Kartu: Nama Surah, Ayat, & Tombol Toggle Sembunyikan Teks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_currentSurahName, Ayat $_currentAyahNumber',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              // Tombol Hide/Show Text (Uji Ingatan)
              InkWell(
                onTap: () {
                  setState(() {
                    _isTextHidden = !_isTextHidden;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isTextHidden
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isTextHidden ? 'Tampilkan' : 'Uji Ingat',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Teks Arab Lengkap Beserta Harakat
          if (_isTextHidden)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology_rounded, size: 40, color: Colors.white70),
                  const SizedBox(height: 10),
                  Text(
                    'Teks Arab Disembunyikan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ucapkan ayat dari ingatanmu, lalu ketuk "Tampilkan" untuk memeriksa.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              ayah.arabicText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 2.1,
              ),
            ),
            const SizedBox(height: 16),

            // Transliterasi Latin
            if (ayah.latinText.isNotEmpty)
              Text(
                ayah.latinText,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 10),

            // Terjemahan Bahasa Indonesia
            Text(
              ayah.translation,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 28),

          // Audio Controls Panel (Kecepatan, Play/Pause, Pengulangan Loop)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kecepatan Audio (0.5x, 0.75x, 1x, 1.25x)
              InkWell(
                onTap: _cycleSpeed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_playbackSpeed}x',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Tombol Putar Audio Utama
              InkWell(
                onTap: _togglePlayAudio,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Tombol Pengulangan Audio (Loop)
              InkWell(
                onTap: _toggleLoop,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isLooping
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.repeat_rounded,
                      size: 22,
                      color: _isLooping ? const Color(0xFF518427) : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtonsRow() {
    return Row(
      children: [
        // Tombol Memerlukan Latihan
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _setStatus(HafalanStatus.memerlukanLatihan),
            icon: const Icon(Icons.sync_problem_rounded, size: 16, color: Color(0xFFE67E22)),
            label: Text(
              'Perlu Latihan',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFE67E22)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE67E22)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Sudah Dikuasai
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _setStatus(HafalanStatus.sudahDikuasai),
            icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
            label: Text(
              'Sudah Hafal',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF518427),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context, bool hasPrev, bool hasNext) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Hitung Pengulangan (Ketuk untuk hitung)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _incrementRepetition,
                  icon: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
                  label: Text(
                    'Ketuk untuk hitung (${_repetitionCount}x)',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3710),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Navigasi Ayat Sebelumnya / Berikutnya
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: hasPrev ? _prevAyah : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: Text(
                      'Ayat Sebelumnya',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF518427),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: hasNext ? _nextAyah : null,
                    icon: Text(
                      'Ayat Berikutnya',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    label: const Icon(Icons.chevron_right_rounded),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF518427),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cara Menghafal Efektif',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tutorialItem('1. Dengarkan', 'Putar audio beberapa kali untuk memastikan makhraj dan harakat benar.'),
            _tutorialItem('2. Tirukan & Ulangi', 'Ucapkan ayat secara mandiri dan ketuk tombol "Ketuk untuk hitung".'),
            _tutorialItem('3. Uji Ingatan', 'Tekan "Uji Ingat" untuk menyembunyikan teks dan membacanya dari ingatan.'),
            _tutorialItem('4. Tandai Hafal', 'Tandai "Sudah Hafal" setelah menguasainya dengan lancar.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _tutorialItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
