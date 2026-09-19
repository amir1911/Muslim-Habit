import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/verse_read_state.dart';
import 'tajwid_text.dart';

class VerseCard extends StatelessWidget {
  final int ayahNumber;
  final String arabicText;
  final String translation;
  final VerseReadState readState;
  final bool isBookmarked;
  final bool isAudioPlaying;
  final bool showTajwid;
  final bool showTranslation;
  final double arabicFontSize;
  final double translationFontSize;
  final Color cardBackground;
  final Color textColor;
  final Color translationColor;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;
  final VoidCallback? onPlayAudio;

  const VerseCard({
    super.key,
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    required this.readState,
    required this.isBookmarked,
    this.isAudioPlaying = false,
    this.showTajwid = true,
    this.showTranslation = true,
    this.arabicFontSize = 24.0,
    this.translationFontSize = 13.0,
    this.cardBackground = Colors.white,
    this.textColor = const Color(0xFF1E3710),
    this.translationColor = const Color(0xFF4A4A4A),
    required this.onTap,
    required this.onToggleBookmark,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = readState == VerseReadState.read;
    final bool isActive = readState == VerseReadState.active;

    // Background color dengan tint subtle sesuai state
    Color effectiveBg = cardBackground;
    Color borderColor = const Color(0xFFE8EEE0);

    if (isAudioPlaying) {
      effectiveBg = const Color(0xFFE3F2FD); // Lembut biru saat audio play
      borderColor = const Color(0xFF90CAF9);
    } else if (isActive) {
      effectiveBg = const Color(0xFFEFF7E9); // Highlight hijau lembut saat focused
      borderColor = const Color(0xFF8BB750).withValues(alpha: 0.6);
    } else if (isRead) {
      effectiveBg = const Color(0xFFF7FAF4); // Sangat subtle untuk read
      borderColor = const Color(0xFFDDE7D3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: effectiveBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
          left: isActive || isAudioPlaying
              ? BorderSide(
                  color: isAudioPlaying ? const Color(0xFF1976D2) : const Color(0xFF557C2B),
                  width: 3.5,
                )
              : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF557C2B).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF557C2B).withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row info: Read Indicator & Bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Checkmark subtle jika sudah dibaca
                    Row(
                      children: [
                        AnimatedOpacity(
                          opacity: isRead ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF557C2B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF557C2B),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Selesai',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3B6114),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isActive && !isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8BB750).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Sedang Dibaca',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E5410),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Action Buttons (Audio & Bookmark)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onPlayAudio != null) ...[
                          IconButton(
                            icon: Icon(
                              isAudioPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                              color: isAudioPlaying ? const Color(0xFF1976D2) : const Color(0xFF8BB750),
                              size: 20,
                            ),
                            padding: const EdgeInsets.only(right: 8),
                            constraints: const BoxConstraints(),
                            tooltip: isAudioPlaying ? 'Jeda Audio' : 'Dengarkan Suara Ayat',
                            onPressed: onPlayAudio,
                          ),
                        ],
                        // Bookmark button (terpisah tanpa memengaruhi read status)
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            color: isBookmarked ? const Color(0xFF3B6114) : const Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: isBookmarked ? 'Hapus Bookmark' : 'Bookmark Ayat',
                          onPressed: onToggleBookmark,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Arabic Text + Rosette Ayah Number at end
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TajwidText(
                        text: arabicText,
                        fontSize: arabicFontSize,
                        defaultColor: textColor,
                        showTajwid: showTajwid,
                      ),
                    ),
                  ],
                ),

                // Rosette Ayah Number in Arabic style
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                    child: _buildAyahBadge(ayahNumber),
                  ),
                ),

                // Translation (optional toggle)
                if (showTranslation && translation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    translation,
                    style: GoogleFonts.inter(
                      fontSize: translationFontSize,
                      color: translationColor,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge nomor ayat bernuansa ornamen Mushaf
  Widget _buildAyahBadge(int number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E3CB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 11,
            color: Color(0xFF557C2B),
          ),
          const SizedBox(width: 4),
          Text(
            'Ayat $number',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B6114),
            ),
          ),
        ],
      ),
    );
  }
}
