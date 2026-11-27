import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/hijri_helper.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';
import '../quran/quran_screen.dart';
import '../doa/doa_screen.dart';
import '../sholat/sholat_screen.dart';
import '../puasa/puasa_screen.dart';
import '../dzikir/dzikir_screen.dart';
import '../shell/main_navigation_shell.dart';
import '../../features/mascot/screens/mascot_hub_screen.dart';
import 'kalender_planning_screen.dart';
import 'widgets/edit_plan_bottom_sheet.dart';
import 'services/habit_navigation_helper.dart';
import '../../core/widgets/custom_back_button.dart';
import '../../core/widgets/streak_badge.dart';
import '../../core/widgets/notification_bell_button.dart';

/// HabbitDashboardScreen (Laman Utama Habbit Tracker)
/// Alias HabitsScreen untuk kompatibilitas dengan MainNavigationShell
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  // Tanggal aktif otomatis di strip mingguan (0: Sen, ..., 6: Min)
  int _selectedDayIndex = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          final switched = MainNavigationShell.switchToTab(context, 0);
          if (!switched) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationShell(initialIndex: 0)),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        appBar: _buildAppBar(context, habitProv),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // 1. Dua Kartu Ringkasan Atas (Sejajar)
              _buildTopSummaryCards(habitProv),
              const SizedBox(height: 14),

              // 2. Kartu Progres Utama (Hero Card)
              _buildHeroProgressCard(habitProv),
              const SizedBox(height: 14),

              // 3. Kartu Kalender Mingguan
              _buildWeeklyCalendarCard(context),
              const SizedBox(height: 16),

              // 4. Baris Tombol Fitur ("Fitur-Fitur")
              _buildFeatureButtonsRow(context),
              const SizedBox(height: 18),

              // 5. Bagian "Sebentar Lagi..."
              _buildUpcomingSection(context, habitProv),
              const SizedBox(height: 18),

              // 6. Bagian "Program Aktif"
              _buildActiveProgramSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // APP BAR (Judul di Kiri Samping Tombol Kembali)
  // ==========================================
  PreferredSizeWidget _buildAppBar(BuildContext context, HabitProvider habitProv) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F6EE),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: CustomBackButton(
          isLightBackground: true,
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final switched = MainNavigationShell.switchToTab(context, 0);
              if (!switched) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationShell(initialIndex: 0)),
                );
              }
            }
          },
        ),
      ),
      titleSpacing: 10,
      title: Text(
        'Habbit',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2E5714),
        ),
      ),
      actions: [
        // Pill Streak Api Terpadu
        StreakBadge(
          streakOverride: habitProv.streakCount,
          backgroundColor: const Color(0xFF2E5714),
          iconColor: const Color(0xFFFFB300),
        ),
        const SizedBox(width: 6),

        // Pill Poin Bintang Kuning
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF518427),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFD700),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${habitProv.userPoints}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Tombol Bulat Lonceng Notifikasi Terpadu
        const NotificationBellButton(
          backgroundColor: Color(0xFF2E5714),
          size: 34,
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  // ==========================================
  // 1. DUA KARTU RINGKASAN ATAS (SEJAJAR)
  // ==========================================
  Widget _buildTopSummaryCards(HabitProvider habitProv) {
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kartu Kiri (Hijau Tua) - Fokus Ibadahku & Maskot Nunu
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MascotHubScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5714),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E5714).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Fokus Ibadahku',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Nunu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Ilustrasi Maskot Unta Nunu
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: Image.asset(
                        'assets/images/mascot_nunu.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.pets_rounded,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Kartu Kanan (Putih) - My Streak & Api Oranye
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECE4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'My Streak',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF75856B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${habitProv.streakCount} days',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E5714),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Ikon Api Oranye Besar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF2E6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFF07026),
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. KARTU PROGRES UTAMA (HERO CARD - TARGET HARI INI)
  // ==========================================
  Widget _buildHeroProgressCard(HabitProvider habitProv) {
    // Mengambil data real-time progres 5 kategori ibadah
    final progressFraction = habitProv.fiveCategoriesProgressFraction;
    final displayPercent = habitProv.fiveCategoriesProgressPercent;
    final completedCount = habitProv.todayCompletedCategoriesCount;
    final targetCount = habitProv.todayTargetCategoriesCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E5714), Color(0xFF9BC366)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E5714).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator Tebal
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: progressFraction > 0 ? progressFraction : 0.05,
                  strokeWidth: 6.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '$displayPercent%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),

          // Teks Target Hari Ini (Real-Time Progres Habit)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Hari Ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$completedCount dari $targetCount aktivitas selesai',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. KARTU KALENDER MINGGUAN OTOMATIS
  // ==========================================
  Widget _buildWeeklyCalendarCard(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String toArabicNumeral(int number) {
      return number.toString().split('').map((char) {
        final idx = int.tryParse(char);
        return idx != null ? arabicDigits[idx] : char;
      }).join('');
    }

    final List<Map<String, dynamic>> daysData = [];
    for (int i = 0; i < 7; i++) {
      final d = DateTime(monday.year, monday.month, monday.day).add(Duration(days: i));
      final h = HijriHelper.fromGregorian(d);
      daysData.add({
        'day': dayLabels[i],
        'date': '${d.day}',
        'arabic': toArabicNumeral(h.day),
        'dateTime': d,
      });
    }

    final safeIndex = _selectedDayIndex.clamp(0, 6);
    final selectedDate = (daysData[safeIndex]['dateTime'] as DateTime?) ?? now;
    final hijriSelected = HijriHelper.fromGregorian(selectedDate);
    final currentTimeStr = DateFormat('HH:mm').format(now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tanggal Masehi & Hijriah di kiri, jam & link di kanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${HijriHelper.getDayNameIndonesian(selectedDate)}, ${selectedDate.day} ${HijriHelper.getMonthNameIndonesian(selectedDate.month)} ${selectedDate.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E5714),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hijriSelected.toFormattedString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF75856B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        color: Color(0xFF518427),
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentTimeStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E5714),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KalenderPlanningScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Text(
                      'Lihat Kalender >',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF518427),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Strip 7 Hari (Sen - Min)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(daysData.length, (index) {
              final item = daysData[index];
              final isSelected = index == _selectedDayIndex;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF518427)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item['day'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF75856B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['date'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF2E5714),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['arabic'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFFA0ABA0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Footer: Tombol Kanan Bawah "EditJadwal"
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => EditPlanBottomSheet.show(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EditJadwal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E5714),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit_square,
                      size: 15,
                      color: Color(0xFF2E5714),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. BARIS TOMBOL FITUR ("Fitur-Fitur")
  // ==========================================
  Widget _buildFeatureButtonsRow(BuildContext context) {
    final features = [
      {
        'label': 'Sholat',
        'asset': 'assets/icon/shalat.png',
        'icon': Icons.mosque_outlined,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SholatScreen()),
            ),
      },
      {
        'label': 'Al-Quran',
        'asset': 'assets/icon/Vector.png',
        'icon': Icons.menu_book_rounded,
        'onTap': () {
          if (!MainNavigationShell.switchToTab(context, 2)) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuranScreen()),
            );
          }
        },
      },
      {
        'label': 'Dzikir',
        'asset': 'assets/icon/Image (Dzikir).png',
        'icon': Icons.spa_rounded,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DzikirScreen()),
            ),
      },
      {
        'label': 'Doa',
        'asset': 'assets/icon/Image (Doa).png',
        'icon': Icons.volunteer_activism_rounded,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoaScreen()),
            ),
      },
      {
        'label': 'Puasa',
        'asset': 'assets/icon/Image (Malam).png',
        'icon': Icons.nightlight_round,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PuasaScreen()),
            ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur-Fitur',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E5714),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: features.map((feat) {
            final asset = feat['asset'] as String?;
            final icon = feat['icon'] as IconData;
            final label = feat['label'] as String;
            final onTap = feat['onTap'] as VoidCallback;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF518427),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF518427).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (asset != null)
                          Image.asset(
                            asset,
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                Icon(icon, color: Colors.white, size: 28),
                          )
                        else
                          Icon(icon, color: Colors.white, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================
  // 5. BAGIAN "Sebentar Lagi..."
  // ==========================================
  Widget _buildUpcomingSection(BuildContext context, HabitProvider habitProv) {
    final upcoming = habitProv.upcomingHabits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sebentar Lagi...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E5714),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KalenderPlanningScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Text(
                  'See More',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF518427),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (upcoming.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8ECE4)),
            ),
            child: Center(
              child: Text(
                'Tidak ada jadwal ibadah terdekat',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF75856B),
                ),
              ),
            ),
          )
        else
          ...upcoming.map((item) => _buildUpcomingCard(context, item, habitProv)),
      ],
    );
  }

  Widget _buildUpcomingCard(
    BuildContext context,
    HabitItem item,
    HabitProvider habitProv,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            HabitNavigationHelper.navigateToActivity(context, item);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Ikon Masjid / Kategori dalam Kotak Bulat Hijau Muda
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF2E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Color(0xFF518427),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Judul & Jam Jadwal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E5714),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF75856B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.scheduledTime,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF75856B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Toggle Notifikasi Lonceng
                IconButton(
                  icon: Icon(
                    item.isMuted
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_active_rounded,
                    color: item.isMuted
                        ? const Color(0xFFA0ABA0)
                        : const Color(0xFF518427),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    habitProv.toggleMute(item.id);
                  },
                ),

                // Chevron Kanan
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFA0ABA0),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 6. BAGIAN "Program Aktif"
  // ==========================================
  Widget _buildActiveProgramSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Program Aktif',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E5714),
              ),
            ),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka Komunitas MuslimHabit'),
                    duration: Duration(milliseconds: 1000),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      size: 15,
                      color: Color(0xFF518427),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Komunitas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF518427),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Kartu Hijau Tua Program Aktif
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E5714),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E5714).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SholatScreen(
                      initialCategoryIndex: 1,
                      initialPrayerKey: 'dhuha',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Baris Atas: Thumbnail, Judul, Lonceng, Chevron
                    Row(
                      children: [
                        // Lingkaran Avatar / Thumbnail
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mosque_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Judul Program
                        Expanded(
                          child: Text(
                            'Target baru sholat dhuha s...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Lonceng & Panah Kanan
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Baris Bawah: Badge 1 Minggu, 100 XP, 0/7 Sholat Dhuha
                    Row(
                      children: [
                        // Pill Durasi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '1 Minggu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Pill XP
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFD700),
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '100 XP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        // Teks Progress Target
                        Text(
                          '0/7 Sholat Dhuha',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Alias HabbitDashboardScreen agar sesuai penamaan di instruksi
typedef HabbitDashboardScreen = HabitsScreen;
