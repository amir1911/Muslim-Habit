import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../shell/main_navigation_shell.dart';
import '../auth/auth_modal_sheet.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _fadeInSiply1;
  late Animation<double> _circleGrowth;
  late Animation<double> _mascotAppearance;
  late Animation<double> _mascotBounce;
  late Animation<double> _bottomSheetSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // SIPLY 1: Fade-in text on cream (0% - 20%)
    _fadeInSiply1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );

    // SIPLY 2 & 3: Circle grows from center (20% - 55%)
    _circleGrowth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.55, curve: Curves.easeInOutCubic),
      ),
    );

    // SIPLY 4: Mascot fade and scale in (52% - 78%)
    _mascotAppearance = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.75, curve: Curves.easeOut),
      ),
    );

    _mascotBounce = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.78, curve: Curves.elasticOut),
      ),
    );

    // SIPLY 5: Curved bottom sheet slides up (75% - 100%)
    _bottomSheetSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start auto-playing the intro animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const MainNavigationShell(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showAuthSheet(bool isRegister) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuthModalSheet(
        isRegisterInitial: isRegister,
        onSuccess: () {
          Navigator.pop(ctx);
          _navigateToMainApp();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final circleProgress = _circleGrowth.value;
          final currentCircleRadius = circleProgress * maxRadius;

          return Stack(
            fit: StackFit.expand,
            children: [
              // BASE LAYER (Cream background - SIPLY 1)
              Container(
                color: const Color(0xFFF7F6EE),
                child: Center(
                  child: Opacity(
                    opacity: _fadeInSiply1.value,
                    child: Text(
                      'Muslim Habit',
                      style: GoogleFonts.balooThammudu2(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // EXPANDING CIRCLE LAYER (SIPLY 2 - 3)
              if (circleProgress > 0.0)
                ClipPath(
                  clipper: CircleRevealClipper(
                    center: Offset(size.width / 2, size.height / 2),
                    radius: currentCircleRadius,
                  ),
                  child: Container(
                    color: AppColors.primaryGreen,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Inverted text inside circle during growth (SIPLY 2 & 3)
                        if (_mascotAppearance.value < 0.6)
                          Center(
                            child: Text(
                              'Muslim Habit',
                              style: GoogleFonts.balooThammudu(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                        // SIPLY 4 & 5 CONTENT (Mascot, Arch, Title)
                        if (_mascotAppearance.value > 0.0)
                          Opacity(
                            opacity: _mascotAppearance.value,
                            child: Transform.scale(
                              scale: _mascotBounce.value,
                              child: _buildSiply4And5Content(size),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // TOP DEBUG / STEP CONTROLLER BAR (Optional for demo exploration)
              Positioned(
                top: 50,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_rounded, color: Colors.white70, size: 20),
                        tooltip: 'Putar Ulang Splash',
                        onPressed: () => _controller.forward(from: 0.0),
                      ),
                      TextButton(
                        onPressed: _navigateToMainApp,
                        child: Text(
                          'Lewati',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSiply4And5Content(Size size) {
    return Stack(
      children: [
        // Top Header Text "Muslim Habit"
        Positioned(
          top: size.height * 0.13,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Muslim Habit',
              style: GoogleFonts.balooThammudu2(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        // 3D Camel Mascot & Islamic Mosque Arch (Centered Scene)
        Positioned(
          top: size.height * 0.20,
          bottom: size.height * 0.16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'assets/images/image 52.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildVectorMascotFallback(),
              ),
            ),
          ),
        ),

        // SIPLY 5: Curved Bottom Sheet with Auth Buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, _bottomSheetSlide.value * 280),
            child: _buildCurvedBottomAuthPanel(size),
          ),
        ),
      ],
    );
  }

  Widget _buildCurvedBottomAuthPanel(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8F2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // White Button "Masuk" (with sage text and border)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _showAuthSheet(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: Color(0xFFE2E0CF), width: 1.5),
                ),
              ),
              child: Text(
                'Masuk',
                style: GoogleFonts.balooThammudu(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Olive Green Button "Daftar"
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _showAuthSheet(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E8036),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Daftar',
                style: GoogleFonts.balooThammudu(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Subtle Guest Entry Link
          TextButton(
            onPressed: _navigateToMainApp,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMedium,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Lanjutkan sebagai Tamu →',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorMascotFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐪', style: TextStyle(fontSize: 70)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Jamal Si Unta Buddy',
          style: GoogleFonts.balooThammudu2(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: radius),
      );
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
