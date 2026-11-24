import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashedCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final Color color;
  final double strokeWidth;

  const DashedCircleButton({
    super.key,
    required this.onTap,
    this.size = 36,
    this.color = const Color(0xFF55822B),
    this.strokeWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: color,
          strokeWidth: strokeWidth,
          dashCount: 12,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              Icons.add_rounded,
              color: color,
              size: size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class SolidCheckCircle extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color color;

  const SolidCheckCircle({
    super.key,
    this.onTap,
    this.size = 36,
    this.color = const Color(0xFF55822B),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.8,
    this.dashCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final dashLength = circumference / (dashCount * 2);
    final dashAngle = dashLength / radius;

    double currentAngle = 0;
    while (currentAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
