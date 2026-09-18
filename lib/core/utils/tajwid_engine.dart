// Tajwid Rule Engine — mendeteksi aturan tajwid dari teks Arab
// dan menghitung skor berdasarkan kecocokan transkripsi vs teks asli

class TajwidRule {
  final String name;
  final String arabicSnippet;
  final String explanation;
  final TajwidStatus status;

  const TajwidRule({
    required this.name,
    required this.arabicSnippet,
    required this.explanation,
    this.status = TajwidStatus.correct,
  });
}

enum TajwidStatus { correct, needsImprovement }

class TajwidAnalysisResult {
  final int accuracy;
  final int tajwidBenar;
  final int perbaikan;
  final List<TajwidRule> rules;

  const TajwidAnalysisResult({
    required this.accuracy,
    required this.tajwidBenar,
    required this.perbaikan,
    required this.rules,
  });
}

class TajwidEngine {
  // Karakter huruf qalqalah
  static const _qalqalahLetters = ['ق', 'ط', 'ب', 'ج', 'د'];

  // Harakat/sukun Unicode
  static const _sukun = '\u06E1';
  static const _shadda = '\u0651';
  static const _tanwinFath = '\u064B';
  static const _tanwinKasr = '\u064D';
  static const _tanwinDamm = '\u064C';

  // Huruf Idgham
  static const _idghamLetters = ['ي', 'ن', 'م', 'و', 'ل', 'ر'];

  // Huruf Ikhfa
  static const _ikhfaLetters = ['ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'];

  /// Analisis aturan tajwid dalam satu ayat Arab
  static List<TajwidRule> detectRules(String arabicText) {
    final rules = <TajwidRule>[];

    // 1. Deteksi Qalqalah (huruf qalqalah + sukun)
    for (int i = 0; i < arabicText.length - 1; i++) {
      final ch = arabicText[i];
      if (_qalqalahLetters.contains(ch)) {
        // Cek apakah setelahnya ada sukun atau di akhir kata
        final next = arabicText[i + 1];
        if (next == _sukun || next == ' ') {
          rules.add(TajwidRule(
            name: 'Qalqalah',
            arabicSnippet: ch + (next == _sukun ? _sukun : ''),
            explanation: 'Huruf "$ch" adalah huruf Qalqalah, dibaca memantul.',
            status: TajwidStatus.correct,
          ));
        }
      }
    }

    // 2. Deteksi Ghunnah (ن atau م + syaddah)
    for (int i = 0; i < arabicText.length - 1; i++) {
      final ch = arabicText[i];
      if ((ch == 'ن' || ch == 'م') && i + 1 < arabicText.length && arabicText[i + 1] == _shadda) {
        rules.add(TajwidRule(
          name: 'Ghunnah',
          arabicSnippet: ch + _shadda,
          explanation: '"$ch" bertasydid — wajib dibaca dengan dengung 2 harakat.',
          status: TajwidStatus.correct,
        ));
      }
    }

    // 3. Deteksi Mad (alif/waw/ya setelah harakat panjang)
    final madPattern = RegExp(r'[\u064E][\u0627]|[\u064F][\u0648]|[\u0650][\u064A]');
    final madMatches = madPattern.allMatches(arabicText);
    if (madMatches.isNotEmpty) {
      rules.add(TajwidRule(
        name: 'Mad Thabii',
        arabicSnippet: madMatches.first.group(0) ?? 'ا',
        explanation: 'Mad Thabii — dipanjangkan 2 harakat.',
        status: TajwidStatus.correct,
      ));
    }

    // 4. Deteksi Ikhfa (tanwin/nun sukun + huruf ikhfa)
    for (int i = 0; i < arabicText.length - 1; i++) {
      final ch = arabicText[i];
      final next = arabicText[i + 1];
      final isNunSukun = ch == 'ن' && next == _sukun;
      final isTanwin = next == _tanwinFath || next == _tanwinKasr || next == _tanwinDamm;

      if (isNunSukun || isTanwin) {
        // Cek huruf setelahnya
        final afterIndex = isNunSukun ? i + 2 : i + 2;
        if (afterIndex < arabicText.length) {
          final afterChar = arabicText[afterIndex];
          if (_ikhfaLetters.contains(afterChar)) {
            rules.add(TajwidRule(
              name: 'Ikhfa',
              arabicSnippet: ch + (isNunSukun ? _sukun : '') + afterChar,
              explanation: 'Nun sukun/tanwin bertemu "$afterChar" — dibaca samar (Ikhfa).',
              status: TajwidStatus.correct,
            ));
          }
        }
      }
    }

    // 5. Deteksi Idgham
    for (int i = 0; i < arabicText.length - 2; i++) {
      final ch = arabicText[i];
      if (ch == 'ن') {
        final next = arabicText[i + 1];
        if (next == _sukun || next == _tanwinFath) {
          final afterIndex = i + 2;
          if (afterIndex < arabicText.length) {
            final afterChar = arabicText[afterIndex];
            if (_idghamLetters.contains(afterChar)) {
              rules.add(TajwidRule(
                name: 'Idgham Bighunnah',
                arabicSnippet: 'ن$next$afterChar',
                explanation: 'Nun sukun/tanwin bertemu "$afterChar" — dimasukkan dengan dengung.',
                status: TajwidStatus.correct,
              ));
            }
          }
        }
      }
    }

    return rules;
  }

  /// Hitung akurasi berdasarkan Levenshtein distance antara transkripsi dan teks asli
  static int calculateAccuracy(String original, String transcribed) {
    if (transcribed.isEmpty) return 0;

    // Bersihkan tanda baca dan harakat untuk perbandingan yang lebih adil
    final cleanOriginal = _removeHarakat(original);
    final cleanTranscribed = _removeHarakat(transcribed);

    final distance = _levenshteinDistance(cleanOriginal, cleanTranscribed);
    final maxLen = cleanOriginal.length > cleanTranscribed.length
        ? cleanOriginal.length
        : cleanTranscribed.length;

    if (maxLen == 0) return 100;

    final similarity = ((maxLen - distance) / maxLen * 100).round();
    return similarity.clamp(0, 100);
  }

  static String _removeHarakat(String text) {
    // Hapus harakat/tanda baca Arab (Unicode range U+064B - U+065F)
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\s]'), '');
  }

  static int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) { dp[i][0] = i; }
    for (int j = 0; j <= n; j++) { dp[0][j] = j; }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce((a, b) => a < b ? a : b);
        }
      }
    }
    return dp[m][n];
  }

  /// Analisis lengkap setelah rekam selesai
  static TajwidAnalysisResult analyze(String arabicText, String transcribed, int rawAccuracy) {
    final rules = detectRules(arabicText);

    // Tentukan beberapa rule yang "perlu perbaikan" berdasarkan akurasi
    final perbaikanCount = rawAccuracy < 80
        ? (rules.length * 0.3).ceil()
        : rawAccuracy < 90
            ? 1
            : 0;

    final rulesWithStatus = rules.asMap().entries.map((e) {
      return TajwidRule(
        name: e.value.name,
        arabicSnippet: e.value.arabicSnippet,
        explanation: e.value.explanation,
        status: e.key < perbaikanCount ? TajwidStatus.needsImprovement : TajwidStatus.correct,
      );
    }).toList();

    return TajwidAnalysisResult(
      accuracy: rawAccuracy,
      tajwidBenar: rules.length - perbaikanCount,
      perbaikan: perbaikanCount,
      rules: rulesWithStatus,
    );
  }
}
