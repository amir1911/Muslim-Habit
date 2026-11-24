import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/community_provider.dart';
import '../../models/community/community_notification_model.dart';

class NotifikasiCommunityScreen extends StatelessWidget {
  const NotifikasiCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final notifs = provider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF518427),
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
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (notifs.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                provider.markAllNotificationsRead();
              },
              child: Text(
                'Tandai dibaca',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
        ],
      ),
      body: notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 54, color: const Color(0xFFCBD5E1)),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada notifikasi baru',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final n = notifs[index];
                return _buildNotificationCard(context, n);
              },
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, CommunityNotificationModel n) {
    IconData icon;
    Color color;

    switch (n.type) {
      case NotificationType.friendRequest:
      case NotificationType.friendAccepted:
        icon = Icons.person_add_rounded;
        color = const Color(0xFF2563EB);
        break;
      case NotificationType.newChat:
        icon = Icons.chat_bubble_rounded;
        color = const Color(0xFF10B981);
        break;
      case NotificationType.postComment:
        icon = Icons.mode_comment_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case NotificationType.postLike:
        icon = Icons.favorite_rounded;
        color = const Color(0xFFEF4444);
        break;
      case NotificationType.communityJoined:
      case NotificationType.communityInvite:
      case NotificationType.announcement:
        icon = Icons.groups_rounded;
        color = const Color(0xFF518427);
        break;
    }

    final timeStr = DateFormat('d MMM, HH:mm').format(n.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: n.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBBF7D0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
