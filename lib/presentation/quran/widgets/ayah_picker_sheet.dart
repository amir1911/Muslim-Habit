import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AyahPickerSheet extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  final int totalAyahs;
  final int selectedAyahNumber;
  final ValueChanged<int> onSelectAyah;

  const AyahPickerSheet({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.totalAyahs,
    required this.selectedAyahNumber,
    required this.onSelectAyah,
  });

  static Future<int?> show(
    BuildContext context, {
    required int surahNumber,
    required String surahName,
    required int totalAyahs,
    required int selectedAyahNumber,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AyahPickerSheet(
        surahNumber: surahNumber,
        surahName: surahName,
        totalAyahs: totalAyahs,
        selectedAyahNumber: selectedAyahNumber,
        onSelectAyah: (ayah) => Navigator.of(ctx).pop(ayah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Nomor Ayat',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '$surahName (Total $totalAyahs Ayat)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Grid Nomor Ayat
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: totalAyahs,
              itemBuilder: (ctx, idx) {
                final ayahNum = idx + 1;
                final isSelected = (ayahNum == selectedAyahNumber);

                return InkWell(
                  onTap: () => onSelectAyah(ayahNum),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF518427) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF518427) : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$ayahNum',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
