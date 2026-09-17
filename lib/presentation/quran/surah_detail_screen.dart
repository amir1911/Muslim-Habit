import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/surah_item.dart';
import '../../models/surah_detail.dart';
import '../../providers/quran_provider.dart';
import 'widgets/islamic_star_badge.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahItem surah;
  final int? initialAyah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahDetail(widget.surah.number);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranProv = context.watch<QuranProvider>();
    final detail = quranProv.currentSurahDetail;
    final isLoading = quranProv.isLoadingDetail;
    final errorMsg = quranProv.detailErrorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F8F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E3710), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.surah.nameLatin,
              style: GoogleFonts.balooTammudu2(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3710),
                height: 1.1,
              ),
            ),
            Text(
              '${widget.surah.translation} · ${widget.surah.numberOfAyahs} Ayat',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF557C2B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E3710)),
            tooltip: 'Muat Ulang',
            onPressed: () => quranProv.loadSurahDetail(widget.surah.number),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF557C2B)),
                  SizedBox(height: 16),
                  Text('Memuat ayat-ayat Al-Qur\'an...'),
                ],
              ),
            )
          : errorMsg != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          errorMsg,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => quranProv.loadSurahDetail(widget.surah.number),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF557C2B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : detail == null || detail.ayahs.isEmpty
                  ? const Center(child: Text('Tidak ada data ayat.'))
                  : CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Header Surah Card
                        SliverToBoxAdapter(
                          child: _buildSurahBanner(detail),
                        ),

                        // List Ayat
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, index) {
                                final ayah = detail.ayahs[index];
                                return _buildAyahCard(ayah, detail);
                              },
                              childCount: detail.ayahs.length,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSurahBanner(SurahDetail detail) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B6114), Color(0xFF557C2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B6114).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            detail.nameLatin,
            style: GoogleFonts.balooTammudu2(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            '${detail.translation} · ${detail.revelation} · ${detail.numberOfAyahs} Ayat',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          // Bismillah (kecuali Surah At-Taubah #9)
          if (detail.number != 9) ...[
            Container(
              height: 1,
              width: 140,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 14),
            Text(
              'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
              style: GoogleFonts.amiri(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAyahCard(SurahAyah ayah, SurahDetail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris Nomor Ayat & Tombol Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IslamicStarBadge(
                number: ayah.ayahNumber,
                size: 36,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline_rounded, size: 20, color: Color(0xFF557C2B)),
                    tooltip: 'Tandai Terakhir Dibaca',
                    onPressed: () {
                      final progress = (ayah.ayahNumber / detail.numberOfAyahs).clamp(0.0, 1.0);
                      context.read<QuranProvider>().updateRecentReading(
                            surahNumber: detail.number,
                            surahName: detail.nameLatin,
                            ayahNumber: ayah.ayahNumber,
                            progress: progress,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tersimpan: ${detail.nameLatin} Ayat ${ayah.ayahNumber}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF557C2B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Teks Arab
          Text(
            ayah.arabicText,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3710),
              height: 2.1,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),

          // Terjemahan Bahasa Indonesia
          Text(
            ayah.translation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF333333),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
