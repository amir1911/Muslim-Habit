import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';

/// Widget Standar Icon Streak Muslim Habit
/// Menyatukan bentuk, ukuran, font, dan warna icon streak di seluruh aplikasi.
class StreakBadge extends StatelessWidget {
  final int? streakOverride;
  final Color? backgroundColor;
  final Color? textColor;
  final Color iconColor;
  final double height;
  final VoidCallback? onTap;

  const StreakBadge({
    super.key,
    this.streakOverride,
    this.backgroundColor,
    this.textColor,
    this.iconColor = const Color(0xFFFFB300),
    this.height = 34,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider?>();
    final streak = streakOverride ?? habitProv?.streakCount ?? 0;
    final bg = backgroundColor ?? const Color(0xFF2E5714);
    final textCol = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  streak > 0
                      ? '🔥 Luar biasa! Streak ibadahmu berjalan $streak hari berturut-turut.'
                      : '🔥 Selesaikan ibadah hari ini untuk menambah streak-mu!',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF2E5714),
              ),
            );
          },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: iconColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
