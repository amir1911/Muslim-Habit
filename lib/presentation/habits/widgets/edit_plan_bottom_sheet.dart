import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../edit_habit_screen.dart';

/// Modal Bottom Sheet Edit Plan (EditPlanBottomSheet)
class EditPlanBottomSheet extends StatelessWidget {
  const EditPlanBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditPlanBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Atas
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCD3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Bar: Judul "Edit Plan" & Tombol Tutup "X"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Text(
                  'Edit Plan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. OPSI: EDIT ATAU TAMBAH HABBIT
            _buildOptionCard(
              context: context,
              icon: Icons.bolt_rounded,
              title: 'Edit atau Tambah Habbit',
              description: 'Ubah Setting Habbit-mu Disini! Baik dari Alarm atau Seberapa Sering Kamu Melakukannya!',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditHabitScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 2. OPSI: EDIT FOKUS HABBIT
            _buildOptionCard(
              context: context,
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Edit Fokus Habbit',
              description: 'Ubah Fokus Habbit dan Pendampingmu!',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Fokus ibadah & pendamping Nunu siap disesuaikan.',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: const Color(0xFF55822B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E7DF), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF386616),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6B7280),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
