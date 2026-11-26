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
    final startColor = category.bgColor;
    final endColor = category.endBgColor ?? category.bgColor.withValues(alpha: 0.85);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          // Soft ambient shadow
          BoxShadow(
            color: category.iconColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          // Subtle floor depth shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: Colors.white.withValues(alpha: 0.35),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          child: Container(
            height: 124,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Stack(
                children: [
                  // 1. Ornamen dekorasi sudut kiri atas: blob cahaya lembut
                  Positioned(
                    top: -24,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                  ),

                  // 2. Ornamen islami samar: bintang 4 titik / sparkle halus
                  Positioned(
                    top: 14,
                    right: 48,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),

                  // 3. Ornamen lingkaran dekoratif di belakang badge icon (layer 1)
                  Positioned(
                    right: -14,
                    bottom: -14,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                  ),

                  // 4. Ornamen lingkaran dekoratif (layer 2 - inner halo)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),

                  // 5. Illustration Badge / Icon di kanan bawah
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: _buildIllustration(category),
                  ),

                  // 6. Konten Teks (Judul & Subtitle Jumlah Bagian)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 68, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Judul Kategori
                        Text(
                          category.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E2818),
                            height: 1.22,
                            letterSpacing: -0.2,
                          ),
                        ),

                        // Subtitle "x Bagian" dalam pill badge tipis yang estetik
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '$count Bagian',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334928),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(DoaCategoryMeta cat) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: cat.badgeBgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: cat.iconColor.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(-1, -1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: cat.imagePath != null
            // Gunakan Image.asset jika gambar tersedia, fallback ke Icon jika gagal load
            ? Image.asset(
                cat.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(cat.icon, size: 24, color: cat.iconColor),
                ),
              )
            : Center(
                child: Icon(cat.icon, size: 24, color: cat.iconColor),
              ),
      ),
    );
  }
}
