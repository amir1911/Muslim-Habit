import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/habit_provider.dart';
import '../providers/mascot_provider.dart';
import '../widgets/mascot_character.dart';
import '../widgets/mascot_speech_bubble.dart';
import 'toko_screen.dart';
import 'lemari_screen.dart';
import 'chatbot_screen.dart';

/// Halaman Utama Maskot Nunu (MascotHubScreen)
class MascotHubScreen extends StatelessWidget {
  const MascotHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final mascotProv = context.watch<MascotProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // ── 1. BACKGROUND PEMANDANGAN ALAM CERAH ──
            Positioned.fill(
              child: Image.asset(
                'assets/images/home_bg_day.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF87CEEB), Color(0xFFC8E6C9), Color(0xFFF7F6EE)],
                    ),
                  ),
                ),
              ),
            ),

            // ── 2. KONTEN UTAMA DENGAN SAFE AREA ──
            SafeArea(
              child: Column(
                children: [
                  // ── HEADER ATAS (AVATAR, STATS, ACTIONS) ──
                  _buildHeader(context, habitProv),

                  // ── TOMBOL MISI (FLAG) & PENGATURAN (GEAR) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRoundActionButton(
                            icon: Icons.flag_outlined,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Misi Harian: Rawat Nunu & Selesaikan 3 Habit!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildRoundActionButton(
                            icon: Icons.settings_outlined,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pengaturan Suara & Animasi Maskot'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── AREA MASKOT NUNU DENGAN SPEECH BUBBLE ──
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Speech Bubble Nunu (dapat diklik untuk dialog acak)
                            MascotSpeechBubble(
                              text: mascotProv.currentDialogue,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                mascotProv.cycleDialogue();
                              },
                            ),
                            const SizedBox(height: 12),

                            // Maskot Nunu Berdiri dengan Aksesoris Kostum & Sparkle
                            MascotCharacter(
                              height: 250,
                              costumeId: mascotProv.equippedCostume,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                mascotProv.cycleDialogue();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── 3 TOMBOL NAVIGASI UTAMA (TOKO, MULAI CHAT, LEMARI) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavButton(
                          context: context,
                          label: 'TOKO',
                          icon: Icons.shopping_cart_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TokoScreen()),
                            );
                          },
                        ),
                        _buildNavButton(
                          context: context,
                          label: 'Mulai Chat',
                          icon: Icons.chat_bubble_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                            );
                          },
                        ),
                        _buildNavButton(
                          context: context,
                          label: 'Lemari',
                          icon: Icons.checkroom_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LemariScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── KARTU IKATAN PERSAHABATAN (FRIENDSHIP CARD) ──
                  _buildFriendshipCard(mascotProv),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HEADER ATAS
  // ==========================================
  Widget _buildHeader(BuildContext context, HabitProvider habitProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + Sapaan & Tombol Back Bulat
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF4A7220), size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Sapaan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamualaikum',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E350E),
                    ),
                  ),
                  Text(
                    habitProv.userName,
                    style: GoogleFonts.balooTammudu2(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E350E),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Streak Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF518427),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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

          // Stars Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF518427),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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

          // Bell Notifikasi
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF518427),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF2E5714), size: 17),
      ),
    );
  }

  // ==========================================
  // 3 TOMBOL NAVIGASI UTAMA (HIJAU ZAITUN)
  // ==========================================
  Widget _buildNavButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: const Color(0xFF518427),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E5714).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // KARTU IKATAN PERSAHABATAN (FRIENDSHIP CARD)
  // ==========================================
  Widget _buildFriendshipCard(MascotProvider mascotProv) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris: Ikon Unta + "Ikatan Persahabatan" & "❤️ Lv. X"
          Row(
            children: [
              const Icon(
                Icons.pets_rounded,
                color: Color(0xFF518427),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Ikatan Persahabatan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E350E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE91E63),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lv. ${mascotProv.friendshipLevel}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E5714),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thick Olive Green Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mascotProv.friendshipProgressFraction,
              minHeight: 12,
              backgroundColor: const Color(0xFFE5EBE0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF518427)),
            ),
          ),
          const SizedBox(height: 8),

          // Subtext Keterangan
          Center(
            child: Text(
              'Tingkatkan Poin Afeksi untuk Mendapatkan Manfaat Khusus',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF518427),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
