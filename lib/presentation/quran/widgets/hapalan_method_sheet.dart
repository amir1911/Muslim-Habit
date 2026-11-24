import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum HafalanMethodType {
  perAyat,      // Satu ayat bertahap (default)
  beberapaAyat, // Rentang ayat (misal: 1-5)
  perSurah,     // Seluruh surah
}

class HafalanMethodSheet extends StatefulWidget {
  final HafalanMethodType initialMethod;
  final int totalAyahsInSurah;
  final int currentStartAyah;
  final int currentEndAyah;
  final Function(HafalanMethodType method, int startAyah, int endAyah) onApply;

  const HafalanMethodSheet({
    super.key,
    required this.initialMethod,
    required this.totalAyahsInSurah,
    required this.currentStartAyah,
    required this.currentEndAyah,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required HafalanMethodType initialMethod,
    required int totalAyahsInSurah,
    required int currentStartAyah,
    required int currentEndAyah,
    required Function(HafalanMethodType method, int startAyah, int endAyah) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HafalanMethodSheet(
        initialMethod: initialMethod,
        totalAyahsInSurah: totalAyahsInSurah,
        currentStartAyah: currentStartAyah,
        currentEndAyah: currentEndAyah,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HafalanMethodSheet> createState() => _HafalanMethodSheetState();
}

class _HafalanMethodSheetState extends State<HafalanMethodSheet> {
  late HafalanMethodType _selectedMethod;
  late int _startAyah;
  late int _endAyah;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
    _startAyah = widget.currentStartAyah.clamp(1, widget.totalAyahsInSurah);
    _endAyah = widget.currentEndAyah.clamp(_startAyah, widget.totalAyahsInSurah);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              // Title bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Metode Hafalan',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3710),
                    ),
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

              // 1. OPSI: PER AYAT (DEFAULT)
              _buildMethodCard(
                type: HafalanMethodType.perAyat,
                title: 'Hafalan Per Ayat (Direkomendasikan)',
                description: 'Menghafal satu per satu ayat secara bertahap dan teratur.',
                icon: Icons.filter_1_rounded,
              ),
              const SizedBox(height: 10),

              // 2. OPSI: BEBERAPA AYAT (RENTANG)
              _buildMethodCard(
                type: HafalanMethodType.beberapaAyat,
                title: 'Hafalan Beberapa Ayat',
                description: 'Tentukan rentang ayat target (misal: Ayat 1–5).',
                icon: Icons.format_list_numbered_rounded,
              ),

              // Pengaturan rentang ayat jika memilih beberapa ayat
              if (_selectedMethod == HafalanMethodType.beberapaAyat) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD3E0C4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Dari Ayat
                      Column(
                        children: [
                          Text(
                            'Dari Ayat',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFC7D6B8)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _startAyah,
                                items: List.generate(
                                  widget.totalAyahsInSurah,
                                  (idx) => DropdownMenuItem(
                                    value: idx + 1,
                                    child: Text(
                                      'Ayat ${idx + 1}',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _startAyah = val;
                                      if (_endAyah < _startAyah) {
                                        _endAyah = _startAyah;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF518427)),

                      // Sampai Ayat
                      Column(
                        children: [
                          Text(
                            'Sampai Ayat',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFC7D6B8)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _endAyah,
                                items: List.generate(
                                  widget.totalAyahsInSurah - _startAyah + 1,
                                  (idx) {
                                    final ayahVal = _startAyah + idx;
                                    return DropdownMenuItem(
                                      value: ayahVal,
                                      child: Text(
                                        'Ayat $ayahVal',
                                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    );
                                  },
                                ),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _endAyah = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // 3. OPSI: PER SURAH
              _buildMethodCard(
                type: HafalanMethodType.perSurah,
                title: 'Hafalan Per Surah',
                description: 'Uji hafalan seluruh ayat dalam surah ini (1–${widget.totalAyahsInSurah}).',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(height: 18),

              // Tombol Terapkan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (_selectedMethod == HafalanMethodType.perSurah) {
                      widget.onApply(_selectedMethod, 1, widget.totalAyahsInSurah);
                    } else if (_selectedMethod == HafalanMethodType.beberapaAyat) {
                      widget.onApply(_selectedMethod, _startAyah, _endAyah);
                    } else {
                      widget.onApply(_selectedMethod, _startAyah, _startAyah);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF518427),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Terapkan Metode',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
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

  Widget _buildMethodCard({
    required HafalanMethodType type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F7EC) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF518427) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF518427) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF1E3710) : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF518427) : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
