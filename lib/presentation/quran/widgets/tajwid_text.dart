import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette warna tajwid standar yang disukai pembaca Al-Qur'an:
/// - Merah = Ghunnah
/// - Hijau = Ikhfa
/// - Biru = Idgham
/// - Kuning / Gold = Mad
/// - Ungu = Qalqalah
/// - Oranye = Iqlab
class TajwidColors {
  static const Color ghunnah = Color(0xFFD32F2F);   // Merah
  static const Color ikhfa = Color(0xFF2E7D32);     // Hijau
  static const Color idgham = Color(0xFF1976D2);    // Biru
  static const Color mad = Color(0xFFD97706);       // Amber/Emas (terlihat jelas di background terang)
  static const Color qalqalah = Color(0xFF7B1FA2);  // Ungu
  static const Color iqlab = Color(0xFFE65100);     // Oranye
}

class TajwidRuleInfo {
  final String name;
  final Color color;
  final String description;

  const TajwidRuleInfo({
    required this.name,
    required this.color,
    required this.description,
  });
}

const List<TajwidRuleInfo> kTajwidRules = [
  TajwidRuleInfo(
    name: 'Ghunnah',
    color: TajwidColors.ghunnah,
    description: 'Nun/Mim bertasydid (نّ / مّ) — dengung 2 harakat',
  ),
  TajwidRuleInfo(
    name: 'Ikhfa',
    color: TajwidColors.ikhfa,
    description: 'Nun sukun/tanwin bertemu 15 huruf ikhfa — dibaca samar',
  ),
  TajwidRuleInfo(
    name: 'Idgham',
    color: TajwidColors.idgham,
    description: 'Nun sukun/tanwin bertemu (ي، ن، م، و، ل، ر) — dileburkan',
  ),
  TajwidRuleInfo(
    name: 'Mad',
    color: TajwidColors.mad,
    description: 'Harakat panjang / mad lazim / mad wajib / mad jaiz',
  ),
  TajwidRuleInfo(
    name: 'Qalqalah',
    color: TajwidColors.qalqalah,
    description: 'Huruf memantul (ق، ط، ب، ج، د) sukun',
  ),
  TajwidRuleInfo(
    name: 'Iqlab',
    color: TajwidColors.iqlab,
    description: 'Nun sukun/tanwin bertemu Ba (ب) — ditukar menjadi Mim',
  ),
];

/// Widget untuk merender teks Al-Qur'an dengan highlighting tajwid berwarna.
class TajwidText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color defaultColor;
  final bool showTajwid;
  final TextAlign textAlign;
  final double lineHeight;

  const TajwidText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
    this.defaultColor = const Color(0xFF1E3710),
    this.showTajwid = true,
    this.textAlign = TextAlign.right,
    this.lineHeight = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTajwid) {
      return Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: defaultColor,
          height: lineHeight,
        ),
      );
    }

    final spans = _parseTajwidSpans(text, fontSize, defaultColor);

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
    );
  }

  /// Tokenisasi teks Arab dan pemberian warna tajwid berdasarkan kaidah fonetik Al-Qur'an
  static List<TextSpan> _parseTajwidSpans(
    String input,
    double fontSize,
    Color baseColor,
  ) {
    final List<TextSpan> spans = [];
    final int len = input.length;
    int i = 0;

    const qalqalahLetters = {'ق', 'ط', 'ب', 'ج', 'د'};
    const ikhfaLetters = {
      'ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'
    };
    const idghamLetters = {'ي', 'ن', 'م', 'و', 'ل', 'ر'};

    // Karakter Unicode Al-Qur'an
    const shaddah = '\u0651';
    const sukun = '\u06DF'; // Small high rounded zero or standard sukun
    const sukunStandard = '\u0652';
    const sukunJazm = '\u06E1';
    const madSign = '\u0653'; // Maddah above
    const daggerAlif = '\u0670'; // Superscript alif
    const smallMeem = '\u06E2'; // Iqlab sign

    final baseStyle = GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: baseColor,
      height: 2.2,
    );

    while (i < len) {
      final char = input[i];

      // 1. Cek Tanda Mad (Maddah ~ atau Dagger Alif panjang)
      if (char == madSign || char == daggerAlif || (i + 1 < len && input[i + 1] == madSign)) {
        int end = i + 1;
        if (i + 1 < len && input[i + 1] == madSign) end = i + 2;
        spans.add(TextSpan(
          text: input.substring(i, end),
          style: baseStyle.copyWith(
            color: TajwidColors.mad,
            fontWeight: FontWeight.w700,
          ),
        ));
        i = end;
        continue;
      }

      // 2. Cek Iqlab (Tanda mim kecil atau Nun/Tanwin diikuti Ba)
      if (char == smallMeem || (char == 'ۢ') || (char == 'ۭ')) {
        spans.add(TextSpan(
          text: char,
          style: baseStyle.copyWith(
            color: TajwidColors.iqlab,
            fontWeight: FontWeight.w700,
          ),
        ));
        i++;
        continue;
      }

      // 3. Cek Ghunnah (Nun/Mim bertasydid: نّ atau مّ)
      if ((char == 'ن' || char == 'م') && i + 1 < len && input[i + 1] == shaddah) {
        int end = i + 2;
        // Ambil harakat berikutnya jika ada
        if (end < len && _isHarakat(input[end])) {
          end++;
        }
        spans.add(TextSpan(
          text: input.substring(i, end),
          style: baseStyle.copyWith(
            color: TajwidColors.ghunnah,
            fontWeight: FontWeight.w700,
          ),
        ));
        i = end;
        continue;
      }

      // 4. Cek Qalqalah (Huruf qalqalah bersukun)
      if (qalqalahLetters.contains(char) &&
          i + 1 < len &&
          (input[i + 1] == sukunStandard ||
              input[i + 1] == sukunJazm ||
              input[i + 1] == sukun)) {
        spans.add(TextSpan(
          text: input.substring(i, i + 2),
          style: baseStyle.copyWith(
            color: TajwidColors.qalqalah,
            fontWeight: FontWeight.w700,
          ),
        ));
        i += 2;
        continue;
      }

      // 5. Cek Ikhfa & Idgham (Nun sukun / Tanwin)
      if (char == 'ن' &&
          i + 1 < len &&
          (input[i + 1] == sukunStandard || input[i + 1] == sukunJazm || input[i + 1] == ' ')) {
        // Cari huruf berikutnya setelah spasi/sukun
        int nextCharIdx = i + 1;
        while (nextCharIdx < len && (_isHarakat(input[nextCharIdx]) || input[nextCharIdx] == ' ')) {
          nextCharIdx++;
        }
        if (nextCharIdx < len) {
          final nextChar = input[nextCharIdx];
          if (ikhfaLetters.contains(nextChar)) {
            // Warnai nun dan huruf ikhfa
            spans.add(TextSpan(
              text: input.substring(i, nextCharIdx + 1),
              style: baseStyle.copyWith(
                color: TajwidColors.ikhfa,
                fontWeight: FontWeight.w700,
              ),
            ));
            i = nextCharIdx + 1;
            continue;
          } else if (idghamLetters.contains(nextChar)) {
            // Warnai idgham
            spans.add(TextSpan(
              text: input.substring(i, nextCharIdx + 1),
              style: baseStyle.copyWith(
                color: TajwidColors.idgham,
                fontWeight: FontWeight.w700,
              ),
            ));
            i = nextCharIdx + 1;
            continue;
          }
        }
      }

      // Default span karakter biasa
      int nextSpecial = i + 1;
      while (nextSpecial < len) {
        final c = input[nextSpecial];
        if (c == madSign ||
            c == daggerAlif ||
            c == smallMeem ||
            c == 'ۢ' ||
            c == 'ۭ' ||
            ((c == 'ن' || c == 'م') &&
                nextSpecial + 1 < len &&
                input[nextSpecial + 1] == shaddah) ||
            (qalqalahLetters.contains(c) &&
                nextSpecial + 1 < len &&
                (input[nextSpecial + 1] == sukunStandard ||
                    input[nextSpecial + 1] == sukunJazm ||
                    input[nextSpecial + 1] == sukun))) {
          break;
        }
        nextSpecial++;
      }

      spans.add(TextSpan(
        text: input.substring(i, nextSpecial),
        style: baseStyle,
      ));
      i = nextSpecial;
    }

    return spans;
  }

  static bool _isHarakat(String char) {
    final code = char.codeUnitAt(0);
    // Arabic diacritics Unicode range 064B - 065F
    return code >= 0x064B && code <= 0x065F;
  }
}
