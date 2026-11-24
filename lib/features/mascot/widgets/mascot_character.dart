import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MascotCharacter extends StatefulWidget {
  final double height;
  final String costumeId;
  final VoidCallback? onTap;
  final bool showSparkles;

  const MascotCharacter({
    super.key,
    this.height = 240,
    this.costumeId = 'normal',
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── SPARKLES DI SEKITAR MASKOT ──
                if (widget.showSparkles) ...[
                  Positioned(
                    top: 20,
                    left: 20,
                    child: _buildSparkle(
                      opacity: 0.6 + 0.4 * math.sin(_animController.value * math.pi),
                      scale: 0.8 + 0.3 * _animController.value,
                    ),
                  ),
                  Positioned(
                    top: 70,
                    right: 25,
                    child: _buildSparkle(
                      opacity: 0.5 + 0.5 * math.cos(_animController.value * math.pi),
                      scale: 0.9 + 0.2 * (1 - _animController.value),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 10,
                    child: _buildSparkle(
                      opacity: 0.7 + 0.3 * _animController.value,
                      scale: 0.7 + 0.2 * _animController.value,
                    ),
                  ),
                ],

                // ── GAMBAR MASKOT NUNU BERDIRI ──
                Image.asset(
                  'assets/images/mascot_standing.png',
                  height: widget.height,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/mascot_nunu.png',
                    height: widget.height,
                    fit: BoxFit.contain,
                  ),
                ),

                // ── OVERLAY AKSESORIS KOSTUM SESUAI PILIHAN ──
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
}
