import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/habit_provider.dart';
import '../models/costume_model.dart';
import '../providers/mascot_provider.dart';
import '../widgets/dashed_circle_button.dart';
import '../widgets/mascot_character.dart';
import 'toko_screen.dart';

/// Halaman Lemari Kostum (LemariScreen)
class LemariScreen extends StatelessWidget {
  const LemariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final mascotProv = context.watch<MascotProvider>();

    // Daftar kostum yang dimiliki user
    final ownedCostumes = CostumeModel.predefinedCostumes
        .where((c) => mascotProv.isCostumeOwned(c.id))
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── 1. HEADER ATAS (KOSTUM) ──
              _buildTopBar(context, habitProv),

              // ── 2. PREVIEW MASKOT NUNU DENGAN BACKGROUND ALAM ──
              _buildMascotPreview(mascotProv),

              // ── 3. DAFTAR KOSTUM ANDA ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  children: [
                    Text(
                      'Kostum Anda',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E350E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Beri Untamu Kostum Indah!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF75856B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Kartu-Kartu Kostum yang Dimiliki
                    ...ownedCostumes.map((costume) {
                      final isEquipped = mascotProv.equippedCostume == costume.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isEquipped
                                ? const Color(0xFF518427)
                                : const Color(0xFFE5E7EB),
                            width: isEquipped ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Thumbnail Kostum
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F6EE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Icon(
                                  costume.icon ?? Icons.checkroom_rounded,
                                  color: costume.themeColor,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Nama & Keterangan Kostum
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    costume.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    costume.description,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Status: Solid Check (Sedang Dipakai) atau Dashed (+) untuk Pasang
                            if (isEquipped)
                              const SolidCheckCircle(
                                size: 34,
                                color: Color(0xFF518427),
                              )
                            else
                              DashedCircleButton(
                                size: 34,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  mascotProv.equipCostume(costume.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Kostum ${costume.name} berhasil digunakan!'),
                                      backgroundColor: const Color(0xFF518427),
                                      duration: const Duration(milliseconds: 1200),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP BAR
  // ==========================================
  Widget _buildTopBar(BuildContext context, HabitProvider habitProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Tombol Kembali
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF2E5714),
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),

          // Judul "Kostum"
          Text(
            'Kostum',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E5714),
            ),
          ),

          const Spacer(),

          // Pill Streak
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
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFFB300),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${habitProv.streakCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Pill Saldo Bintang
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Keranjang Toko
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TokoScreen()),
              );
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF518427),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PREVIEW MASKOT NUNU BERDIRI DI ALAM
  // ==========================================
  Widget _buildMascotPreview(MascotProvider mascotProv) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_bg_day.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: MascotCharacter(
          height: 200,
          costumeId: mascotProv.equippedCostume,
          onTap: () {
            HapticFeedback.lightImpact();
            mascotProv.cycleDialogue();
          },
        ),
      ),
    );
  }
}
