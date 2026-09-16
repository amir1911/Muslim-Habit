import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/badge_item.dart';
import '../../providers/habit_provider.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final unlockedCount = provider.badges.where((b) => b.isUnlocked).length;
    final totalBadges = provider.badges.length;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          'Pencapaian & Badge',
          style: GoogleFonts.balooThammudu2(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // LEVEL & MASCOT SHOWCASE HERO
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.beigeAccent),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Mascot & Badge Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greenSurface,
                        border: Border.all(color: AppColors.primaryGreen, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/image 52.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text('🐪', style: TextStyle(fontSize: 50)),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldBadge,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Level ${provider.userLevel}',
                          style: GoogleFonts.balooThammudu2(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  provider.userName,
                  style: GoogleFonts.balooThammudu2(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gelar: Santri Istiqomah',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 16),

                // XP Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Level ${provider.userLevel + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          '${provider.userPoints} / ${(provider.userLevel * 200)} XP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldBadge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (provider.userPoints / (provider.userLevel * 200)).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.greenSurface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldBadge),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // BADGES SECTION HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Koleksi Lencana Islami',
                style: GoogleFonts.balooThammudu2(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unlockedCount / $totalBadges Terbuka',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // BADGES GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final badge = provider.badges[index];
              return _buildBadgeCard(context, badge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, BadgeItem badge) {
    return InkWell(
      onTap: () => _showBadgeDetail(context, badge),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badge.isUnlocked ? badge.accentColor.withValues(alpha: 0.5) : AppColors.beigeAccent,
            width: badge.isUnlocked ? 1.5 : 1,
          ),
          boxShadow: [
            if (badge.isUnlocked)
              BoxShadow(
                color: badge.accentColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Icon Circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? badge.accentColor.withValues(alpha: 0.15)
                    : AppColors.beigeAccent.withValues(alpha: 0.5),
              ),
              child: Icon(
                badge.isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                size: 28,
                color: badge.isUnlocked ? badge.accentColor : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.balooThammudu2(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: badge.isUnlocked ? AppColors.textDark : AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.category,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: badge.isUnlocked ? AppColors.primaryGreen : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeItem badge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? badge.accentColor.withValues(alpha: 0.2)
                    : AppColors.beigeAccent,
              ),
              child: Icon(
                badge.isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                size: 38,
                color: badge.isUnlocked ? badge.accentColor : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: GoogleFonts.balooThammudu2(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: badge.isUnlocked ? AppColors.greenSurface : AppColors.beigeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.isUnlocked ? '✓ Telah Dibuka' : 'Terkunci • Target: ${badge.requiredStreak} hari',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badge.isUnlocked ? AppColors.primaryDarkGreen : AppColors.textMedium,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Tutup',
                style: GoogleFonts.balooThammudu2(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
