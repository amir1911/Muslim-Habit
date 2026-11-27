import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/surah_item.dart';
import '../../providers/quran_provider.dart';
import '../../services/hapalan_progress_service.dart';
import 'hafalan_practice_screen.dart';
import '../../core/widgets/custom_back_button.dart';

class HafalanSurahListScreen extends StatefulWidget {
  const HafalanSurahListScreen({super.key});

  @override
  State<HafalanSurahListScreen> createState() => _HafalanSurahListScreenState();
}

class _HafalanSurahListScreenState extends State<HafalanSurahListScreen> {
  // Set surah yang sedang dibuka dropdown-nya (accordion)
  final Set<int> _expandedSurahs = {2}; // Default Al-Baqarah terbuka

  // Filter tab aktif: 0: Semua / Untuk Dihafalkan, 1: Memerlukan Latihan, 2: Sudah Dikuasai
  int _selectedFilter = 0;

  // Cache record hafalan per surah { surahNumber: { ayahNumber: AyahHafalanRecord } }
  Map<int, Map<int, AyahHafalanRecord>> _hafalanCache = {};
  bool _isLoadingRecords = true;

  // Posisi hafalan terakhir
  int _recentSurah = 2;
  int _recentAyah = 1;

  @override
  void initState() {
    super.initState();
    _loadAllProgress();
  }

  Future<void> _loadAllProgress() async {
    setState(() => _isLoadingRecords = true);

    final recentS = await HapalanProgressService.getRecentSurah();
    final recentA = await HapalanProgressService.getRecentAyah();

    final allRecords = await HapalanProgressService.getAllRecords();
    final Map<int, Map<int, AyahHafalanRecord>> map = {};

    for (final rec in allRecords) {
      if (!map.containsKey(rec.surahNumber)) {
        map[rec.surahNumber] = {};
      }
      map[rec.surahNumber]![rec.ayahNumber] = rec;
    }

    if (mounted) {
      setState(() {
        _recentSurah = recentS;
        _recentAyah = recentA;
        _expandedSurahs.add(recentS);
        _hafalanCache = map;
        _isLoadingRecords = false;
      });
    }
  }

  void _toggleSurahExpansion(int surahNumber) {
    setState(() {
      if (_expandedSurahs.contains(surahNumber)) {
        _expandedSurahs.remove(surahNumber);
      } else {
        _expandedSurahs.add(surahNumber);
      }
    });
  }

  void _openPractice(int surahNumber, int ayahNumber) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HafalanPracticeScreen(
          initialSurahNumber: surahNumber,
          initialAyahNumber: ayahNumber,
        ),
      ),
    );

    // Refresh progres setelah kembali dari latihan
    if (result == true || mounted) {
      _loadAllProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranProv = context.watch<QuranProvider>();
    final surahList = quranProv.surahList.isNotEmpty
        ? quranProv.surahList
        : SurahItem.fallbackSurahList;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF518427),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CustomBackButton(),
          ),
        ),
        title: Text(
          'Target Hafalan Al-Qur\'an',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── 1. KARTU LANJUTKAN HAFALAN TERAKHIR ──
          _buildRecentResumeCard(surahList),

          // ── 2. FILTER STATUS CHIPS (Untuk Dihafalkan, Perlu Latihan, Sudah Dikuasai) ──
          _buildFilterChips(),

          // ── 3. DAFTAR SURAH ACCORDION BESERTA TOMBOL AYAT ──
          Expanded(
            child: _isLoadingRecords && surahList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF518427)),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 24),
                    itemCount: surahList.length,
                    itemBuilder: (context, index) {
                      final surah = surahList[index];
                      final isExpanded = _expandedSurahs.contains(surah.number);
                      final surahRecords = _hafalanCache[surah.number] ?? {};

                      return _buildSurahAccordionItem(surah, isExpanded, surahRecords);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResumeCard(List<SurahItem> list) {
    final surah = list.firstWhere(
      (s) => s.number == _recentSurah,
      orElse: () => list.isNotEmpty ? list.first : SurahItem.fallbackSurahList.first,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF518427).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_fill_rounded,
              color: Color(0xFF518427),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lanjutkan Hafalan',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${surah.nameLatin} • Ayat $_recentAyah',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3710),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _openPractice(_recentSurah, _recentAyah),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF518427),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Lanjut',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Semua Ayat', 'icon': Icons.menu_book_rounded},
      {'label': 'Perlu Latihan', 'icon': Icons.sync_problem_rounded},
      {'label': 'Sudah Dikuasai', 'icon': Icons.check_circle_rounded},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return ChoiceChip(
            showCheckmark: false,
            avatar: Icon(
              filters[index]['icon'] as IconData,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF518427),
            ),
            label: Text(
              filters[index]['label'] as String,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D3C21),
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFF518427),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? const Color(0xFF518427) : const Color(0xFFE0E5D8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (val) {
              setState(() {
                _selectedFilter = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSurahAccordionItem(
    SurahItem surah,
    bool isExpanded,
    Map<int, AyahHafalanRecord> surahRecords,
  ) {
    // Hitung berapa ayat yang sudah dihafal di surah ini
    final masteredCount = surahRecords.values.where((r) => r.status == HafalanStatus.sudahDikuasai).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? const Color(0xFF518427) : const Color(0xFFE8EEE0),
          width: isExpanded ? 1.5 : 1,
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
        children: [
          // Header Surah (Bisa diklik untuk buka/tutup)
          InkWell(
            onTap: () => _toggleSurahExpansion(surah.number),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Nomor Surah Badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFF518427)
                          : const Color(0xFF518427).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${surah.number}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isExpanded ? Colors.white : const Color(0xFF518427),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nama Surah & Detail
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
                        const SizedBox(height: 2),
                        Text(
                          '${surah.translation} • ${surah.numberOfAyahs} ayat ($masteredCount hafal)',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nama Arab & Icon Expand
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (surah.nameArabic.isNotEmpty)
                        Text(
                          surah.nameArabic,
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF518427),
                          ),
                        ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tombol Grid Nomor Ayat saat Accordion Terbuka
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: _buildAyahGrid(surah, surahRecords),
            ),
        ],
      ),
    );
  }

  Widget _buildAyahGrid(SurahItem surah, Map<int, AyahHafalanRecord> surahRecords) {
    final totalAyahs = surah.numberOfAyahs;
    final List<int> ayahsToShow = [];

    for (int i = 1; i <= totalAyahs; i++) {
      final rec = surahRecords[i];
      final status = rec?.status ?? HafalanStatus.belumDipelajari;

      if (_selectedFilter == 1 && status != HafalanStatus.memerlukanLatihan) {
        continue;
      }
      if (_selectedFilter == 2 && status != HafalanStatus.sudahDikuasai) {
        continue;
      }
      ayahsToShow.add(i);
    }

    if (ayahsToShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Tidak ada ayat dengan kriteria ini.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ayahsToShow.map((ayahNum) {
        final rec = surahRecords[ayahNum];
        final status = rec?.status ?? HafalanStatus.belumDipelajari;

        Color bgColor;
        Color textColor;
        Border? border;

        switch (status) {
          case HafalanStatus.sudahDikuasai:
            bgColor = const Color(0xFF518427); // Hijau solid jika sudah hafal
            textColor = Colors.white;
            break;
          case HafalanStatus.memerlukanLatihan:
            bgColor = const Color(0xFFFFF3E0);
            textColor = const Color(0xFFE67E22);
            border = Border.all(color: const Color(0xFFE67E22), width: 1.2);
            break;
          case HafalanStatus.sedangDipelajari:
            bgColor = const Color(0xFFE8F5E9);
            textColor = const Color(0xFF2E7D32);
            border = Border.all(color: const Color(0xFF81C784), width: 1);
            break;
          case HafalanStatus.belumDipelajari:
          default:
            bgColor = const Color(0xFFF1F5E9);
            textColor = const Color(0xFF4A5568);
            break;
        }

        return InkWell(
          onTap: () => _openPractice(surah.number, ayahNum),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: border,
            ),
            child: Center(
              child: Text(
                '$ayahNum',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
