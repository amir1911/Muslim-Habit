import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SholatDateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onCalendarTap;
  final bool isCalendarOpen;

  const SholatDateHeader({
    super.key,
    required this.selectedDate,
    required this.onCalendarTap,
    this.isCalendarOpen = false,
  });

  // Perkiraan konversi kalender Hijriah (fallback formula teruji)
  String _getHijriDate(DateTime date) {
    // Offset standar masehi ke hijriah
    // 24 April 2026 bertepatan sekitar 7 Dhu al-Qi'dah 1447 H (seperti di referensi desain)
    final hijriMonths = [
      'Muharram',
      'Safar',
      'Rabi\'ul Awwal',
      'Rabi\'ul Akhir',
      'Jumadil Awwal',
      'Jumadil Akhir',
      'Rajab',
      'Sya\'ban',
      'Ramadhan',
      'Syawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    // Hitung perkiraan hari Julian
    int day = date.day;
    int month = date.month;
    int year = date.year;

    int m = month;
    int y = year;
    if (m < 3) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    int jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        (l / 5670).floor() * ((43 * l) / 15238).floor();
    l = l - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    int validMonthIndex = (hMonth - 1).clamp(0, 11);
    return '$hDay ${hijriMonths[validMonthIndex]} $hYear H';
  }

  String _formatGregorian(DateTime date) {
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E5D3).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Tanggal Masehi & Hijriah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatGregorian(selectedDate),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF2C3E1F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _getHijriDate(selectedDate),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: const Color(0xFF8B967D),
                  ),
                ),
              ],
            ),
          ),

          // Right: Jam + Button Lihat Kalender
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 15,
                    color: Color(0xFF7E8D6B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF2C3E1F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: onCalendarTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Kalender',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: const Color(0xFF7E8D6B),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      isCalendarOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      size: 14,
                      color: const Color(0xFF7E8D6B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

