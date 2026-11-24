import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/arabic_matching_service.dart';

/// Modal Bottom Sheet untuk menampilkan hasil evaluasi hafalan AI secara komprehensif
class HapalanResultSheet extends StatefulWidget {
  final HafalanEvaluationResult result;
  final VoidCallback onRetry;
  final VoidCallback onNextAyah;
  final bool hasNextAyah;

  const HapalanResultSheet({
    super.key,
    required this.result,
    required this.onRetry,
    required this.onNextAyah,
    this.hasNextAyah = true,
  });

  static Future<void> show({
    required BuildContext context,
    required HafalanEvaluationResult result,
    required VoidCallback onRetry,
    required VoidCallback onNextAyah,
    bool hasNextAyah = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HapalanResultSheet(
        result: result,
        onRetry: onRetry,
        onNextAyah: onNextAyah,
        hasNextAyah: hasNextAyah,
      ),
    );
  }

  @override
  State<HapalanResultSheet> createState() => _HapalanResultSheetState();
}

class _HapalanResultSheetState extends State<HapalanResultSheet> {
  bool _showDetails = false;

  Color get _gradeColor {
    switch (widget.result.grade) {
      case HafalanGrade.sangatBaik:
        return const Color(0xFF2E7D32); // Hijau pekat
      case HafalanGrade.baik:
        return const Color(0xFF4F8426); // Hijau aplikasi
      case HafalanGrade.perluLatihan:
        return const Color(0xFFE65100); // Oranye
      case HafalanGrade.ulangiHafalan:
        return const Color(0xFFC62828); // Merah
    }
  }

  Color get _gradeBgColor {
    switch (widget.result.grade) {
      case HafalanGrade.sangatBaik:
        return const Color(0xFFE8F5E9);
      case HafalanGrade.baik:
        return const Color(0xFFF1F8E9);
      case HafalanGrade.perluLatihan:
        return const Color(0xFFFFF3E0);
      case HafalanGrade.ulangiHafalan:
        return const Color(0xFFFFEBEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Atas
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header: Judul & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _gradeBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: _gradeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil Pengujian Hafalan',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          res.ayahDisplayLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARD NILAI & PREDIKAT UTAMA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: _gradeBgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _gradeColor.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Lingkaran Skor Persentase
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _gradeColor.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${res.matchPercentage.toInt()}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: _gradeColor,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'Akurasi',
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Teks Predikat & Feedback
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _gradeColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    res.gradeTitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  res.feedbackMessage,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: const Color(0xFF374151),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // METRIK RINGKASAN KATA (Sesuai, Keliru, Terlewat)
                    Row(
                      children: [
                        // Kata Sesuai (Hijau)
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Sesuai',
                            count: res.correctCount,
                            color: const Color(0xFF2E7D32),
                            bgColor: const Color(0xFFE8F5E9),
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Kata Keliru (Merah)
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Keliru',
                            count: res.incorrectCount,
                            color: const Color(0xFFC62828),
                            bgColor: const Color(0xFFFFEBEE),
                            icon: Icons.highlight_off_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Kata Terlewat (Oranye)
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Terlewat',
                            count: res.missingCount,
                            color: const Color(0xFFEF6C00),
                            bgColor: const Color(0xFFFFF3E0),
                            icon: Icons.error_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ANALISIS BACAAN AYAT DENGAN HIGHLIGHT KATA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Evaluasi Kata Ayat',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3710),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showDetails = !_showDetails;
                            });
                          },
                          child: Text(
                            _showDetails ? 'Sembunyikan Detail' : 'Lihat Detail Kata',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4F8426),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Container highlight teks Arab kata demi kata
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFBF7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8D8)),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: res.evaluatedWords.map((word) {
                            Color textColor;
                            Color bgPill;
                            BorderSide border;

                            switch (word.status) {
                              case WordMatchStatus.correct:
                                textColor = const Color(0xFF2E7D32);
                                bgPill = const Color(0xFFE8F5E9);
                                border = const BorderSide(color: Color(0xFFA5D6A7), width: 1);
                                break;
                              case WordMatchStatus.incorrect:
                                textColor = const Color(0xFFC62828);
                                bgPill = const Color(0xFFFFEBEE);
                                border = const BorderSide(color: Color(0xFFEF9A9A), width: 1);
                                break;
                              case WordMatchStatus.missing:
                                textColor = const Color(0xFFEF6C00);
                                bgPill = const Color(0xFFFFF3E0);
                                border = const BorderSide(color: Color(0xFFFFCC80), width: 1);
                                break;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: bgPill,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.fromBorderSide(border),
                              ),
                              child: Text(
                                word.originalText,
                                style: GoogleFonts.amiri(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Petunjuk Legenda Warna
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(const Color(0xFF2E7D32), 'Sesuai'),
                        const SizedBox(width: 16),
                        _buildLegendItem(const Color(0xFFC62828), 'Keliru'),
                        const SizedBox(width: 16),
                        _buildLegendItem(const Color(0xFFEF6C00), 'Terlewat'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // BACAAN SUARA YANG DIKENALI (TRANSKRIPSI)
                    if (res.recognizedTranscript.isNotEmpty) ...[
                      Text(
                        'Bacaan yang Dikenali (Transkripsi Suara)',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          res.recognizedTranscript,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 17,
                            color: const Color(0xFF1F2937),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // DETAIL PER KATA (JIKA DIBUKA)
                    if (_showDetails) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rincian Kata Per Kata',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...res.evaluatedWords.map((w) {
                              final statusLabel = w.status == WordMatchStatus.correct
                                  ? 'Sesuai'
                                  : (w.status == WordMatchStatus.incorrect ? 'Keliru' : 'Terlewat');
                              final statusColor = w.status == WordMatchStatus.correct
                                  ? const Color(0xFF2E7D32)
                                  : (w.status == WordMatchStatus.incorrect
                                      ? const Color(0xFFC62828)
                                      : const Color(0xFFEF6C00));

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      w.originalText,
                                      style: GoogleFonts.amiri(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // DISCLAIMER TEKNIS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Penilaian berbasis tingkat kecocokan teks hasil transkripsi suara dengan ayat mushaf. Bukan pengganti penilaian makhraj & hukum tajwid dari ustadz/guru Al-Qur\'an.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF1E40AF),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ACTION BUTTONS (Ulangi Hafalan & Lanjut Ayat Berikutnya)
            Row(
              children: [
                // Tombol Ulangi
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRetry();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4F8426), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF4F8426),
                      size: 20,
                    ),
                    label: Text(
                      'Ulangi Hafalan',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4F8426),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol Lanjut ke Ayat Berikutnya
                if (widget.hasNextAyah)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onNextAyah();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8426),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Lanjut Ayat',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count Kata',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
