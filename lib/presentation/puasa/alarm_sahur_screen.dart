import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/hijri_helper.dart';
import '../../services/fasting_alarm_service.dart';
import 'tidak_puasa_screen.dart';

class AlarmSahurScreen extends StatefulWidget {
  final String? planId;
  final String? ringtoneName;

  const AlarmSahurScreen({super.key, this.planId, this.ringtoneName});

  @override
  State<AlarmSahurScreen> createState() => _AlarmSahurScreenState();
}

class _AlarmSahurScreenState extends State<AlarmSahurScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdController;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    FastingAlarmService().playAlarmSound(widget.ringtoneName ?? 'Adzan Makkah');
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAlarmTurnedOff();
      }
    });
  }

  @override
  void dispose() {
    FastingAlarmService().stopAlarmSound();
    _holdController.dispose();
    super.dispose();
  }

  void _onHoldStart(TapDownDetails details) {
    if (_isDismissed) return;
    HapticFeedback.lightImpact();
    _holdController.forward();
  }

  void _onHoldEnd(TapUpDetails details) {
    if (_isDismissed) return;
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  void _onHoldCancel() {
    if (_isDismissed) return;
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  Future<void> _onAlarmTurnedOff() async {
    setState(() => _isDismissed = true);
    HapticFeedback.heavyImpact();
    await FastingAlarmService().stopAlarmSound();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 54),
            const SizedBox(height: 14),
            Text(
              'Alarm Berhasil Dimatikan',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Selamat menikmati sahur & semoga puasa hari ini lancar dan berkah. 🌿',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // alarm screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF518427),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSnooze() {
    FastingAlarmService().snoozeSahurAlarm(context: context, minutes: 5);
    Navigator.of(context).pop();
  }

  void _onBatalPuasa() {
    FastingAlarmService().stopAlarmSound();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TidakPuasaScreen(planId: widget.planId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijri = HijriHelper.fromGregorian(now);
    final dayName = HijriHelper.getDayNameIndonesian(now);

    final hourStr = now.hour.toString().padLeft(2, '0');
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';

    return PopScope(
      canPop: _isDismissed,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFD4E6D6), // soft morning fog
                Color(0xFFE8EFE5),
                Color(0xFFFCFDFB),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Bell with waves icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title "Waktunya Sahur"
                  Text(
                    'Waktunya Sahur',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Hari & Tanggal Hijriah
                  Text(
                    '$dayName, ${hijri.day} ${hijri.monthName}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Big Clock Display "03:30 AM"
                  Text(
                    '$hourStr:$minuteStr $amPm',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Instruksi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tekan dan Tahan hingga lingkaran hijau sepenuhnya mengisi bagian putih untuk mematikan alarm.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Circular Press & Hold Button (Fingerprint) ──
                  GestureDetector(
                    onTapDown: _onHoldStart,
                    onTapUp: _onHoldEnd,
                    onTapCancel: _onHoldCancel,
                    child: AnimatedBuilder(
                      animation: _holdController,
                      builder: (ctx, _) {
                        final progress = _holdController.value;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circular progress ring
                            SizedBox(
                              width: 190,
                              height: 190,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                backgroundColor: Colors.white,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF84CC16), // Lime green
                                ),
                              ),
                            ),

                            // Inner circle
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  Colors.white,
                                  const Color(0xFFDCFCE7),
                                  progress,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF84CC16)
                                        .withValues(alpha: 0.2 + progress * 0.3),
                                    blurRadius: 20 + progress * 15,
                                    spreadRadius: 2 + progress * 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fingerprint_rounded,
                                    size: 48,
                                    color: Color.lerp(
                                      const Color(0xFF84CC16),
                                      const Color(0xFF15803D),
                                      progress,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'TEKAN DAN TAHAN',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Subtext Waktu Imsak
                  Text(
                    'Waktu Imsak tersisa sekitar 45 menit lagi.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const Spacer(),

                  // ── Tombol Snooze (5 Menit) ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onSnooze,
                      icon: const Icon(Icons.snooze_rounded, size: 18),
                      label: const Text('Snooze (5 Menit)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D6318),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Tombol Batal Puasa ──
                  TextButton(
                    onPressed: _onBatalPuasa,
                    child: Text(
                      'Batal Puasa',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
