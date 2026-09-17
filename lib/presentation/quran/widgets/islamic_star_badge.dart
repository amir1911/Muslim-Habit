import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Islamic 8-pointed star badge (Rub el Hizb)
/// Sesuai desain lingkaran bintang segi 8 pada mockup
class IslamicStarBadge extends StatelessWidget {
  final int number;
  final double size;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;

  const IslamicStarBadge({
    super.key,
    required this.number,
    this.size = 46.0,
    this.fillColor = const Color(0xFF4A7220),
    this.borderColor = const Color(0xFF8BB750),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RubElHizbPainter(
              fillColor: fillColor,
              borderColor: borderColor,
            ),
          ),
          Text(
            '$number',
            style: GoogleFonts.balooTammudu2(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RubElHizbPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _RubElHizbPainter({
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Gambar bintang 8 (Rub el Hizb) dengan 16 titik (8 puncak, 8 lekukan)
    final path = Path();
    const int points = 16;
    final innerRadius = radius * 0.78;

    for (int i = 0; i < points; i++) {
      final isPeak = i % 2 == 0;
      final r = isPeak ? radius : innerRadius;
      final angle = (i * 2 * math.pi / points) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // Lingkaran aksen halus di dalam
    final innerCirclePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, innerRadius * 0.85, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _RubElHizbPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}
