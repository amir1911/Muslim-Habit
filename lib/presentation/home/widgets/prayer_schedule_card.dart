import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/prayer_time_provider.dart';
import '../../shell/main_navigation_shell.dart';
import '../../sholat/sholat_screen.dart';

/// Standalone Widget Jadwal Sholat — Islamic Garden (Soft Green & Gold)
///
/// Komponen Flutter terpisah yang menampilkan:
/// - Panel Kiri: Waktu sholat saat ini, jam digital besar real-time, lokasi,
///   maskot Nunu, dan tombol "Pantau Habit →".
/// - Panel Kanan: Jadwal 5 waktu sholat hari ini (Subuh, Dzuhur, Ashar, Maghrib, Isya)
///   lengkap dengan indikator waktu berikutnya dan sholat yang sudah lewat.
/// - Aset dekoratif: masjid.png, lentera.png, sabit.png, mascot_nunu.png.
class PrayerScheduleCard extends StatefulWidget {
  final VoidCallback? onPantauHabit;

  const PrayerScheduleCard({
    super.key,
    this.onPantauHabit,
  });

  @override
  State<PrayerScheduleCard> createState() => _PrayerScheduleCardState();
}

class _PrayerScheduleCardState extends State<PrayerScheduleCard> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  int _timeToMinutes(String timeStr) {
    try {
      final clean = timeStr.trim().split(' ')[0];
      final parts = clean.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        return h * 60 + m;
      }
    } catch (_) {}
    return 0;
  }

  String _formatDigitalClock() {
    final h = _currentTime.hour.toString().padLeft(2, '0');
    final m = _currentTime.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeProvider>(
      builder: (context, prayerProvider, _) {
        final times = prayerProvider.prayerTimes;
        final subuhStr = times['Fajr'] ?? times['Subuh'] ?? '04:30';
        final dzuhurStr = times['Dhuhr'] ?? times['Dzuhur'] ?? '11:55';
        final asharStr = times['Asr'] ?? times['Ashar'] ?? '15:30';
        final maghribStr = times['Maghrib'] ?? '17:50';
        final isyaStr = times['Isha'] ?? times['Isya'] ?? '19:00';
        final city = prayerProvider.currentCity.isNotEmpty
            ? prayerProvider.currentCity
            : 'Palembang';

        final nowMin = _currentTime.hour * 60 + _currentTime.minute;
        final subuhMin = _timeToMinutes(subuhStr);
        final dzuhurMin = _timeToMinutes(dzuhurStr);
        final asharMin = _timeToMinutes(asharStr);
        final maghribMin = _timeToMinutes(maghribStr);
        final isyaMin = _timeToMinutes(isyaStr);

        // Tentukan sholat sekarang dan berikutnya
        String currentPrayerName = 'Subuh';
        String nextPrayerKey = 'Dzuhur';

        if (nowMin < subuhMin) {
          currentPrayerName = 'Isya';
          nextPrayerKey = 'Subuh';
        } else if (nowMin < dzuhurMin) {
          currentPrayerName = 'Subuh';
          nextPrayerKey = 'Dzuhur';
        } else if (nowMin < asharMin) {
          currentPrayerName = 'Dzuhur';
          nextPrayerKey = 'Ashar';
        } else if (nowMin < maghribMin) {
          currentPrayerName = 'Ashar';
          nextPrayerKey = 'Maghrib';
        } else if (nowMin < isyaMin) {
          currentPrayerName = 'Maghrib';
          nextPrayerKey = 'Isya';
        } else {
          currentPrayerName = 'Isya';
          nextPrayerKey = 'Subuh';
        }

        final prayerList = [
          {
            'name': 'Subuh',
            'time': subuhStr,
            'minutes': subuhMin,
            'icon': Icons.mosque_rounded,
          },
          {
            'name': 'Dzuhur',
            'time': dzuhurStr,
            'minutes': dzuhurMin,
            'icon': Icons.wb_sunny_rounded,
          },
          {
            'name': 'Ashar',
            'time': asharStr,
            'minutes': asharMin,
            'icon': Icons.wb_cloudy_rounded,
          },
          {
            'name': 'Maghrib',
            'time': maghribStr,
            'minutes': maghribMin,
            'icon': Icons.wb_twilight_rounded,
          },
          {
            'name': 'Isya',
            'time': isyaStr,
            'minutes': isyaMin,
            'icon': Icons.nightlight_round,
          },
        ];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF9FDF5),
                Color(0xFFEAF5DD),
                Color(0xFFDBEECD),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD6E8C2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF385520).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 1. Siluet Masjid Background (Opacity lembut)
                Positioned(
                  left: 60,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.13,
                    child: Image.asset(
                      'assets/icon/masjid.png',
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // 2. Lentera Gantung Islami di Kiri Atas
                Positioned(
                  top: 0,
                  left: 12,
                  child: Image.asset(
                    'assets/icon/lentera.png',
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

                // 3. Konten Utama: 2 Kolom (Kiri & Kanan)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── KOLOM KIRI: Info Sholat Sekarang, Jam Digital, Maskot Nunu & Tombol ──
                      Expanded(
                        flex: 11,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row Kiri: Badge Sekarang + Nama Sholat + Bulan Sabit
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF28481B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Sekarang',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      currentPrayerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1F3814),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    'assets/icon/sabit.png',
                                    height: 16,
                                    width: 16,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Color(0xFFE5A93C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Jam Digital Berukuran Besar
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                _formatDigitalClock(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1B3B12),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),

                            // Informasi Lokasi
                            Padding(
                              padding: const EdgeInsets.only(left: 6, top: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 13,
                                    color: Color(0xFF4C752B),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      city,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4C752B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Maskot Nunu
                            Center(
                              child: Image.asset(
                                'assets/icon/mascot_nunu.png',
                                height: 86,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  height: 86,
                                  child: Icon(Icons.pets, size: 40, color: Color(0xFF518427)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Tombol Pantau Habit
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.onPantauHabit != null) {
                                    widget.onPantauHabit!();
                                  } else {
                                    MainNavigationShell.switchToTab(context, 1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF487723),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Pantau Habit',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_rounded, size: 13),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ── KOLOM KANAN: Jadwal Sholat Hari Ini ──
                      Expanded(
                        flex: 13,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Judul Card
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SholatScreen()),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 15,
                                      color: Color(0xFF28481B),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        'Jadwal Sholat Hari Ini',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1F3814),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Daftar 5 Waktu Sholat
                              ...prayerList.map((item) {
                                final name = item['name'] as String;
                                final time = item['time'] as String;
                                final minutes = item['minutes'] as int;
                                final icon = item['icon'] as IconData;

                                final isPassed = nowMin > minutes;
                                final isNext = (name == nextPrayerKey);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: isNext
                                        ? const Color(0xFFFFF7E6)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Icon
                                        Icon(
                                          icon,
                                          size: 14,
                                          color: isNext
                                              ? const Color(0xFFD48B17)
                                              : (isPassed
                                                  ? const Color(0xFF4C752B)
                                                  : const Color(0xFF7A975E)),
                                        ),
                                        const SizedBox(width: 6),

                                        // Nama Sholat (tidak wrap vertikal)
                                        SizedBox(
                                          width: 52,
                                          child: Text(
                                            name,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isNext
                                                  ? const Color(0xFF8C5807)
                                                  : const Color(0xFF223E16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),

                                        // Jam Sholat
                                        SizedBox(
                                          width: 38,
                                          child: Text(
                                            time,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: isNext
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              color: isNext
                                                  ? const Color(0xFF8C5807)
                                                  : const Color(0xFF223E16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),

                                        // Status: Centang Hijau / Badge Berikutnya
                                        SizedBox(
                                          width: 46,
                                          height: 18,
                                          child: isPassed
                                              ? const Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Color(0xFF447D22),
                                                    size: 15,
                                                  ),
                                                )
                                              : (isNext
                                                  ? Container(
                                                      alignment: Alignment.center,
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 4, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFE5A93C),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        'Berikutnya',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 7.5,
                                                          fontWeight: FontWeight.w800,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink()),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

