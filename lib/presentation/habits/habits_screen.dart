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
          style: GoogleFonts.balooThammudu2(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.primaryGreen,
          ),
        ),
        actions: [
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
                  style: GoogleFonts.balooThammudu2(
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Greeting & Hijri Date Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal → Inter (penjelasan)
                    Text(
                      todayFormatted,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Salam → Baloo (judul)
                    Text(
                      'Assalamu\'alaikum, ${habitProvider.userName}',
                      style: GoogleFonts.balooThammudu2(
                        fontSize: 18,
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
                    // Tanggal hijriah → Inter
                    Text(
                      '28 Rabiul Awwal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildCamelBuddyCard(context, habitProvider),
          const SizedBox(height: 20),

          _buildDailyProgressCard(habitProvider),
          const SizedBox(height: 20),

          _buildCategoryFilter(habitProvider),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Section heading → Baloo
              Text(
                'Target Hari Ini',
                style: GoogleFonts.balooThammudu2(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              // Counter caption → Inter
              Text(
                '${habitProvider.completedHabitsCount} dari ${habitProvider.totalHabitsCount} Selesai',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
                  'assets/images/camel_solo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🐪', style: TextStyle(fontSize: 38)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

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
                      // Label chip → Baloo
                      child: Text(
                        'Jamal • Level ${provider.userLevel}',
                        style: GoogleFonts.balooThammudu2(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // XP → Baloo (gamifikasi angka penting)
                    Text(
                      '${provider.userPoints} XP',
                      style: GoogleFonts.balooThammudu2(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Pesan maskot → Inter (kalimat penjelasan)
                Text(
                  provider.mascotMessage,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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
                  // Angka % → Baloo
                  child: Text(
                    '$pct%',
                    style: GoogleFonts.balooThammudu2(
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label → Baloo
                Text(
                  'Konsistensi Harian',
                  style: GoogleFonts.balooThammudu2(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                // Penjelasan → Inter
                Text(
                  '${provider.completedHabitsCount} dari ${provider.totalHabitsCount} ibadah telah selesai hari ini',
                  style: GoogleFonts.inter(
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
        // Chip label → Inter
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
              // Judul habit → Baloo
              child: Text(
                habit.title,
                style: GoogleFonts.balooThammudu2(
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
                      style: GoogleFonts.balooThammudu2(
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
        // Waktu & XP → Inter (penjelasan)
        subtitle: Text(
          '${habit.timeSuggestion} • +${habit.points} XP',
          style: GoogleFonts.inter(
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
