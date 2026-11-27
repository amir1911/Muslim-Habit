import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/streak_badge.dart';
import '../../../providers/habit_provider.dart';
import '../models/costume_model.dart';
import '../providers/mascot_provider.dart';
import '../widgets/dashed_circle_button.dart';
import '../widgets/mascot_character.dart';
import 'toko_screen.dart';

/// Halaman Lemari Kostum & Aksesoris Unta (LemariScreen)
class LemariScreen extends StatefulWidget {
  const LemariScreen({super.key});

  @override
  State<LemariScreen> createState() => _LemariScreenState();
}

class _LemariScreenState extends State<LemariScreen> {
  // 0: Semua, 1: Aksesoris, 2: Kostum
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final mascotProv = context.watch<MascotProvider>();

    // Daftar kostum yang dimiliki user
    final ownedCostumes = CostumeModel.predefinedCostumes
        .where((c) => mascotProv.isCostumeOwned(c.id))
        .toList();

    // Daftar aksesoris unta (Peci, Syal, Lonceng)
    final accessories = AccessoryModel.predefinedAccessories
        .where((a) => mascotProv.isAccessoryOwned(a.id))
        .toList();

    final showAccessories = _selectedFilterIndex == 0 || _selectedFilterIndex == 1;
    final showCostumes = _selectedFilterIndex == 0 || _selectedFilterIndex == 2;

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
              // ── 1. HEADER ATAS (KOSTUM & STATS) ──
              _buildTopBar(context, habitProv),

              // ── 2. PREVIEW MASKOT NUNU DENGAN AKSESORIS REAL-TIME ──
              _buildMascotPreview(mascotProv),

              // ── 3. FILTER TABS (SEMUA / AKSESORIS / KOSTUM) ──
              _buildFilterTabs(accessories.length, ownedCostumes.length),

              // ── 4. DAFTAR AKSESORIS & KOSTUM ──
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: [
                    // ── SEKSI AKSESORIS UNTA ──
                    if (showAccessories) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aksesoris Unta',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E350E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dapat dipasang bersamaan (Peci + Syal + Lonceng)',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF75856B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF518427).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${mascotProv.equippedAccessories.length}/3',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF518427),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // List Kartu Aksesoris Mandiri
                      ...accessories.map((acc) {
                        final isEquipped = mascotProv.isAccessoryEquipped(acc.id);

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
                                color: isEquipped
                                    ? const Color(0xFF518427).withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon / Thumbnail Aksesoris
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isEquipped
                                      ? const Color(0xFFEFF7E0)
                                      : const Color(0xFFF7F6EE),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Icon(
                                    acc.icon,
                                    color: acc.themeColor,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info Aksesoris
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          acc.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        if (acc.id == 'lonceng') ...[
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.volume_up_rounded,
                                            size: 14,
                                            color: Color(0xFFD4AF37),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      acc.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: const Color(0xFF6B7280),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tombol Pasang / Lepas Aksesoris
                              if (isEquipped)
                                SolidCheckCircle(
                                  size: 34,
                                  color: const Color(0xFF518427),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    mascotProv.toggleAccessory(acc.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Aksesoris ${acc.name} dilepas.'),
                                        duration: const Duration(milliseconds: 1000),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                )
                              else
                                DashedCircleButton(
                                  size: 34,
                                  color: const Color(0xFF518427),
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    mascotProv.toggleAccessory(acc.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Aksesoris ${acc.name} berhasil dipasang!'),
                                        backgroundColor: const Color(0xFF518427),
                                        duration: const Duration(milliseconds: 1200),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // ── SEKSI KOSTUM UTAMA ──
                    if (showCostumes) ...[
                      Text(
                        'Kostum Utama',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E350E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih kostum tubuh lengkap untuk untamu',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF75856B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // List Kartu Kostum yang Dimiliki
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

                              // Tombol Status Kostum
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
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
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
  // FILTER TABS (Semua, Aksesoris, Kostum)
  // ==========================================
  Widget _buildFilterTabs(int accCount, int costumeCount) {
    final filters = [
      'Semua (${accCount + costumeCount})',
      'Aksesoris ($accCount)',
      'Kostum ($costumeCount)',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilterIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 4,
                  right: index == filters.length - 1 ? 0 : 4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF518427) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF518427) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Center(
                  child: Text(
                    filters[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // TOP BAR
  // ==========================================
  Widget _buildTopBar(BuildContext context, HabitProvider habitProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // Tombol Kembali Standar Muslim Habit
          const CustomBackButton(),
          const SizedBox(width: 8),

          // Judul "Kostum & Aksesoris" – Expanded agar fleksibel dan tidak pernah overflow
          Expanded(
            child: Text(
              'Kostum & Aksesoris',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E5714),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          const SizedBox(width: 6),

          // Pill Streak Terpadu
          StreakBadge(
            streakOverride: habitProv.streakCount,
            backgroundColor: const Color(0xFF518427),
            iconColor: const Color(0xFFFFB300),
          ),
          const SizedBox(width: 5),

          // Pill Saldo Bintang (compact)
          _buildStatPill(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFD700),
            label: '${habitProv.userPoints}',
          ),
          const SizedBox(width: 5),

          // Keranjang Toko
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TokoScreen()),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF518427),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF518427),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
          equippedAccessories: mascotProv.equippedAccessories,
          onTap: () {
            HapticFeedback.lightImpact();
            mascotProv.cycleDialogue();
          },
        ),
      ),
    );
  }
}
