import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/habit_provider.dart';
import '../../../models/ai_assistant_model.dart';
import 'ai_chat_screen.dart';
import 'companion_settings_screen.dart';

class CompanionHubScreen extends StatelessWidget {
  const CompanionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final companion = habitProvider.currentAssistant;
        return Scaffold(
          backgroundColor: const Color(0xFF4A7220),
          body: _buildBody(context, habitProvider, companion),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, HabitProvider habitProvider, AIAssistantModel companion) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(context, habitProvider),
          Expanded(child: _buildMascotArea(context, habitProvider, companion)),
          _buildBottomSheet(context, habitProvider, companion),
        ],
      ),
    );
  }

  // ─── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, HabitProvider habitProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Avatar + Name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamualaikum',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    habitProvider.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Badges
          _buildBadge(Icons.local_fire_department_rounded,
              '${habitProvider.streakCount}', const Color(0xFFFF9500)),
          const SizedBox(width: 6),
          _buildBadge(Icons.star_rounded, '${habitProvider.userPoints}',
              const Color(0xFFFFCC00)),
          const SizedBox(width: 6),
          // Bell
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 3),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ─── Mascot & Speech Bubble ──────────────────────────────────────────────────
  Widget _buildMascotArea(
      BuildContext context, HabitProvider habitProvider, AIAssistantModel companion) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background (taman / nature)
        Positioned.fill(
          child: ClipRRect(
            child: Image.asset(
              'assets/images/home_bg_day.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF6BA832),
              ),
            ),
          ),
        ),
        // Settings & Bookmark icons top-right
        Positioned(
          top: 8,
          right: 12,
          child: Row(
            children: [
              _buildIconBtn(Icons.bookmark_border_rounded, () {}),
              const SizedBox(width: 6),
              _buildIconBtn(Icons.settings_rounded, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompanionSettingsScreen(),
                  ),
                );
              }),
            ],
          ),
        ),
        // Speech bubble top-left
        Positioned(
          top: 24,
          left: 20,
          child: _buildSpeechBubble(companion.homeMotivationDefault, habitProvider.userName),
        ),
        // Mascot centered
        Positioned(
          bottom: 0,
          child: Image.asset(
            companion.imagePath,
            height: 240,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(height: 240),
          ),
        ),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildSpeechBubble(String message, String userName) {
    // Replace [nama] placeholder
    final text = message.replaceAll('[nama]', userName);
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
          height: 1.4,
        ),
      ),
    );
  }

  // ─── Bottom Sheet (white pill) ───────────────────────────────────────────────
  Widget _buildBottomSheet(
      BuildContext context, HabitProvider habitProvider, AIAssistantModel companion) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8F2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Three action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.shopping_cart_outlined,
                label: 'Toko',
                onTap: () => _showComingSoon(context, 'Toko'),
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Mulai Chat',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIChatScreen()),
                ),
              ),
              _buildActionButton(
                icon: Icons.checkroom_outlined,
                label: 'Lemari',
                onTap: () => _showComingSoon(context, 'Lemari'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Ikatan Persahabatan
          _buildFriendshipBar(habitProvider),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF3D6B1A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3D6B1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendshipBar(HabitProvider habitProvider) {
    // Level based on userPoints
    final level = (habitProvider.userPoints / 50).floor().clamp(1, 10);
    final progress = (habitProvider.userPoints % 50) / 50.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: Color(0xFFE05555), size: 18),
              const SizedBox(width: 6),
              const Text(
                'Ikatan Persahabatan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: Color(0xFFE05555), size: 12),
                    const SizedBox(width: 3),
                    Text(
                      'Lv. $level',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE05555),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A7220)),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tingkatkan Poin Afeksi untuk Mendapatkan Manfaat Khusus',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $featureName segera hadir!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

