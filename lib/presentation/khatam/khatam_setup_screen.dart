import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/khatam_provider.dart';
import 'khatam_target_modal.dart';
import 'khatam_dashboard_screen.dart';

/// Halaman Pengaturan Target Mode Khatam Al-Qur'an (ModeKhatamSetupScreen)
class KhatamSetupScreen extends StatefulWidget {
  const KhatamSetupScreen({super.key});

  @override
  State<KhatamSetupScreen> createState() => _KhatamSetupScreenState();
}

typedef ModeKhatamSetupScreen = KhatamSetupScreen;

class _KhatamSetupScreenState extends State<KhatamSetupScreen> {
  DateTime _startDate = DateTime.now();
  int _targetQuantity = 1;
  String _targetUnit = 'juz';
  int _targetPeriodValue = 1;
  String _targetPeriodUnit = 'hari';
  int _targetDurationDays = 30;

  bool _reminderMaghrib = true;
  bool _reminderFajr = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<KhatamProvider>();
      final plan = prov.activePlan;
      if (plan != null) {
        setState(() {
          _startDate = plan.startDate;
          _targetQuantity = plan.targetQuantity;
          _targetUnit = plan.targetUnit;
          _targetPeriodUnit = plan.targetPeriod;
          _targetDurationDays = plan.targetDuration;
          _reminderMaghrib = plan.reminderMaghrib;
          _reminderFajr = plan.reminderFajr;
        });
      }
    });
  }

  double get _calculatedDailyJuz {
    if (_targetUnit == 'juz') {
      if (_targetPeriodUnit == 'minggu') {
        return _targetQuantity / 7.0;
      } else {
        return _targetQuantity / _targetPeriodValue;
      }
    } else {
      // 208 ayat ~ 1 Juz
      final juzVal = _targetQuantity / 208.0;
      return _targetPeriodUnit == 'minggu' ? juzVal / 7.0 : juzVal / _targetPeriodValue;
    }
  }

  String get _dailyTargetLabel {
    final daily = _calculatedDailyJuz;
    if (daily >= 1.0) {
      if (daily == daily.roundToDouble()) {
        return '${daily.toInt()} Juz/hari';
      } else {
        return '${daily.toStringAsFixed(1)} Juz/hari';
      }
    } else {
      final ayatPerDay = (_targetUnit == 'ayat')
          ? (_targetQuantity / (_targetPeriodUnit == 'minggu' ? 7 : _targetPeriodValue)).round()
          : (daily * 208).round();
      return '$ayatPerDay Ayat/hari';
    }
  }

  int get _estimatedReadingMinutes {
    final daily = _calculatedDailyJuz;
    return (daily * 45).round().clamp(10, 180);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF518427),
              onPrimary: Colors.white,
              onSurface: Color(0xFF264E0B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _openTargetModal() async {
    final result = await TargetKhatamBottomSheet.show(
      context,
      initialQuantity: _targetQuantity,
      initialUnit: _targetUnit,
      initialPeriodValue: _targetPeriodValue,
      initialPeriodUnit: _targetPeriodUnit,
    );
    if (result != null) {
      setState(() {
        _targetQuantity = result.quantity;
        _targetUnit = result.unit;
        _targetPeriodValue = result.periodValue;
        _targetPeriodUnit = result.periodUnit;

        // Hitung durasi total hari
        final daily = _calculatedDailyJuz;
        _targetDurationDays = (30 / daily).ceil().clamp(1, 365);
      });
    }
  }

  Future<void> _startPlan() async {
    final prov = context.read<KhatamProvider>();

    if (prov.hasActivePlan) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Perbarui Target Khatam?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          content: Text(
            'Target khatam Anda akan diperbarui. Progres ayat yang sudah Anda baca akan tetap tersimpan aman.',
            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF4B5563)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF518427),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Perbarui', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await prov.startOrUpdatePlan(
      startDate: _startDate,
      targetDuration: _targetDurationDays,
      targetQuantity: _targetQuantity,
      targetUnit: _targetUnit,
      targetPeriod: _targetPeriodUnit,
      reminderMaghrib: _reminderMaghrib,
      reminderFajr: _reminderFajr,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KhatamDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_startDate);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF518427),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF518427),
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF84B74E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 26),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Mode Khatam',
            style: GoogleFonts.inter(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              // ── ATUR TARGET KHATAM SECTION ──
              Text(
                'Atur Target Khatam',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF264E0B),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Rencanakan perjalanan spiritual Anda dengan disiplin dan ketenangan.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // ── TWO FORM FIELDS (Tanggal Mulai & Target Durasi) ──
              Row(
                children: [
                  // Tanggal Mulai
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal mulai',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 7),
                        GestureDetector(
                          onTap: _selectStartDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFCCD7C9), width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateStr,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF4B5563)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Target Durasi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target durasi',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 7),
                        GestureDetector(
                          onTap: _openTargetModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFCCD7C9), width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$_targetDurationDays hari (1Juz/hari)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.alarm_add_outlined, size: 19, color: Color(0xFF4B5563)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── KARTU TARGET HARIAN PUTIH ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Target Harian',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _dailyTargetLabel,
                      style: GoogleFonts.inter(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF264E0B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_outlined, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 6),
                            Text(
                              'Juz 1 - Juz 30',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 14,
                          width: 1,
                          color: const Color(0xFFD1D5DB),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 6),
                            Text(
                              '± $_estimatedReadingMinutes Menit/hari',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ── PENGINGAT SPIRITUAL SECTION ──
              Row(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: const Color(0xFF264E0B), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Pengigat Spritual',
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF264E0B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Item 1: Ba'da Maghrib
              _buildReminderCard(
                icon: Icons.nightlight_round,
                title: "Ba'da Maghrib",
                subtitle: 'Murojaah sebelum beristirahat',
                isEnabled: _reminderMaghrib,
                onChanged: (val) => setState(() => _reminderMaghrib = val),
              ),

              const SizedBox(height: 12),

              // Item 2: Ba'da Fajr
              _buildReminderCard(
                icon: Icons.wb_sunny_outlined,
                title: "Ba'da Fajr",
                subtitle: 'Waktu terbaik untuk menghafal',
                isEnabled: _reminderFajr,
                onChanged: (val) => setState(() => _reminderFajr = val),
              ),

              const SizedBox(height: 34),

              // ── TOMBOL MULAI PERJALANAN ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF518427),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: _startPlan,
                  child: Text(
                    'Mulai Perjalanan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E7DF), width: 1.2),
            ),
            child: Icon(icon, color: const Color(0xFF264E0B), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF264E0B),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
          ),
        ],
      ),
    );
  }
}
