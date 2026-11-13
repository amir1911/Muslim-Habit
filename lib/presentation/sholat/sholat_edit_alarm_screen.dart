import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_alarm_model.dart';
import '../../providers/prayer_time_provider.dart';
import 'widgets/sholat_app_bar.dart';
import 'widgets/sholat_time_picker_modal.dart';

class SholatEditAlarmScreen extends StatefulWidget {
  final String initialPrayerKey;
  final bool isSunnah;

  const SholatEditAlarmScreen({
    super.key,
    required this.initialPrayerKey,
    this.isSunnah = false,
  });

  @override
  State<SholatEditAlarmScreen> createState() => _SholatEditAlarmScreenState();
}

class _SholatEditAlarmScreenState extends State<SholatEditAlarmScreen> {
  late String _activePrayerKey;
  late PrayerAlarmModel _currentConfig;
  bool _isInitialized = false;

  final List<Map<String, String>> _wajibKeys = const [
    {'key': 'subuh', 'name': 'Subuh'},
    {'key': 'dzuhur', 'name': 'Dzuhur'},
    {'key': 'ashar', 'name': 'Ashar'},
    {'key': 'maghrib', 'name': 'Maghrib'},
    {'key': 'isya', 'name': 'Isya'},
  ];

  @override
  void initState() {
    super.initState();
    _activePrayerKey = widget.initialPrayerKey.toLowerCase();
  }

  void _loadConfig(PrayerTimeProvider provider) {
    if (_isInitialized) return;
    final sched = provider.schedule;
    final defaultTime = _getDefaultScheduleTime(sched, _activePrayerKey);
    _currentConfig = provider.getAlarmModel(_activePrayerKey, defaultTime);
    _isInitialized = true;
  }

  String _getDefaultScheduleTime(dynamic schedule, String key) {
    switch (key.toLowerCase()) {
      case 'subuh':
        return schedule.subuh;
      case 'dzuhur':
        return schedule.dzuhur;
      case 'ashar':
        return schedule.ashar;
      case 'maghrib':
        return schedule.maghrib;
      case 'isya':
        return schedule.isya;
      default:
        return '18:00';
    }
  }

  void _switchPrayerTab(String newKey, PrayerTimeProvider provider) {
    final sched = provider.schedule;
    final defaultTime = _getDefaultScheduleTime(sched, newKey);
    setState(() {
      _activePrayerKey = newKey;
      _currentConfig = provider.getAlarmModel(newKey, defaultTime);
    });
  }

  void _showTimePicker() {
    SholatTimePickerModal.show(
      context: context,
      initialTime: _currentConfig.customTime,
      initialApplyToAllDays: _currentConfig.applyToAllDays,
      onApply: (newTime, applyAll) {
        setState(() {
          _currentConfig = _currentConfig.copyWith(
            customTime: newTime,
            applyToAllDays: applyAll,
          );
        });
      },
    );
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
    return '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerTimeProvider>();
    _loadConfig(prayerProvider);

    final sched = prayerProvider.schedule;
    final prayerTimesMap = {
      'subuh': sched.subuh,
      'dzuhur': sched.dzuhur,
      'ashar': sched.ashar,
      'maghrib': sched.maghrib,
      'isya': sched.isya,
    };

    final title = widget.isSunnah ? 'Edit Sholat Sunnah' : 'Edit Sholat Wajib';
    final activePrayerName = _wajibKeys.firstWhere(
      (p) => p['key'] == _activePrayerKey,
      orElse: () => {'name': _activePrayerKey[0].toUpperCase() + _activePrayerKey.substring(1)},
    )['name']!;

    final adzanTime = prayerTimesMap[_activePrayerKey] ?? '18:00';

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: SholatAppBar(
        title: title,
        subtitle: 'Edit Alarm Sholat',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Date Selector with Chevrons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBF6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE8E5D3).withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final prev = prayerProvider.selectedDate.subtract(const Duration(days: 1));
                          prayerProvider.setSelectedDate(prev);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 22,
                          color: Color(0xFF7E8D6B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatGregorian(prayerProvider.selectedDate),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E1F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '7 Dhu al-Qi\'dah 1447 H',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8B967D),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            '10:00',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E1F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final next = prayerProvider.selectedDate.add(const Duration(days: 1));
                          prayerProvider.setSelectedDate(next);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Color(0xFF7E8D6B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Waktu Alarm Sholat Selector Cards
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBF6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE8E5D3).withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Alarm Sholat',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _wajibKeys.map((item) {
                          final isSelected = item['key'] == _activePrayerKey;
                          final timeStr = prayerTimesMap[item['key']] ?? '12:00';

                          return GestureDetector(
                            onTap: () => _switchPrayerTab(item['key']!, prayerProvider),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 58,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF557C2B)
                                    : const Color(0xFFF4F2E6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF557C2B)
                                      : const Color(0xFFE4E0CE),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white70 : const Color(0xFF7E8D6B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : const Color(0xFF2C3E1F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Info Adzan Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBF6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE8E5D3).withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatGregorian(prayerProvider.selectedDate),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E1F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '7 Dhu al-Qi\'dah 1447 H',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8B967D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bedtime_outlined,
                                size: 14,
                                color: Color(0xFF7E8D6B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                adzanTime,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E1F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Adzan $activePrayerName',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8B967D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Alarm Card (Toggle + Big Time display + Pengaturan Tambahan)
                Container(
                  padding: const EdgeInsets.all(18),
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
                      // Alarm Header & Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                size: 18,
                                color: Color(0xFF2C3E1F),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Alarm $activePrayerName',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E1F),
                                ),
                              ),
                            ],
                          ),
                          Transform.scale(
                            scale: 0.85,
                            child: CupertinoSwitch(
                              value: _currentConfig.isAlarmActive,
                              activeTrackColor: const Color(0xFF557C2B),
                              onChanged: (val) {
                                setState(() {
                                  _currentConfig = _currentConfig.copyWith(isAlarmActive: val);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Big Time Display: clickable to open TimePicker
                      Center(
                        child: GestureDetector(
                          onTap: _showTimePicker,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _currentConfig.customTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2C3E1F),
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  activePrayerName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7E8D6B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pengaturan Tambahan Section
                      Text(
                        'Pengaturan Tambahan',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E1F),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tunda (Snooze) Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.snooze_rounded,
                                size: 18,
                                color: Color(0xFF7E8D6B),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tunda',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2C3E1F),
                                    ),
                                  ),
                                  Text(
                                    '${_currentConfig.snoozeMinutes} menit default',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF8B967D),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: _currentConfig.isSnoozeActive,
                              activeTrackColor: const Color(0xFF557C2B),
                              onChanged: (val) {
                                setState(() {
                                  _currentConfig = _currentConfig.copyWith(isSnoozeActive: val);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Getaran Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.vibration_rounded,
                                size: 18,
                                color: Color(0xFF7E8D6B),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Getaran',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E1F),
                                ),
                              ),
                            ],
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: _currentConfig.isVibrateActive,
                              activeTrackColor: const Color(0xFF557C2B),
                              onChanged: (val) {
                                setState(() {
                                  _currentConfig = _currentConfig.copyWith(isVibrateActive: val);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 5. Checkbox "Terapkan untuk semua hari"
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentConfig = _currentConfig.copyWith(
                        applyToAllDays: !_currentConfig.applyToAllDays,
                      );
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _currentConfig.applyToAllDays
                              ? const Color(0xFF557C2B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _currentConfig.applyToAllDays
                                ? const Color(0xFF557C2B)
                                : const Color(0xFFB5BDAB),
                            width: 1.5,
                          ),
                        ),
                        child: _currentConfig.applyToAllDays
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Terapkan untuk semua hari',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2C3E1F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Simpan Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await prayerProvider.saveAlarmModel(_currentConfig);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alarm $activePrayerName berhasil disimpan'),
                          backgroundColor: const Color(0xFF557C2B),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF557C2B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.inter(
                      fontSize: 15,
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
