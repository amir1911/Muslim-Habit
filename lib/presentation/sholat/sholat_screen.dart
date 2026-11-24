import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prayer_time_provider.dart';
import '../../services/adzan_service.dart';
import 'widgets/sholat_app_bar.dart';
import 'widgets/sholat_category_switch.dart';
import 'widgets/sholat_date_header.dart';
import 'widgets/sholat_week_strip.dart';
import 'widgets/sholat_alarm_banner.dart';
import 'widgets/sholat_list_item_card.dart';
import 'sholat_edit_alarm_screen.dart';

class SholatScreen extends StatefulWidget {
  const SholatScreen({super.key});

  @override
  State<SholatScreen> createState() => _SholatScreenState();
}

class _SholatScreenState extends State<SholatScreen> {
  int _categoryIndex = 0; // 0: Wajib, 1: Sunnah
  bool _isCalendarExpanded = false;

  final List<Map<String, dynamic>> _wajibPrayers = const [
    {
      'key': 'subuh',
      'title': 'Sholat Wajib Shubuh',
      'shortTitle': 'Sholat Shubuh',
    },
    {
      'key': 'dzuhur',
      'title': 'Sholat Wajib Dzuhur',
      'shortTitle': 'Sholat Dzuhur',
    },
    {
      'key': 'ashar',
      'title': 'Sholat Wajib Ashar',
      'shortTitle': 'Sholat Ashar',
    },
    {
      'key': 'maghrib',
      'title': 'Sholat Wajib Maghrib',
      'shortTitle': 'Sholat Maghrib',
    },
    {
      'key': 'isya',
      'title': 'Sholat Wajib Isya',
      'shortTitle': 'Sholat Isya',
    },
  ];

  final List<Map<String, dynamic>> _sunnahPrayers = const [
    {
      'key': 'tahajjud',
      'title': 'Sholat Sunnah Tahajjud',
      'shortTitle': 'Sholat Tahajjud',
      'defaultTime': '03:15',
    },
    {
      'key': 'dhuha',
      'title': 'Sholat Sunnah Dhuha',
      'shortTitle': 'Sholat Dhuha',
      'defaultTime': '07:30',
    },
    {
      'key': 'rawatib',
      'title': 'Sholat Rawatib',
      'shortTitle': 'Sholat Rawatib',
      'defaultTime': '12:20',
    },
    {
      'key': 'witir',
      'title': 'Sholat Sunnah Witir',
      'shortTitle': 'Sholat Witir',
      'defaultTime': '20:30',
    },
  ];

  String _getPrayerScheduleTime(PrayerTimeProvider provider, String prayerKey) {
    final s = provider.schedule;
    switch (prayerKey.toLowerCase()) {
      case 'subuh':
        return s.subuh;
      case 'dzuhur':
        return s.dzuhur;
      case 'ashar':
        return s.ashar;
      case 'maghrib':
        return s.maghrib;
      case 'isya':
        return s.isya;
      case 'dhuha':
        return s.dhuha;
      default:
        return '10:00';
    }
  }

  void _openEditAlarm(BuildContext context, String initialPrayerKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SholatEditAlarmScreen(
          initialPrayerKey: initialPrayerKey,
          isSunnah: _categoryIndex == 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final schedule = prayerProvider.schedule;
    final nextPrayer = prayerProvider.nextPrayer;
    final nextKey = (nextPrayer['name'] ?? 'dzuhur').toLowerCase();

    final prayerTimesMap = {
      'subuh': schedule.subuh,
      'dzuhur': schedule.dzuhur,
      'ashar': schedule.ashar,
      'maghrib': schedule.maghrib,
      'isya': schedule.isya,
    };

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: const SholatAppBar(
        title: 'Sholat',
        subtitle: 'Pilih Kategori',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        physics: const BouncingScrollPhysics(),
        children: [
          // 0. Banner Adzan Sedang Berkumandang (Bila Aktif)
          ListenableBuilder(
            listenable: AdzanService(),
            builder: (context, _) {
              if (!AdzanService().isPlaying) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF518427), Color(0xFF3D6318)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF518427).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adzan ${AdzanService().currentPrayerName ?? "Salat"} Berkumandang',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Waktu salat telah tiba. Mari tunaikan ibadah.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => AdzanService().stopAdzan(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF518427),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Hentikan',
                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 1. Category Switch (Wajib | Sunnah)
          SholatCategorySwitch(
            selectedIndex: _categoryIndex,
            onTabChanged: (index) {
              setState(() {
                _categoryIndex = index;
              });
            },
          ),
          const SizedBox(height: 14),

          // 2. Date Header (Masehi + Hijriah + Jam + Lihat Kalender)
          SholatDateHeader(
            selectedDate: prayerProvider.selectedDate,
            isCalendarOpen: _isCalendarExpanded,
            onCalendarTap: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
          ),

          // 3. Calendar Week Strip (Bila expanded)
          if (_isCalendarExpanded) ...[
            SholatWeekStrip(
              selectedDate: prayerProvider.selectedDate,
              onDateSelected: (newDate) {
                prayerProvider.setSelectedDate(newDate);
              },
            ),
          ],
          const SizedBox(height: 14),

          // 4. Waktu Alarm Sholat Banner Card
          SholatAlarmBanner(
            prayerTimes: prayerTimesMap,
            nextPrayerKey: nextKey,
            onEditPressed: () => _openEditAlarm(context, nextKey),
          ),
          const SizedBox(height: 20),

          // 5. Section Header ("Sholat Wajib" / "Sholat Sunnah")
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Color(0xFF518427),
              ),
              const SizedBox(width: 8),
              Text(
                _categoryIndex == 0 ? 'Sholat Wajib' : 'Sholat Sunnah',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color(0xFF2C3E1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 6. List of Prayer Cards
          if (_categoryIndex == 0) ...[
            ..._wajibPrayers.map((prayer) {
              final key = prayer['key'] as String;
              final fullTitle = prayer['title'] as String;
              final schedTime = _getPrayerScheduleTime(prayerProvider, key);
              final recordedTime = prayerProvider.getRecordedPrayerTime(key);
              final isDone = prayerProvider.isPrayerDone(key);

              // Ambil alarm config untuk waktu custom bila ada
              final alarmConfig = prayerProvider.getAlarmModel(key, schedTime);
              final displayAlarmTime = alarmConfig.customTime.isNotEmpty
                  ? alarmConfig.customTime
                  : schedTime;

              final subtitle = isDone
                  ? (recordedTime != null ? '$recordedTime' : schedTime)
                  : '10:15 AM';

              final actionLabel = isDone
                  ? 'Catat Waktu Ini'
                  : '${prayer["shortTitle"]} belum berkumandang';

              final actionTime = isDone ? schedTime : displayAlarmTime;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SholatListItemCard(
                  title: fullTitle,
                  subtitle: subtitle,
                  actionLabel: actionLabel,
                  actionTime: actionTime,
                  isRecorded: isDone,
                  onCheckTap: () {
                    prayerProvider.togglePrayerRecord(key);
                  },
                  onCardTap: () => _openEditAlarm(context, key),
                ),
              );
            }),
          ] else ...[
            ..._sunnahPrayers.map((prayer) {
              final key = prayer['key'] as String;
              final fullTitle = prayer['title'] as String;
              final defaultTime = prayer['defaultTime'] as String? ?? '07:30';
              final schedTime = _getPrayerScheduleTime(prayerProvider, key);
              final baseTime = schedTime != '10:00' ? schedTime : defaultTime;
              final recordedTime = prayerProvider.getRecordedPrayerTime(key);
              final isDone = prayerProvider.isPrayerDone(key);

              final alarmConfig = prayerProvider.getAlarmModel(key, baseTime);
              final displayAlarmTime = alarmConfig.customTime.isNotEmpty
                  ? alarmConfig.customTime
                  : baseTime;

              final subtitle = isDone
                  ? (recordedTime != null ? '$recordedTime' : baseTime)
                  : 'Belum dikerjakan';

              final actionLabel = isDone
                  ? 'Catat Waktu Ini'
                  : 'Waktu yang dianjurkan';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SholatListItemCard(
                  title: fullTitle,
                  subtitle: subtitle,
                  actionLabel: actionLabel,
                  actionTime: displayAlarmTime,
                  isRecorded: isDone,
                  onCheckTap: () {
                    prayerProvider.togglePrayerRecord(key);
                  },
                  onCardTap: () => _openEditAlarm(context, key),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

