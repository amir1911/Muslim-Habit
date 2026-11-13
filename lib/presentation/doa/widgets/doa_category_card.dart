import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/doa_category_meta.dart';

class DoaCategoryCard extends StatelessWidget {
  final DoaCategoryMeta category;
  final int count;
  final VoidCallback onTap;

  const DoaCategoryCard({
    super.key,
    required this.category,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 124,
        decoration: BoxDecoration(
          color: category.bgColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Decorative background circle for illustration
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Illustration Badge / Icon
              Positioned(
                right: 12,
                bottom: 12,
                child: _buildIllustration(category),
              ),

              // Title and Subtitle Text
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 70, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E2818),
                        height: 1.25,
                      ),
                    ),
                    Text(
                      '$count Bagian',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4C5B42),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(DoaCategoryMeta cat) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cat.badgeBgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          cat.icon,
          size: 26,
          color: cat.iconColor,
        ),
      ),
    );
  }
}
