import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/fasting_plan.dart';
import '../../providers/fasting_provider.dart';
import '../../providers/prayer_time_provider.dart';
import '../../services/fasting_alarm_service.dart';

class AlarmIftarScreen extends StatefulWidget {
  final String? planId;
  final String? ringtoneName;

  const AlarmIftarScreen({super.key, this.planId, this.ringtoneName});

  @override
  State<AlarmIftarScreen> createState() => _AlarmIftarScreenState();
}

class _AlarmIftarScreenState extends State<AlarmIftarScreen> {
  bool _soundPlaying = true;

  @override
  void initState() {
    super.initState();
    FastingAlarmService().playAlarmSound(widget.ringtoneName ?? 'Bedug & Adzan');
  }

  @override
  void dispose() {
    FastingAlarmService().stopAlarmSound();
    super.dispose();
  }

  void _stopSound() {
    FastingAlarmService().stopAlarmSound();
    setState(() => _soundPlaying = false);
  }

  Future<void> _markCompleted() async {
    _stopSound();
    final provider = context.read<FastingProvider>();
    final today = DateTime.now();

    String targetId = widget.planId ?? '';
    if (targetId.isEmpty) {
      final existingToday = provider.getPlanForDate(today);
      if (existingToday != null) {
        targetId = existingToday.id;
      } else {
        targetId = 'plan_${today.millisecondsSinceEpoch}';
        await provider.addPlan(
          FastingPlan(
            id: targetId,
            date: DateTime(today.year, today.month, today.day),
            type: FastingType.seninKamis,
            status: FastingStatus.planned,
          ),
        );
      }
    }

    await provider.markCompleted(targetId);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 54),
            const SizedBox(height: 14),
            Text(
              'Alhamdulillah! Puasa Selesai',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Semoga Allah SWT menerima amal ibadah puasa dan melipatgandakan pahala kebaikan Anda hari ini. 🤲',
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

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final maghribTime = prayerProvider.schedule.maghrib;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF3C7), // Warm sunset gold
              Color(0xFFFDE68A),
              Color(0xFFF8FAF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Bedug & Sunset Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.dinner_dining_rounded,
                    color: Color(0xFFB45309),
                    size: 34,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Waktunya Berbuka',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Waktu Maghrib: $maghribTime WIB',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF78350F),
                  ),
                ),

                const SizedBox(height: 20),

                // Card Doa Berbuka Puasa
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Doa Berbuka Puasa',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Dzahabazh zhama\'u wabtallatil \'uruuqu wa tsabatal ajru insyaa Allah.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"Telah hilang rasa dahaga, dan urat-urat telah basah serta pahala telah ditetapkan, insya Allah."',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Tombol Hentikan Suara
                if (_soundPlaying)
                  OutlinedButton.icon(
                    onPressed: _stopSound,
                    icon: const Icon(Icons.volume_off_rounded, size: 18),
                    label: const Text('Hentikan Suara Bedug/Adzan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB45309),
                      side: const BorderSide(color: Color(0xFFFCD34D)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                const SizedBox(height: 12),

                // Tombol Tandai Selesai
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _markCompleted,
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text('Tandai Puasa Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    _stopSound();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
