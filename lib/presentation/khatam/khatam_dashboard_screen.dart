import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/khatam_provider.dart';
import 'khatam_setup_screen.dart';
import 'khatam_reading_screen.dart';

class KhatamDashboardScreen extends StatelessWidget {
  const KhatamDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KhatamProvider>();
    final plan = prov.activePlan;

    final currentJuz = plan?.currentJuz ?? 1;
    final progressPct = (plan?.progressPercentage ?? 0.0).round();
    final completedCount = plan?.completedJuzCount ?? 0;
    final nextJuz = plan?.nextAchievementJuz ?? 2;
    final estimatedDays = plan?.estimatedDaysRemaining ?? 30;
    final dailyTargetStr = plan != null
        ? (plan.dailyJuzTarget >= 1.0
            ? '${plan.dailyJuzTarget.toStringAsFixed(plan.dailyJuzTarget == plan.dailyJuzTarget.roundToDouble() ? 0 : 1)} Juz/hari'
            : '${(plan.dailyJuzTarget * 208).round()} Ayat/hari')
        : '1 Juz/hari';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Khatam Al-Qur’an',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhatamSetupScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // ── KARTU PROGRES KHATAM ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row atas: "Sedang Berjalan" & "Progres 45%"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sedang Berjalan',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Progres ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '$progressPct%',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Judul Juz Besar
                  Text(
                    'Juz $currentJuz',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B432C),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (plan?.progressPercentage ?? 0.0) / 100.0,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C5220)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Baris Bawah: Target Harian & Tombol Lanjutkan
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF4B5563)),
                      const SizedBox(width: 6),
                      Text(
                        'Target Harian: $dailyTargetStr',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          prov.loadAyahsForJuz(currentJuz);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KhatamReadingScreen(juzNumber: currentJuz),
                            ),
                          );
                        },
                        child: Text(
                          'Lanjutkan',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── DUA KARTU KECIL (PENCAPAIAN MENDATANG & ESTIMASI KHATAM) ──
            Row(
              children: [
                // Kartu 1: Pencapaian Mendatang
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B), size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'Pencapaian Mendatang',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Khatam Juz $nextJuz',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B432C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Kartu 2: Estimasi Khatam
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.date_range_outlined, color: Color(0xFF4A7C59), size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'Estimasi Khatam',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$estimatedDays Hari',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B432C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── PERJALANAN 30 JUZ HEADER ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perjalanan 30 Juz',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF386641),
                  ),
                ),
                Text(
                  '$completedCount / 30 SELESAI',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── GRID 30 JUZ (6 KOLOM X 5 BARIS) SESUAI DESAIN GAMBAR KEDUA ──
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 30,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final juzNum = index + 1;
                final isCompleted = plan?.completedJuzList.contains(juzNum) ?? false;
                final isCurrent = juzNum == currentJuz && !isCompleted;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      prov.loadAyahsForJuz(juzNum);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KhatamReadingScreen(juzNumber: juzNum),
                        ),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF2C5220) // Hijau tua selesai
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFF59E0B) // Border oranye aktif
                              : (isCompleted ? Colors.transparent : const Color(0xFFE5E7EB)),
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$juzNum',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? Colors.white
                                    : (isCurrent ? const Color(0xFF1B432C) : const Color(0xFF6B7280)),
                              ),
                            ),
                          ),
                          // Badge play oranye di pojok kanan atas untuk Juz yang sedang aktif
                          if (isCurrent)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // ── FOOTER KALIGRAFI ARAB HADITS ──
            Column(
              children: [
                Text(
                  'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C5220),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“Sebaik-baik kalian adalah orang yang belajar Al-Qur’an dan mengajarkannya.”',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
