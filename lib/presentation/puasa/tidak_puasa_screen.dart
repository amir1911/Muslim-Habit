import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/fasting_plan.dart';
import '../../providers/fasting_provider.dart';
import '../../core/widgets/custom_back_button.dart';

class TidakPuasaScreen extends StatefulWidget {
  final String? planId;

  const TidakPuasaScreen({super.key, this.planId});

  @override
  State<TidakPuasaScreen> createState() => _TidakPuasaScreenState();
}

class _TidakPuasaScreenState extends State<TidakPuasaScreen> {
  SkippedReason _selectedReason = SkippedReason.sakit;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSkipped() async {
    final provider = context.read<FastingProvider>();
    final today = DateTime.now();

    // Jika planId ada, gunakan planId tersebut. Jika tidak, cari atau buat untuk hari ini.
    String targetId = widget.planId ?? '';
    if (targetId.isEmpty) {
      final existingToday = provider.getPlanForDate(today);
      if (existingToday != null) {
        targetId = existingToday.id;
      } else {
        targetId = 'plan_${today.millisecondsSinceEpoch}';
        await provider.addPlan(
          FastingPlan(
            id: targetId,
            date: DateTime(today.year, today.month, today.day),
            type: FastingType.seninKamis,
            status: FastingStatus.planned,
          ),
        );
      }
    }

    await provider.markSkipped(
      id: targetId,
      reason: _selectedReason,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan telah disimpan untuk pengingat qadha. Tetap semangat! 🌿'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CustomBackButton(
            isLightBackground: true,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tidak Puasa?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'Catat alasan dan rencana qadha ibadahmu',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon & Judul Empathic
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF518427),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.nightlight_round, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Alasan Tidak Puasa',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Pesan Pengingat Qadha
            Text(
              'Tetap semangat, sahabat... Allah SWT Maha Mengetahui niat baikmu. Catat alasanmu hari ini untuk pengingat qadha di kemudian hari.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Pilih Alasan
            Text(
              'Pilih Alasan',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),

            // Grid 6 Alasan
            _buildReasonGrid(),

            const SizedBox(height: 20),

            // Catatan Tambahan (Opsional)
            Text(
              'Catatan Tambahan (Opsional)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Misal: Sakit demam sejak pagi...',
                hintStyle: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF518427), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol SIMPAN
            ElevatedButton(
              onPressed: _saveSkipped,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF518427),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'SIMPAN',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonGrid() {
    const reasons = SkippedReason.values;

    return Column(
      children: [
        // Row 1: Sakit & Musafir
        Row(
          children: [
            Expanded(child: _buildReasonCard(reasons[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildReasonCard(reasons[1])),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Haid & Nifas
        Row(
          children: [
            Expanded(child: _buildReasonCard(reasons[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildReasonCard(reasons[3])),
          ],
        ),
        const SizedBox(height: 10),

        // Row 3: Hamil/Menyusui (Full width)
        _buildReasonCard(reasons[4], isFullWidth: true),
        const SizedBox(height: 10),

        // Row 4: Lainnya (Full width)
        _buildReasonCard(reasons[5], isFullWidth: true),
      ],
    );
  }

  Widget _buildReasonCard(SkippedReason reason, {bool isFullWidth = false}) {
    final isSelected = (_selectedReason == reason);

    return InkWell(
      onTap: () => setState(() => _selectedReason = reason),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF518427) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(
              reason.icon,
              size: 20,
              color: isSelected ? const Color(0xFF15803D) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reason.displayName,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF15803D) : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF15803D)),
          ],
        ),
      ),
    );
  }
}
