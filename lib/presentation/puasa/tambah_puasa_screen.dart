import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/hijri_helper.dart';
import '../../models/fasting_plan.dart';
import 'pengaturan_alarm_puasa_screen.dart';
import '../../core/widgets/custom_back_button.dart';

class TambahPuasaScreen extends StatefulWidget {
  const TambahPuasaScreen({super.key});

  @override
  State<TambahPuasaScreen> createState() => _TambahPuasaScreenState();
}

class _TambahPuasaScreenState extends State<TambahPuasaScreen> {
  FastingType _selectedType = FastingType.seninKamis;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  final Set<DateTime> _selectedDates = {};

  @override
  void initState() {
    super.initState();
    _applyDefaultDatesForType(_selectedType);
  }

  void _applyDefaultDatesForType(FastingType type) {
    _selectedDates.clear();

    if (type == FastingType.seninKamis) {
      final mondaysThursdays = HijriHelper.getMondaysAndThursdays(
        _currentMonth.year,
        _currentMonth.month,
      );
      _selectedDates.addAll(mondaysThursdays);
    } else if (type == FastingType.daud) {
      final daudDays = HijriHelper.getDaudFastingDays(
        DateTime(_currentMonth.year, _currentMonth.month, 1),
        10,
      );
      _selectedDates.addAll(daudDays.where((d) => d.month == _currentMonth.month));
    } else if (type == FastingType.syawal) {
      // 6 hari default
      for (int i = 2; i <= 7; i++) {
        _selectedDates.add(DateTime(_currentMonth.year, _currentMonth.month, i));
      }
    }
  }

  void _toggleDateSelection(DateTime date) {
    setState(() {
      final normalized = DateTime(date.year, date.month, date.day);
      if (_selectedDates.any((d) => _isSameDay(d, normalized))) {
        _selectedDates.removeWhere((d) => _isSameDay(d, normalized));
      } else {
        if (_selectedType == FastingType.syawal && _selectedDates.length >= 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Puasa Syawal dianjurkan 6 hari.')),
          );
          return;
        }
        _selectedDates.add(normalized);
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final hijriRange = HijriHelper.getHijriMonthRangeForGregorianMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final monthName = HijriHelper.getMonthNameIndonesian(_currentMonth.month);

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
                'Tambah Puasa',
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
            // ── Section 1: Pilih Jenis Puasa ──
            Text(
              'Pilih Jenis Puasa',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Pilih puasa yang dapat dilakukan bulan ini',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            _buildFastingTypeCard(
              type: FastingType.seninKamis,
              title: 'Senin - Kamis',
              subtitle: 'Sesuai sunnah Rasulullah SAW.',
            ),
            const SizedBox(height: 10),
            _buildFastingTypeCard(
              type: FastingType.daud,
              title: 'Puasa Daud',
              subtitle: 'Sehari berpuasa, sehari berbuka.',
            ),
            const SizedBox(height: 10),
            _buildFastingTypeCard(
              type: FastingType.syawal,
              title: 'Puasa Syawal',
              subtitle: '6 hari setelah Idul Fitri.',
            ),

            const SizedBox(height: 24),

            // ── Section 2: Target Puasa (Pilih Hari Puasa) ──
            Text(
              'Target Puasa',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Pilih Hari Puasa pada kalender di bawah',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // Kalender Pemilihan Tanggal
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
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
                  // Bulan & Navigasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$monthName ${_currentMonth.year}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              hijriRange,
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month - 1,
                                  1,
                                );
                                _applyDefaultDatesForType(_selectedType);
                              });
                            },
                            icon: const Icon(Icons.chevron_left_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month + 1,
                                  1,
                                );
                                _applyDefaultDatesForType(_selectedType);
                              });
                            },
                            icon: const Icon(Icons.chevron_right_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Header Hari
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _DayHeader('Min'),
                      _DayHeader('Sen'),
                      _DayHeader('Sel'),
                      _DayHeader('Rab'),
                      _DayHeader('Kam'),
                      _DayHeader('Jum'),
                      _DayHeader('Sab'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Grid Pemilihan
                  _buildSelectionGrid(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Section 3: Kotak Motivasi (Green Leaf) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_rounded, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Insya Allah, kamu akan berpuasa selama ${_selectedDates.length} hari di bulan ini. Tetap semangat mengumpulkan pahala!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF166534),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Lanjut ke Pengaturan Alarm
            ElevatedButton(
              onPressed: _selectedDates.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PengaturanAlarmPuasaScreen(
                            selectedType: _selectedType,
                            selectedDates: _selectedDates.toList(),
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF518427),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Lanjut ke Pengaturan Alarm',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastingTypeCard({
    required FastingType type,
    required String title,
    required String subtitle,
  }) {
    final isSelected = (_selectedType == type);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _applyDefaultDatesForType(type);
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF518427) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF518427) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF518427),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionGrid() {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final totalSlots = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.9,
      ),
      itemCount: totalSlots,
      itemBuilder: (ctx, slotIdx) {
        final dayNum = slotIdx - firstWeekday + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(year, month, dayNum);
        final isSelected = _selectedDates.any((d) => _isSameDay(d, date));
        final hijri = HijriHelper.fromGregorian(date);

        return InkWell(
          onTap: () => _toggleDateSelection(date),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF518427) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
                Text(
                  '${hijri.day}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade500,
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

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
