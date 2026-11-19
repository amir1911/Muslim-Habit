import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/hijri_helper.dart';
import '../../models/fasting_plan.dart';
import '../../providers/fasting_provider.dart';

class RiwayatPuasaScreen extends StatefulWidget {
  const RiwayatPuasaScreen({super.key});

  @override
  State<RiwayatPuasaScreen> createState() => _RiwayatPuasaScreenState();
}

class _RiwayatPuasaScreenState extends State<RiwayatPuasaScreen> {
  int _filterIndex = 0; // 0 = Semua, 1 = Selesai, 2 = Tidak Puasa

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FastingProvider>();
    final allPlans = provider.plans;

    final completedList = allPlans.where((p) => p.status == FastingStatus.completed).toList();
    final skippedList = allPlans.where((p) => p.status == FastingStatus.skipped).toList();

    List<FastingPlan> displayList;
    if (_filterIndex == 1) {
      displayList = completedList;
    } else if (_filterIndex == 2) {
      displayList = skippedList;
    } else {
      displayList = allPlans.where((p) => p.status != FastingStatus.planned).toList();
    }

    displayList.sort((a, b) => b.date.compareTo(a.date));

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
        title: Text(
          'Riwayat Puasa',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ringkasan Statistik
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Selesai',
                    value: '${completedList.length} Hari',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Perlu Qadha',
                    value: '${skippedList.length} Hari',
                    icon: Icons.bookmark_added_rounded,
                    color: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFFEBEE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Filter Tabs
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildTabItem(index: 0, label: 'Semua (${completedList.length + skippedList.length})'),
                  _buildTabItem(index: 1, label: 'Selesai (${completedList.length})'),
                  _buildTabItem(index: 2, label: 'Qadha (${skippedList.length})'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Daftar Riwayat
            if (displayList.isEmpty)
              Container(
                padding: const EdgeInsets.all(36),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada catatan riwayat puasa.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            else
              ...displayList.map((plan) => _buildHistoryCard(plan)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required int index, required String label}) {
    final isSelected = (_filterIndex == index);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filterIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(FastingPlan plan) {
    final dayName = HijriHelper.getDayNameIndonesian(plan.date);
    final monthName = HijriHelper.getMonthNameIndonesian(plan.date.month);
    final dateStr = '$dayName, ${plan.date.day} $monthName ${plan.date.year}';
    final isCompleted = (plan.status == FastingStatus.completed);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.type.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompleted ? 'Selesai' : 'Tidak Puasa',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                ),
                if (!isCompleted && plan.skippedReason != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alasan: ${plan.skippedReason!.displayName}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        if (plan.skippedNotes != null && plan.skippedNotes!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '"${plan.skippedNotes!}"',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
