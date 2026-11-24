import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/community_provider.dart';
import '../../models/community/user_profile_model.dart';
import '../../models/community/community_model.dart';
import 'chat_detail_screen.dart';
import 'tambah_teman_screen.dart';
import 'temukan_komunitas_screen.dart';
import 'buat_komunitas_screen.dart';
import 'detail_komunitas_screen.dart';
import 'notifikasi_community_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final isTemanTab = provider.selectedTab == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── HEADER ──
            _buildHeader(context, provider),

            // ── TAB TOGGLE (TEMAN / KOMUNITAS) ──
            _buildTabSelector(context, provider),

            const SizedBox(height: 12),

            // ── BODY CONTENT ──
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF518427),
                onRefresh: () => provider.refreshAll(),
                child: isTemanTab
                    ? _buildTabTemanContent(context, provider)
                    : _buildTabKomunitasContent(context, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. TOP HEADER (Komunitas + Badges)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, CommunityProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button jika dibuka via push, atau text judul
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (Navigator.canPop(context)) const SizedBox(width: 8),

          Text(
            'Komunitas',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),

          // Badge 1 (Daun/Hijau 17)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF518427),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '17',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Badge 2 (Bintang/Kuning 10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '10',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Icon Notifikasi
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotifikasiCommunityScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF518427),
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 16, color: Colors.white),
                  if (provider.unreadNotificationCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${provider.unreadNotificationCount}',
                          style: GoogleFonts.inter(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. SEGMENTED TAB SELECTOR (Teman / Komunitas)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTabSelector(BuildContext context, CommunityProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => provider.switchTab(0),
                child: Container(
                  decoration: BoxDecoration(
                    color: provider.selectedTab == 0 ? const Color(0xFF518427) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Teman',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: provider.selectedTab == 0 ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => provider.switchTab(1),
                child: Container(
                  decoration: BoxDecoration(
                    color: provider.selectedTab == 1 ? const Color(0xFF518427) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Komunitas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: provider.selectedTab == 1 ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. TAB TEMAN CONTENT
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTabTemanContent(BuildContext context, CommunityProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      children: [
        // ── Story Horizontal Avatars ──
        _buildStoryFriendsRow(context, provider),

        const SizedBox(height: 16),

        // ── Banner "Ajak Temanmu!" ──
        _buildBanner(
          context: context,
          icon: Icons.group_add_rounded,
          title: 'Ajak Temanmu!',
          subtitle: 'Perkuat ukhuwah bersama Al-Majlis',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahTemanScreen()),
            );
          },
        ),

        const SizedBox(height: 20),

        // ── Friend List Items ──
        if (provider.friends.isEmpty)
          _buildEmptyFriendsState(context)
        else
          ...provider.friends.map((friend) => _buildFriendCard(context, friend)),

        const SizedBox(height: 24),

        // ── Footer ──
        Center(
          child: Text(
            "You're All Caught Up! Try inviting more friends!",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStoryFriendsRow(BuildContext context, CommunityProvider provider) {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.friends.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Tombol Tambah
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahTemanScreen()),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.add, size: 24, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TAMBAH',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }

          final friend = provider.friends[index - 1];
          final firstName = friend.displayName.split(' ').first.toUpperCase();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDetailScreen(friend: friend)),
              );
            },
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: friend.isOnline ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: Text(
                          friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : 'U',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF518427),
                          ),
                        ),
                      ),
                    ),
                    if (friend.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 64,
                  child: Text(
                    firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, UserProfileModel friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatDetailScreen(friend: friend)),
          );
        },
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFE2E8F0),
          child: Text(
            friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : 'U',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF518427),
            ),
          ),
        ),
        title: Text(
          friend.displayName,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          friend.activeStatusString,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: friend.isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B),
            fontWeight: friend.isOnline ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: Text(
          DateFormat('d MMMM yyyy').format(friend.lastActive).toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. TAB KOMUNITAS CONTENT
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTabKomunitasContent(BuildContext context, CommunityProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      children: [
        // ── Story Horizontal Community Icons ──
        _buildStoryCommunitiesRow(context, provider),

        const SizedBox(height: 16),

        // ── Banner "Temukan Komunitasmu!" ──
        _buildBanner(
          context: context,
          icon: Icons.groups_rounded,
          title: 'Temukan Komunitasmu!',
          subtitle: 'Perkuat ukhuwah bersama Al-Majlis',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemukanKomunitasScreen()),
            );
          },
        ),

        const SizedBox(height: 20),

        // ── List of Joined / Featured Communities ──
        if (provider.joinedCommunities.isEmpty)
          _buildEmptyCommunityState(context)
        else
          ...provider.joinedCommunities.map((comm) => _buildCommunityCard(context, comm)),

        const SizedBox(height: 24),

        // ── Footer ──
        Center(
          child: Text(
            "You're All Caught Up! Try joining more groups!",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStoryCommunitiesRow(BuildContext context, CommunityProvider provider) {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.joinedCommunities.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Tombol Tambah Komunitas
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuatKomunitasScreen()),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.add, size: 24, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TAMBAH',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }

          final comm = provider.joinedCommunities[index - 1];
          final shortName = comm.name.length > 7 ? '${comm.name.substring(0, 7)}..' : comm.name;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailKomunitasScreen(community: comm)),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF518427), Color(0xFF2D5A3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    comm.name.isNotEmpty ? comm.name[0].toUpperCase() : 'K',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 64,
                  child: Text(
                    shortName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, CommunityModel comm) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailKomunitasScreen(community: comm)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover / Banner
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF518427),
                    const Color(0xFF2D5A3C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      comm.category == 'Al-Qur\'an'
                          ? Icons.menu_book_rounded
                          : comm.category == 'Dhuha'
                              ? Icons.wb_sunny_rounded
                              : Icons.groups_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${comm.memberCount} members',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comm.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        comm.privacyLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
                      const SizedBox(width: 8),
                      Text(
                        comm.category,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF518427),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. BANNER KOMPONEN
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBanner({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF518427),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF518427).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. EMPTY STATES
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyFriendsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.person_add_disabled_rounded, size: 54, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Teman',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ayo undang teman dan bangun lingkaran ukhuwah bersama!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCommunityState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.group_off_rounded, size: 54, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(
            'Belum Bergabung Komunitas',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cari komunitas ibadah yang sesuai dengan minatmu sekarang!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
