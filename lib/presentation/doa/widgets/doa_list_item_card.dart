import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/doa_item.dart';

class DoaListItemCard extends StatelessWidget {
  final int index;
  final DoaItem doa;
  final VoidCallback onTap;

  const DoaListItemCard({
    super.key,
    required this.index,
    required this.doa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFECEADF),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Number Index
                SizedBox(
                  width: 28,
                  child: Text(
                    '$index',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Doa Title
                Expanded(
                  child: Text(
                    doa.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E2818),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Arrow Icon
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFFB5BAAE),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
