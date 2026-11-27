import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../presentation/notifications/notification_screen.dart';

/// Tombol Lonceng Notifikasi Terpadu Muslim Habit
/// Memiliki badge indikator jumlah notifikasi belum dibaca
/// dan membuka Halaman Notifikasi saat diklik.
class NotificationBellButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const NotificationBellButton({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationProvider?>();
    final unread = notifProv?.unreadCount ?? 0;
    final bg = backgroundColor ?? const Color(0xFF2E5714);
    final ic = iconColor ?? Colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: ic,
              size: size * 0.54,
            ),
          ),

          // Badge Notifikasi Belum Dibaca
          if (unread > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
