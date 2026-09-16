import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';

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
    final now = DateTime.now();

    // Next prayer calculation (simple static for now – real app would use adhan package)
    final nextPrayer = _getNextPrayer(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Top green header (greeting + stats + mascot + prayer + ayah) ──
          SliverToBoxAdapter(child: _buildGreenHeader(context, provider, nextPrayer)),

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
                _buildHadithCard(),
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
  Widget _buildGreenHeader(BuildContext context, HabitProvider provider, Map<String, String> nextPrayer) {
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
                        // Ayah Card
                        Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'خُطْوَةٌ صَغِيرَةٌ تُقَرِّبُكَ إِلَى اللَّهِ',
                                style: GoogleFonts.amiri(
                                  fontSize: 13,
                                  color: const Color(0xFF1E3710),
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"Satu langkah kecil mendekatkanmu kepada Allah."',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  color: const Color(0xFF2E4717),
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Next Prayer Widget
                        _buildPrayerWidget(nextPrayer),
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

  Widget _buildPrayerWidget(Map<String, String> prayer) {
    return Container(
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
                  child: Text(
                    'SEKARANG',
                    style: GoogleFonts.inter(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  prayer['name']!,
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
                      prayer['time']!,
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
                      'Palembang',
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

          // Emblem icon container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF3F6919),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ────────────── FEATURE GRID ──────────────
  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {'label': 'Sholat', 'icon': Icons.mosque_outlined},
      {'label': 'Al-Quran', 'icon': Icons.menu_book_rounded},
      {'label': 'Dzikir', 'icon': Icons.spa_rounded},
      {'label': 'Doa', 'icon': Icons.volunteer_activism_rounded},
      {'label': 'Puasa', 'icon': Icons.nightlight_round},
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
              icon: f['icon'] as IconData,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureItem({required String label, required IconData icon}) {
    return GestureDetector(
      onTap: () {},
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
            child: Icon(icon, color: Colors.white, size: 28),
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

  // ────────────── HADITH CARD ──────────────
  Widget _buildHadithCard() {
    const hadiths = [
      {
        'text': 'Bacalah Al-Qur\'an, karena ia akan datang sebagai pemberi syafa\'at bagi pembacanya.',
        'source': 'HR. Muslim',
      },
      {
        'text': 'Sebaik-baik kalian adalah orang yang mempelajari Al-Qur\'an dan mengajarkannya.',
        'source': 'HR. Bukhari',
      },
    ];
    final hadith = hadiths[math.Random().nextInt(hadiths.length)];

    return Container(
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
      child: Column(
        children: [
          Text(
            hadith['text']!,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2D3C21),
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hadith['source']!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF557C2B),
            ),
          ),
        ],
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

  // ────────────── HELPERS ──────────────
  Map<String, String> _getNextPrayer(DateTime now) {
    final prayers = [
      {'name': 'Subuh', 'hour': 4, 'minute': 30},
      {'name': 'Dzuhur', 'hour': 12, 'minute': 5},
      {'name': 'Ashar', 'hour': 15, 'minute': 15},
      {'name': 'Maghrib', 'hour': 18, 'minute': 10},
      {'name': 'Isya', 'hour': 19, 'minute': 20},
    ];

    for (final p in prayers) {
      final h = p['hour'] as int;
      final m = p['minute'] as int;
      final prayerTime = DateTime(now.year, now.month, now.day, h, m);
      if (now.isBefore(prayerTime)) {
        return {
          'name': p['name'] as String,
          'time': '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
        };
      }
    }

    // If past Isya, show Subuh tomorrow
    return {'name': 'Subuh', 'time': '04:30'};
  }
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

