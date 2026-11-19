import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/khatam/khatam_plan_model.dart';
import '../../providers/khatam_provider.dart';

class KhatamReadingScreen extends StatefulWidget {
  final int juzNumber;

  const KhatamReadingScreen({super.key, required this.juzNumber});

  @override
  State<KhatamReadingScreen> createState() => _KhatamReadingScreenState();
}

class _KhatamReadingScreenState extends State<KhatamReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<KhatamProvider>();
      if (prov.viewingJuz != widget.juzNumber || prov.currentJuzGroups.isEmpty) {
        prov.loadAyahsForJuz(widget.juzNumber);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToGlobalIndex(int globalIndex) {
    final key = _ayahKeys[globalIndex];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        alignment: 0.15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KhatamProvider>();
    final juzMeta = JuzMetadata.getByJuzNumber(prov.viewingJuz);
    final groups = prov.currentJuzGroups;
    final plan = prov.activePlan;

    final readCount = prov.readCountInViewingJuz;
    final totalAyahs = prov.totalAyahsInViewingJuz;
    final progressRatio = prov.viewingJuzProgressRatio;
    final progressPct = prov.viewingJuzProgressPercent;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () {
            prov.stopAudio();
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Juz ${prov.viewingJuz}',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              juzMeta.name,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP PROGRESS BAR & STATS ──
            ClipRRect(
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 4,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C5220)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF4A7C59)),
                      const SizedBox(width: 6),
                      Text(
                        '$readCount / $totalAyahs Ayat',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B432C),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$progressPct%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // ── SCROLLABLE LIST OF SURAH GROUPS & AYAHS ──
            Expanded(
              child: prov.isLoadingAyahs
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF4A7C59)),
                          SizedBox(height: 12),
                          Text('Memuat bacaan Juz dari API...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    )
                  : groups.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak dapat memuat ayat Juz ${prov.viewingJuz}.',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: groups.length,
                          itemBuilder: (context, groupIndex) {
                            final group = groups[groupIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── HEADER PEMISAH SURAH (SESUAI SYARAT USER) ──
                                _buildSurahHeaderCard(group),
                                const SizedBox(height: 14),

                                // Daftar Ayat dalam Surah ini
                                ...group.ayahs.map((entry) {
                                  final isRead = plan?.readAyahKeys.contains(entry.uniqueKey) ?? false;
                                  final isPlayingThis = prov.isPlayingAudio && prov.playingAyahKey == entry.uniqueKey;
                                  final key = _ayahKeys.putIfAbsent(entry.globalIndexInJuz, () => GlobalKey());

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      key: key,
                                      onTap: () {
                                        prov.markAyahRead(entry);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isPlayingThis
                                              ? const Color(0xFFEFF7E0)
                                              : (isRead ? const Color(0xFFFAFBF8) : Colors.white),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isPlayingThis
                                                ? const Color(0xFF8BA677)
                                                : (isRead ? const Color(0xFFE2E7DF) : const Color(0xFFE5E7EB)),
                                            width: isPlayingThis ? 1.5 : 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Baris Teks Arab & Aksi
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Checkbox bacaan
                                                GestureDetector(
                                                  onTap: () => prov.markAyahRead(entry),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Icon(
                                                      isRead
                                                          ? Icons.check_circle_rounded
                                                          : Icons.radio_button_unchecked_rounded,
                                                      size: 22,
                                                      color: isRead
                                                          ? const Color(0xFF4A7C59)
                                                          : const Color(0xFFD1D5DB),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                // Tombol audio mini per ayat
                                                GestureDetector(
                                                  onTap: () => prov.toggleAudio(entry),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Icon(
                                                      isPlayingThis
                                                          ? Icons.pause_circle_filled_rounded
                                                          : Icons.play_circle_outline_rounded,
                                                      size: 22,
                                                      color: const Color(0xFF4A7C59),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                // Teks Arab Utsmani Lengkap
                                                Expanded(
                                                  child: Text(
                                                    entry.ayah.arabicText,
                                                    textAlign: TextAlign.right,
                                                    textDirection: TextDirection.rtl,
                                                    style: GoogleFonts.amiri(
                                                      fontSize: 26,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF1B432C),
                                                      height: 1.9,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // Nomor Ayat dalam Ornamen Emas
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEF7D6),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: const Color(0xFFE6D27E)),
                                                  ),
                                                  child: Text(
                                                    '${entry.ayah.ayahNumber}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF7A5D00),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 12),

                                            // Terjemahan Bahasa Indonesia
                                            Padding(
                                              padding: const EdgeInsets.only(left: 36),
                                              child: Text(
                                                entry.ayah.translation,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF4B5563),
                                                  height: 1.45,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      // ── FLOATING BOTTOM CONTROLS (SESUAI GAMBAR 1) ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Juz Sebelumnya (<)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: prov.viewingJuz > 1 ? const Color(0xFF1B432C) : const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
                    onPressed: prov.viewingJuz > 1 ? () => prov.previousJuz() : null,
                  ),
                ),

                // Ayat Sebelumnya (|<<)
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Color(0xFF1B432C), size: 24),
                  onPressed: () {
                    prov.previousAyah();
                    _scrollToGlobalIndex(prov.currentAyahIndex);
                  },
                ),

                // Play / Pause Audio Ayat (▶ / ⏸)
                IconButton(
                  icon: Icon(
                    prov.isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: const Color(0xFF1B432C),
                    size: 36,
                  ),
                  onPressed: () {
                    prov.toggleAudio(null);
                  },
                ),

                // Ayat Selanjutnya (>>|)
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Color(0xFF1B432C), size: 24),
                  onPressed: () {
                    prov.nextAyah();
                    _scrollToGlobalIndex(prov.currentAyahIndex);
                  },
                ),

                // Juz Selanjutnya (>)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: prov.viewingJuz < 30 ? const Color(0xFF1B432C) : const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                    onPressed: prov.viewingJuz < 30 ? () => prov.nextJuz() : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── WIDGET HEADER PEMISAH SURAH ──
  Widget _buildSurahHeaderCard(JuzSurahGroup group) {
    final firstAyahInGroup = group.ayahs.first.ayah.ayahNumber;
    final lastAyahInGroup = group.ayahs.last.ayah.ayahNumber;
    final bool showBismillah = group.surahNumber != 9 && firstAyahInGroup == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7C59).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4A7C59).withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge nomor & nama surah
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${group.surahNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.surahNameLatin,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B432C),
                        ),
                      ),
                      Text(
                        '${group.surahTranslation} • Ayat $firstAyahInGroup - $lastAyahInGroup (${group.totalAyahsInJuz} Ayat)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF4A7C59),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Nama Surah Tulisan Arab
              Text(
                group.surahNameArabic,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B432C),
                ),
              ),
            ],
          ),

          // Teks Bismillah jika awal surah (bukan At-Taubah)
          if (showBismillah) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.8, color: Color(0xFFCCD7C9)),
            const SizedBox(height: 12),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B432C),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
