import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bubble dialog putih dengan panah segitiga ke bawah menghadap maskot
class MascotSpeechBubble extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const MascotSpeechBubble({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E350E),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Panah Segitiga Bawah
          CustomPaint(
            size: const Size(18, 10),
            painter: _TrianglePointerPainter(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TrianglePointerPainter extends CustomPainter {
  final Color color;
  _TrianglePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
