import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/utils/hijri_helper.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';
import 'services/habit_navigation_helper.dart';
import 'widgets/edit_plan_bottom_sheet.dart';
import '../../core/widgets/custom_back_button.dart';

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

  // Kalender Bulanan state otomatis mengikuti tanggal aktual
  late DateTime _selectedDate;
  late int _currentMonth;
  late int _currentYear;
  Timer? _clockTimer;
  String _currentTime = '';

  // Expansion states untuk 4 accordion
  bool _pagiExpanded = true;
  bool _siangExpanded = false;
  bool _soreExpanded = false;
  bool _malamExpanded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = now.month;
    _currentYear = now.year;
    _currentTime = DateFormat('HH:mm').format(now);

    // Update jam aktual setiap 30 detik
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('HH:mm').format(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
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
    final progressPct = habitProv.getProgressForDate(_selectedDate);

    // Ambil daftar habit sesuai tanggal yang dipilih
    final habitsForDate = habitProv.getHabitsForDate(_selectedDate);

    // Filtered lists berdasarkan pencarian atau filter chip
    List<HabitItem> filterHabits(List<HabitItem> list) {
      if (_activeFilterChip != null && _activeFilterChip!.isNotEmpty) {
        return list.where((h) => h.title.toLowerCase().contains(_activeFilterChip!.toLowerCase())).toList();
      }
      if (_searchQuery.isNotEmpty) {
        return list.where((h) => h.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
      return list;
    }

    final pagiList = filterHabits(habitsForDate.where((h) => h.timeSlot == 'pagi').toList());
    final siangList = filterHabits(habitsForDate.where((h) => h.timeSlot == 'siang').toList());
    final soreList = filterHabits(habitsForDate.where((h) => h.timeSlot == 'sore').toList());
    final malamList = filterHabits(habitsForDate.where((h) => h.timeSlot == 'malam').toList());

    String getSlotRatio(List<HabitItem> list) {
      final done = list.where((h) => h.isCompleted).length;
      return '$done/${list.length}';
    }

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
          leading: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: CustomBackButton(),
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
                              '${HijriHelper.getDayNameIndonesian(_selectedDate)}, ${_selectedDate.day} ${HijriHelper.getMonthNameIndonesian(_selectedDate.month)} ${_selectedDate.year}',
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              HijriHelper.fromGregorian(_selectedDate).toFormattedString(),
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
                              _currentTime,
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
                          _selectedDate.year == DateTime.now().year &&
                                  _selectedDate.month == DateTime.now().month &&
                                  _selectedDate.day == DateTime.now().day
                              ? 'Progress Hari Ini'
                              : 'Progress ${_selectedDate.day} ${HijriHelper.getMonthNameIndonesian(_selectedDate.month)}',
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
                              '${HijriHelper.getMonthNameIndonesian(_currentMonth)} $_currentYear',
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              HijriHelper.getHijriMonthRangeForGregorianMonth(_currentYear, _currentMonth),
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
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  if (_currentMonth == 1) {
                                    _currentMonth = 12;
                                    _currentYear--;
                                  } else {
                                    _currentMonth--;
                                  }
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.chevron_left_rounded, size: 22, color: Color(0xFF4B5563)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  if (_currentMonth == 12) {
                                    _currentMonth = 1;
                                    _currentYear++;
                                  } else {
                                    _currentMonth++;
                                  }
                                });
                              },
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

              // ── 3. BAGIAN "HABBIT HARI INI" / TANGGAL TERPILIH ──
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF264E0B)),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDate.year == DateTime.now().year &&
                            _selectedDate.month == DateTime.now().month &&
                            _selectedDate.day == DateTime.now().day
                        ? 'Habbit Hari ini'
                        : 'Habbit ${_selectedDate.day} ${HijriHelper.getMonthNameIndonesian(_selectedDate.month)}',
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
                subtitle: '${getSlotRatio(pagiList)} • 04:00-10:00',
                icon: Icons.wb_twilight_rounded,
                isExpanded: _pagiExpanded,
                onToggle: () => setState(() => _pagiExpanded = !_pagiExpanded),
                habits: pagiList,
                onCheckTap: (id) => habitProv.toggleHabitForDate(id, _selectedDate),
              ),

              const SizedBox(height: 10),

              // 2. Habit Siang
              _buildTimeSlotAccordion(
                title: 'Habit Siang',
                subtitle: getSlotRatio(siangList),
                icon: Icons.wb_sunny_outlined,
                isExpanded: _siangExpanded,
                onToggle: () => setState(() => _siangExpanded = !_siangExpanded),
                habits: siangList,
                onCheckTap: (id) => habitProv.toggleHabitForDate(id, _selectedDate),
              ),

              const SizedBox(height: 10),

              // 3. Habit Sore
              _buildTimeSlotAccordion(
                title: 'Habit Sore',
                subtitle: getSlotRatio(soreList),
                icon: Icons.wb_cloudy_outlined,
                isExpanded: _soreExpanded,
                onToggle: () => setState(() => _soreExpanded = !_soreExpanded),
                habits: soreList,
                onCheckTap: (id) => habitProv.toggleHabitForDate(id, _selectedDate),
              ),

              const SizedBox(height: 10),

              // 4. Habit Malam
              _buildTimeSlotAccordion(
                title: 'Habit Malam',
                subtitle: getSlotRatio(malamList),
                icon: Icons.nightlight_round,
                isExpanded: _malamExpanded,
                onToggle: () => setState(() => _malamExpanded = !_malamExpanded),
                habits: malamList,
                onCheckTap: (id) => habitProv.toggleHabitForDate(id, _selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Menghitung tanggal kalender dinamis dengan awal pekan hari Minggu
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final leadingEmptyCells = firstDayOfMonth.weekday % 7; // Dart: Sunday = 7 -> 7 % 7 = 0
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;

    final List<int?> days = [];
    for (int i = 0; i < leadingEmptyCells; i++) {
      days.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(d);
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }

    final now = DateTime.now();

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

        final isSelected = _selectedDate.year == _currentYear &&
            _selectedDate.month == _currentMonth &&
            _selectedDate.day == dayNum;
        final isToday = now.year == _currentYear &&
            now.month == _currentMonth &&
            now.day == dayNum;

        final hijriDate = HijriHelper.fromGregorian(DateTime(_currentYear, _currentMonth, dayNum));

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedDate = DateTime(_currentYear, _currentMonth, dayNum);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E5714) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF55822B), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isToday ? const Color(0xFF55822B) : const Color(0xFF1F2937)),
                  ),
                ),
                Text(
                  _toArabicNumeral(hijriDate.day),
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFBF9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          HabitNavigationHelper.navigateToActivity(context, habit);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onCheckTap(habit.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
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
                              ),
                              const SizedBox(width: 4),

                              // Panah >
                              const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                            ],
                          ),
                        ),
                      ),
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
