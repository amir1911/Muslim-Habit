import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/khatam_provider.dart';
import 'khatam_setup_screen.dart';
import 'khatam_reading_screen.dart';

/// Laman Utama Khatam Al-Qur'an (KhatamDashboardScreen)
class KhatamDashboardScreen extends StatelessWidget {
  const KhatamDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KhatamProvider>();
    final plan = prov.activePlan;

    // Nilai dinamis dengan fallback jika belum ada plan aktif
    final currentJuz = plan?.currentJuz ?? 14;
    final progressPct = plan != null ? (plan.progressPercentage).round() : 45;
    final completedCount = plan != null ? (currentJuz - 1).clamp(0, 30) : 13;
    final nextJuz = (currentJuz < 30) ? currentJuz + 1 : 30;
    final estimatedDays = plan?.estimatedDaysRemaining ?? 16;
    final dailyTargetStr = plan != null
        ? (plan.dailyJuzTarget >= 1.0
            ? '${plan.dailyJuzTarget.toStringAsFixed(plan.dailyJuzTarget == plan.dailyJuzTarget.roundToDouble() ? 0 : 1)} Juz/hari'
            : '${(plan.dailyJuzTarget * 208).round()} Ayat/hari')
        : '1 Juz/hari';

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
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF84B74E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 26),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Khatam Al-Qur’an',
            style: GoogleFonts.inter(
              fontSize: 18.5,
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
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // ── 1. KARTU PROGRES UTAMA (CARD PUTIH) ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris 1: "Sedang Berjalan" & "Progres"
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
                        Text(
                          'Progres',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Baris 2: "Juz 14" & "45%"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Juz $currentJuz',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF264E0B),
                          ),
                        ),
                        Text(
                          '$progressPct%',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // LinearProgressIndicator membulat dengan warna hijau tua
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progressPct / 100.0).clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF264E0B)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Baris 3: Target Harian & Tombol "Lanjutkan"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF4B5563)),
                            const SizedBox(width: 8),
                            Text(
                              'Target Harian: $dailyTargetStr',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            prov.loadAyahsForJuz(currentJuz);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KhatamReadingScreen(juzNumber: currentJuz),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF55822B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Lanjutkan',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. DUA KARTU STATISTIK SEJAJAR ──
              Row(
                children: [
                  // Kartu Kiri: Pencapaian Mendatang
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                        children: [
                          const Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B), size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'Pencapaian Mendatang',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Khatam Juz $nextJuz',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Kartu Kanan: Estimasi Khatam
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFF4B5563), size: 24),
                          const SizedBox(height: 10),
                          Text(
                            'Estimasi Khatam',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$estimatedDays Hari',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── 3. GRID PERJALANAN 30 JUZ ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Perjalanan 30 Juz',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF264E0B),
                    ),
                  ),
                  Text(
                    '$completedCount / 30 SELESAI',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF55822B),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Grid 6 Kolom x 5 Baris
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final juzNum = index + 1;
                  final isCompleted = juzNum < currentJuz;
                  final isCurrent = juzNum == currentJuz;

                  return GestureDetector(
                    onTap: () {
                      prov.loadAyahsForJuz(juzNum);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KhatamReadingScreen(juzNumber: juzNum),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF264E0B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFF59E0B)
                              : (isCompleted ? const Color(0xFF264E0B) : const Color(0xFFE5E7EB)),
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              '$juzNum',
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? Colors.white
                                    : (isCurrent ? const Color(0xFFB45309) : const Color(0xFF6B7280)),
                              ),
                            ),
                          ),
                          // Badge Oranye Kecil di Pojok Kanan Atas untuk Juz Sedang Berjalan
                          if (isCurrent)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 7,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ── 4. FOOTER HADIS AL-QUR'AN ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF264E0B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"Sebaik-baik kalian adalah orang yang belajar Al-Qur\'an dan mengajarkannya."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF6B7280),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
