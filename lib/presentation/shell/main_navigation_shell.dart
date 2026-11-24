import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../habits/habits_screen.dart';
import '../quran/quran_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../badges/badges_screen.dart';
import '../community/community_screen.dart';
import '../../features/ai_companion/screens/companion_hub_screen.dart';
import '../../features/mascot/screens/mascot_hub_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  /// Static helper to switch tabs on the active MainNavigationShell from any child widget
  static bool switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    if (state != null) {
      state.switchTab(index);
      return true;
    }
    return false;
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    if (mounted && _currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    HabitsScreen(),
    QuranScreen(),
    CommunityScreen(),
    BadgesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Hitung total tinggi nav bar floating untuk posisi tombol AI:
    // SafeArea bottom + padding bottom(16) + tinggi container(72) + gap tombol(12)
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + 16 + 72 + 12;

    return Scaffold(
      extendBody: true, // content mengalir di bawah floating nav
      body: Stack(
        children: [
          // ── Konten halaman utama ──
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // ── Floating AI Chat Button ──
          Positioned(
            right: 20,
            bottom: bottomNavHeight,
            child: _buildAiChatButton(context),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SafeArea(
          top: false,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.13),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.track_changes_outlined, Icons.track_changes_rounded, 'Habbit'),
                _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book_rounded, "Qur'an"),
                _buildNavItem(3, Icons.people_outline_rounded, Icons.people_rounded, 'Community'),
                _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Floating AI Chat Button ──
  Widget _buildAiChatButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MascotHubScreen()),
      ),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF557C2B),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF557C2B).withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/icon/tanyaAI.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                key: ValueKey(isSelected),
                color: isSelected ? const Color(0xFF557C2B) : AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF557C2B) : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
