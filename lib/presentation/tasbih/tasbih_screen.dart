import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/tasbih_provider.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapCounter(TasbihProvider provider) {
    _pulseController.forward().then((_) => _pulseController.reverse());
    HapticFeedback.lightImpact();

    final reachedTarget = provider.incrementCount();
    if (reachedTarget) {
      HapticFeedback.heavyImpact();
      _showTargetReachedDialog(provider);
    }
  }

  void _showTargetReachedDialog(TasbihProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Column(
            children: [
              const Text('✨', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                'Alhamdulillah!',
                style: GoogleFonts.balooTammudu2(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        content: Text(
          'Target putaran dzikir ${provider.currentDhikr.latin} telah tercapai (${provider.target}x). Semoga menjadi pemberat amal kebaikan!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMedium,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Lanjutkan Dzikir'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasbih = context.watch<TasbihProvider>();
    final dhikr = tasbih.currentDhikr;
    final progress = tasbih.target > 0 ? (dhikr.currentCount / tasbih.target).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          'Tasbih Digital',
          style: GoogleFonts.balooTammudu2(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primaryGreen,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              tasbih.vibrationEnabled ? Icons.vibration_rounded : Icons.phone_android_rounded,
              color: tasbih.vibrationEnabled ? AppColors.primaryGreen : AppColors.textMuted,
            ),
            tooltip: 'Getaran',
            onPressed: tasbih.toggleVibration,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textMedium),
            tooltip: 'Reset Hitungan',
            onPressed: () => _confirmReset(tasbih),
          ),
        ],
      ),
      body: Column(
        children: [
          // DHIKR HORIZONTAL SELECTOR
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tasbih.dhikrList.length,
              itemBuilder: (context, index) {
                final item = tasbih.dhikrList[index];
                final isSelected = tasbih.selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(item.latin),
                    selected: isSelected,
                    onSelected: (_) => tasbih.selectDhikr(index),
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.balooTammudu2(
                      color: isSelected ? Colors.white : AppColors.textMedium,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGreen : AppColors.beigeAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  // ARABIC PHRASE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.beigeAccent),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          dhikr.arabic,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dhikr.latin,
                          style: GoogleFonts.balooTammudu2(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${dhikr.translation}"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMedium,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // TACTILE 3D DIGITAL COUNTER BUTTON
                  GestureDetector(
                    onTap: () => _onTapCounter(tasbih),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.creamBackground,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 20,
                              offset: Offset(0, -6),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Progress Ring
                            SizedBox(
                              width: 210,
                              height: 210,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                backgroundColor: AppColors.greenSurface,
                                color: AppColors.primaryGreen,
                              ),
                            ),

                            // Inner Interactive Button
                            Container(
                              width: 178,
                              height: 178,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFF8CAF5C), Color(0xFF688C40)],
                                  center: Alignment(-0.2, -0.3),
                                  radius: 0.9,
                                ),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${dhikr.currentCount}',
                                    style: GoogleFonts.balooTammudu2(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '/ ${tasbih.target} Target',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sentuh untuk Dzikir',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TARGET CYCLES & QUICK SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTargetButton(tasbih, 33),
                      const SizedBox(width: 8),
                      _buildTargetButton(tasbih, 99),
                      const SizedBox(width: 8),
                      _buildTargetButton(tasbih, 100),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // TOTAL RECORD CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.beigeAccent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.goldBadge, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Total Dzikirmu: ${tasbih.totalAllTime} kali',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetButton(TasbihProvider provider, int target) {
    final isSelected = provider.target == target;
    return InkWell(
      onTap: () => provider.setTarget(target),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.beigeAccent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          '$target x',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryDarkGreen : AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  void _confirmReset(TasbihProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Hitungan?',
          style: GoogleFonts.balooTammudu2(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Hitungan putaran aktif akan kembali ke 0.',
          style: GoogleFonts.inter(color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetCurrentCount();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
