import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/costume_model.dart';
import '../providers/mascot_provider.dart';

class MascotCharacter extends StatefulWidget {
  final double height;
  final String costumeId;
  final List<String>? equippedAccessories;
  final VoidCallback? onTap;
  final bool showSparkles;

  const MascotCharacter({
    super.key,
    this.height = 240,
    this.costumeId = 'normal',
    this.equippedAccessories,
    this.onTap,
    this.showSparkles = true,
  });

  @override
  State<MascotCharacter> createState() => _MascotCharacterState();
}

class _MascotCharacterState extends State<MascotCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnimation;

  int _expressionIndex = 0;
  static const List<String> _expressions = [
    'assets/images/mascot 4.png',
    'assets/images/mascot 1.png',
    'assets/images/mascot 2.png',
    'assets/images/mascot 3.png',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotProv = context.watch<MascotProvider?>();
    final activeAccessories = widget.equippedAccessories ?? mascotProv?.equippedAccessories ?? [];
    final hasPeci = activeAccessories.contains('peci');
    final hasSyal = activeAccessories.contains('syal');
    final hasLonceng = activeAccessories.contains('lonceng');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _expressionIndex = (_expressionIndex + 1) % _expressions.length;
        });
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final charW = widget.height * 0.945;
          final charH = widget.height;

          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: SizedBox(
              width: charW,
              height: charH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── SPARKLES DI SEKITAR MASKOT ──
                  if (widget.showSparkles) ...[
                    Positioned(
                      top: 20,
                      left: 10,
                      child: _buildSparkle(
                        opacity: 0.6 + 0.4 * math.sin(_animController.value * math.pi),
                        scale: 0.8 + 0.3 * _animController.value,
                      ),
                    ),
                    Positioned(
                      top: 70,
                      right: 15,
                      child: _buildSparkle(
                        opacity: 0.5 + 0.5 * math.cos(_animController.value * math.pi),
                        scale: 0.9 + 0.2 * (1 - _animController.value),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 5,
                      child: _buildSparkle(
                        opacity: 0.7 + 0.3 * _animController.value,
                        scale: 0.7 + 0.2 * _animController.value,
                      ),
                    ),
                  ],

                  // ── GAMBAR MASKOT DENGAN 4 EKSPRESI DINAMIS ──
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Image.asset(
                        _expressions[_expressionIndex],
                        key: ValueKey<int>(_expressionIndex),
                        height: charH,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/mascot_standing.png',
                          height: charH,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // ── OVERLAY AKSESORIS 1: SYAL HIJAU ORNAMEN EMAS (MELINGKAR DI LEHER) ──
                  if (hasSyal)
                    Positioned(
                      top: charH * 0.44,
                      left: charH * 0.24,
                      child: SizedBox(
                        width: charH * 0.35,
                        height: charH * 0.32,
                        child: Image.asset(
                          AccessoryPaths.syal,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) {
                            debugPrint('[AKSESORIS] SYAL gagal dimuat: $error');
                            return _buildFallbackSyal(charH);
                          },
                        ),
                      ),
                    ),

                  // ── OVERLAY AKSESORIS 2: LONCENG EMAS TALI COKELAT (DI BAGIAN LEHER) ──
                  if (hasLonceng)
                    Positioned(
                      top: charH * 0.56,
                      left: charH * 0.32,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          mascotProv?.playBellSound();
                        },
                        child: SizedBox(
                          width: charH * 0.20,
                          height: charH * 0.20,
                          child: Image.asset(
                            AccessoryPaths.lonceng,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) {
                              debugPrint('[AKSESORIS] LONCENG gagal dimuat: $error');
                              return _buildFallbackLonceng(charH);
                            },
                          ),
                        ),
                      ),
                    ),

                  // ── OVERLAY AKSESORIS 3: PECI ISLAMI PUTIH HIASAN EMAS (DI ATAS KEPALA) ──
                  if (hasPeci)
                    Positioned(
                      top: charH * 0.03,
                      left: charH * 0.25,
                      child: Transform.rotate(
                        angle: -0.105, // -6 derajat rotasi mengikuti kemiringan kepala unta
                        child: SizedBox(
                          width: charH * 0.28,
                          height: charH * 0.18,
                          child: Image.asset(
                            AccessoryPaths.peci,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) {
                              debugPrint('[AKSESORIS] PECI gagal dimuat: $error');
                              return _buildFallbackPeci(charH);
                            },
                          ),
                        ),
                      ),
                    ),

                // ── OVERLAY AKSESORIS KOSTUM (SORBAN EMAS / JUBAH ZAMRUD) ──
                if (widget.costumeId == 'sorban_emas') ...[
                  // Aksesoris Sorban Emas di kepala
                  Positioned(
                    top: widget.height * 0.08,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Sorban Emas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (widget.costumeId == 'jubah_zamrud') ...[
                  // Aksesoris Jubah Zamrud
                  Positioned(
                    top: widget.height * 0.08,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF00796B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.diamond_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Jubah Zamrud',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildSparkle({required double opacity, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: const Icon(
          Icons.star_rounded,
          color: Color(0xFF9CCC65),
          size: 24,
        ),
      ),
    );
  }

  // =========================================================================
  // FALLBACK RENDERER AKSESORIS (Bila file PNG belum dimasukkan ke assets)
  // =========================================================================

  /// Fallback Peci Islami (Putih hiasan hijau dan emas)
  Widget _buildFallbackPeci(double h) {
    return Center(
      child: Container(
        width: h * 0.28,
        height: h * 0.12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(6)),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Kubah / Atas Peci
            Expanded(
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Lis Hijau & Emas di bagian bawah peci
            Container(
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF518427),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback Syal (Hijau tua ornamen emas melingkar di leher)
  Widget _buildFallbackSyal(double h) {
    return Center(
      child: Container(
        width: h * 0.44,
        height: h * 0.10,
        decoration: BoxDecoration(
          color: const Color(0xFF2E5714),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E350E).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(width: 4, color: const Color(0xFFFFD700)),
            Container(width: 4, color: const Color(0xFFFFD700)),
            Container(width: 4, color: const Color(0xFFFFD700)),
          ],
        ),
      ),
    );
  }

  /// Fallback Lonceng (Lonceng emas dengan tali cokelat)
  Widget _buildFallbackLonceng(double h) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tali Cokelat
          Container(
            width: h * 0.18,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF6D4C41),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          // Lonceng Emas
          Container(
            width: h * 0.11,
            height: h * 0.11,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFEA00), Color(0xFFFFB300)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFF5D4037),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
