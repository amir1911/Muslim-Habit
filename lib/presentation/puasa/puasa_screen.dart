import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/hijri_helper.dart';
import '../../models/fasting_plan.dart';
import '../../providers/fasting_provider.dart';
import 'tambah_puasa_screen.dart';
import 'pengaturan_alarm_puasa_screen.dart';
import 'tidak_puasa_screen.dart';
import 'riwayat_puasa_screen.dart';

class PuasaScreen extends StatelessWidget {
  const PuasaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FastingProvider>();
    final currentMonth = provider.currentMonth;
    final plansThisMonth = provider.getPlansForCurrentMonth();

    final completedCount = plansThisMonth.where((p) => p.status == FastingStatus.completed).length;
    final totalCount = plansThisMonth.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puasa',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_rounded, color: Colors.white),
            tooltip: 'Pengaturan Alarm',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PengaturanAlarmPuasaScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            tooltip: 'Riwayat Puasa',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RiwayatPuasaScreen()),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. Card Target Puasa (Kalender) ──
                  _buildCalendarCard(context, provider, currentMonth),

                  const SizedBox(height: 20),

                  // ── 2. Header Puasa Bulan Ini ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 8),
                          Text(
                            'Puasa Bulan Ini',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$completedCount/$totalCount',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TambahPuasaScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Tambah'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── 3. List Puasa Bulan Ini ──
                  if (plansThisMonth.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...plansThisMonth.map((plan) => _buildFastingPlanCard(context, provider, plan)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TambahPuasaScreen()),
          );
        },
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  // ── Card Kalender Target Puasa ─────────────────────────
  Widget _buildCalendarCard(BuildContext context, FastingProvider provider, DateTime currentMonth) {
    final hijriRange = HijriHelper.getHijriMonthRangeForGregorianMonth(currentMonth.year, currentMonth.month);
    final monthName = HijriHelper.getMonthNameIndonesian(currentMonth.month);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Judul & Navigasi Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF4A7C59)),
                      const SizedBox(width: 6),
                      Text(
                        'Target Puasa',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$monthName ${currentMonth.year}',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    hijriRange,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: provider.previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: provider.nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
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

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Header Hari (Min, Sen, Sel, Rab, Kam, Jum, Sab)
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

          // Grid Tanggal Kalender
          _buildMonthGrid(context, provider, currentMonth),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Legenda Status
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: const [
              _LegendItem(color: Color(0xFF2E7D32), label: 'Selesai'),
              _LegendItem(color: Color(0xFFC8E6C9), label: 'Direncanakan', isBorder: true),
              _LegendItem(color: Color(0xFFFFCDD2), label: 'Tidak Berpuasa', isRed: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context, FastingProvider provider, DateTime currentMonth) {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // 0 = Minggu

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
        final plan = provider.getPlanForDate(date);
        final hijri = HijriHelper.fromGregorian(date);

        Color? bgColor;
        Color textColor = const Color(0xFF334155);
        Border? border;

        if (plan != null) {
          switch (plan.status) {
            case FastingStatus.completed:
              bgColor = const Color(0xFF2E7D32);
              textColor = Colors.white;
              break;
            case FastingStatus.planned:
            case FastingStatus.fasting:
              bgColor = const Color(0xFFE8F5E9);
              textColor = const Color(0xFF1B5E20);
              border = Border.all(color: const Color(0xFF81C784), width: 1.5);
              break;
            case FastingStatus.skipped:
              bgColor = const Color(0xFFFFEBEE);
              textColor = const Color(0xFFC62828);
              border = Border.all(color: const Color(0xFFEF9A9A), width: 1.5);
              break;
          }
        }

        final isToday = DateTime.now().year == year &&
            DateTime.now().month == month &&
            DateTime.now().day == dayNum;

        return InkWell(
          onTap: () {
            if (plan != null) {
              _showPlanOptionsSheet(context, provider, plan);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: bgColor ?? (isToday ? const Color(0xFFF1F5F9) : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: border ?? (isToday ? Border.all(color: const Color(0xFF94A3B8)) : null),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: (plan != null || isToday) ? FontWeight.w800 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Text(
                  '${hijri.day}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: plan?.status == FastingStatus.completed
                        ? Colors.white.withValues(alpha: 0.8)
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Card Rencana Puasa dalam Daftar ───────────────────
  Widget _buildFastingPlanCard(BuildContext context, FastingProvider provider, FastingPlan plan) {
    final dayName = HijriHelper.getDayNameIndonesian(plan.date);
    final monthName = HijriHelper.getMonthNameIndonesian(plan.date.month);
    final dateFormatted = '$dayName, ${plan.date.day} $monthName ${plan.date.year}';

    Color cardBg;
    Color iconBg;
    Color statusColor;
    String statusText;

    switch (plan.status) {
      case FastingStatus.completed:
        cardBg = const Color(0xFFF0FDF4);
        iconBg = const Color(0xFFDCFCE7);
        statusColor = const Color(0xFF16A34A);
        statusText = 'Selesai';
        break;
      case FastingStatus.planned:
      case FastingStatus.fasting:
        cardBg = Colors.white;
        iconBg = const Color(0xFFE8F5E9);
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Direncanakan';
        break;
      case FastingStatus.skipped:
        cardBg = const Color(0xFFFEF2F2);
        iconBg = const Color(0xFFFEE2E2);
        statusColor = const Color(0xFFDC2626);
        statusText = 'Tidak Puasa (${plan.skippedReason?.displayName ?? "Batal"})';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.nightlight_round, color: Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.type.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormatted,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
            onPressed: () => _showPlanOptionsSheet(context, provider, plan),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_note_rounded, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada target puasa bulan ini',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mulai rencanakan puasa sunnah Senin-Kamis, Daud, atau Syawal dengan menekan tombol di bawah.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TambahPuasaScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Rencanakan Puasa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet Opsi untuk Satu Tanggal ───────────────
  void _showPlanOptionsSheet(BuildContext context, FastingProvider provider, FastingPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
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
            Text(
              '${plan.type.displayName} - ${plan.date.day} ${HijriHelper.getMonthNameIndonesian(plan.date.month)}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Tandai Selesai
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32)),
              title: const Text('Tandai Puasa Selesai'),
              onTap: () {
                Navigator.pop(context);
                provider.markCompleted(plan.id);
              },
            ),

            // Tidak Puasa (Catat Alasan)
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
              title: const Text('Catat Tidak Berpuasa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TidakPuasaScreen(planId: plan.id)),
                );
              },
            ),

            // Hapus Rencana
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
              title: const Text('Hapus Rencana Ini'),
              onTap: () {
                Navigator.pop(context);
                provider.removePlan(plan.id);
              },
            ),
          ],
        ),
      ),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isBorder;
  final bool isRed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isBorder = false,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBorder ? const Color(0xFFE8F5E9) : color,
            borderRadius: BorderRadius.circular(3),
            border: isBorder ? Border.all(color: const Color(0xFF81C784)) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
