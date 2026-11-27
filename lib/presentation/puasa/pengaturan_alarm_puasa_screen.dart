import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/fasting_plan.dart';
import '../../providers/fasting_provider.dart';
import '../../providers/prayer_time_provider.dart';
import '../../services/fasting_alarm_service.dart';
import '../../core/widgets/custom_back_button.dart';

class PengaturanAlarmPuasaScreen extends StatefulWidget {
  final FastingType selectedType;
  final List<DateTime> selectedDates;

  const PengaturanAlarmPuasaScreen({
    super.key,
    this.selectedType = FastingType.seninKamis,
    this.selectedDates = const [],
  });

  @override
  State<PengaturanAlarmPuasaScreen> createState() => _PengaturanAlarmPuasaScreenState();
}

class _PengaturanAlarmPuasaScreenState extends State<PengaturanAlarmPuasaScreen> {
  late FastingAlarmConfig _config;
  bool _applyToAll = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FastingProvider>();
    _config = provider.alarmConfig;
    _applyToAll = _config.applyToAllFastingDays;
  }

  Future<void> _pickSahurTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _config.sahurHour, minute: _config.sahurMinute),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF518427),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _config = _config.copyWith(
          sahurHour: picked.hour,
          sahurMinute: picked.minute,
        );
      });
    }
  }

  void _showRingtonePicker({required bool isSahur}) {
    final options = isSahur
        ? [
            {'title': 'Adzan Makkah', 'desc': 'Kumandang adzan Makkah Al-Mukarramah'},
            {'title': 'Adzan Madinah', 'desc': 'Lantunan merdu adzan Madinah Nabawi'},
            {'title': 'Nada Lembut', 'desc': 'Melodi lembut & menenangkan untuk bangun'},
            {'title': 'Bel Tradisional', 'desc': 'Dentang bel klasik sahur'},
          ]
        : [
            {'title': 'Bedug & Adzan', 'desc': 'Kombinasi tabuhan bedug dan adzan Maghrib'},
            {'title': 'Bedug Sahur', 'desc': 'Tabuhan bedug tradisional berirama'},
            {'title': 'Adzan Maghrib', 'desc': 'Adzan penanda waktu berbuka puasa'},
            {'title': 'Genta Islami', 'desc': 'Genta resonan khidmat penyejuk hati'},
          ];

    String? playingRingtone;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final current = isSahur ? _config.sahurRingtone : _config.iftarRingtone;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Nada Dering ${isSahur ? 'Sahur' : 'Iftar'}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tekan tombol putar untuk mendengar cuplikan suara',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (playingRingtone != null)
                      IconButton(
                        tooltip: 'Hentikan Suara',
                        icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent, size: 26),
                        onPressed: () {
                          FastingAlarmService().stopAlarmSound();
                          setModalState(() => playingRingtone = null);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                ...options.map((item) {
                  final opt = item['title']!;
                  final desc = item['desc']!;
                  final isSelected = current == opt;
                  final isAudioPlaying = playingRingtone == opt;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF518427).withValues(alpha: 0.08)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF518427) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: InkWell(
                        onTap: () async {
                          if (isAudioPlaying) {
                            await FastingAlarmService().stopAlarmSound();
                            setModalState(() => playingRingtone = null);
                          } else {
                            await FastingAlarmService().playPreviewSound(opt);
                            setModalState(() => playingRingtone = opt);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isAudioPlaying
                                ? Colors.redAccent.withValues(alpha: 0.15)
                                : const Color(0xFF518427).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAudioPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                            color: isAudioPlaying ? Colors.redAccent : const Color(0xFF518427),
                            size: 22,
                          ),
                        ),
                      ),
                      title: Text(
                        opt,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF518427) : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF518427), size: 22)
                          : const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFFCBD5E1), size: 22),
                      onTap: () {
                        FastingAlarmService().stopAlarmSound();
                        setState(() {
                          if (isSahur) {
                            _config = _config.copyWith(sahurRingtone: opt);
                          } else {
                            _config = _config.copyWith(iftarRingtone: opt);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      FastingAlarmService().stopAlarmSound();
    });
  }

  void _showSnoozePicker() {
    final options = [3, 5, 10, 15];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Durasi Tunda (Snooze)',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            ...options.map((minutes) {
              final isSelected = _config.snoozeDurationMinutes == minutes;

              return ListTile(
                title: Text('$minutes Menit', style: GoogleFonts.inter(fontSize: 14)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF518427))
                    : null,
                onTap: () {
                  setState(() {
                    _config = _config.copyWith(snoozeDurationMinutes: minutes);
                  });
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPrepMinutesPicker() {
    final options = [5, 10, 15, 20, 30];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pengingat Persiapan Sebelum Maghrib',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            ...options.map((m) {
              final isSelected = _config.iftarPreparationMinutes == m;

              return ListTile(
                title: Text('$m Menit Sebelum', style: GoogleFonts.inter(fontSize: 14)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF518427))
                    : null,
                onTap: () {
                  setState(() {
                    _config = _config.copyWith(iftarPreparationMinutes: m);
                  });
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndSave() async {
    final fastingProvider = context.read<FastingProvider>();

    // Simpan konfigurasi alarm
    final updatedConfig = _config.copyWith(applyToAllFastingDays: _applyToAll);
    await fastingProvider.updateAlarmConfig(updatedConfig);

    // Simpan rencana tanggal jika dibuka dari alur tambah puasa
    if (widget.selectedDates.isNotEmpty) {
      final newPlans = widget.selectedDates.map((date) {
        return FastingPlan(
          id: 'plan_${date.millisecondsSinceEpoch}',
          date: DateTime(date.year, date.month, date.day),
          type: widget.selectedType,
          status: FastingStatus.planned,
        );
      }).toList();

      await fastingProvider.addPlans(newPlans);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rencana puasa dan alarm berhasil dikonfirmasi! 🌙'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Kembali ke halaman utama puasa
    Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/puasa');
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final maghribTime = prayerProvider.schedule.maghrib;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF518427),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CustomBackButton(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pengaturan Alarm',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Jadwal Puasa-mu Bulan Ini',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card 1: Alarm Sahur ──
            _buildSahurCard(),

            const SizedBox(height: 16),

            // ── Card 2: Alarm Iftar ──
            _buildIftarCard(maghribTime),

            const SizedBox(height: 18),

            // ── Checkbox: Terapkan untuk semua hari puasa ──
            InkWell(
              onTap: () => setState(() => _applyToAll = !_applyToAll),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _applyToAll,
                        onChanged: (val) => setState(() => _applyToAll = val ?? true),
                        activeColor: const Color(0xFF518427),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Terapkan untuk semua hari puasa',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Konfirmasi ──
            ElevatedButton(
              onPressed: _confirmAndSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF518427),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Konfirmasi Rencana Alarm',
                style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 20),

            // ── Section Uji Coba Simulator Alarm ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science_outlined, size: 16, color: Color(0xFF475569)),
                      const SizedBox(width: 6),
                      Text(
                        'Pengujian Simulator Alarm',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Uji coba tampilan layar alarm tanpa perlu menunggu jam sahur atau berbuka sesungguhnya:',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => FastingAlarmService().simulateSahurAlarm(
                            context,
                            ringtoneName: _config.sahurRingtone,
                          ),
                          icon: const Icon(Icons.wb_twilight_rounded, size: 16),
                          label: const Text('Simulasi Sahur'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF81C784)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => FastingAlarmService().simulateIftarAlarm(
                            context,
                            ringtoneName: _config.iftarRingtone,
                          ),
                          icon: const Icon(Icons.dinner_dining_rounded, size: 16),
                          label: const Text('Simulasi Iftar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB45309),
                            side: const BorderSide(color: Color(0xFFFCD34D)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card 1: Alarm Sahur ──
  Widget _buildSahurCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, size: 18, color: Color(0xFF518427)),
                  const SizedBox(width: 8),
                  Text(
                    'Alarm Sahur',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Switch(
                value: _config.sahurAlarmEnabled,
                onChanged: (val) => setState(() => _config = _config.copyWith(sahurAlarmEnabled: val)),
                activeColor: const Color(0xFF518427),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Big Clock Display
          Center(
            child: InkWell(
              onTap: _config.sahurAlarmEnabled ? _pickSahurTime : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  _config.sahurTimeFormatted,
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: _config.sahurAlarmEnabled ? const Color(0xFF1E293B) : Colors.grey.shade400,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // Row: Nada Dering
          _buildSettingsRow(
            icon: Icons.music_note_rounded,
            title: 'Nada Dering',
            trailingText: _config.sahurRingtone,
            onTap: _config.sahurAlarmEnabled ? () => _showRingtonePicker(isSahur: true) : null,
          ),

          // Row: Tunda (Snooze)
          _buildSettingsRow(
            icon: Icons.snooze_rounded,
            title: 'Tunda (Snooze)',
            trailingText: '${_config.snoozeDurationMinutes} Menit',
            onTap: _config.sahurAlarmEnabled ? _showSnoozePicker : null,
          ),

          // Row: Peringatan Imsak Toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.hourglass_bottom_rounded, size: 16, color: Color(0xFF518427)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Peringatan Imsak',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155)),
                  ),
                ),
                Switch(
                  value: _config.imsakWarningEnabled,
                  onChanged: _config.sahurAlarmEnabled
                      ? (val) => setState(() => _config = _config.copyWith(imsakWarningEnabled: val))
                      : null,
                  activeColor: const Color(0xFF518427),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 2: Alarm Iftar ──
  Widget _buildIftarCard(String maghribTime) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.nightlight_round, size: 18, color: Color(0xFF518427)),
                  const SizedBox(width: 8),
                  Text(
                    'Alarm Iftar',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Switch(
                value: _config.iftarAlarmEnabled,
                onChanged: (val) => setState(() => _config = _config.copyWith(iftarAlarmEnabled: val)),
                activeColor: const Color(0xFF518427),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Big Clock Display (Waktu Maghrib)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  maghribTime,
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: _config.iftarAlarmEnabled ? const Color(0xFF1E293B) : Colors.grey.shade400,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Maghrib',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // Row: Nada Dering
          _buildSettingsRow(
            icon: Icons.music_note_rounded,
            title: 'Nada Dering',
            trailingText: _config.iftarRingtone,
            onTap: _config.iftarAlarmEnabled ? () => _showRingtonePicker(isSahur: false) : null,
          ),

          // Row: Pengingat Persiapan
          _buildSettingsRow(
            icon: Icons.timer_outlined,
            title: 'Pengingat Persiapan',
            trailingText: '${_config.iftarPreparationMinutes} Menit Sebelum',
            onTap: _config.iftarAlarmEnabled ? _showPrepMinutesPicker : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF518427)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155)),
              ),
            ),
            Text(
              trailingText,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF518427),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
