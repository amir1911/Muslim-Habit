import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/khatam/khatam_plan_model.dart';
import '../../providers/khatam_provider.dart';

/// Halaman Baca Al-Qur'an Mode Khatam (KhatamReaderScreen)
class KhatamReadingScreen extends StatefulWidget {
  final int juzNumber;

  const KhatamReadingScreen({super.key, required this.juzNumber});

  @override
  State<KhatamReadingScreen> createState() => _KhatamReadingScreenState();
}

typedef KhatamReaderScreen = KhatamReadingScreen;

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

  /// Konversi angka Latin ke angka Arab (١, ٢, ٣, ...)
  String _toArabicNumeral(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final idx = int.tryParse(char);
      return idx != null ? arabicDigits[idx] : char;
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KhatamProvider>();
    final juzMeta = JuzMetadata.getByJuzNumber(prov.viewingJuz);
    final groups = prov.currentJuzGroups;

    final progressRatio = prov.viewingJuzProgressRatio;
    final progressPct = prov.viewingJuzProgressPercent;

    final surahName = groups.isNotEmpty ? groups.first.surahNameLatin : juzMeta.name;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF518427),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF518427),
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF84B74E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 26),
            ),
            onPressed: () {
              prov.stopAudio();
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            'Khatam Al-Qur’an',
            style: GoogleFonts.inter(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── PROGRESS BAR HIJAU TUA TEPAT DI BAWAH APPBAR ──
                  LinearProgressIndicator(
                    value: progressRatio > 0 ? progressRatio : 0.30,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF264E0B)),
                  ),

                  // ── SUBHEADER INFO: "Juz 14 Al Hijr" & "30%" ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    color: const Color(0xFFF7F6EE),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Juz ${prov.viewingJuz} $surahName',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF264E0B),
                          ),
                        ),
                        Text(
                          '$progressPct%',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8D8)),

                  // ── DAFTAR AYAT DENGAN TAMPILAN PERSIS REFERENSI ──
                  Expanded(
                    child: prov.isLoadingAyahs
                        ? const Center(
                            child: CircularProgressIndicator(color: Color(0xFF518427)),
                          )
                        : groups.isEmpty
                            ? Center(
                                child: Text(
                                  'Memuat ayat Juz ${prov.viewingJuz}...',
                                  style: GoogleFonts.inter(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                                itemCount: groups.length,
                                itemBuilder: (context, groupIndex) {
                                  final group = groups[groupIndex];
                                  final isStartOfSurah = group.ayahs.any((a) => a.ayah.ayahNumber == 1);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Lafaz Bismillah di Awal Surah (Kecuali Surah 9)
                                      if (isStartOfSurah && group.surahNumber != 9) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: Center(
                                            child: Text(
                                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirection.rtl,
                                              style: GoogleFonts.amiri(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],

                                      // Daftar Ayat
                                      ...group.ayahs.map((entry) {
                                        final key = _ayahKeys.putIfAbsent(
                                          entry.globalIndexInJuz,
                                          () => GlobalKey(),
                                        );
                                        final isPlayingThis =
                                            prov.isPlayingAudio && prov.playingAyahKey == entry.uniqueKey;

                                        return Container(
                                          key: key,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: Color(0xFFE2E8D8), width: 1),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Baris Teks Arab Utsmani & Ornamen Nomor Ayat
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Nomor Ayat Ornamen Emas (Kiri dari teks Arab)
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 4, right: 8),
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFBF4D8),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color(0xFFD6B962),
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _toArabicNumeral(entry.ayah.ayahNumber),
                                                        style: GoogleFonts.amiri(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: const Color(0xFF8C6D1F),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Teks Arab Lengkap Rata Kanan
                                                  Expanded(
                                                    child: Text(
                                                      entry.ayah.arabicText,
                                                      textAlign: TextAlign.right,
                                                      textDirection: TextDirection.rtl,
                                                      style: GoogleFonts.amiri(
                                                        fontSize: 23,
                                                        fontWeight: FontWeight.bold,
                                                        color: isPlayingThis
                                                            ? const Color(0xFF518427)
                                                            : const Color(0xFF1F2937),
                                                        height: 2.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 10),

                                              // Terjemahan Bahasa Indonesia Rata Kiri
                                              Text(
                                                entry.ayah.translation,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.5,
                                                  color: const Color(0xFF4B5563),
                                                  height: 1.45,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                },
                              ),
                  ),
                ],
              ),

              // ── FLOATING BOTTOM CONTROLS (PERSIS REFERENSI GAMBAR 1) ──
              Positioned(
                bottom: 18,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Tombol Bulat Kiri (<) Hijau Tua
                    GestureDetector(
                      onTap: () {
                        if (prov.viewingJuz > 1) {
                          prov.previousJuz();
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF124A18),
                          shape: BoxShape.circle,
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
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // 2. Bar Kapsul Putih Melayang (Kontrol Audio Murottal)
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Prev Ayat Audio
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              color: Color(0xFF1F2937),
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32),
                            onPressed: () {
                              prov.previousAyah();
                              _scrollToGlobalIndex(prov.currentAyahIndex);
                            },
                          ),
                          const SizedBox(width: 12),

                          // Play / Pause Circle Audio
                          GestureDetector(
                            onTap: () {
                              prov.toggleAudio(null);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1F2937),
                                  width: 1.8,
                                ),
                              ),
                              child: Icon(
                                prov.isPlayingAudio
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: const Color(0xFF1F2937),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Next Ayat Audio
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: Color(0xFF1F2937),
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32),
                            onPressed: () {
                              prov.nextAyah();
                              _scrollToGlobalIndex(prov.currentAyahIndex);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // 3. Tombol Bulat Kanan (>) Hijau Tua
                    GestureDetector(
                      onTap: () {
                        // Memperbarui progres bacaan khatam dan berpindah ke juz selanjutnya
                        prov.markJuzComplete(prov.viewingJuz);
                        if (prov.viewingJuz < 30) {
                          prov.nextJuz();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Alhamdulillah, Anda telah menyelesaikan seluruh 30 Juz!',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: const Color(0xFF518427),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF124A18),
                          shape: BoxShape.circle,
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
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
