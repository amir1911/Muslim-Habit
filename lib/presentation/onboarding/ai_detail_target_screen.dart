import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/ai_assistant_model.dart';
import '../../providers/habit_provider.dart';
import '../shell/main_navigation_shell.dart';
import 'widgets/onboarding_curve_painter.dart';
import '../../core/widgets/custom_back_button.dart';

class AIDetailTargetScreen extends StatefulWidget {
  final int initialIndex;

  const AIDetailTargetScreen({
    super.key,
    required this.initialIndex,
  });

  @override
  State<AIDetailTargetScreen> createState() => _AIDetailTargetScreenState();
}

class _AIDetailTargetScreenState extends State<AIDetailTargetScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final List<AIAssistantModel> _assistants = AIAssistantModel.assistants;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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

  void _confirmSelection(BuildContext context) async {
    final selectedAI = _assistants[_currentIndex];
    final habitProvider = context.read<HabitProvider>();

    await habitProvider.completeOnboarding(selectedAI.id);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const MainNavigationShell(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFA1CD5A), // Exact top green background #A1CD5A
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Organic Hill Curve
          CustomPaint(
            size: size,
            painter: const DetailCurvePainter(),
          ),

          // 2. PageView
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _assistants.length,
            onPageChanged: (idx) {
              setState(() => _currentIndex = idx);
            },
            itemBuilder: (context, index) {
              final item = _assistants[index];
              return _buildDetailPageContent(item, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPageContent(AIAssistantModel item, int index) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header Bar: Back Arrow `<` and Title "Pilih Fokus Ibadahmu" ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const CustomBackButton(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: Text(
                        'Pilih Fokus Ibadahmu',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Illustration Section: Speech Bubble on Left, Camel on Right ──
          SizedBox(
            height: 180,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Speech bubble with right pointer
                  Expanded(
                    flex: 12,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildSpeechBubble(item.greetingBubble),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Camel sitting / standing on the hill
                  Expanded(
                    flex: 9,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        item.detailImagePath,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Floating White Card Container containing Level Title & Target Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF9F0), // Exact warm ivory white card #FCF9F0
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Level Title (Level Kid / Level Teen / Level Adult)
                  Text(
                    item.levelTitle,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF375F16), // Exact dark green title #375F16
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Targets Stacked Cards
                  ...List.generate(item.targets.length, (i) {
                    return Container(
                      margin: EdgeInsets.only(bottom: i < item.targets.length - 1 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF9F0),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}.  ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E1F),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.targets[i],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2C3E1F),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ── Bottom Action Row: [ < ]  [ Ya, saya pilih level ini ]  [ > ] ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                // Left Dark Circle Button (<)
                GestureDetector(
                  onTap: index > 0 ? _onPrevious : null,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: index > 0 ? 1.0 : 0.3,
                    child: Container(
                      width: 58,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF154212), // Exact deep forest green #154212
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF154212).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Center Pill Button: "Ya, saya pilih level ini"
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF518427).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _confirmSelection(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF518427), // Exact button green #518427
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        'Ya, saya pilih level ini',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Right Dark Circle Button (>)
                GestureDetector(
                  onTap: index < _assistants.length - 1 ? _onNext : null,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: index < _assistants.length - 1 ? 1.0 : 0.3,
                    child: Container(
                      width: 58,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF154212), // Exact deep forest green #154212
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF154212).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E1F),
          height: 1.35,
        ),
      ),
    );
  }
}
