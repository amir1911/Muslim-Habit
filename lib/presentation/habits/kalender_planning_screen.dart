import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';
import 'widgets/edit_plan_bottom_sheet.dart';

/// Halaman Kalender Planning (KalenderPlanningScreen)
class KalenderPlanningScreen extends StatefulWidget {
  const KalenderPlanningScreen({super.key});

  @override
  State<KalenderPlanningScreen> createState() => _KalenderPlanningScreenState();
}

class _KalenderPlanningScreenState extends State<KalenderPlanningScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeFilterChip;

  // Kalender Bulanan state
  DateTime _selectedDate = DateTime(2026, 4, 24); // Tanggal aktif sesuai referensi (24 April 2026)
  int _currentMonth = 4;
  int _currentYear = 2026;

  // Expansion states untuk 4 accordion
  bool _pagiExpanded = true;
  bool _siangExpanded = false;
  bool _soreExpanded = false;
  bool _malamExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _toArabicNumeral(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final idx = int.tryParse(char);
      return idx != null ? arabicDigits[idx] : char;
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final progressPct = habitProv.dailyProgressPercent > 0 ? habitProv.dailyProgressPercent : 15;

    // Filtered lists
    List<HabitItem> filterHabits(List<HabitItem> list) {
      if (_activeFilterChip != null && _activeFilterChip!.isNotEmpty) {
        return list.where((h) => h.title.toLowerCase().contains(_activeFilterChip!.toLowerCase())).toList();
      }
      if (_searchQuery.isNotEmpty) {
        return list.where((h) => h.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
      return list;
    }

    final pagiList = filterHabits(habitProv.pagiHabits);
    final siangList = filterHabits(habitProv.siangHabits);
    final soreList = filterHabits(habitProv.soreHabits);
    final malamList = filterHabits(habitProv.malamHabits);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF55822B),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF55822B),
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Kalender Planning',
            style: GoogleFonts.inter(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                    _activeFilterChip = null;
                  }
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        // ── FAB BULAT HIJAU ZAITUN BERIKON EDIT DI KANAN ──
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF55822B),
          elevation: 4,
          onPressed: () => EditPlanBottomSheet.show(context),
          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            children: [
              // ── SEARCH BAR & FILTER CHIP (JIKA AKTIF) ──
              if (_isSearching) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCCD7C9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Habbit Untuk Disesuaikan',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      suffixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_activeFilterChip == 'Sholat Dhuha') {
                            _activeFilterChip = null;
                          } else {
                            _activeFilterChip = 'Sholat Dhuha';
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _activeFilterChip == 'Sholat Dhuha'
                              ? const Color(0xFF55822B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCCD7C9)),
                        ),
                        child: Text(
                          '✕ Sholat Dhuha',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _activeFilterChip == 'Sholat Dhuha'
                                ? Colors.white
                                : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // ── 1. KARTU STATUS HARIAN (HIJAU TUA #2E5714) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5714),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E5714).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Atas: Tanggal & Jam Matahari
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jumat, 24 April 2026',
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '7 Dhu al-Qi\'dah 1447 H',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFFE2EAD8),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '10:00',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar & Teks Persentase
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Hari Ini',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE2EAD8),
                          ),
                        ),
                        Text(
                          '$progressPct%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // LinearProgressIndicator
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progressPct / 100.0).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: const Color(0xFF456B24),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9BC366)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. KARTU KALENDER BULANAN (PUTIH) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bulan & Navigasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'April 2026',
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Syawal 1447 - Dzulqa\'dah 1447',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Perkembangan Anda',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF55822B),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.chevron_left_rounded, size: 22, color: Color(0xFF4B5563)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF4B5563)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Baris Nama Hari (Min, Sen, Sel, Rab, Kam, Jum, Sab)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((d) {
                        return SizedBox(
                          width: 36,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),

                    // Grid Tanggal Kalender (7 Kolom)
                    _buildCalendarGrid(),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── 3. BAGIAN "HABBIT HARI INI" ──
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF264E0B)),
                  const SizedBox(width: 8),
                  Text(
                    'Habbit Hari ini',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── 4 ACCORDION / COLLAPSIBLE CARDS WAKTU ──
              // 1. Habit Pagi (04:00 - 10:00)
              _buildTimeSlotAccordion(
                title: 'Habit Pagi',
                subtitle: '${habitProv.pagiRatio} • 04:00-10:00',
                icon: Icons.wb_twilight_rounded,
                isExpanded: _pagiExpanded,
                onToggle: () => setState(() => _pagiExpanded = !_pagiExpanded),
                habits: pagiList,
                onCheckTap: (id) => habitProv.toggleHabit(id),
              ),

              const SizedBox(height: 10),

              // 2. Habit Siang
              _buildTimeSlotAccordion(
                title: 'Habit Siang',
                subtitle: habitProv.siangRatio,
                icon: Icons.wb_sunny_outlined,
                isExpanded: _siangExpanded,
                onToggle: () => setState(() => _siangExpanded = !_siangExpanded),
                habits: siangList,
                onCheckTap: (id) => habitProv.toggleHabit(id),
              ),

              const SizedBox(height: 10),

              // 3. Habit Sore
              _buildTimeSlotAccordion(
                title: 'Habit Sore',
                subtitle: habitProv.soreRatio,
                icon: Icons.wb_cloudy_outlined,
                isExpanded: _soreExpanded,
                onToggle: () => setState(() => _soreExpanded = !_soreExpanded),
                habits: soreList,
                onCheckTap: (id) => habitProv.toggleHabit(id),
              ),

              const SizedBox(height: 10),

              // 4. Habit Malam
              _buildTimeSlotAccordion(
                title: 'Habit Malam',
                subtitle: habitProv.malamRatio,
                icon: Icons.nightlight_round,
                isExpanded: _malamExpanded,
                onToggle: () => setState(() => _malamExpanded = !_malamExpanded),
                habits: malamList,
                onCheckTap: (id) => habitProv.toggleHabit(id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Tanggal-tanggal bulan April 2026 (1 April dimulai hari Rabu = kolom 3)
    // Baris 1: null, null, null, 1, 2, 3, 4
    final days = <int?>[
      null, null, null, 1, 2, 3, 4,
      5, 6, 7, 8, 9, 10, 11,
      12, 13, 14, 15, 16, 17, 18,
      19, 20, 21, 22, 23, 24, 25,
      26, 27, 28, 29, 30, null, null,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.9,
      ),
      itemCount: days.length,
      itemBuilder: (context, idx) {
        final dayNum = days[idx];
        if (dayNum == null) return const SizedBox.shrink();

        final isSelected = dayNum == 24; // 24 April 2026 aktif sesuai referensi
        final hijriDay = ((dayNum + 13) % 30) + 1; // Perkiraan tanggal Hijriah

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(2026, 4, dayNum);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E5714) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  _toArabicNumeral(hijriDay),
                  style: GoogleFonts.amiri(
                    fontSize: 10,
                    color: isSelected ? const Color(0xFFE2EAD8) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotAccordion({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<HabitItem> habits,
    required ValueChanged<String> onCheckTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Accordion
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFFB45309), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Konten List Habit saat expanded
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: habits.map((habit) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFBF9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        // Lingkaran Masjid Hijau Muda
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F2E2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mosque_rounded, color: Color(0xFF264E0B), size: 18),
                        ),
                        const SizedBox(width: 12),

                        // Judul Habit & Waktu / Recorded Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                habit.isCompleted && habit.recordedTime != null
                                    ? 'Recorded: ${habit.recordedTime}'
                                    : habit.scheduledTime,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: habit.isCompleted ? const Color(0xFF55822B) : const Color(0xFF6B7280),
                                  fontWeight: habit.isCompleted ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Centang Hijau Solid / Ikon Lonceng
                        GestureDetector(
                          onTap: () => onCheckTap(habit.id),
                          child: habit.isCompleted
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF55822B),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                )
                              : Icon(
                                  habit.isMuted
                                      ? Icons.notifications_off_outlined
                                      : Icons.notifications_none_rounded,
                                  size: 20,
                                  color: const Color(0xFF6B7280),
                                ),
                        ),
                        const SizedBox(width: 8),

                        // Panah >
                        const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
