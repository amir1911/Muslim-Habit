import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/quran_provider.dart';
import '../surah_detail_screen.dart';

class QuranBookmarkTab extends StatelessWidget {
  const QuranBookmarkTab({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProv = context.watch<QuranProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bookmark header / info
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EEE0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF557C2B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bookmark_added_rounded, color: Color(0xFF557C2B), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ayat Tersimpan',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tandai ayat favorit Anda saat membaca Al-Qur\'an',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF7A8B6E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Default / pinned favorite bookmarks
        Text(
          'Bookmark Pilihan',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3710),
          ),
        ),
        const SizedBox(height: 12),

        _buildBookmarkCard(
          context: context,
          surahNumber: 2,
          surahName: 'Al-Baqarah',
          ayahNumber: 255,
          arabicSnippet: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
          latinSnippet: 'Ayat Kursi • Keagungan Allah',
          quranProv: quranProv,
        ),
        const SizedBox(height: 10),

        _buildBookmarkCard(
          context: context,
          surahNumber: 94,
          surahName: 'Ash-Sharh',
          ayahNumber: 6,
          arabicSnippet: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
          latinSnippet: 'Bersama kesulitan ada kemudahan',
          quranProv: quranProv,
        ),
        const SizedBox(height: 10),

        _buildBookmarkCard(
          context: context,
          surahNumber: 67,
          surahName: 'Al-Mulk',
          ayahNumber: 1,
          arabicSnippet: 'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ',
          latinSnippet: 'Pelindung siksa kubur',
          quranProv: quranProv,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBookmarkCard({
    required BuildContext context,
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String arabicSnippet,
    required String latinSnippet,
    required QuranProvider quranProv,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final surah = quranProv.surahList.firstWhere(
              (s) => s.number == surahNumber,
              orElse: () => quranProv.surahList.isNotEmpty
                  ? quranProv.surahList.first
                  : throw Exception('No surah'),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surah: surah,
                  initialAyah: ayahNumber,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEE0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$surahNumber',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$surahName : Ayat $ayahNumber',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3710),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latinSnippet,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF7A8B6E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  arabicSnippet,
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF557C2B),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF1E3710),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
