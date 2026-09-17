import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';
import '../../providers/prayer_time_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/hadith_provider.dart';
import '../../providers/qibla_provider.dart';
import '../quran/quran_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN  (sesuai desain Figma)
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _totalQuranPages = 604;
  int _quranPageReading = 1;
  final String _currentSurah = 'Al-Baqarah';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final quranProvider = context.watch<QuranProvider>();
    final hadithProvider = context.watch<HadithProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Top green header (greeting + stats + mascot + prayer + ayah) ──
          SliverToBoxAdapter(
            child: _buildGreenHeader(context, provider, prayerProvider, quranProvider),
          ),

          // ── White content area ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Fitur-Fitur
                _buildSectionTitle('Fitur-Fitur'),
                const SizedBox(height: 12),
                _buildFeatureGrid(context),
                const SizedBox(height: 22),

                // Progres Habit
                _buildSectionTitle('Progres Habit'),
                const SizedBox(height: 12),
                _buildProgressCard(provider),
                const SizedBox(height: 22),

                // Al-Quran Reading Tracker
                _buildQuranTracker(),
                const SizedBox(height: 22),

                // Lanjutkan Sesi
                _buildSectionTitle('Lanjutkan Sesi'),
                const SizedBox(height: 12),
                _buildContinueCard(provider),
                const SizedBox(height: 14),

                // Hadis Harian
                _buildHadithCard(context, hadithProvider),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),

      // Floating Chat Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF557C2B),
        elevation: 4,
        mini: false,
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  // ────────────── GREEN HEADER (Nature background + Standing Mascot) ──────────────
  Widget _buildGreenHeader(BuildContext context, HabitProvider provider, PrayerTimeProvider prayerProvider, QuranProvider quranProvider) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Row + streak/stars/bell ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF4A7220), size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamualaikum',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF1E3710),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          provider.userName,
                          style: GoogleFonts.balooTammudu2(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3710),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Streak badge
                  _greenBadge(icon: '🔥', value: '${provider.streakCount}'),
                  const SizedBox(width: 6),

                  // XP/Stars badge
                  _greenBadge(icon: '⭐', value: '${provider.userPoints}'),
                  const SizedBox(width: 6),

                  // Bell
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7220),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),

            // ── Two Columns: (Left: Ayah + Prayer Card) & (Right: Speech + Mascot) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left column: Ayah card + Prayer widget
                  Expanded(
                    flex: 11,
                    child: Column(
                      children: [
                        // Ayah Card (live dari API MyQuran)
                        GestureDetector(
                          onTap: () => _showVerseDetailModal(context, quranProvider),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: quranProvider.isLoading
                                ? const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF557C2B),
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        quranProvider.currentVerse.arabicText,
                                        style: GoogleFonts.amiri(
                                          fontSize: 13,
                                          color: const Color(0xFF1E3710),
                                          fontWeight: FontWeight.w700,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.right,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        quranProvider.currentVerse.translation,
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          color: const Color(0xFF2E4717),
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        quranProvider.currentVerse.reference,
                                        style: GoogleFonts.inter(
                                          fontSize: 8.5,
                                          color: const Color(0xFF557C2B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Next Prayer Widget
                        _buildPrayerWidget(context, prayerProvider),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Right column: Speech Bubble + Mascot
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Speech bubble
                        _buildSpeechBubble('Semangat menghafal hari ini, ${context.read<HabitProvider>().userName.split(' ').first}!'),
                        const SizedBox(height: 2),

                        // Standing Camel mascot
                        SizedBox(
                          height: 165,
                          child: Image.asset(
                            'assets/images/mascot_standing.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Soft bottom transition to scaffold color
            Container(
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFF9F8F2).withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF233615),
              height: 1.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: ClipPath(
            clipper: _SpeechArrowClipper(),
            child: Container(
              width: 12,
              height: 8,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _greenBadge({required String icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7220),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.balooTammudu2(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerWidget(BuildContext context, PrayerTimeProvider prayerProvider) {
    final prayer = prayerProvider.nextPrayer;
    final city = prayerProvider.currentCity;
    final isLoading = prayerProvider.isLoading;

    return GestureDetector(
      onTap: () => _showPrayerScheduleModal(context, prayerProvider),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7CB83E), Color(0xFF538622)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B6114).withValues(alpha: 0.25),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SELANJUTNYA',
                          style: GoogleFonts.inter(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (isLoading) ...[
                          const SizedBox(width: 4),
                          const SizedBox(
                            width: 7,
                            height: 7,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prayer['name'] ?? 'Sholat',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        prayer['time'] ?? '--:--',
                        style: GoogleFonts.balooTammudu2(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'WIB',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.white70, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        city,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Emblem icon container (Tap to open Qibla Compass)
            GestureDetector(
              onTap: () => _showQiblaCompassModal(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F6919),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Image.asset(
                    'assets/icon/kiblat.png',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────── FEATURE GRID ──────────────
  Widget _buildFeatureGrid(BuildContext context) {
    final prayerProvider = context.read<PrayerTimeProvider>();
    final features = [
      {
        'label': 'Sholat',
        'asset': 'assets/icon/shalat.png',
        'icon': Icons.mosque_outlined,
        'onTap': () => _showPrayerScheduleModal(context, prayerProvider),
      },
      {
        'label': 'Al-Quran',
        'asset': 'assets/icon/Vector.png',
        'icon': Icons.menu_book_rounded,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuranScreen()),
        ),
      },
      {'label': 'Dzikir', 'asset': 'assets/icon/Image (Dzikir).png', 'icon': Icons.spa_rounded},
      {'label': 'Doa', 'asset': 'assets/icon/Image (Doa).png', 'icon': Icons.volunteer_activism_rounded},
      {'label': 'Puasa', 'asset': 'assets/icon/Image (Malam).png', 'icon': Icons.nightlight_round},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: features.map((f) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildFeatureItem(
              label: f['label'] as String,
              icon: f['icon'] as IconData?,
              asset: f['asset'] as String?,
              onTap: f['onTap'] as VoidCallback?,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String label,
    IconData? icon,
    String? asset,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF557C2B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF557C2B).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: asset != null
                  ? Image.asset(
                      asset,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon ?? Icons.help_outline, color: Colors.white, size: 28),
                    )
                  : Icon(icon ?? Icons.circle, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3C21),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── PROGRESS CARD ──────────────
  Widget _buildProgressCard(HabitProvider provider) {
    final progress = provider.progressFraction;
    final habits = provider.habits;

    // Show all up to 5 (Al-Quran, Shalat, Doa, Dzikir, Puasa)
    final displayHabits = [
      {'label': 'Al-Quran', 'done': habits.where((h) => h.id == 'tilawah').any((h) => h.isCompleted)},
      {'label': 'Shalat', 'done': habits.where((h) => h.category == HabitCategory.wajib && h.isCompleted).isNotEmpty},
      {'label': 'Doa', 'done': false},
      {'label': 'Dzikir', 'done': habits.where((h) => h.id == 'dzikir').any((h) => h.isCompleted)},
      {'label': 'Puasa', 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCDE8A0), width: 1),
      ),
      child: Row(
        children: [
          // Circular progress
          CustomPaint(
            size: const Size(88, 88),
            painter: _CircleProgressPainter(progress: progress),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.balooTammudu2(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D3C21),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Habit list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayHabits.map((h) {
                final done = h['done'] as bool;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? const Color(0xFF557C2B) : Colors.white,
                          border: Border.all(
                            color: done ? const Color(0xFF557C2B) : const Color(0xFFB0C09A),
                            width: 1.5,
                          ),
                        ),
                        child: done
                            ? const Icon(Icons.check, size: 9, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        h['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: done
                              ? const Color(0xFF2D3C21)
                              : const Color(0xFF5E6B52),
                          decoration: done ? TextDecoration.none : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── QURAN TRACKER ──────────────
  Widget _buildQuranTracker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSurah,
                      style: GoogleFonts.balooTammudu2(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3C21),
                      ),
                    ),
                    Text(
                      'Halaman $_quranPageReading dari $_totalQuranPages',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF5E6B52),
                      ),
                    ),
                  ],
                ),
              ),

              // Lanjut button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_quranPageReading < _totalQuranPages) {
                      _quranPageReading++;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF557C2B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Lanjut',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _quranPageReading / _totalQuranPages,
              backgroundColor: const Color(0xFFE8EEE0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF557C2B)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── CONTINUE CARD ──────────────
  Widget _buildContinueCard(HabitProvider provider) {
    // Find first incomplete habit
    final incompleteHabits = provider.habits.where((h) => !h.isCompleted).toList();
    final habit = incompleteHabits.isNotEmpty ? incompleteHabits.first : null;

    if (habit == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7E0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCDE8A0), width: 1),
        ),
        child: Text(
          'Maa Syaa Allah! Semua target hari ini selesai! 🎉',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3C21),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Habit icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(habit.icon, color: const Color(0xFF557C2B), size: 24),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        habit.title.length > 24
                            ? '${habit.title.substring(0, 24)}...'
                            : habit.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3C21),
                        ),
                      ),
                    ),
                    const Icon(Icons.notifications_none_rounded, size: 18, color: Color(0xFF8F9C84)),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8F9C84)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _infoChip(icon: Icons.calendar_today_outlined, text: '1 Minggu'),
                    const SizedBox(width: 10),
                    _infoChip(icon: Icons.bolt_rounded, text: '${habit.points} XP'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF5E6B52)),
                    const SizedBox(width: 4),
                    Text(
                      '0/7 ${habit.title}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF5E6B52),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF5E6B52)),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5E6B52),
          ),
        ),
      ],
    );
  }

  // ────────────── HADITH CARD (live dari API MyQuran) ──────────────
  Widget _buildHadithCard(BuildContext context, HadithProvider hadithProvider) {
    final hadith = hadithProvider.currentHadith;
    final isLoading = hadithProvider.isLoading;

    return GestureDetector(
      onTap: () => _showHadithDetailModal(context, hadithProvider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF557C2B),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📖 Hadis Harian',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF557C2B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF7E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hadith.grade,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B6114),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hadith.translation.isNotEmpty
                        ? hadith.translation
                        : '"${hadith.arabicText}"',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF2D3C21),
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hadith.takhrij,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF557C2B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ketuk untuk lihat selengkapnya',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ────────────── SECTION TITLE ──────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.balooTammudu2(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2D3C21),
      ),
    );
  }

  // ────────────── PRAYER MODAL & DIALOG ──────────────
  void _showPrayerScheduleModal(BuildContext context, PrayerTimeProvider prayerProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<PrayerTimeProvider>(
          builder: (context, provider, _) {
            final schedule = provider.schedule;
            final nextPrayer = provider.nextPrayer;
            final times = [
              {'name': 'Imsak', 'time': schedule.imsak, 'icon': Icons.nightlight_round},
              {'name': 'Subuh', 'time': schedule.subuh, 'icon': Icons.wb_twilight_rounded},
              {'name': 'Terbit', 'time': schedule.terbit, 'icon': Icons.wb_sunny_outlined},
              {'name': 'Dhuha', 'time': schedule.dhuha, 'icon': Icons.wb_sunny_rounded},
              {'name': 'Dzuhur', 'time': schedule.dzuhur, 'icon': Icons.wb_sunny_rounded},
              {'name': 'Ashar', 'time': schedule.ashar, 'icon': Icons.wb_cloudy_rounded},
              {'name': 'Maghrib', 'time': schedule.maghrib, 'icon': Icons.wb_twilight_rounded},
              {'name': 'Isya', 'time': schedule.isya, 'icon': Icons.bedtime_rounded},
            ];

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAF9F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF557C2B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jadwal Sholat Hari Ini',
                              style: GoogleFonts.balooTammudu2(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2D3C21),
                                height: 1.1,
                              ),
                            ),
                            Text(
                              schedule.date.isNotEmpty ? schedule.date : 'Bimas Islam Kemenag RI',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // City selector chip & Refresh
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showChangeCityDialog(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF7E0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCDE8A0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF557C2B)),
                              const SizedBox(width: 4),
                              Text(
                                provider.currentCity,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D3C21),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.edit_rounded, size: 12, color: Color(0xFF557C2B)),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Perbarui Jadwal',
                        onPressed: provider.isLoading ? null : () => provider.loadTodayPrayer(),
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF557C2B)),
                              )
                            : const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF557C2B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Prayer list cards
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: times.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = times[i];
                        final name = item['name'] as String;
                        final time = item['time'] as String;
                        final icon = item['icon'] as IconData;
                        final isNext = name.toLowerCase() == (nextPrayer['name'] ?? '').toLowerCase();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isNext ? const Color(0xFFEAF5D8) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isNext ? const Color(0xFF557C2B) : const Color(0xFFE5EAD8),
                              width: isNext ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                size: 18,
                                color: isNext ? const Color(0xFF557C2B) : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                                  color: isNext ? const Color(0xFF1E3710) : const Color(0xFF333333),
                                ),
                              ),
                              if (isNext) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF557C2B),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Berikutnya',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                '$time WIB',
                                style: GoogleFonts.balooTammudu2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isNext ? const Color(0xFF557C2B) : const Color(0xFF2D3C21),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer
                  Center(
                    child: Text(
                      'Sumber: Bimas Islam Kemenag RI via API MyQuran v3',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangeCityDialog(BuildContext context, PrayerTimeProvider provider) {
    final controller = TextEditingController(text: provider.currentCity);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Ubah Lokasi Kota',
            style: GoogleFonts.balooTammudu2(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan nama kota/kabupaten di Indonesia:',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Contoh: Palembang, Jakarta, Surabaya',
                  prefixIcon: const Icon(Icons.location_city_rounded, color: Color(0xFF557C2B)),
                  filled: true,
                  fillColor: const Color(0xFFEFF7E0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                final newCity = controller.text.trim();
                if (newCity.isNotEmpty) {
                  provider.changeCity(newCity);
                }
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF557C2B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  // ────────────── QURAN VERSE DETAIL MODAL ──────────────
  void _showVerseDetailModal(BuildContext context, QuranProvider quranProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<QuranProvider>(
          builder: (ctx, qProv, _) {
            final verse = qProv.currentVerse;
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F8F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  // Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3D6B1C), Color(0xFF557C2B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                verse.surahName,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                verse.reference,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            quranProvider.loadRandomVerse();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: Text(
                            '🔀 Acak',
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Arabic text
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8EEE0)),
                    ),
                    child: qProv.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF557C2B), strokeWidth: 2))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                verse.arabicText,
                                style: GoogleFonts.amiri(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E3710),
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const Divider(height: 20, color: Color(0xFFE8EEE0)),
                              Text(
                                verse.translation,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF2D3C21),
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ────────────── HADITH DETAIL MODAL ──────────────
  void _showHadithDetailModal(BuildContext context, HadithProvider hadithProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<HadithProvider>(
          builder: (ctx, hProv, _) {
            final hadith = hProv.currentHadith;
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F8F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  // Header bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D5A0E), Color(0xFF4A7220)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hadis Harian',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                hadith.takhrij,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hadith.grade,
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8EEE0)),
                    ),
                    child: hProv.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF557C2B), strokeWidth: 2))
                        : Column(
                            children: [
                              if (hadith.arabicText.isNotEmpty)
                                Text(
                                  hadith.arabicText,
                                  style: GoogleFonts.amiri(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E3710),
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              if (hadith.arabicText.isNotEmpty) const Divider(height: 20, color: Color(0xFFE8EEE0)),
                              Text(
                                hadith.translation.isNotEmpty ? hadith.translation : hadith.arabicText,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF2D3C21),
                                  height: 1.65,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Refresh button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          hadithProvider.loadRandomHadith();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text('Hadis Lain', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF557C2B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ────────────── QIBLA COMPASS MODAL ──────────────
  void _showQiblaCompassModal(BuildContext context) {
    // Muat lokasi & arah kiblat saat modal dibuka
    final qiblaProv = context.read<QiblaProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      qiblaProv.determineLocationAndQibla();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<QiblaProvider>(
          builder: (ctx, qibla, _) {
            final double heading = qibla.deviceHeading ?? 0.0;
            final double qiblaAngle = qibla.qiblaDirection;
            final double relativeDiff = qibla.relativeAngle;
            final bool isAligned = qibla.isFacingQibla;
            final bool hasSensor = qibla.hasCompassSensor;

            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F8F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Gradient
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAligned
                              ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                              : [const Color(0xFF234410), const Color(0xFF4A7220)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (isAligned)
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Image.asset(
                                'assets/icon/kiblat.png',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAligned ? 'Tepat Menghadap Kiblat! 🕋' : 'Petunjuk Arah Kiblat',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  qibla.qiblaInfo.cityName.isNotEmpty
                                      ? 'Lokasi: ${qibla.qiblaInfo.cityName}'
                                      : 'Sudut Kiblat: ${qiblaAngle.toStringAsFixed(1)}° dari Utara',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: qibla.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded, color: Colors.white),
                            onPressed: qibla.isLoading
                                ? null
                                : () => qibla.determineLocationAndQibla(),
                          ),
                        ],
                      ),
                    ),

                    if (qibla.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.orange.shade800, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  qibla.errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // COMPASS CONTAINER
                    Center(
                      child: SizedBox(
                        width: 270,
                        height: 270,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Dial Kompas Luar (Berputar mengikuti arah kompas device)
                            Transform.rotate(
                              angle: hasSensor ? -heading * (math.pi / 180) : 0,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isAligned ? const Color(0xFF4CAF50) : const Color(0xFFE8EEE0),
                                    width: isAligned ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: _CompassDialPainter(),
                                ),
                              ),
                            ),

                            // 2. Jarum Kiblat (Menunjuk ke Ka'bah)
                            // Jika ada sensor, arah needle relatif terhadap device: relativeDiff
                            // Jika tidak ada sensor, tampilkan needle pada sudut qiblaAngle dari dial
                            Transform.rotate(
                              angle: (hasSensor ? relativeDiff : qiblaAngle) * (math.pi / 180),
                              child: SizedBox(
                                width: 230,
                                height: 230,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Pointer Icon (Ka'bah / Arrow)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isAligned ? const Color(0xFF2E7D32) : const Color(0xFF557C2B),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.navigation_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    Container(
                                      width: 3,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: isAligned ? const Color(0xFF2E7D32) : const Color(0xFF557C2B),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),

                            // 3. Center Emblem (Ka'bah icon)
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: isAligned ? const Color(0xFFE8F5E9) : const Color(0xFFEFF7E0),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isAligned ? const Color(0xFF2E7D32) : const Color(0xFF557C2B),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icon/kiblat.png',
                                  width: 26,
                                  height: 26,
                                  color: isAligned ? const Color(0xFF2E7D32) : const Color(0xFF557C2B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // STATUS & DEGREE CARDS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE8EEE0)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Arah Kiblat',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${qiblaAngle.toStringAsFixed(1)}°',
                                    style: GoogleFonts.balooTammudu2(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF234410),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE8EEE0)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Arah Kompas',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasSensor
                                        ? '${heading.toStringAsFixed(0)}°'
                                        : 'Tanpa Sensor',
                                    style: GoogleFonts.balooTammudu2(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF557C2B),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Instruction tip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        hasSensor
                            ? (isAligned
                                ? '✨ Alhamdulillah! Anda sedang menghadap kiblat.'
                                : 'Letakkan ponsel di bidang datar, lalu putar perlahan hingga jarum hijau menunjuk ke atas.')
                            : 'Sensor kompas tidak aktif pada perangkat ini. Silakan gunakan sudut ${qiblaAngle.toStringAsFixed(1)}° sebagai acuan kompas manual.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: isAligned ? FontWeight.w600 : FontWeight.w400,
                          color: isAligned ? const Color(0xFF2E7D32) : const Color(0xFF55684B),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ────────────── COMPASS DIAL PAINTER ──────────────
class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = const Color(0xFFB0C5A4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = const Color(0xFF557C2B)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cardinalPoints = {
      0: 'U',    // Utara
      90: 'T',   // Timur
      180: 'S',  // Selatan
      270: 'B',  // Barat
    };

    // Draw 360-degree ticks (every 15 degrees)
    for (int deg = 0; deg < 360; deg += 15) {
      final isMajor = deg % 90 == 0;
      final isSemiMajor = deg % 45 == 0;
      final rad = (deg - 90) * (math.pi / 180);

      final double tickLength = isMajor ? 12 : (isSemiMajor ? 8 : 5);
      final p1 = Offset(
        center.dx + (radius - 10) * math.cos(rad),
        center.dy + (radius - 10) * math.sin(rad),
      );
      final p2 = Offset(
        center.dx + (radius - 10 - tickLength) * math.cos(rad),
        center.dy + (radius - 10 - tickLength) * math.sin(rad),
      );

      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : tickPaint);

      if (isMajor) {
        final label = cardinalPoints[deg]!;
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: deg == 0 ? const Color(0xFFD32F2F) : const Color(0xFF234410),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelRadius = radius - 32;
        final labelOffset = Offset(
          center.dx + labelRadius * math.cos(rad) - textPainter.width / 2,
          center.dy + labelRadius * math.sin(rad) - textPainter.height / 2,
        );
        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ────────────── CUSTOM PAINTER (Circle Progress) ──────────────
class _CircleProgressPainter extends CustomPainter {
  final double progress;

  _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const strokeWidth = 9.0;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFD4E8B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = const Color(0xFF557C2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) => old.progress != progress;
}

// ────────────── SPEECH BUBBLE ARROW CLIPPER ──────────────
class _SpeechArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.7, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

