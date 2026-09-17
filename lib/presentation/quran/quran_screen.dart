import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/surah_item.dart';
import '../../providers/habit_provider.dart';
import '../../providers/quran_provider.dart';
import 'surah_detail_screen.dart';
import 'widgets/islamic_star_badge.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final quranProv = context.watch<QuranProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── TOP HEADER (Back arrow, Al-Quran, Badges, Bell) ──
            _buildTopHeader(context, habitProv),

            // ── SCROLLABLE BODY ──
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF557C2B),
                onRefresh: () => quranProv.loadSurahList(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Tab Segment Control (Baca, Belajar, Bookmark)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: _buildSegmentTabs(quranProv),
                      ),
                    ),

                    // Recent Reading Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: _buildRecentCard(context, quranProv),
                      ),
                    ),

                    // Section Title: Daftar Surat & Dropdown Tampilan
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: _buildDaftarSuratHeader(quranProv),
                      ),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: _buildSearchBar(quranProv),
                      ),
                    ),

                    // Daftar List Surat
                    _buildSurahListSliver(context, quranProv),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
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

  // ────────────── TOP HEADER ──────────────
  Widget _buildTopHeader(BuildContext context, HabitProvider habitProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E3710), size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 4),

          // Title
          Expanded(
            child: Text(
              'Al-Quran',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3710),
              ),
            ),
          ),

          // Streak badge (🔥 17)
          _buildPillBadge(
            icon: '🔥',
            label: '${habitProv.streakCount}',
          ),
          const SizedBox(width: 6),

          // XP badge (⭐ 10)
          _buildPillBadge(
            icon: '⭐',
            label: '${habitProv.userPoints}',
          ),
          const SizedBox(width: 8),

          // Notification Bell
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF3E611C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge({required String icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF557C2B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── SEGMENT TABS (Baca, Belajar, Bookmark) ──────────────
  Widget _buildSegmentTabs(QuranProvider quranProv) {
    final tabs = ['Baca', 'Belajar', 'Bookmark'];
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7D8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = quranProv.selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => quranProv.setTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF557C2B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF42562E),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ────────────── RECENT READING CARD ──────────────
  Widget _buildRecentCard(BuildContext context, QuranProvider quranProv) {
    final surahNum = quranProv.recentSurahNumber;
    final surahName = quranProv.recentSurahName;
    final ayahNum = quranProv.recentAyahNumber;
    final progress = quranProv.recentProgress;
    final percentText = '${(progress * 100).toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7A8B6E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
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
              // Badge nomor surat recent
              IslamicStarBadge(
                number: surahNum,
                size: 46,
              ),
              const SizedBox(width: 14),

              // Info & Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          surahName,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3710),
                          ),
                        ),
                        Text(
                          'Ayat $ayahNum',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF7A8B6E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFE4E9DC),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B6114)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          percentText,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF557C2B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Tombol Bulat Panah Kanan `>`
              GestureDetector(
                onTap: () {
                  final surahItem = quranProv.surahList.firstWhere(
                    (s) => s.number == surahNum,
                    orElse: () => SurahItem(
                      number: surahNum,
                      nameLatin: surahName,
                      nameArabic: '',
                      nameId: surahName,
                      translation: '',
                      numberOfAyahs: 286,
                      revelation: 'Madaniyah',
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(
                        surah: surahItem,
                        initialAyah: ayahNum,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D5010),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────── SECTION TITLE + DROPDOWN TAMPILAN ──────────────
  Widget _buildDaftarSuratHeader(QuranProvider quranProv) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Surat',
          style: GoogleFonts.balooTammudu2(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3710),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF3B6114),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tampilan: ${quranProv.viewFilter}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────── SEARCH BAR ──────────────
  Widget _buildSearchBar(QuranProvider quranProv) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => quranProv.searchSurah(val),
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E3710)),
        decoration: InputDecoration(
          hintText: 'Cari nama surat atau nomor...',
          hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF557C2B), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 16, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    quranProv.searchSurah('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // ────────────── SURAH LIST SLIVER ──────────────
  Widget _buildSurahListSliver(BuildContext context, QuranProvider quranProv) {
    if (quranProv.isLoadingSurahs && quranProv.surahList.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF557C2B)),
          ),
        ),
      );
    }

    final list = quranProv.surahList;
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Surat tidak ditemukan.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final surah = list[index];
            return _buildSurahCard(context, surah);
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, SurahItem surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(surah: surah),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Badge nomor surat segi 8
              IslamicStarBadge(
                number: surah.number,
                size: 44,
              ),
              const SizedBox(width: 14),

              // Nama Surat & Arti/Jumlah Ayat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameLatin,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${surah.translation.isNotEmpty ? surah.translation : surah.revelation} · ${surah.numberOfAyahs} Ayat',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF7A8B6E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Tulisan Arab Nama Surat
              if (surah.nameArabic.isNotEmpty)
                Text(
                  surah.nameArabic,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF557C2B),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
