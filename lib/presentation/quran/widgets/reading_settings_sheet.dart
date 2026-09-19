import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tajwid_legend.dart';

class ReadingSettingsSheet extends StatelessWidget {
  final double arabicFontSize;
  final double translationFontSize;
  final bool showTajwid;
  final bool showTranslation;
  final String readerTheme; // 'light', 'sepia', 'dark'
  final double audioSpeed;
  final ValueChanged<double> onArabicFontSizeChanged;
  final ValueChanged<double> onTranslationFontSizeChanged;
  final ValueChanged<bool> onShowTajwidChanged;
  final ValueChanged<bool> onShowTranslationChanged;
  final ValueChanged<String> onReaderThemeChanged;
  final ValueChanged<double> onAudioSpeedChanged;

  const ReadingSettingsSheet({
    super.key,
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.showTajwid,
    required this.showTranslation,
    required this.readerTheme,
    required this.audioSpeed,
    required this.onArabicFontSizeChanged,
    required this.onTranslationFontSizeChanged,
    required this.onShowTajwidChanged,
    required this.onShowTranslationChanged,
    required this.onReaderThemeChanged,
    required this.onAudioSpeedChanged,
  });

  static void show({
    required BuildContext context,
    required double arabicFontSize,
    required double translationFontSize,
    required bool showTajwid,
    required bool showTranslation,
    required String readerTheme,
    required double audioSpeed,
    required ValueChanged<double> onArabicFontSizeChanged,
    required ValueChanged<double> onTranslationFontSizeChanged,
    required ValueChanged<bool> onShowTajwidChanged,
    required ValueChanged<bool> onShowTranslationChanged,
    required ValueChanged<String> onReaderThemeChanged,
    required ValueChanged<double> onAudioSpeedChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReadingSettingsSheet(
        arabicFontSize: arabicFontSize,
        translationFontSize: translationFontSize,
        showTajwid: showTajwid,
        showTranslation: showTranslation,
        readerTheme: readerTheme,
        audioSpeed: audioSpeed,
        onArabicFontSizeChanged: onArabicFontSizeChanged,
        onTranslationFontSizeChanged: onTranslationFontSizeChanged,
        onShowTajwidChanged: onShowTajwidChanged,
        onShowTranslationChanged: onShowTranslationChanged,
        onReaderThemeChanged: onReaderThemeChanged,
        onAudioSpeedChanged: onAudioSpeedChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengaturan Baca',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3710),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── TEMA TAMPILAN (Light, Sepia, Dark) ──
          Text(
            'Tema Halaman',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildThemeChoice(
                context,
                title: 'Sepia (Hangat)',
                value: 'sepia',
                bgColor: const Color(0xFFF9F8F2),
                selected: readerTheme == 'sepia',
              ),
              const SizedBox(width: 8),
              _buildThemeChoice(
                context,
                title: 'Terang',
                value: 'light',
                bgColor: Colors.white,
                selected: readerTheme == 'light',
              ),
              const SizedBox(width: 8),
              _buildThemeChoice(
                context,
                title: 'Gelap',
                value: 'dark',
                bgColor: const Color(0xFF1E1E1E),
                selected: readerTheme == 'dark',
                textColor: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── UKURAN FONT ARAB ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ukuran Teks Arab',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              Text(
                '${arabicFontSize.toInt()} pt',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF557C2B),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              activeTrackColor: const Color(0xFF557C2B),
              thumbColor: const Color(0xFF3B6114),
            ),
            child: Slider(
              value: arabicFontSize,
              min: 18.0,
              max: 38.0,
              divisions: 10,
              onChanged: onArabicFontSizeChanged,
            ),
          ),

          const SizedBox(height: 10),

          // ── UKURAN FONT TERJEMAHAN ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ukuran Teks Terjemahan',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              Text(
                '${translationFontSize.toInt()} pt',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF557C2B),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              activeTrackColor: const Color(0xFF557C2B),
              thumbColor: const Color(0xFF3B6114),
            ),
            child: Slider(
              value: translationFontSize,
              min: 11.0,
              max: 20.0,
              divisions: 9,
              onChanged: onTranslationFontSizeChanged,
            ),
          ),

          const SizedBox(height: 12),

          // ── TOGGLE TAJWID & TRANSLATION ──
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: showTajwid,
            activeColor: const Color(0xFF557C2B),
            title: Text(
              'Tampilkan Tajwid Berwarna',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3710),
              ),
            ),
            subtitle: Text(
              'Membantu membedakan hukum bacaan Al-Qur\'an',
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey[600]),
            ),
            onChanged: onShowTajwidChanged,
          ),

          // Tombol Buka Panduan Tajwid
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                TajwidLegendSheet.show(context);
              },
              icon: const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF557C2B)),
              label: Text(
                'Lihat Panduan Warna Tajwid',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF557C2B),
                ),
              ),
            ),
          ),

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: showTranslation,
            activeColor: const Color(0xFF557C2B),
            title: Text(
              'Tampilkan Terjemahan',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3710),
              ),
            ),
            subtitle: Text(
              'Terjemahan bahasa Indonesia resmi Kemenag',
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey[600]),
            ),
            onChanged: onShowTranslationChanged,
          ),

          const SizedBox(height: 14),

          // ── KECEPATAN AUDIO ──
          Text(
            'Kecepatan Putar Audio',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [0.75, 1.0, 1.25, 1.5].map((speed) {
              final isSel = (audioSpeed - speed).abs() < 0.05;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: isSel ? const Color(0xFF557C2B) : Colors.transparent,
                      side: BorderSide(
                        color: isSel ? const Color(0xFF557C2B) : const Color(0xFFD0DCC4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => onAudioSpeedChanged(speed),
                    child: Text(
                      '${speed}x',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : const Color(0xFF1E3710),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChoice(
    BuildContext context, {
    required String title,
    required String value,
    required Color bgColor,
    required bool selected,
    Color textColor = const Color(0xFF1E3710),
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onReaderThemeChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF557C2B) : const Color(0xFFDDE7D3),
              width: selected ? 2.2 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
