import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          'Muslim Habit',
          style: GoogleFonts.balooTammudu2(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.primaryGreen,
          ),
        ),
        actions: [
          // Streak Counter Chip
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.streakFire.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.streakFire.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${habitProvider.streakCount} Hari',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.streakFire,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Greeting & Hijri Date Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayFormatted,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assalamu\'alaikum, ${habitProvider.userName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 4),
                    Text(
                      '28 Rabiul Awwal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GAMIFIED CAMEL BUDDY INTERACTIVE CARD
          _buildCamelBuddyCard(context, habitProvider),
          const SizedBox(height: 20),

          // PROGRESS OVERVIEW RING & STATS
          _buildDailyProgressCard(habitProvider),
          const SizedBox(height: 20),

          // CATEGORY SELECTOR CHIPS (Semua, Wajib, Sunnah)
          _buildCategoryFilter(habitProvider),
          const SizedBox(height: 16),

          // HABIT CHECKLIST SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Hari Ini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${habitProvider.completedHabitsCount} dari ${habitProvider.totalHabitsCount} Selesai',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Habit Cards
          ...habitProvider.habits.map((habit) => _buildHabitItemCard(context, habitProvider, habit)),
        ],
      ),
    );
  }

  Widget _buildCamelBuddyCard(BuildContext context, HabitProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF789B55), Color(0xFF648742)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // 3D Camel Avatar
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/image 52.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/image 52.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🐪', style: TextStyle(fontSize: 38)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Camel Speech Bubble & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Jamal • Level ${provider.userLevel}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.userPoints} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  provider.mascotMessage,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgressCard(HabitProvider provider) {
    final pct = (provider.progressFraction * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.beigeAccent),
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: provider.progressFraction,
                  strokeWidth: 6,
                  backgroundColor: AppColors.greenSurface,
                  color: AppColors.primaryGreen,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '$pct%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),

          // Progress text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsistensi Harian',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${provider.completedHabitsCount} dari ${provider.totalHabitsCount} ibadah telah selesai hari ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(HabitProvider provider) {
    return Row(
      children: [
        _buildFilterChip(provider, 'all', 'Semua'),
        const SizedBox(width: 8),
        _buildFilterChip(provider, 'wajib', 'Shalat Fardhu'),
        const SizedBox(width: 8),
        _buildFilterChip(provider, 'sunnah', 'Amalan Sunnah'),
      ],
    );
  }

  Widget _buildFilterChip(HabitProvider provider, String key, String label) {
    final isSelected = provider.selectedCategory == key;

    return GestureDetector(
      onTap: () => provider.setCategory(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.beigeAccent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItemCard(BuildContext context, HabitProvider provider, HabitItem habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: habit.isCompleted ? AppColors.greenAccent : AppColors.beigeAccent,
          width: habit.isCompleted ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: habit.isCompleted ? AppColors.greenSurface : AppColors.creamBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            habit.icon,
            color: habit.isCompleted ? AppColors.primaryGreen : AppColors.textMedium,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                habit.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                  color: habit.isCompleted ? AppColors.textMedium : AppColors.textDark,
                ),
              ),
            ),
            if (habit.streak > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.streakFire.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 2),
                    Text(
                      '${habit.streak}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.streakFire,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${habit.timeSuggestion} • +${habit.points} XP',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
        trailing: GestureDetector(
          onTap: () => provider.toggleHabit(habit.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: habit.isCompleted ? AppColors.primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: habit.isCompleted ? AppColors.primaryGreen : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: habit.isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        ),
      ),
    );
  }
}
