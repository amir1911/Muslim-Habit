import 'package:flutter/material.dart';

/// Custom Painter yang menggambar bukit/lengkungan cream persis seperti desain referensi:
/// - Screen 1: Curve turun dari kiri (y ≈ 0.55 tinggi) melandai ke kanan bawah (y ≈ 0.60)
class SelectionCurvePainter extends CustomPainter {
  final Color curveColor;

  const SelectionCurvePainter({
    this.curveColor = const Color(0xFFF9FAEF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = curveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    // Mulai dari kiri di 54.5% tinggi layar
    final startY = size.height * 0.547;
    path.moveTo(0, startY);

    // Titik puncak melengkung halus melintasi bagian tengah dan menurun ke kanan di 60.5%
    path.cubicTo(
      size.width * 0.28,
      size.height * 0.495,
      size.width * 0.68,
      size.height * 0.515,
      size.width,
      size.height * 0.605,
    );

    // Sambungkan ke bawah memenuhi layar
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// - Screen 2: Lengkungan bukit dimulai lebih tinggi (y ≈ 0.40 di kiri)
/// melandai halus ke arah kanan di y ≈ 0.32
class DetailCurvePainter extends CustomPainter {
  final Color curveColor;

  const DetailCurvePainter({
    this.curveColor = const Color(0xFFF9FAEF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = curveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    // Mulai dari kiri di y ≈ 0.408
    final startY = size.height * 0.408;
    path.moveTo(0, startY);

    // Lengkungan melandai ke atas di tengah-kanan (puncak ≈ 0.31)
    path.cubicTo(
      size.width * 0.30,
      size.height * 0.325,
      size.width * 0.65,
      size.height * 0.305,
      size.width,
      size.height * 0.325,
    );

    // Sambungkan ke bawah memenuhi layar
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

