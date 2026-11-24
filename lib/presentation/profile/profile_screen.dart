import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/habit_provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../auth/auth_screen.dart';
import '../shell/main_navigation_shell.dart';
import '../habits/kalender_planning_screen.dart';
import '../habits/widgets/edit_plan_bottom_sheet.dart';
import '../badges/badges_screen.dart';
import '../doa/doa_screen.dart';
import '../../features/mascot/screens/chatbot_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late StorageService _storage;
  String _userEmail = 'ahmad.husain@email.com';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null && fbUser.email != null && fbUser.email!.isNotEmpty) {
      _userEmail = fbUser.email!;
    } else {
      try {
        _storage = context.read<StorageService>();
        _userEmail = _storage.getUserEmail();
      } catch (_) {
        _userEmail = 'ahmad.husain@email.com';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final userName = habitProv.userName.isNotEmpty ? habitProv.userName : 'Ahmad Husain';
    final userLevel = habitProv.userLevel;
    final streak = habitProv.streakCount;
    final xp = habitProv.userPoints;
    final levelTitle = habitProv.currentAssistant.levelTitle.isNotEmpty
        ? habitProv.currentAssistant.levelTitle
        : 'Level Teen';

    // Inisial untuk avatar AH
    String initials = 'AH';
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6EE),
      appBar: _buildAppBar(context, streak, xp),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // ── HEADER INFO PENGGUNA ──
            _buildUserHeader(context, userName, _userEmail, levelTitle, initials, habitProv),
            const SizedBox(height: 24),

            // ── GROUP 1: AKUN ──
            _buildSectionHeader('AKUN'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                onTap: () => _showEditProfileDialog(context, habitProv),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF0F2EB)),
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: 'Pengaturan Akun',
                onTap: () => _showAccountSettingsSheet(context),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF0F2EB)),
              _buildMenuItem(
                icon: Icons.smart_toy_outlined,
                title: 'Setting Chatbot',
                onTap: () => _showChatbotSettingsSheet(context),
              ),
            ]),
            const SizedBox(height: 20),

            // ── GROUP 2: AKTIVITAS IBADAH ──
            _buildSectionHeader('AKTIVITAS IBADAH'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.history_rounded,
                title: 'Riwayat Ibadah',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KalenderPlanningScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF0F2EB)),
              _buildMenuItem(
                icon: Icons.bar_chart_rounded,
                title: 'Statistik Ibadah',
                onTap: () => _showStatisticsSheet(context, habitProv),
              ),
            ]),
            const SizedBox(height: 20),

            // ── GROUP 3: TARGET & PENGINGAT ──
            _buildSectionHeader('TARGET & PENGINGAT'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.track_changes_rounded,
                title: 'Target Ibadah',
                onTap: () => EditPlanBottomSheet.show(context),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF0F2EB)),
              _buildMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Pengingat',
                onTap: () => _showRemindersSheet(context),
              ),
            ]),
            const SizedBox(height: 20),

            // ── GROUP 4: PERSONAL ──
            _buildSectionHeader('PERSONAL'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'Favorit / Doa Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoaScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            // ── GROUP 5: BANTUAN ──
            _buildSectionHeader('BANTUAN'),
            const SizedBox(height: 8),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Pusat Bantuan & FAQ',
                onTap: () => _showHelpAndFaqSheet(context),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF0F2EB)),
              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'Tentang Muslim Habit',
                onTap: () => _showAboutAppSheet(context),
              ),
            ]),
            const SizedBox(height: 24),

            // ── TOMBOL KELUAR DARI AKUN ──
            _buildLogoutButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // APPBAR
  // ==========================================
  PreferredSizeWidget _buildAppBar(BuildContext context, int streak, int xp) {
    return AppBar(
      backgroundColor: const Color(0xFF518427),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF86AB53),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        'Profile',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        // Streak pill
        Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF3E601C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFFB300),
                size: 15,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Star XP pill
        Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF3E601C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFD700),
                size: 15,
              ),
              const SizedBox(width: 4),
              Text(
                '$xp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Bell icon
        Container(
          margin: const EdgeInsets.only(right: 14),
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF3E601C),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 17,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifikasi profile aktif'),
                  duration: Duration(milliseconds: 1000),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // USER HEADER
  // ==========================================
  Widget _buildUserHeader(
    BuildContext context,
    String userName,
    String email,
    String levelTitle,
    String initials,
    HabitProvider habitProv,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lingkaran Avatar Hijau dengan Inisial + Ikon Tambah (+)
        Stack(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFF518427),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _showEditProfileDialog(context, habitProv),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B6114),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF7F6EE), width: 2),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Detail Teks: Nama, Email, Pill Level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E3710),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF75856B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Pill Level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF518427),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  levelTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION HEADER & CARD ITEM
  // ==========================================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF75856B),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            // Lingkaran Ikon Hijau Muda
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2E3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF518427),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Judul Menu
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3710),
                ),
              ),
            ),

            // Chevron Panah Kanan
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB4C0AD),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOGOUT BUTTON
  // ==========================================
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutConfirmation(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFD32F2F),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ACTION SHEETS & DIALOGS
  // ==========================================

  // 1. Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context, HabitProvider habitProv) {
    final nameCtrl = TextEditingController(text: habitProv.userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E5714),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  filled: true,
                  fillColor: const Color(0xFFF7F6EE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF518427)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  filled: true,
                  fillColor: const Color(0xFFF7F6EE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF518427)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    final newEmail = emailCtrl.text.trim();
                    if (newName.isNotEmpty) {
                      habitProv.setUserName(newName);
                    }
                    if (newEmail.isNotEmpty) {
                      setState(() {
                        _userEmail = newEmail;
                      });
                      try {
                        context.read<StorageService>().setUserEmail(newEmail);
                      } catch (_) {}
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil diperbarui'),
                        backgroundColor: Color(0xFF518427),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF518427),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Pengaturan Akun
  void _showAccountSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengaturan Akun & Keamanan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E5714),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_reset_rounded, color: Color(0xFF518427)),
                title: Text('Ubah Kata Sandi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Ganti password akun Anda', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tautan reset kata sandi telah dikirim ke email')),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.security_rounded, color: Color(0xFF518427)),
                title: Text('Privasi Data & Akun', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Data ibadah Anda tersimpan secara lokal dan aman', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. Setting Chatbot
  void _showChatbotSettingsSheet(BuildContext context) {
    String currentTone = 'Ramah & Islami';
    try {
      currentTone = context.read<StorageService>().getChatbotTone();
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Setting Chatbot Nunu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E5714),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih gaya respon percakapan asisten Nunu Anda:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF75856B)),
                  ),
                  const SizedBox(height: 14),
                  RadioListTile<String>(
                    activeColor: const Color(0xFF518427),
                    title: Text('Ramah & Islami (Rekomendasi)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    value: 'Ramah & Islami',
                    groupValue: currentTone,
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => currentTone = val);
                        try {
                          context.read<StorageService>().setChatbotTone(val);
                        } catch (_) {}
                      }
                    },
                  ),
                  RadioListTile<String>(
                    activeColor: const Color(0xFF518427),
                    title: Text('Formal & Penuh Hikmah', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    value: 'Formal & Penuh Hikmah',
                    groupValue: currentTone,
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => currentTone = val);
                        try {
                          context.read<StorageService>().setChatbotTone(val);
                        } catch (_) {}
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF518427),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Buka Chatbot Sekarang', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4. Statistik Ibadah Sheet
  void _showStatisticsSheet(BuildContext context, HabitProvider habitProv) {
    final completedCount = habitProv.completedHabitsCount;
    final totalCount = habitProv.totalHabitsCount;
    final percent = habitProv.dailyProgressPercent;
    final streak = habitProv.streakCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Statistik & Konsistensi Ibadah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E5714),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2EADF)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF07026), size: 28),
                          const SizedBox(height: 4),
                          Text('$streak Hari', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF2E5714))),
                          Text('Streak Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF75856B))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2EADF)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF518427), size: 28),
                          const SizedBox(height: 4),
                          Text('$percent%', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF2E5714))),
                          Text('$completedCount dari $totalCount Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF75856B))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BadgesScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF518427),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Lihat Penghargaan & Badges', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. Pengingat Sheet
  void _showRemindersSheet(BuildContext context) {
    bool isEnabled = true;
    try {
      isEnabled = context.read<StorageService>().getHabitRemindersEnabled();
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pengaturan Pengingat',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E5714),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    activeColor: const Color(0xFF518427),
                    contentPadding: EdgeInsets.zero,
                    title: Text('Aktifkan Notifikasi Pengingat', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                    subtitle: Text('Kirim alarm waktu sholat & habit harian', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF75856B))),
                    value: isEnabled,
                    onChanged: (val) {
                      setSheetState(() => isEnabled = val);
                      try {
                        context.read<StorageService>().setHabitRemindersEnabled(val);
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEnabled ? 'Pengingat ibadah aktif' : 'Pengingat ibadah dinonaktifkan'),
                            backgroundColor: const Color(0xFF518427),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF518427),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Simpan Pengaturan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 6. Bantuan & FAQ
  void _showHelpAndFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pusat Bantuan & FAQ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E5714),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildFaqItem(
                      'Bagaimana cara menambah target habit baru?',
                      'Masuk ke menu Habbit lalu tekan tombol "+" atau "EditJadwal" untuk memilih ibadah yang ingin ditargetkan.',
                    ),
                    _buildFaqItem(
                      'Bagaimana streak dihitung?',
                      'Streak bertambah setiap hari ketika Anda mencentang dan menyelesaikan target ibadah harian.',
                    ),
                    _buildFaqItem(
                      'Apakah aplikasi dapat berjalan secara offline?',
                      'Ya, jadwal ibadah, checklist kebiasaan, dan Al-Qur\'an lokal dapat diakses tanpa koneksi internet.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(q, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E3710))),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(a, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF556050))),
        ),
      ],
    );
  }

  // 7. Tentang Muslim Habit
  void _showAboutAppSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF518427),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'Muslim Habit',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2E5714)),
              ),
              Text(
                'Versi 1.0.0 (Build 2026)',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF75856B)),
              ),
              const SizedBox(height: 12),
              Text(
                'Aplikasi pendamping ibadah, pembangun kebiasaan Islami, Al-Qur\'an digital, dan komunitas kebaikan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF334B22)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // 8. Logout Confirmation Dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Keluar dari Akun',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2E5714)),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Muslim Habit Anda?',
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF556050)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF75856B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final authService = AuthService();
                await authService.signOut();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(
                        isRegisterInitial: false,
                        onSuccess: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainNavigationShell(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}
