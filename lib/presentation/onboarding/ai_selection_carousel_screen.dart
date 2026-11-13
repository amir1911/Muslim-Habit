import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ai_assistant_model.dart';
import 'ai_detail_target_screen.dart';
import 'widgets/onboarding_curve_painter.dart';

class AISelectionCarouselScreen extends StatefulWidget {
  const AISelectionCarouselScreen({super.key});

  @override
  State<AISelectionCarouselScreen> createState() => _AISelectionCarouselScreenState();
}

class _AISelectionCarouselScreenState extends State<AISelectionCarouselScreen> {
  late PageController _pageController;
  int _currentIndex = 0; // 0: Kid, 1: Teen, 2: Adult
  final List<AIAssistantModel> _assistants = AIAssistantModel.assistants;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onNext() {
    if (_currentIndex < _assistants.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _openDetailScreen(int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => AIDetailTargetScreen(initialIndex: index),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFA1CD5A), // Exact top green background #A1CD5A
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Bottom Organic Cream Hill Background
          CustomPaint(
            size: size,
            painter: const SelectionCurvePainter(),
          ),

          // 2. Carousel of Screens
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _assistants.length,
            onPageChanged: (idx) {
              setState(() => _currentIndex = idx);
            },
            itemBuilder: (context, index) {
              final item = _assistants[index];
              return _buildScreenContent(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScreenContent(AIAssistantModel item, int index) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 18),

          // ── Header: "Muslim Habit" ──
          Text(
            'Muslim Habit',
            style: GoogleFonts.balooTammudu2(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),

          // ── Subtitle: "Pilih Fokus Ibadahmu" ──
          Text(
            'Pilih Fokus Ibadahmu',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 26),

          // ── Level Title: "Level Kid" / "Level Teen" / "Level Adult" ──
          Text(
            item.levelTitle,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF375F16), // Exact dark olive green title #375F16
            ),
          ),
          const SizedBox(height: 14),

          // ── Mascot Area with Navigation Chevrons ──
          SizedBox(
            height: 225,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mascot Center Image (Berdiri di atas lengkungan)
                Center(
                  child: Image.asset(
                    item.imagePath,
                    height: 215,
                    fit: BoxFit.contain,
                  ),
                ),

                // Left Arrow (<) - Exact Chevron Shape
                Positioned(
                  left: 14,
                  child: GestureDetector(
                    onTap: index > 0 ? _onPrevious : null,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: index > 0 ? 1.0 : 0.2,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 38,
                        color: Color(0xFF375F16),
                      ),
                    ),
                  ),
                ),

                // Right Arrow (>) - Exact Chevron Shape
                Positioned(
                  right: 14,
                  child: GestureDetector(
                    onTap: index < _assistants.length - 1 ? _onNext : null,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: index < _assistants.length - 1 ? 1.0 : 0.2,
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 38,
                        color: Color(0xFF375F16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── AI Name: LULU / NUNU / RIRI ──
          Text(
            item.name.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF375F16), // Exact dark olive green #375F16
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // ── Description Paragraph ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A583A), // Dark olive body text
                height: 1.45,
              ),
            ),
          ),

          const Spacer(),

          // ── Bottom Pill Button: "Lihat ketentuan level ini" ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF518427).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _openDetailScreen(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF518427), // Exact button green #518427
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Lihat ketentuan level ini',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
