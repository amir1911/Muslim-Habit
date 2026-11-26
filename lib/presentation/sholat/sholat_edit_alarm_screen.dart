import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_alarm_model.dart';
import '../../providers/prayer_time_provider.dart';
import '../../services/adzan_service.dart';
import '../../services/storage_service.dart';
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

  late StorageService _storageService;
  bool _adzanAutoEnabled = true;
  final Map<String, bool> _prayerAdzanEnabled = {
    'subuh': true,
    'dzuhur': true,
    'ashar': true,
    'maghrib': true,
    'isya': true,
  };
  double _adzanVolume = 1.0;
  bool _preReminderEnabled = false;
  int _preReminderMinutes = 10;

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
    _storageService = context.read<StorageService>();
    final sched = provider.schedule;
    final defaultTime = _getDefaultScheduleTime(sched, _activePrayerKey);
    _currentConfig = provider.getAlarmModel(_activePrayerKey, defaultTime);

    // Muat konfigurasi Adzan Otomatis dari StorageService
    _adzanAutoEnabled = _storageService.getAdzanAutoEnabled();
    for (final key in _wajibKeys.map((e) => e['key']!)) {
      _prayerAdzanEnabled[key] = _storageService.getAdzanPrayerEnabled(key);
    }
    _adzanVolume = _storageService.getAdzanVolume();
    _preReminderEnabled = _storageService.getPrayerPreReminderEnabled();
    _preReminderMinutes = _storageService.getPrayerPreReminderMinutes();

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
                                    ? const Color(0xFF518427)
                                    : const Color(0xFFF4F2E6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF518427)
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
                              activeTrackColor: const Color(0xFF518427),
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
                              activeTrackColor: const Color(0xFF518427),
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
                              activeTrackColor: const Color(0xFF518427),
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
                              ? const Color(0xFF518427)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _currentConfig.applyToAllDays
                                ? const Color(0xFF518427)
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
                const SizedBox(height: 16),

                // 6. Pengaturan Adzan Otomatis
                _buildAdzanSection(context, prayerProvider),
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

                    // Simpan seluruh preferensi Adzan Otomatis secara permanen
                    await _storageService.setAdzanAutoEnabled(_adzanAutoEnabled);
                    for (final entry in _prayerAdzanEnabled.entries) {
                      await _storageService.setAdzanPrayerEnabled(entry.key, entry.value);
                    }
                    await _storageService.setAdzanVolume(_adzanVolume);
                    await _storageService.setPrayerPreReminderEnabled(_preReminderEnabled);
                    await _storageService.setPrayerPreReminderMinutes(_preReminderMinutes);

                    // Sinkronkan dan jadwalkan ulang alarm exact Android
                    await AdzanService().scheduleAlarms(prayerProvider.schedule);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pengaturan Alarm & Adzan berhasil disimpan'),
                          backgroundColor: const Color(0xFF518427),
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
                    backgroundColor: const Color(0xFF518427),
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

  Widget _buildAdzanSection(BuildContext context, PrayerTimeProvider provider) {
    return Container(
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
          // Row Header: Switch Utama Adzan Otomatis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF518427).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        size: 20,
                        color: Color(0xFF518427),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adzan Otomatis',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E1F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Putar audio saat masuk waktu salat',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF7E8D6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: CupertinoSwitch(
                  value: _adzanAutoEnabled,
                  activeTrackColor: const Color(0xFF518427),
                  onChanged: (val) {
                    setState(() {
                      _adzanAutoEnabled = val;
                    });
                  },
                ),
              ),
            ],
          ),

          if (_adzanAutoEnabled) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFE8E5D3), height: 1),
            const SizedBox(height: 14),

            // 1. Pengaturan Per Waktu Salat
            Text(
              'Adzan Per Waktu Salat',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3E1F),
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: _wajibKeys.map((item) {
                final key = item['key']!;
                final name = item['name']!;
                final isSubuh = key == 'subuh';
                final isEnabled = _prayerAdzanEnabled[key] ?? true;
                final audioDesc = isSubuh ? 'adzan shubuh.mp3' : 'adzan.mp3';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? const Color(0xFF518427).withValues(alpha: 0.06)
                          : const Color(0xFFF4F2E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEnabled
                            ? const Color(0xFF518427).withValues(alpha: 0.25)
                            : const Color(0xFFE4E0CE),
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
                                'Adzan $name',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E1F),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.audiotrack_rounded,
                                    size: 12,
                                    color: isSubuh
                                        ? const Color(0xFF518427)
                                        : const Color(0xFF7E8D6B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    audioDesc,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: isSubuh ? FontWeight.w600 : FontWeight.w400,
                                      color: isSubuh
                                          ? const Color(0xFF518427)
                                          : const Color(0xFF7E8D6B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.75,
                          child: CupertinoSwitch(
                            value: isEnabled,
                            activeTrackColor: const Color(0xFF518427),
                            onChanged: (val) {
                              setState(() {
                                _prayerAdzanEnabled[key] = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),
            const Divider(color: Color(0xFFE8E5D3), height: 1),
            const SizedBox(height: 14),

            // 2. Kontrol Volume & Tes Audio
            Text(
              'Uji Suara & Volume Audio',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3E1F),
              ),
            ),
            const SizedBox(height: 10),

            // Slider Volume
            Row(
              children: [
                const Icon(Icons.volume_down_rounded, size: 18, color: Color(0xFF7E8D6B)),
                Expanded(
                  child: Slider(
                    value: _adzanVolume,
                    min: 0.1,
                    max: 1.0,
                    activeColor: const Color(0xFF518427),
                    inactiveColor: const Color(0xFFE4E0CE),
                    onChanged: (val) {
                      setState(() {
                        _adzanVolume = val;
                      });
                    },
                  ),
                ),
                Text(
                  '${(_adzanVolume * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E1F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status pemutaran aktif & tombol tes suara
            ListenableBuilder(
              listenable: AdzanService(),
              builder: (context, _) {
                final isPlaying = AdzanService().isPlaying;
                final prayerName = AdzanService().currentPrayerName ?? 'Adzan';

                if (isPlaying) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF518427).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF518427), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.graphic_eq_rounded, color: Color(0xFF518427), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$prayerName sedang berbunyi...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF518427),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => AdzanService().stopAdzan(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Hentikan',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Tombol Uji Suara
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                        label: Text(
                          'Tes Subuh',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF518427),
                          side: const BorderSide(color: Color(0xFF518427)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => AdzanService().testAdzanSound(isSubuh: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                        label: Text(
                          'Tes Reguler',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF518427),
                          side: const BorderSide(color: Color(0xFF518427)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => AdzanService().testAdzanSound(isSubuh: false),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),
            const Divider(color: Color(0xFFE8E5D3), height: 1),
            const SizedBox(height: 14),

            // 3. Pengingat Sebelum Waktu Salat (Layout bebas overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pengingat Sebelum Salat',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E1F),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: _preReminderEnabled,
                    activeTrackColor: const Color(0xFF518427),
                    onChanged: (val) {
                      setState(() {
                        _preReminderEnabled = val;
                      });
                      _storageService.setPrayerPreReminderEnabled(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Pemberitahuan beberapa menit sebelum adzan',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF7E8D6B),
              ),
            ),
            if (_preReminderEnabled) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15].map((mins) {
                  final isSelected = _preReminderMinutes == mins;
                  return ChoiceChip(
                    label: Text('$mins Menit'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF518427),
                    backgroundColor: const Color(0xFFF4F2E6),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF2C3E1F),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _preReminderMinutes = mins;
                      });
                      _storageService.setPrayerPreReminderMinutes(mins);
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 18),
            const Divider(color: Color(0xFFE8E5D3), height: 1),
            const SizedBox(height: 14),

            // 4. Tombol Simulasi Waktu Salat (Testing Cepat)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: Text(
                      'Simulasi Waktu Salat Tiba (Uji Coba)',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D6318),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showSimulationDialog(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showSimulationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Salat untuk Simulasi Adzan',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Sistem akan mensimulasikan adzan seolah-olah waktu salat telah tiba seketika.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ..._wajibKeys.map((item) {
                final key = item['key']!;
                final name = item['name']!;
                final isSubuh = key == 'subuh';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF518427).withValues(alpha: 0.15),
                    child: Icon(
                      isSubuh ? Icons.wb_twilight_rounded : Icons.access_time_rounded,
                      color: const Color(0xFF518427),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Simulasi Salat $name',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    isSubuh ? 'Audio: adzan shubuh.mp3' : 'Audio: adzan.mp3',
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF518427)),
                  onTap: () {
                    Navigator.pop(ctx);
                    AdzanService().simulatePrayerTime(key);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
