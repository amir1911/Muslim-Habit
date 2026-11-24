import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable Surah Number Badge using `assets/icon/lingkar nomor.png`
class IslamicStarBadge extends StatelessWidget {
  final int number;
  final double size;

  const IslamicStarBadge({
    super.key,
    required this.number,
    this.size = 40.0,
    Color? fillColor,
    Color? borderColor,
    Color? textColor,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = number >= 100 ? 11.5 : (number >= 10 ? 13.0 : 14.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/icon/lingkar nomor.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          Center(
            child: Text(
              '$number',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
