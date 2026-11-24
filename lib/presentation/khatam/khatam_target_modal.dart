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

/// Modal Bottom Sheet Picker Target (TargetKhatamBottomSheet)
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

typedef TargetKhatamBottomSheet = KhatamTargetModal;

class _KhatamTargetModalState extends State<KhatamTargetModal> {
  late int _quantity;
  late String _unit; // 'juz' atau 'ayat'
  late int _periodValue;
  late String _periodUnit; // 'hari' atau 'minggu'

  late FixedExtentScrollController _quantityScrollController;
  late FixedExtentScrollController _periodScrollController;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _unit = widget.initialUnit.toLowerCase();
    _periodValue = widget.initialPeriodValue;
    _periodUnit = widget.initialPeriodUnit.toLowerCase();

    final initialQIndex = _unit == 'juz'
        ? (_quantity - 1).clamp(0, 29)
        : (_quantity ~/ 10 - 1).clamp(0, 30);
    final initialPIndex = (_periodValue - 1).clamp(0, 59);

    _quantityScrollController = FixedExtentScrollController(initialItem: initialQIndex);
    _periodScrollController = FixedExtentScrollController(initialItem: initialPIndex);
  }

  @override
  void dispose() {
    _quantityScrollController.dispose();
    _periodScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle atas
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

            // ── AREA PICKER (KOTAK HIJAU MUDA LEMBUT #EBF2E1) ──
            Container(
              height: 130,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF2E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // 1. Selector Angka & Unit Kuantitas (Kiri)
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Wheel Scroll Angka Kuantitas
                        SizedBox(
                          width: 48,
                          child: ListWheelScrollView.useDelegate(
                            controller: _quantityScrollController,
                            itemExtent: 44,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.003,
                            diameterRatio: 1.5,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _quantity = _unit == 'juz' ? (index + 1) : ((index + 1) * 10);
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final val = _unit == 'juz' ? (index + 1) : ((index + 1) * 10);
                                final isSelected = val == _quantity;
                                return Center(
                                  child: Text(
                                    '$val',
                                    style: GoogleFonts.inter(
                                      fontSize: isSelected ? 34 : 16,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF264E0B)
                                          : const Color(0xFFA0AF95),
                                    ),
                                  ),
                                );
                              },
                              childCount: _unit == 'juz' ? 30 : 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Unit Switcher Vertikal (Juz / Ayat)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildUnitChip(
                              label: 'Juz',
                              isSelected: _unit == 'juz',
                              onTap: () {
                                setState(() {
                                  _unit = 'juz';
                                  _quantity = 1;
                                  _quantityScrollController.jumpToItem(0);
                                });
                              },
                            ),
                            const SizedBox(height: 6),
                            _buildUnitChip(
                              label: 'Ayat',
                              isSelected: _unit == 'ayat',
                              onTap: () {
                                setState(() {
                                  _unit = 'ayat';
                                  _quantity = 20;
                                  _quantityScrollController.jumpToItem(1);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tanda Garis Miring Tebal "/" di Tengah
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '/',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF264E0B),
                      ),
                    ),
                  ),

                  // 2. Selector Angka & Unit Periode (Kanan)
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Wheel Scroll Angka Periode
                        SizedBox(
                          width: 48,
                          child: ListWheelScrollView.useDelegate(
                            controller: _periodScrollController,
                            itemExtent: 44,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.003,
                            diameterRatio: 1.5,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _periodValue = index + 1;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final val = index + 1;
                                final isSelected = val == _periodValue;
                                return Center(
                                  child: Text(
                                    '$val',
                                    style: GoogleFonts.inter(
                                      fontSize: isSelected ? 34 : 16,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF264E0B)
                                          : const Color(0xFFA0AF95),
                                    ),
                                  ),
                                );
                              },
                              childCount: 60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Periode Switcher Vertikal (Hari / Minggu)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildUnitChip(
                              label: 'Hari',
                              isSelected: _periodUnit == 'hari',
                              onTap: () => setState(() => _periodUnit = 'hari'),
                            ),
                            const SizedBox(height: 6),
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

            // ── TOMBOL AKSI: SETEL TARGET (HIJAU TUA) ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386616),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
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

            // ── TOMBOL AKSI: BATAL (ABU-ABU KEHIJAUAN) ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2E7D7),
                  foregroundColor: const Color(0xFF264E0B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF264E0B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF386616) : const Color(0xFFE4ECE0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
