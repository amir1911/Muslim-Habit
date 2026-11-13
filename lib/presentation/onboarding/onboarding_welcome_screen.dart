import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_selection_carousel_screen.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  State<OnboardingWelcomeScreen> createState() => _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeHello;
  late Animation<double> _scaleCircle;
  late Animation<double> _fadePilihAI;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 0 - 35%: "Halo! Selamat datang di Muslim Habit"
    _fadeHello = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // 40% - 70%: Green circle expands
    _scaleCircle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.70, curve: Curves.elasticOut),
      ),
    );

    // 65% - 95%: "Pilih AI?" inside green circle
    _fadePilihAI = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.95, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Auto navigate ke halaman pemilihan AI setelah animasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _navigateToCarousel();
          }
        });
      }
    });
  }

  void _navigateToCarousel() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const AISelectionCarouselScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF6), // Cream background as in SIPLY 8, 9, 10
      body: GestureDetector(
        onTap: () {
          // Pengguna bisa tap untuk langsung skip ke pemilihan AI
          _navigateToCarousel();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final helloOpacity = _controller.value < 0.40
                ? _fadeHello.value
                : (1.0 - (_controller.value - 0.40) / 0.10).clamp(0.0, 1.0);

            final showCircle = _controller.value >= 0.40;

            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // SIPLY 8: Halo! Selamat datang di Muslim Habit
                if (helloOpacity > 0)
                  Opacity(
                    opacity: helloOpacity,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Halo!',
                            style: GoogleFonts.balooTammudu2(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF88B342), // Light green header
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selamat datang di Muslim Habit',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF88B342),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // SIPLY 9 & 10: Circle grows & shows "Pilih AI?"
                if (showCircle)
                  Transform.scale(
                    scale: _scaleCircle.value,
                    child: Container(
                      width: 175,
                      height: 175,
                      decoration: const BoxDecoration(
                        color: Color(0xFF99C256), // Green circle matching SIPLY 9 & 10
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: _fadePilihAI.value,
                        child: Text(
                          'Pilih AI?',
                          style: GoogleFonts.balooTammudu2(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

