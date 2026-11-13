import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SholatAlarmBanner extends StatelessWidget {
  final Map<String, String> prayerTimes;
  final String nextPrayerKey; // e.g. 'dzuhur'
  final VoidCallback? onEditPressed;

  const SholatAlarmBanner({
    super.key,
    required this.prayerTimes,
    required this.nextPrayerKey,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final list = [
      {'key': 'subuh', 'label': 'Subuh', 'time': prayerTimes['subuh'] ?? '05:15'},
      {'key': 'dzuhur', 'label': 'Dzuhur', 'time': prayerTimes['dzuhur'] ?? '12:05'},
      {'key': 'ashar', 'label': 'Ashar', 'time': prayerTimes['ashar'] ?? '15:20'},
      {'key': 'maghrib', 'label': 'Maghrib', 'time': prayerTimes['maghrib'] ?? '18:10'},
      {'key': 'isya', 'label': 'Isya', 'time': prayerTimes['isya'] ?? '19:25'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E5D3).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: "Waktu Alarm Sholat" & Edit Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waktu Alarm Sholat',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF2C3E1F),
                ),
              ),
              GestureDetector(
                onTap: onEditPressed,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 22,
                    color: const Color(0xFF557C2B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal grid 5 prayers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: list.map((item) {
              final isNext = item['key']!.toLowerCase() == nextPrayerKey.toLowerCase();
              return _buildPrayerItem(
                label: item['label']!,
                time: item['time']!,
                isNext: isNext,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem({
    required String label,
    required String time,
    required bool isNext,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNext)
          Text(
            'next',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF557C2B),
            ),
          )
        else
          const SizedBox(height: 15),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isNext ? const Color(0xFF557C2B) : const Color(0xFFF4F2E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNext ? const Color(0xFF557C2B) : const Color(0xFFE4E0CE),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isNext ? Colors.white70 : const Color(0xFF7E8D6B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isNext ? Colors.white : const Color(0xFF2C3E1F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

