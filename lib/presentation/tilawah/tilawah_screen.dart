import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/tilawah_provider.dart';

class TilawahScreen extends StatelessWidget {
  const TilawahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tilawah = context.watch<TilawahProvider>();

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          'Tilawah Al-Qur\'an',
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
          // TARGET & DAILY PROGRESS HERO CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF789B55), Color(0xFF5A783A)],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Target: 1 Juz / Hari',
                        style: GoogleFonts.balooThammudu2(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'Khatam dlm ~${tilawah.remainingDaysToKhatam} hari',
                          style: GoogleFonts.balooThammudu2(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Current Reading Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Juz ${tilawah.currentJuz}',
                            style: GoogleFonts.balooThammudu2(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Halaman ${tilawah.currentPage} dari 604',
                            style: GoogleFonts.balooThammudu2(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${(tilawah.overallProgress * 100).toInt()}%',
                          style: GoogleFonts.balooThammudu2(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Today Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: tilawah.todayProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hari ini: ${tilawah.pagesReadToday} / ${tilawah.dailyTargetPages} halaman terbaca',
                  style: GoogleFonts.balooThammudu2(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // QUICK UPDATE ACTIONS
          Text(
            'Catat Bacaan Hari Ini',
            style: GoogleFonts.balooThammudu2(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildQuickAddButton(
                  title: '+1 Hlm',
                  onTap: () => tilawah.addPagesRead(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickAddButton(
                  title: '+5 Hlm',
                  onTap: () => tilawah.addPagesRead(5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickAddButton(
                  title: '+1 Juz (20 Hlm)',
                  isPrimary: true,
                  onTap: () => tilawah.addPagesRead(20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 30 JUZ TRACKER GRID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar 30 Juz',
                style: GoogleFonts.balooThammudu2(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${tilawah.currentJuz - 1} dari 30 Khatam',
                style: GoogleFonts.balooThammudu2(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 30,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final isCompleted = juzNum < tilawah.currentJuz;
              final isCurrent = juzNum == tilawah.currentJuz;

              Color bgColor = Colors.white;
              Color textColor = AppColors.textDark;
              Border border = Border.all(color: AppColors.beigeAccent);

              if (isCompleted) {
                bgColor = AppColors.greenSurface;
                textColor = AppColors.primaryDarkGreen;
                border = Border.all(color: AppColors.primaryGreen);
              } else if (isCurrent) {
                bgColor = AppColors.primaryGreen;
                textColor = Colors.white;
                border = Border.all(color: AppColors.primaryGreen, width: 2);
              }

              return InkWell(
                onTap: () => tilawah.updateCurrentPage((juzNum - 1) * 20 + 1),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: border,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Juz $juzNum',
                          style: GoogleFonts.balooThammudu2(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (isCompleted)
                          const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primaryGreen)
                        else if (isCurrent)
                          const Text('📖', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton({
    required String title,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppColors.primaryGreen : AppColors.beigeAccent,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.balooThammudu2(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
