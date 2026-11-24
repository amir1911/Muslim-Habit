import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kode warna tajwid standar terverifikasi sesuai Mushaf Tajwid Standar (Kemenag / Dar al-Ma'rifah)
class TajwidColors {
  // 1. Ghunnah & Idgham
  static const Color ghunnah = Color(0xFFD81B60);          // Magenta / Pink Tua (نّ / مّ)
  static const Color idghamBighunnah = Color(0xFFE91E63);   // Pink Terang (ي، ن، م، و)
  static const Color idghamBilaghunnah = Color(0xFF00897B); // Teal / Hijau Kebiruan (ل، ر)
  static const Color idghamMimi = Color(0xFFC2185B);        // Deep Rose (مْ bertemu م)

  // 2. Ikhfa & Iqlab
  static const Color ikhfaHaqiqi = Color(0xFFF57C00);       // Oranye / Emas (15 huruf ikhfa)
  static const Color ikhfaSyafawi = Color(0xFFAFB42B);      // Olive / Kuning Kehijauan (مْ bertemu ب)
  static const Color iqlab = Color(0xFF2E7D32);             // Hijau Daun (Nun/Tanwin -> Mim sebelum Ba)

  // 3. Izhar
  static const Color izharHalqi = Color(0xFF0D47A1);        // Biru Tua / Navy (6 huruf tenggorokan)
  static const Color izharSyafawi = Color(0xFF1565C0);      // Biru Kobalt (مْ bertemu selain م & ب)

  // 4. Qalqalah
  static const Color qalqalah = Color(0xFF0288D1);          // Biru Cerah (ق، ط، ب، ج، د sukun)

  // 5. Hukum Mad
  static const Color madThabii = Color(0xFFD97706);         // Amber / Emas (Mad Asli 2 harakat)
  static const Color madWajib = Color(0xFFD32F2F);          // Merah (Mad Wajib Muttashil 4-5 harakat)
  static const Color madJaiz = Color(0xFFFF5722);           // Oranye Kemerahan (Mad Jaiz Munfashil 4-5 harakat)
  static const Color madLazim = Color(0xFFB71C1C);          // Merah Marun Gelap (Mad Lazim 6 harakat)
  static const Color madAridh = Color(0xFFFB8C00);          // Jingga Hangat (Mad 'Aridh Lissukun)

  // 6. Hukum Alif Lam
  static const Color alifLamSyamsiyah = Color(0xFF9E9E9E);  // Abu-abu (Alif Lam lebur / tidak dibaca)
  static const Color alifLamQamariyah = Color(0xFF388E3C);  // Hijau Zaitun (Lam sukun dibaca jelas)

  // Backwards compatibility aliases
  static const Color ikhfa = ikhfaHaqiqi;
  static const Color idgham = idghamBighunnah;
  static const Color mad = madThabii;
}

/// Metadata dan penjelasan untuk setiap aturan tajwid
class TajwidRuleInfo {
  final String name;
  final String category;
  final Color color;
  final String description;
  final String example;

  const TajwidRuleInfo({
    required this.name,
    required this.category,
    required this.color,
    required this.description,
    required this.example,
  });
}

/// Daftar 16 hukum tajwid lengkap untuk legenda dan panduan pengguna
const List<TajwidRuleInfo> kTajwidRules = [
  // 1. Hukum Nun Sukun & Tanwin
  TajwidRuleInfo(
    name: 'Ikhfa Haqiqi',
    category: 'Nun Sukun & Tanwin',
    color: TajwidColors.ikhfaHaqiqi,
    description: 'Nun sukun atau tanwin bertemu salah satu dari 15 huruf ikhfa — dibaca samar antara izhar dan idgham dengan dengung.',
    example: 'أُنزِلَ ، مِن قَبْلِكَ ، يُنفِقُونَ',
  ),
  TajwidRuleInfo(
    name: 'Idgham Bighunnah',
    category: 'Nun Sukun & Tanwin',
    color: TajwidColors.idghamBighunnah,
    description: 'Nun sukun atau tanwin bertemu huruf (ي، ن، م، و) dalam kata terpisah — dileburkan disertai dengung 2 harakat.',
    example: 'مَن يَقُولُ ، هُدًى مِّن رَّبِّهِمْ',
  ),
  TajwidRuleInfo(
    name: 'Idgham Bilaghunnah',
    category: 'Nun Sukun & Tanwin',
    color: TajwidColors.idghamBilaghunnah,
    description: 'Nun sukun atau tanwin bertemu huruf Lam (ل) atau Ra (ر) — dileburkan tanpa dengung.',
    example: 'هُدًى لِّلْمُتَّقِينَ ، مِن رَّبِّهِمْ',
  ),
  TajwidRuleInfo(
    name: 'Iqlab',
    category: 'Nun Sukun & Tanwin',
    color: TajwidColors.iqlab,
    description: 'Nun sukun atau tanwin bertemu huruf Ba (ب) — bunyi nun ditukar menjadi mim disertai dengung (tanda mim kecil ۢ).',
    example: 'مِنۢ بَعْدِ ، عَلِيمٌۢ بِذَاتِ',
  ),
  TajwidRuleInfo(
    name: 'Izhar Halqi',
    category: 'Nun Sukun & Tanwin',
    color: TajwidColors.izharHalqi,
    description: 'Nun sukun atau tanwin bertemu 6 huruf tenggorokan (ء، هـ، ع، ح، غ، خ) — dibaca jelas tanpa dengung.',
    example: 'أَنْعَمْتَ ، مِنْ خَوْفٍ',
  ),

  // 2. Hukum Mim Sukun
  TajwidRuleInfo(
    name: 'Ikhfa Syafawi',
    category: 'Mim Sukun',
    color: TajwidColors.ikhfaSyafawi,
    description: 'Mim sukun bertemu huruf Ba (ب) — dibaca samar di bibir disertai dengung.',
    example: 'تَرْمِيهِم بِحِجَارَةٍ ، يَعْتَصِم بِٱللَّهِ',
  ),
  TajwidRuleInfo(
    name: 'Idgham Mimi (Mutamatsilain)',
    category: 'Mim Sukun',
    color: TajwidColors.idghamMimi,
    description: 'Mim sukun bertemu huruf Mim (م) — dimasukkan ke mim berikutnya dengan dengung 2 harakat.',
    example: 'لَهُم مَّا ، فِي قُلُوبِهِم مَّرَضٌ',
  ),
  TajwidRuleInfo(
    name: 'Izhar Syafawi',
    category: 'Mim Sukun',
    color: TajwidColors.izharSyafawi,
    description: 'Mim sukun bertemu huruf hijaiyah selain Mim dan Ba — dibaca jelas dan tegas di bibir.',
    example: 'هُمْ يُوقِنُونَ ، عَلَيْهِمْ غَيْرِ',
  ),

  // 3. Ghunnah & Qalqalah
  TajwidRuleInfo(
    name: 'Ghunnah Musyaddadah',
    category: 'Ghunnah & Qalqalah',
    color: TajwidColors.ghunnah,
    description: 'Huruf Nun (نّ) atau Mim (مّ) bertasydid — wajib dibaca dengan dengung 2 sampai 3 harakat.',
    example: 'إِنَّ ، عَمَّ ، مِمَّا',
  ),
  TajwidRuleInfo(
    name: 'Qalqalah (Sughra & Kubra)',
    category: 'Ghunnah & Qalqalah',
    color: TajwidColors.qalqalah,
    description: 'Huruf (ق، ط، ب، ج، د) dalam keadaan sukun asli (sughra) atau dihentikan pada waqaf (kubra) — dibaca memantul.',
    example: 'رَزَقْنَٰهُمْ ، قَبْلِكَ ، أَحَدٌ',
  ),

  // 4. Hukum Mad (Panjang Bacaan)
  TajwidRuleInfo(
    name: 'Mad Thabi\'i (Mad Asli)',
    category: 'Hukum Mad',
    color: TajwidColors.madThabii,
    description: 'Harakat fathah diikuti alif, kasrah diikuti ya sukun, dhammah diikuti waw sukun, atau tanda alif tegak — dipanjangkan 2 harakat.',
    example: 'قَالَ ، يَقُولُ ، قِيلَ ، ذَٰلِكَ',
  ),
  TajwidRuleInfo(
    name: 'Mad Wajib Muttashil',
    category: 'Hukum Mad',
    color: TajwidColors.madWajib,
    description: 'Mad thabi\'i bertemu hamzah dalam SATU kata (bertanda layar ~) — wajib dipanjangkan 4 atau 5 harakat.',
    example: 'جَآءَ ، سَوَآءٌ ، السَّمَآءِ',
  ),
  TajwidRuleInfo(
    name: 'Mad Jaiz Munfashil',
    category: 'Hukum Mad',
    color: TajwidColors.madJaiz,
    description: 'Mad thabi\'i di akhir kata bertemu hamzah di AWAL kata berikutnya (bertanda layar ~) — dipanjangkan 4 atau 5 harakat.',
    example: 'بِمَآ أُنزِلَ ، وَمَآ أُنزِلَ ، إِنَّآ أَعْطَيْنَٰكَ',
  ),
  TajwidRuleInfo(
    name: 'Mad Lazim',
    category: 'Hukum Mad',
    color: TajwidColors.madLazim,
    description: 'Mad bertemu huruf bertasydid atau sukun asli, atau huruf Muqatta\'at pembuka surah — wajib dipanjangkan 6 harakat.',
    example: 'الٓمٓ ، الضَّآلِّينَ ، كٓهيعٓصٓ',
  ),
  TajwidRuleInfo(
    name: 'Mad \'Aridh Lissukun',
    category: 'Hukum Mad',
    color: TajwidColors.madAridh,
    description: 'Mad thabi\'i berada tepat sebelum huruf terakhir ayat atau tanda waqaf yang disukunkan karena berhenti — dibaca 2, 4, atau 6 harakat.',
    example: 'ٱلرَّحِيمِ ، ٱلْعَٰلَمِينَ ، يُنفِقُونَ',
  ),

  // 5. Hukum Alif Lam
  TajwidRuleInfo(
    name: 'Alif Lam Syamsiyah',
    category: 'Hukum Alif Lam',
    color: TajwidColors.alifLamSyamsiyah,
    description: 'Alif Lam bertemu huruf syamsiyah bertasydid — Alif Lam tidak dibaca (dileburkan langsung ke huruf berikutnya).',
    example: 'ٱلصَّلَوٰةَ ، ٱلَّذِينَ ، ٱلرَّحِيمِ',
  ),
  TajwidRuleInfo(
    name: 'Alif Lam Qamariyah',
    category: 'Hukum Alif Lam',
    color: TajwidColors.alifLamQamariyah,
    description: 'Alif Lam bertemu huruf qamariyah — Lam sukun dibaca terang dan jelas.',
    example: 'ٱلْحَمْدُ ، ٱلْكِتَٰبُ ، ٱلْغَيْبِ',
  ),
];

/// Tipe internal hukum tajwid untuk penandaan kluster karakter Arab
enum _TajwidType {
  none,
  ghunnah,
  idghamBighunnah,
  idghamBilaghunnah,
  idghamMimi,
  iqlab,
  ikhfaHaqiqi,
  ikhfaSyafawi,
  izharHalqi,
  izharSyafawi,
  qalqalah,
  madThabii,
  madWajib,
  madJaiz,
  madLazim,
  madAridh,
  alifLamSyamsiyah,
  alifLamQamariyah,
}

/// Struktur data untuk satu kluster grafem Arab (huruf konsonan + harakat/tanda baca)
class _ArabicCluster {
  final int startIndex;
  final int endIndex;
  final String text;
  final String baseChar;
  final List<String> diacritics;
  final bool isSpace;
  final bool isWaqf;
  final int wordIndex;

  _ArabicCluster({
    required this.startIndex,
    required this.endIndex,
    required this.text,
    required this.baseChar,
    required this.diacritics,
    this.isSpace = false,
    this.isWaqf = false,
    this.wordIndex = 0,
  });

  bool get hasShaddah => diacritics.contains('\u0651');
  bool get hasSukun => diacritics.any((d) => d == '\u0652' || d == '\u06E1' || d == '\u06DF');
  bool get hasTanwin => diacritics.any((d) =>
      d == '\u064B' || d == '\u064C' || d == '\u064D' ||
      d == '\u0618' || d == '\u0619' || d == '\u061A');
  bool get hasMaddah => diacritics.contains('\u0653') || baseChar == '\u0622' || text.contains('\u0653');
  bool get hasDaggerAlif => diacritics.contains('\u0670');
  bool get hasIqlabMeem =>
      diacritics.contains('\u06E2') || diacritics.contains('\u06ED') ||
      text.contains('ۢ') || text.contains('ۭ');
  bool get hasFathah => diacritics.contains('\u064E');
  bool get hasDammah => diacritics.contains('\u064F');
  bool get hasKasrah => diacritics.contains('\u0650');
  bool get isVocalized => hasFathah || hasDammah || hasKasrah || hasTanwin || hasShaddah || hasSukun;
}

/// Widget untuk merender teks Al-Qur'an dengan highlighting tajwid berwarna per huruf
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
    final baseStyle = GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: defaultColor,
      height: lineHeight,
    ).copyWith(
      locale: const Locale('ar'),
    );

    if (!showTajwid) {
      return Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    final spans = parseTajwidSpans(text, fontSize, defaultColor);

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
    );
  }

  /// Parser statis untuk menghasilkan list TextSpan berwarna sesuai hukum tajwid
  static List<TextSpan> parseTajwidSpans(
    String input,
    double fontSize,
    Color baseColor,
  ) {
    if (input.isEmpty) return [];

    final clusters = _tokenizeClusters(input);
    if (clusters.isEmpty) {
      return [
        TextSpan(
          text: input,
          style: GoogleFonts.amiri(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: baseColor,
            height: 2.2,
          ).copyWith(locale: const Locale('ar')),
        )
      ];
    }

    final rules = _applyTajwidRules(clusters);

    final baseStyle = GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: baseColor,
      height: 2.2,
    ).copyWith(
      locale: const Locale('ar'),
    );

    final List<TextSpan> spans = [];
    String currentText = '';
    Color currentColor = baseColor;

    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      final rule = rules[i];
      final Color clusterColor = _getColorForRule(rule, baseColor);

      if (currentText.isEmpty) {
        currentText = cluster.text;
        currentColor = clusterColor;
      } else if (currentColor == clusterColor) {
        currentText += cluster.text;
      } else {
        spans.add(TextSpan(
          text: currentText,
          style: baseStyle.copyWith(color: currentColor),
        ));
        currentText = cluster.text;
        currentColor = clusterColor;
      }
    }

    if (currentText.isNotEmpty) {
      spans.add(TextSpan(
        text: currentText,
        style: baseStyle.copyWith(color: currentColor),
      ));
    }

    return spans;
  }

  /// Tokenisasi teks Arab ke kluster grafem Unicode
  static List<_ArabicCluster> _tokenizeClusters(String input) {
    final List<_ArabicCluster> list = [];
    int i = 0;
    int currentWordIndex = 0;
    final int len = input.length;

    while (i < len) {
      final char = input[i];

      // Penanganan spasi
      if (_isSpace(char)) {
        int end = i + 1;
        while (end < len && _isSpace(input[end])) {
          end++;
        }
        list.add(_ArabicCluster(
          startIndex: i,
          endIndex: end,
          text: input.substring(i, end),
          baseChar: ' ',
          diacritics: const [],
          isSpace: true,
          wordIndex: currentWordIndex,
        ));
        currentWordIndex++;
        i = end;
        continue;
      }

      // Penanganan tanda waqaf standalone
      if (_isWaqfMark(char)) {
        list.add(_ArabicCluster(
          startIndex: i,
          endIndex: i + 1,
          text: char,
          baseChar: char,
          diacritics: const [],
          isWaqf: true,
          wordIndex: currentWordIndex,
        ));
        i++;
        continue;
      }

      // Konsonan dasar
      final int clusterStart = i;
      final String base = char;
      final List<String> diacritics = [];
      i++;

      // Kumpulkan semua combining marks / harakat yang menempel
      while (i < len && _isCombiningMark(input.codeUnitAt(i))) {
        diacritics.add(input[i]);
        i++;
      }

      list.add(_ArabicCluster(
        startIndex: clusterStart,
        endIndex: i,
        text: input.substring(clusterStart, i),
        baseChar: base,
        diacritics: diacritics,
        wordIndex: currentWordIndex,
      ));
    }

    return list;
  }

  /// Evaluasi 16 aturan tajwid pada urutan kluster
  static List<_TajwidType> _applyTajwidRules(List<_ArabicCluster> clusters) {
    final int n = clusters.length;
    final List<_TajwidType> rules = List.filled(n, _TajwidType.none);

    // Deteksi kluster yang merupakan bagian dari Lafaz Jalalah (الله)
    // agar ligature sakral ini tidak terpecah oleh pewarnaan per huruf
    final Set<int> lafazJalalahWordIndices = {};
    final Map<int, List<int>> wordClustersMap = {};
    for (int i = 0; i < n; i++) {
      if (!clusters[i].isSpace && !clusters[i].isWaqf) {
        wordClustersMap.putIfAbsent(clusters[i].wordIndex, () => []).add(i);
      }
    }
    for (final entry in wordClustersMap.entries) {
      final bare = entry.value.map((idx) => clusters[idx].baseChar).join();
      if (_isLafazJalalahWord(bare)) {
        lafazJalalahWordIndices.add(entry.key);
      }
    }

    const qalqalahLetters = {'ق', 'ط', 'ب', 'ج', 'د'};
    const ikhfaLetters = {
      'ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'
    };
    const halqiLetters = {'ء', 'أ', 'إ', 'آ', 'ؤ', 'ئ', 'ه', 'هـ', 'ع', 'ح', 'غ', 'خ'};
    const syamsiyahLetters = {
      'ت', 'ث', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ل', 'ن'
    };
    const qamariyahLetters = {
      'ء', 'أ', 'إ', 'آ', 'ب', 'غ', 'ح', 'ج', 'ك', 'و', 'خ', 'ف', 'ع', 'ق', 'ي', 'م', 'ه'
    };

    // Helper: cari index non-space / non-waqf berikutnya
    int? nextConsonantIndex(int from) {
      for (int k = from + 1; k < n; k++) {
        if (!clusters[k].isSpace && !clusters[k].isWaqf) return k;
      }
      return null;
    }

    // Helper: cek apakah hamzah
    bool isHamzah(String ch) =>
        ch == 'ء' || ch == 'أ' || ch == 'إ' || ch == 'آ' || ch == 'ؤ' || ch == 'ئ';

    // ─────────────────────────────────────────────────────────────
    // PASS 1: Hukum Alif Lam (Syamsiyah & Qamariyah)
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n - 1; i++) {
      final c1 = clusters[i];
      final c2 = clusters[i + 1];

      // Lewatkan jika termasuk Lafaz Jalalah agar ligature Allah tidak terpotong
      if (lafazJalalahWordIndices.contains(c1.wordIndex)) continue;

      final isAlif = c1.baseChar == 'ا' || c1.baseChar == 'ٱ';
      final isLam = c2.baseChar == 'ل';

      if (isAlif && isLam) {
        final nextIdx = nextConsonantIndex(i + 1);
        if (nextIdx != null) {
          final nextC = clusters[nextIdx];
          // Syamsiyah: huruf setelah Lam bertasydid dan termasuk huruf syamsiyah
          if (syamsiyahLetters.contains(nextC.baseChar) && nextC.hasShaddah) {
            rules[i] = _TajwidType.alifLamSyamsiyah;
            rules[i + 1] = _TajwidType.alifLamSyamsiyah;
          }
          // Qamariyah: Lam bersukun dan huruf setelahnya huruf qamariyah
          else if (c2.hasSukun || qamariyahLetters.contains(nextC.baseChar)) {
            rules[i + 1] = _TajwidType.alifLamQamariyah;
          }
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 2: Hukum Mad Berlapis (Lazim, Wajib, Jaiz)
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final c = clusters[i];
      if (c.hasMaddah) {
        final nextIdx = nextConsonantIndex(i);

        // A. Cek Mad Lazim (diikuti huruf bertasydid atau sukun asli atau muqatta'at)
        bool isLazim = false;
        if (nextIdx != null && clusters[nextIdx].hasShaddah) {
          isLazim = true;
          rules[i] = _TajwidType.madLazim;
          rules[nextIdx] = _TajwidType.madLazim;
        } else if (n <= 12 && (c.baseChar == 'ل' || c.baseChar == 'م' || c.baseChar == 'ص' || c.baseChar == 'ق' || c.baseChar == 'ك' || c.baseChar == 'ع' || c.baseChar == 'س')) {
          // Huruf Muqatta'at (e.g. الٓمٓ, طسٓمٓ, صٓ, قٓ)
          isLazim = true;
          rules[i] = _TajwidType.madLazim;
        }

        if (isLazim) continue;

        // B. Cek Mad Wajib Muttashil vs Mad Jaiz Munfashil
        if (nextIdx != null && isHamzah(clusters[nextIdx].baseChar)) {
          if (clusters[nextIdx].wordIndex == c.wordIndex) {
            // Dalam 1 kata = Mad Wajib Muttashil
            rules[i] = _TajwidType.madWajib;
            rules[nextIdx] = _TajwidType.madWajib;
          } else {
            // Di kata berikutnya = Mad Jaiz Munfashil
            rules[i] = _TajwidType.madJaiz;
            rules[nextIdx] = _TajwidType.madJaiz;
          }
        } else {
          // Default tanda maddah jika hamzah di kata berikut
          rules[i] = _TajwidType.madJaiz;
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 3: Ghunnah Musyaddadah (نّ atau مّ)
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final c = clusters[i];
      if ((c.baseChar == 'ن' || c.baseChar == 'م') && c.hasShaddah) {
        if (rules[i] == _TajwidType.none) {
          rules[i] = _TajwidType.ghunnah;
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 4: Hukum Mim Sukun (Ikhfa Syafawi, Idgham Mimi, Izhar Syafawi)
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final c = clusters[i];
      if (c.baseChar == 'م' && (c.hasSukun || (!c.isVocalized && !c.hasShaddah))) {
        final nextIdx = nextConsonantIndex(i);
        if (nextIdx != null) {
          final nextBase = clusters[nextIdx].baseChar;
          if (nextBase == 'م') {
            rules[i] = _TajwidType.idghamMimi;
            rules[nextIdx] = _TajwidType.idghamMimi;
          } else if (nextBase == 'ب') {
            rules[i] = _TajwidType.ikhfaSyafawi;
            rules[nextIdx] = _TajwidType.ikhfaSyafawi;
          } else if (c.hasSukun && rules[i] == _TajwidType.none) {
            rules[i] = _TajwidType.izharSyafawi;
          }
        } else if (c.hasSukun && rules[i] == _TajwidType.none) {
          rules[i] = _TajwidType.izharSyafawi;
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 5: Hukum Nun Sukun & Tanwin
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final c = clusters[i];
      final bool isNunSukun = c.baseChar == 'ن' && (c.hasSukun || (!c.isVocalized && !c.hasShaddah));
      final bool isTanwinOrIqlab = c.hasTanwin || c.hasIqlabMeem;

      if (isNunSukun || isTanwinOrIqlab) {
        final nextIdx = nextConsonantIndex(i);
        if (nextIdx != null) {
          final nextBase = clusters[nextIdx].baseChar;

          // A. Iqlab (bertemu Ba atau ada tanda mim kecil)
          if (nextBase == 'ب' || c.hasIqlabMeem) {
            rules[i] = _TajwidType.iqlab;
            rules[nextIdx] = _TajwidType.iqlab;
            continue;
          }

          // B. Idgham Bighunnah (bertemu ي، ن، م، و di lain kata)
          if (const {'ي', 'ن', 'م', 'و'}.contains(nextBase)) {
            // Jika dalam satu kata seperti دُنْيَا / بُنْيَان maka Izhar Mutlaq, jangan leburkan
            if (c.wordIndex != clusters[nextIdx].wordIndex || isTanwinOrIqlab) {
              rules[i] = _TajwidType.idghamBighunnah;
              rules[nextIdx] = _TajwidType.idghamBighunnah;
              continue;
            }
          }

          // C. Idgham Bilaghunnah (bertemu ل atau ر)
          if (const {'ل', 'ر'}.contains(nextBase)) {
            rules[i] = _TajwidType.idghamBilaghunnah;
            rules[nextIdx] = _TajwidType.idghamBilaghunnah;
            continue;
          }

          // D. Izhar Halqi (bertemu 6 huruf tenggorokan)
          if (halqiLetters.contains(nextBase)) {
            rules[i] = _TajwidType.izharHalqi;
            continue;
          }

          // E. Ikhfa Haqiqi (bertemu 15 huruf ikhfa)
          if (ikhfaLetters.contains(nextBase)) {
            rules[i] = _TajwidType.ikhfaHaqiqi;
            rules[nextIdx] = _TajwidType.ikhfaHaqiqi;
            continue;
          }
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 6: Qalqalah (ق، ط، ب، ج، د sukun / waqaf)
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final c = clusters[i];
      if (qalqalahLetters.contains(c.baseChar) && rules[i] == _TajwidType.none) {
        // Sughra (sukun di tengah)
        if (c.hasSukun) {
          rules[i] = _TajwidType.qalqalah;
        } else {
          // Kubra (di akhir ayat / waqaf)
          final nextIdx = nextConsonantIndex(i);
          if (nextIdx == null && !c.hasShaddah) {
            rules[i] = _TajwidType.qalqalah;
          }
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 7: Mad 'Aridh Lissukun (Mad sebelum huruf akhir ayat/waqaf)
    // ─────────────────────────────────────────────────────────────
    int? lastConsonant;
    for (int k = n - 1; k >= 0; k--) {
      if (!clusters[k].isSpace && !clusters[k].isWaqf) {
        lastConsonant = k;
        break;
      }
    }

    if (lastConsonant != null && lastConsonant > 0) {
      final prevIdx = lastConsonant - 1;
      final prevC = clusters[prevIdx];
      // Cek apakah huruf sebelum konsonan akhir adalah Waw, Ya, Alif, atau Dagger Alif
      final isMadChar = prevC.baseChar == 'و' ||
          prevC.baseChar == 'ي' ||
          prevC.baseChar == 'ى' ||
          prevC.baseChar == 'ا' ||
          prevC.hasDaggerAlif;

      if (isMadChar && rules[prevIdx] == _TajwidType.none) {
        rules[prevIdx] = _TajwidType.madAridh;
        if (rules[lastConsonant] == _TajwidType.none) {
          rules[lastConsonant] = _TajwidType.madAridh;
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PASS 8: Mad Thabi'i (Mad Asli 2 Harakat)
    // ─────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      if (rules[i] != _TajwidType.none) continue;
      final c = clusters[i];

      // Dagger alif (Alif Khanjariyah) e.g. ذَٰلِكَ ، مَٰلِكِ
      if (c.hasDaggerAlif && !c.hasMaddah) {
        rules[i] = _TajwidType.madThabii;
        continue;
      }

      // Alif setelah fathah
      if (c.baseChar == 'ا' && !c.hasMaddah && !c.isVocalized && i > 0) {
        final prevC = clusters[i - 1];
        if (prevC.hasFathah) {
          rules[i] = _TajwidType.madThabii;
          continue;
        }
      }

      // Ya setelah kasrah
      if ((c.baseChar == 'ي' || c.baseChar == 'ى') && !c.hasMaddah && !c.isVocalized && i > 0) {
        final prevC = clusters[i - 1];
        if (prevC.hasKasrah) {
          rules[i] = _TajwidType.madThabii;
          continue;
        }
      }

      // Waw setelah dhammah
      if (c.baseChar == 'و' && !c.hasMaddah && !c.isVocalized && i > 0) {
        final prevC = clusters[i - 1];
        if (prevC.hasDammah) {
          rules[i] = _TajwidType.madThabii;
          continue;
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // PROTEKSI AKHIR: Lafaz Jalalah (الله)
    // ─────────────────────────────────────────────────────────────
    // Pastikan seluruh kluster dalam kata Lafaz Jalalah berstatus _TajwidType.none
    // sehingga tergabung dalam satu TextSpan utuh tanpa terpecah sama sekali.
    for (int i = 0; i < n; i++) {
      if (lafazJalalahWordIndices.contains(clusters[i].wordIndex)) {
        rules[i] = _TajwidType.none;
      }
    }

    return rules;
  }

  /// Cek apakah kata merupakan Lafaz Jalalah (Allah) dalam berbagai variasi
  static bool _isLafazJalalahWord(String bareWord) {
    final norm = bareWord
        .replaceAll('ٱ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('\u0670', '')
        .replaceAll('\u0671', 'ا')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '');

    return norm == 'الله' ||
        norm == 'لله' ||
        norm == 'بالله' ||
        norm == 'والله' ||
        norm == 'فلله' ||
        norm == 'ولله' ||
        norm == 'فالله' ||
        norm == 'تالله' ||
        norm == 'اللهم' ||
        norm == 'واللهم' ||
        norm == 'باللهم' ||
        (norm.length >= 4 && norm.endsWith('الله')) ||
        (norm.length >= 3 && norm.endsWith('لله'));
  }

  /// Pemetaan tipe tajwid ke warna representatif
  static Color _getColorForRule(_TajwidType rule, Color defaultColor) {
    switch (rule) {
      case _TajwidType.ghunnah:
        return TajwidColors.ghunnah;
      case _TajwidType.idghamBighunnah:
        return TajwidColors.idghamBighunnah;
      case _TajwidType.idghamBilaghunnah:
        return TajwidColors.idghamBilaghunnah;
      case _TajwidType.idghamMimi:
        return TajwidColors.idghamMimi;
      case _TajwidType.iqlab:
        return TajwidColors.iqlab;
      case _TajwidType.ikhfaHaqiqi:
        return TajwidColors.ikhfaHaqiqi;
      case _TajwidType.ikhfaSyafawi:
        return TajwidColors.ikhfaSyafawi;
      case _TajwidType.izharHalqi:
        return TajwidColors.izharHalqi;
      case _TajwidType.izharSyafawi:
        return TajwidColors.izharSyafawi;
      case _TajwidType.qalqalah:
        return TajwidColors.qalqalah;
      case _TajwidType.madThabii:
        return TajwidColors.madThabii;
      case _TajwidType.madWajib:
        return TajwidColors.madWajib;
      case _TajwidType.madJaiz:
        return TajwidColors.madJaiz;
      case _TajwidType.madLazim:
        return TajwidColors.madLazim;
      case _TajwidType.madAridh:
        return TajwidColors.madAridh;
      case _TajwidType.alifLamSyamsiyah:
        return TajwidColors.alifLamSyamsiyah;
      case _TajwidType.alifLamQamariyah:
        return TajwidColors.alifLamQamariyah;
      case _TajwidType.none:
        return defaultColor;
    }
  }

  static bool _isSpace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r' || char == '\u00A0';
  }

  static bool _isWaqfMark(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x06D6 && code <= 0x06DC) || code == 0x06DE || code == 0x06E9;
  }

  static bool _isCombiningMark(int code) {
    return (code >= 0x0610 && code <= 0x061A) ||
        (code >= 0x064B && code <= 0x065F) ||
        code == 0x0670 ||
        (code >= 0x06D6 && code <= 0x06DC) ||
        (code >= 0x06DF && code <= 0x06E4) ||
        (code >= 0x06E7 && code <= 0x06E8) ||
        (code >= 0x06EA && code <= 0x06ED);
  }
}
