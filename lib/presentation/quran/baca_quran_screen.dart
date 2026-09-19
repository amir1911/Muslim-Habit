import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/surah_item.dart';
import '../../models/surah_detail.dart';
import '../../providers/baca_quran_provider.dart';
import 'widgets/audio_player_panel.dart';
import 'widgets/reading_settings_sheet.dart';
import 'widgets/verse_card.dart';

class BacaQuranScreen extends StatefulWidget {
  final SurahItem surah;
  final int? initialAyah;

  const BacaQuranScreen({
    super.key,
    required this.surah,
    this.initialAyah,
  });

  @override
  State<BacaQuranScreen> createState() => _BacaQuranScreenState();
}

class _BacaQuranScreenState extends State<BacaQuranScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _showResumeBanner = false;
  int _lastReadToResume = 0;

  @override
  void initState() {
    super.initState();
    _checkResumeBanner();
  }

  void _checkResumeBanner() {
    // Cek apakah ada last read sebelumnya untuk ditampilkan di banner "Lanjutkan Membaca"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final prov = context.read<BacaQuranProvider>();
      final lastRead = prov.progress.lastReadVerse;
      if (lastRead > 0 && lastRead < prov.progress.totalAyahs && widget.initialAyah == null) {
        setState(() {
          _showResumeBanner = true;
          _lastReadToResume = lastRead;
        });
      }

      // Jika ada initialAyah (misalnya diklik dari Recent di beranda), scroll ke sana
      if (widget.initialAyah != null && widget.initialAyah! > 0) {
        _scrollToAyah(widget.initialAyah!);
        prov.clearInitialScroll();
      }
    });
  }

  GlobalKey _getKeyForAyah(int ayahNumber) {
    return _ayahKeys.putIfAbsent(ayahNumber, () => GlobalKey());
  }

  void _scrollToAyah(int ayahNumber) {
    Future.delayed(const Duration(milliseconds: 200), () {
      final key = _ayahKeys[ayahNumber];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: 0.12, // Agar berada tepat di bawah sticky progress header
        );
      }
    });
  }

  /// INTERAKSI UTAMA:
  /// Tap ayat -> Mark as read -> Update progress -> Save -> Delay 350ms -> Smooth scroll ke ayat berikutnya
  void _onVerseTapped(BacaQuranProvider prov, int tappedAyah) {
    // 1-6. Tandai dibaca, update progress, simpan state
    final nextAyah = prov.markVerseAsRead(tappedAyah);

    // 7-8. Setelah delay 350ms, lakukan smooth scroll ke ayat berikutnya (ayat berikutnya menjadi active)
    if (nextAyah != tappedAyah) {
      Future.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        final key = _ayahKeys[nextAyah];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeInOutCubic,
            alignment: 0.12,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BacaQuranProvider>();

    // Tema warna berdasarkan setting (light, sepia, dark)
    Color scaffoldBg = const Color(0xFFF9F8F2);
    Color cardBg = Colors.white;
    Color textColor = const Color(0xFF1E3710);
    Color transColor = const Color(0xFF4A4A4A);

    if (prov.readerTheme == 'light') {
      scaffoldBg = Colors.white;
      cardBg = const Color(0xFFFFFFFF);
      textColor = const Color(0xFF1A2E05);
      transColor = const Color(0xFF333333);
    } else if (prov.readerTheme == 'dark') {
      scaffoldBg = const Color(0xFF141414);
      cardBg = const Color(0xFF1E1E1E);
      textColor = const Color(0xFFE8F5E9);
      transColor = const Color(0xFFB0BEC5);
    }

    final detail = prov.surahDetail;
    final totalAyahs = detail?.ayahs.length ?? widget.surah.numberOfAyahs;
    final readCount = prov.progress.readCount;
    final progressVal = totalAyahs > 0 ? (readCount / totalAyahs).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progressVal * 100).toStringAsFixed(1).replaceAll('.', ',');

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ── 1. HEADER HIJAU ISLAMI (Sesuai Screenshot) ──
                _buildIslamicHeader(context, prov),

                // ── 2. PROGRESS MEMBACA (Sesuai Screenshot) ──
                _buildReadingProgressSection(
                  surahName: widget.surah.nameLatin,
                  readCount: readCount,
                  totalAyahs: totalAyahs,
                  progressVal: progressVal,
                  progressPercent: progressPercent,
                  isDark: prov.readerTheme == 'dark',
                ),

                // ── 3. BANNER "LANJUTKAN MEMBACA" (Jika Ada Sesi Terakhir) ──
                if (_showResumeBanner) _buildResumeReadingBanner(prov),

                // ── 4. KONTEN AYAT-AYAT AL-QUR'AN ──
                Expanded(
                  child: prov.isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF557C2B)),
                              SizedBox(height: 16),
                              Text(
                                'Memuat ayat Al-Qur\'an...',
                                style: TextStyle(color: Color(0xFF557C2B)),
                              ),
                            ],
                          ),
                        )
                      : prov.errorMessage != null
                          ? _buildErrorView(prov)
                          : detail == null || detail.ayahs.isEmpty
                              ? const Center(child: Text('Ayat tidak tersedia'))
                              : ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 120),
                                  itemCount: detail.ayahs.length + 1, // +1 untuk Header Bismillah
                                  itemBuilder: (ctx, index) {
                                    if (index == 0) {
                                      // Header Bismillah di awal surah (kecuali At-Taubah #9)
                                      return _buildBismillahHeader(detail, prov.readerTheme == 'dark');
                                    }

                                    final ayahIndex = index - 1;
                                    final ayah = detail.ayahs[ayahIndex];
                                    final ayahNum = ayah.ayahNumber;
                                    final readState = prov.getVerseState(ayahNum);
                                    final isBookmarked = prov.isBookmarked(ayahNum);
                                    final isAudioPlaying = prov.isPlayingAudio && prov.currentAudioAyah == ayahNum;

                                    return Container(
                                      key: _getKeyForAyah(ayahNum),
                                      child: VerseCard(
                                        ayahNumber: ayahNum,
                                        arabicText: ayah.arabicText,
                                        translation: ayah.translation,
                                        readState: readState,
                                        isBookmarked: isBookmarked,
                                        isAudioPlaying: isAudioPlaying,
                                        showTajwid: prov.showTajwid,
                                        showTranslation: prov.showTranslation,
                                        arabicFontSize: prov.arabicFontSize,
                                        translationFontSize: prov.translationFontSize,
                                        cardBackground: cardBg,
                                        textColor: textColor,
                                        translationColor: transColor,
                                        onTap: () => _onVerseTapped(prov, ayahNum),
                                        onToggleBookmark: () => prov.toggleBookmark(ayahNum),
                                        onPlayAudio: () {
                                          if (isAudioPlaying) {
                                            prov.togglePlayPause();
                                          } else {
                                            prov.playAyahAudio(ayahNum);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),

            // ── 5. FLOATING AUDIO PLAYER (Di bagian bawah layar) ──
            if (!prov.isLoading && detail != null && detail.ayahs.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: AudioPlayerPanel(
                  currentAyah: prov.currentAudioAyah,
                  totalAyahs: totalAyahs,
                  surahName: widget.surah.nameLatin,
                  isPlaying: prov.isPlayingAudio,
                  isRepeat: prov.isRepeatAudio,
                  isAutoNext: prov.isAutoNextAudio,
                  selectedQari: prov.selectedQari,
                  qariList: prov.qariList,
                  position: prov.audioPosition,
                  duration: prov.audioDuration,
                  onPlayPause: () => prov.togglePlayPause(),
                  onNext: () => prov.nextAudio(),
                  onPrevious: () => prov.previousAudio(),
                  onToggleRepeat: () => prov.toggleRepeat(),
                  onToggleAutoNext: () => prov.toggleAutoNext(),
                  onSelectQari: (qari) => prov.selectQari(qari),
                  onSeek: (pos) => prov.seekAudio(pos),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ────────────── 1. HEADER HIJAU ISLAMI ──────────────
  Widget _buildIslamicHeader(BuildContext context, BacaQuranProvider prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF4A7522), // Hijau Islami elegan sesuai referensi
      ),
      child: Row(
        children: [
          // Tombol Kembali Bulat Hijau Terang (sesuai screenshot)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF7EAC47), // Hijau muda bulat
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama Surah di Tengah
          Expanded(
            child: Text(
              "Al-Qur'an",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Settings Button ⚙️
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            tooltip: 'Pengaturan',
            onPressed: () => _openSettingsSheet(context, prov),
          ),

          // Bookmark Icon 🔖
          IconButton(
            icon: Icon(
              prov.bookmarkedAyahs.isNotEmpty ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            tooltip: 'Daftar Bookmark',
            onPressed: () => _showBookmarksSheet(context, prov),
          ),
        ],
      ),
    );
  }

  // ────────────── 2. PROGRESS BAR MEMBACA ──────────────
  Widget _buildReadingProgressSection({
    required String surahName,
    required int readCount,
    required int totalAyahs,
    required double progressVal,
    required String progressPercent,
    required bool isDark,
  }) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Teks Progress: Nama Surat (kiri), Ayat X / Y (tengah), Persen (kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                surahName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2C5611),
                ),
              ),
              Text(
                'Ayat $readCount / $totalAyahs',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A8B6E),
                ),
              ),
              Text(
                '$progressPercent%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF557C2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),

          // Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E9D8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A7522)),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── 3. BANNER "LANJUTKAN MEMBACA" ──────────────
  Widget _buildResumeReadingBanner(BacaQuranProvider prov) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC7DEB7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFF4A7522), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lanjutkan Membaca',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3710),
                  ),
                ),
                Text(
                  '${widget.surah.nameLatin} — Ayat $_lastReadToResume',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF557C2B)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7522),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() => _showResumeBanner = false);
              _scrollToAyah(_lastReadToResume);
              prov.setActiveVerse(_lastReadToResume);
            },
            child: Text(
              'Lanjutkan',
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _showResumeBanner = false),
          ),
        ],
      ),
    );
  }

  // ────────────── HEADER BISMILLAH DI AWAL SURAH ──────────────
  Widget _buildBismillahHeader(SurahDetail detail, bool isDark) {
    if (detail.number == 9) {
      // Surah At-Taubah tidak diawali bismillah
      return const SizedBox(height: 12);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFD4E157) : const Color(0xFF1E3710),
              height: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 1.5,
            color: const Color(0xFF557C2B).withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  // ────────────── ERROR VIEW ──────────────
  Widget _buildErrorView(BacaQuranProvider prov) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              prov.errorMessage ?? 'Gagal memuat ayat Al-Qur\'an',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => prov.loadAyahs(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7522),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────── MODALS ──────────────
  void _openSettingsSheet(BuildContext context, BacaQuranProvider prov) {
    ReadingSettingsSheet.show(
      context: context,
      arabicFontSize: prov.arabicFontSize,
      translationFontSize: prov.translationFontSize,
      showTajwid: prov.showTajwid,
      showTranslation: prov.showTranslation,
      readerTheme: prov.readerTheme,
      audioSpeed: prov.audioSpeed,
      onArabicFontSizeChanged: (v) => prov.setArabicFontSize(v),
      onTranslationFontSizeChanged: (v) => prov.setTranslationFontSize(v),
      onShowTajwidChanged: (v) => prov.setShowTajwid(v),
      onShowTranslationChanged: (v) => prov.setShowTranslation(v),
      onReaderThemeChanged: (v) => prov.setReaderTheme(v),
      onAudioSpeedChanged: (v) => prov.setAudioSpeed(v),
    );
  }

  void _showBookmarksSheet(BuildContext context, BacaQuranProvider prov) {
    final bookmarks = prov.bookmarkedAyahs.toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookmark Ayat (${bookmarks.length})',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3710),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 10),
              if (bookmarks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'Belum ada ayat yang dibookmark di surah ini.\nTekan ikon bookmark pada ayat untuk menyimpan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: bookmarks.length,
                    itemBuilder: (ctx, i) {
                      final ayahNum = bookmarks[i];
                      return ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F2DF),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$ayahNum',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B6114),
                            ),
                          ),
                        ),
                        title: Text(
                          '${widget.surah.nameLatin} — Ayat $ayahNum',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3710),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF557C2B),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _scrollToAyah(ayahNum);
                          prov.setActiveVerse(ayahNum);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
