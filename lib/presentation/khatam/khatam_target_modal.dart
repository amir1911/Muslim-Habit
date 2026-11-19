import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KhatamTargetResult {
  final int quantity;
  final String unit; // 'juz' atau 'ayat'
  final int periodValue;
  final String periodUnit; // 'hari' atau 'minggu'

  KhatamTargetResult({
    required this.quantity,
    required this.unit,
    required this.periodValue,
    required this.periodUnit,
  });

  String get summaryText {
    if (unit == 'juz' && periodUnit == 'hari') {
      return '$quantity Juz / $periodValue Hari';
    } else if (unit == 'juz' && periodUnit == 'minggu') {
      return '$quantity Juz / $periodValue Minggu';
    } else {
      return '$quantity Ayat / $periodValue Hari';
    }
  }
}

class KhatamTargetModal extends StatefulWidget {
  final int initialQuantity;
  final String initialUnit;
  final int initialPeriodValue;
  final String initialPeriodUnit;

  const KhatamTargetModal({
    super.key,
    this.initialQuantity = 1,
    this.initialUnit = 'juz',
    this.initialPeriodValue = 1,
    this.initialPeriodUnit = 'hari',
  });

  static Future<KhatamTargetResult?> show(
    BuildContext context, {
    int initialQuantity = 1,
    String initialUnit = 'juz',
    int initialPeriodValue = 1,
    String initialPeriodUnit = 'hari',
  }) {
    return showModalBottomSheet<KhatamTargetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KhatamTargetModal(
        initialQuantity: initialQuantity,
        initialUnit: initialUnit,
        initialPeriodValue: initialPeriodValue,
        initialPeriodUnit: initialPeriodUnit,
      ),
    );
  }

  @override
  State<KhatamTargetModal> createState() => _KhatamTargetModalState();
}

class _KhatamTargetModalState extends State<KhatamTargetModal> {
  late int _quantity;
  late String _unit; // 'juz' atau 'ayat'
  late int _periodValue;
  late String _periodUnit; // 'hari' atau 'minggu'

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _unit = widget.initialUnit.toLowerCase();
    _periodValue = widget.initialPeriodValue;
    _periodUnit = widget.initialPeriodUnit.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6DCD3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Text(
            'Atur Target Khatam',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B432C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih Target Anda',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 24),

          // ── KOTAK PEMILIH TARGET (SESUAI GAMBAR REFERENSI KETIGA) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2DF).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // 1. Selector Angka Kuantitas
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberStepper(
                        value: _quantity,
                        min: 1,
                        max: _unit == 'juz' ? 30 : 286,
                        onChanged: (val) => setState(() => _quantity = val),
                      ),
                      const SizedBox(width: 8),
                      // Unit Switcher (Juz / Ayat)
                      Column(
                        children: [
                          _buildUnitChip(
                            label: 'Juz',
                            isSelected: _unit == 'juz',
                            onTap: () => setState(() {
                              _unit = 'juz';
                              if (_quantity > 30) _quantity = 1;
                            }),
                          ),
                          const SizedBox(height: 4),
                          _buildUnitChip(
                            label: 'Ayat',
                            isSelected: _unit == 'ayat',
                            onTap: () => setState(() {
                              _unit = 'ayat';
                              if (_quantity <= 5) _quantity = 50;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pemisah "/"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '/',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF1B432C),
                    ),
                  ),
                ),

                // 2. Selector Periode (Hari / Minggu)
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberStepper(
                        value: _periodValue,
                        min: 1,
                        max: 60,
                        onChanged: (val) => setState(() => _periodValue = val),
                      ),
                      const SizedBox(width: 8),
                      // Period Switcher (Hari / Minggu)
                      Column(
                        children: [
                          _buildUnitChip(
                            label: 'Hari',
                            isSelected: _periodUnit == 'hari',
                            onTap: () => setState(() => _periodUnit = 'hari'),
                          ),
                          const SizedBox(height: 4),
                          _buildUnitChip(
                            label: 'Minggu',
                            isSelected: _periodUnit == 'minggu',
                            onTap: () => setState(() => _periodUnit = 'minggu'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Tombol Setel Target
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF456B2D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  KhatamTargetResult(
                    quantity: _quantity,
                    unit: _unit,
                    periodValue: _periodValue,
                    periodUnit: _periodUnit,
                  ),
                );
              },
              child: Text(
                'Setel Target',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tombol Batal
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEDEBE3),
                foregroundColor: const Color(0xFF4B5563),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberStepper({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (value < max) onChanged(value + 1);
          },
          child: Text(
            '${value < max ? value + 1 : ""}',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
        Text(
          '$value',
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C4C20),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (value > min) onChanged(value - 1);
          },
          child: Text(
            '${value > min ? value - 1 : ""}',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF456B2D) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
