import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SholatTimePickerModal extends StatefulWidget {
  final String initialTime; // e.g. "18:10"
  final bool initialApplyToAllDays;
  final Function(String time, bool applyToAllDays) onApply;

  const SholatTimePickerModal({
    super.key,
    required this.initialTime,
    this.initialApplyToAllDays = true,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialTime,
    bool initialApplyToAllDays = true,
    required Function(String time, bool applyToAllDays) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SholatTimePickerModal(
        initialTime: initialTime,
        initialApplyToAllDays: initialApplyToAllDays,
        onApply: onApply,
      ),
    );
  }

  @override
  State<SholatTimePickerModal> createState() => _SholatTimePickerModalState();
}

class _SholatTimePickerModalState extends State<SholatTimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _applyToAllDays;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _applyToAllDays = widget.initialApplyToAllDays;

    final parts = widget.initialTime.split(':');
    _selectedHour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 18) : 18;
    _selectedMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 10) : 10;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String get _period => _selectedHour >= 12 ? 'PM' : 'AM';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBF6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCD8C5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title: Atur Waktu Pengingat
            Text(
              'Atur Waktu Pengingat',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3E1F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih momen untuk praktik pagi Anda.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8B967D),
              ),
            ),
            const SizedBox(height: 20),

            // Wheel / Picker Area
            Container(
              height: 140,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2E6).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center highlight band
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5D3).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Pickers Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours Wheel (00 - 23)
                      SizedBox(
                        width: 70,
                        child: CupertinoPicker(
                          scrollController: _hourController,
                          itemExtent: 44,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedHour = index);
                          },
                          children: List.generate(24, (i) {
                            final text = i.toString().padLeft(2, '0');
                            final isSelected = i == _selectedHour;
                            return Center(
                              child: Text(
                                text,
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF2C3E1F)
                                      : const Color(0xFFB5BDAB),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Colon separator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          ':',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E1F),
                          ),
                        ),
                      ),

                      // Minutes Wheel (00 - 59)
                      SizedBox(
                        width: 70,
                        child: CupertinoPicker(
                          scrollController: _minuteController,
                          itemExtent: 44,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedMinute = index);
                          },
                          children: List.generate(60, (i) {
                            final text = i.toString().padLeft(2, '0');
                            final isSelected = i == _selectedMinute;
                            return Center(
                              child: Text(
                                text,
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF2C3E1F)
                                      : const Color(0xFFB5BDAB),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // AM / PM Badge indicator
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _period == 'PM'
                                  ? const Color(0xFF557C2B)
                                  : const Color(0xFFE4E0CE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PM',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _period == 'PM'
                                    ? Colors.white
                                    : const Color(0xFF8B967D),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _period == 'AM'
                                  ? const Color(0xFF557C2B)
                                  : const Color(0xFFE4E0CE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AM',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _period == 'AM'
                                    ? Colors.white
                                    : const Color(0xFF8B967D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Terapkan Waktu Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final formattedTime =
                      '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
                  widget.onApply(formattedTime, _applyToAllDays);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF557C2B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Terapkan Waktu',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Batal Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF557C2B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Checkbox: Terapkan untuk semua hari
            GestureDetector(
              onTap: () {
                setState(() => _applyToAllDays = !_applyToAllDays);
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _applyToAllDays
                          ? const Color(0xFF557C2B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _applyToAllDays
                            ? const Color(0xFF557C2B)
                            : const Color(0xFFB5BDAB),
                        width: 1.5,
                      ),
                    ),
                    child: _applyToAllDays
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
          ],
        ),
      ),
    );
  }
}

