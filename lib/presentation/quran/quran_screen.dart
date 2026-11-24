import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/surah_item.dart';
import '../../models/khatam/khatam_plan_model.dart';
import '../../providers/habit_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/khatam_provider.dart';
import '../khatam/khatam_reading_screen.dart';
import 'surah_detail_screen.dart';
import 'widgets/quran_belajar_tab.dart';
import 'widgets/quran_bookmark_tab.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  bool _showJuzView = false;

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
                color: const Color(0xFF518427),
                onRefresh: () => quranProv.loadSurahList(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Tab Segment Control (Baca, Belajar, Bookmark)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: _buildSegmentTabs(quranProv),
                      ),
                    ),

                    if (quranProv.selectedTabIndex == 0) ...[
                      // Recent Reading Card (Sederhana & Pendek)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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

                      // Daftar List Surat atau Juz
                      if (_showJuzView)
                        _buildJuzListSliver(context)
                      else
                        _buildSurahListSliver(context, quranProv),
                    ] else if (quranProv.selectedTabIndex == 1) ...[
                      // BELAJAR TAB
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: QuranBelajarTab(),
                        ),
                      ),
                    ] else ...[
                      // BOOKMARK TAB
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: QuranBookmarkTab(),
                        ),
                      ),
                    ],

                    // Bottom padding agar konten terakhir tidak tertutup floating bottom nav bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
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
      padding: const EdgeInsets.fromLTRB(10, 6, 16, 6),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E3710), size: 18),
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3710),
              ),
            ),
          ),

          // Streak badge (🔥 0)
          _buildPillBadge(
            icon: '🔥',
            label: '${habitProv.streakCount}',
          ),
          const SizedBox(width: 6),

          // XP badge (⭐ 755)
          _buildPillBadge(
            icon: '⭐',
            label: '${habitProv.userPoints}',
          ),
          const SizedBox(width: 6),

          // Notification Bell
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF3E611C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge({required String icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF518427),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
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
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = quranProv.selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => quranProv.setTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF518427) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF3D6318),
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
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          child: Row(
            children: [
              // Badge nomor lingkaran hijau sederhana
              _buildNumberBadge(surahNum, size: 40),
              const SizedBox(width: 12),

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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3710),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Ayat $ayahNum',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF7A8B6E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              percentText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF518427),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE4E9DC),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B6114)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

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
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D5010),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 13,
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
          _showJuzView ? 'Daftar Juz' : 'Daftar Surat',
          style: GoogleFonts.balooTammudu2(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3710),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _showJuzView = !_showJuzView;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B6114),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tampilan: ${_showJuzView ? "Juz" : "Surah"}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ────────────── JUZ LIST SLIVER ──────────────
  Widget _buildJuzListSliver(BuildContext context) {
    final khatamProv = context.watch<KhatamProvider>();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final juzNum = index + 1;
            return _buildJuzCard(context, juzNum, khatamProv);
          },
          childCount: 30,
        ),
      ),
    );
  }

  Widget _buildJuzCard(BuildContext context, int juzNum, KhatamProvider khatamProv) {
    final meta = JuzMetadata.getByJuzNumber(juzNum);
    final isCompleted = khatamProv.activePlan?.completedJuzList.contains(juzNum) ?? false;
    final isCurrent = khatamProv.activePlan?.currentJuz == juzNum;

    return Container(
      height: 86,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFF518427) : const Color(0xFFE8EEE0),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          khatamProv.loadAyahsForJuz(juzNum);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KhatamReadingScreen(juzNumber: juzNum),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              _buildNumberBadge(juzNum, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meta.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3710),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF518427),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Aktif',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF2C5220), size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Q.S ${_surahLatinName(meta.startSurah)} ${meta.startAyah} – Q.S ${_surahLatinName(meta.endSurah)} ${meta.endAyah} · ${meta.totalAyahs} Ayat',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF7A8B6E),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: isCurrent ? const Color(0xFF518427) : const Color(0xFFB0BAA5),
              ),
            ],
          ),
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
            child: CircularProgressIndicator(color: Color(0xFF518427)),
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

  // ────────────── SURAH CARD (85-90px, semi-bold, clean green circular icon, no Arabic) ──────────────
  Widget _buildSurahCard(BuildContext context, SurahItem surah) {
    return Container(
      height: 86,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // Ikon nomor lingkaran hijau sederhana
              _buildNumberBadge(surah.number, size: 40),
              const SizedBox(width: 14),

              // Nama Surat & Arti/Jumlah Ayat
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameLatin,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${surah.translation.isNotEmpty ? surah.translation : surah.revelation} · ${surah.numberOfAyahs} Ayat',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF7A8B6E),
                        fontWeight: FontWeight.w400,
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

  // ────────────── IKON NOMOR SURAH DENGAN ORNAMEN ASSET ──────────────
  Widget _buildNumberBadge(int number, {double size = 40}) {
    final fontSize = number >= 100 ? 11.5 : (number >= 10 ? 13.0 : 14.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/icon/lingkar nomor.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          Center(
            child: Text(
              '$number',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: nama Latin Surah berdasarkan nomor
  String _surahLatinName(int surahNum) {
    const names = {
      1: 'Al-Fatihah', 2: 'Al-Baqarah', 3: 'Ali Imran', 4: 'An-Nisa',
      5: 'Al-Maidah', 6: 'Al-Anam', 7: 'Al-Araf', 8: 'Al-Anfal',
      9: 'At-Taubah', 10: 'Yunus', 11: 'Hud', 12: 'Yusuf',
      13: 'Ar-Rad', 14: 'Ibrahim', 15: 'Al-Hijr', 16: 'An-Nahl',
      17: 'Al-Isra', 18: 'Al-Kahf', 19: 'Maryam', 20: 'Ta-Ha',
      21: 'Al-Anbiya', 22: 'Al-Hajj', 23: 'Al-Muminun', 24: 'An-Nur',
      25: 'Al-Furqan', 26: 'Asy-Syuara', 27: 'An-Naml', 28: 'Al-Qasas',
      29: 'Al-Ankabut', 30: 'Ar-Rum', 31: 'Luqman', 32: 'As-Sajdah',
      33: 'Al-Ahzab', 34: 'Saba', 35: 'Fatir', 36: 'Ya-Sin',
      37: 'As-Saffat', 38: 'Sad', 39: 'Az-Zumar', 40: 'Ghafir',
      41: 'Fussilat', 42: 'Asy-Syura', 43: 'Az-Zukhruf', 44: 'Ad-Dukhan',
      45: 'Al-Jasiyah', 46: 'Al-Ahqaf', 47: 'Muhammad', 48: 'Al-Fath',
      49: 'Al-Hujurat', 50: 'Qaf', 51: 'Az-Zariyat', 52: 'At-Tur',
      53: 'An-Najm', 54: 'Al-Qamar', 55: 'Ar-Rahman', 56: 'Al-Waqiah',
      57: 'Al-Hadid', 58: 'Al-Mujadilah', 59: 'Al-Hasyr', 60: 'Al-Mumtahanah',
      61: 'As-Saf', 62: 'Al-Jumuah', 63: 'Al-Munafiqun', 64: 'At-Tagabun',
      65: 'At-Tahrim', 66: 'At-Talaq', 67: 'Al-Mulk', 68: 'Al-Qalam',
      69: 'Al-Haqqah', 70: 'Al-Maarij', 71: 'Nuh', 72: 'Al-Jin',
      73: 'Al-Muzzammil', 74: 'Al-Muddassir', 75: 'Al-Qiyamah', 76: 'Al-Insan',
      77: 'Al-Mursalat', 78: 'An-Naba', 79: 'An-Naziat', 80: 'Abasa',
      81: 'At-Takwir', 82: 'Al-Infitar', 83: 'Al-Mutaffifin', 84: 'Al-Insyiqaq',
      85: 'Al-Buruj', 86: 'At-Tariq', 87: 'Al-Ala', 88: 'Al-Gasyiyah',
      89: 'Al-Fajr', 90: 'Al-Balad', 91: 'Asy-Syams', 92: 'Al-Lail',
      93: 'Ad-Duha', 94: 'Asy-Syarh', 95: 'At-Tin', 96: 'Al-Alaq',
      97: 'Al-Qadr', 98: 'Al-Bayyinah', 99: 'Az-Zalzalah', 100: 'Al-Adiyat',
      101: 'Al-Qariah', 102: 'At-Takasur', 103: 'Al-Asr', 104: 'Al-Humazah',
      105: 'Al-Fil', 106: 'Quraisy', 107: 'Al-Maun', 108: 'Al-Kausar',
      109: 'Al-Kafirun', 110: 'An-Nasr', 111: 'Al-Masad', 112: 'Al-Ikhlas',
      113: 'Al-Falaq', 114: 'An-Nas',
    };
    return names[surahNum] ?? 'Surah $surahNum';
  }
}
