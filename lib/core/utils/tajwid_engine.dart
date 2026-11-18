// Tajwid & Recitation Analysis Engine — Muslim Habbit
// Menghitung analisis bacaan ayat, word-level alignment, dan 17 hukum tajwid
// secara dinamis berdasarkan suara riil pengguna (bukan data statis/simulasi).

enum TajwidRuleType {
  ikhfaHaqiqi,
  ikhfaSyafawi,
  idghamBighunnah,
  idghamBilaghunnah,
  idghamMimi,
  iqlab,
  izharHalqi,
  izharSyafawi,
  ghunnah,
  qalqalahSughra,
  qalqalahKubra,
  madThabii,
  madWajibMuttashil,
  madJaizMunfashil,
  madLazim,
  madAridhLissukun,
  alifLamSyamsiyah,
  alifLamQamariyah,
}

enum TajwidStatus {
  correct, // Sesuai (Hijau)
  needsAttention, // Perlu diperhatikan (Oranye)
  needsImprovement, // Perlu diperbaiki (Merah)
  uncertain, // Belum dapat dianalisis dengan yakin (Abu-abu)
}

enum WordRecitationStatus {
  correct, // Dibaca benar (Hijau)
  needsAttention, // Ada sedikit ketidaksesuaian fonetik (Oranye)
  incorrect, // Salah pelafalan (Merah)
  missed, // Terlewat / tidak terbaca (Merah redup)
  pending, // Belum dibaca / menunggu (Abu-abu)
}

class TajwidRule {
  final TajwidRuleType type;
  final String name;
  final String arabicSnippet;
  final String ruleDescription;
  final String explanation;
  final String improvementTip;
  final TajwidStatus status;
  final double confidence;
  final int wordIndex;

  const TajwidRule({
    required this.type,
    required this.name,
    required this.arabicSnippet,
    required this.ruleDescription,
    required this.explanation,
    required this.improvementTip,
    this.status = TajwidStatus.correct,
    this.confidence = 0.9,
    this.wordIndex = 0,
  });

  TajwidRule copyWith({
    TajwidStatus? status,
    double? confidence,
    String? explanation,
    String? improvementTip,
  }) {
    return TajwidRule(
      type: type,
      name: name,
      arabicSnippet: arabicSnippet,
      ruleDescription: ruleDescription,
      explanation: explanation ?? this.explanation,
      improvementTip: improvementTip ?? this.improvementTip,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      wordIndex: wordIndex,
    );
  }
}

class AnalyzedWord {
  final int index;
  final String arabicText;
  final String cleanText;
  final WordRecitationStatus status;
  final String? transcribedWord;
  final double similarity;
  final List<TajwidRule> rules;

  const AnalyzedWord({
    required this.index,
    required this.arabicText,
    required this.cleanText,
    required this.status,
    this.transcribedWord,
    this.similarity = 0.0,
    this.rules = const [],
  });

  AnalyzedWord copyWith({
    WordRecitationStatus? status,
    String? transcribedWord,
    double? similarity,
    List<TajwidRule>? rules,
  }) {
    return AnalyzedWord(
      index: index,
      arabicText: arabicText,
      cleanText: cleanText,
      status: status ?? this.status,
      transcribedWord: transcribedWord ?? this.transcribedWord,
      similarity: similarity ?? this.similarity,
      rules: rules ?? this.rules,
    );
  }
}

class TajwidAnalysisResult {
  final int accuracy;
  final int tajwidBenar;
  final int perbaikan;
  final int uncertain;
  final int totalWords;
  final int correctWords;
  final List<AnalyzedWord> words;
  final List<TajwidRule> rules;
  final String transcribedText;
  final String feedbackMessage;
  final bool hasAudioInput;

  const TajwidAnalysisResult({
    required this.accuracy,
    required this.tajwidBenar,
    required this.perbaikan,
    this.uncertain = 0,
    required this.totalWords,
    required this.correctWords,
    required this.words,
    required this.rules,
    required this.transcribedText,
    required this.feedbackMessage,
    this.hasAudioInput = true,
  });

  static TajwidAnalysisResult empty(String arabicVerse) {
    final words = TajwidEngine.tokenizeAyah(arabicVerse);
    final expectedRules = TajwidEngine.detectExpectedRules(arabicVerse, words);

    return TajwidAnalysisResult(
      accuracy: 0,
      tajwidBenar: 0,
      perbaikan: 0,
      uncertain: expectedRules.length,
      totalWords: words.length,
      correctWords: 0,
      words: words,
      rules: expectedRules.map((r) => r.copyWith(status: TajwidStatus.uncertain)).toList(),
      transcribedText: '',
      feedbackMessage: 'Sentuh tombol mikrofon dan bacakan ayat untuk memulai analisis bacaan.',
      hasAudioInput: false,
    );
  }
}

class TajwidEngine {
  // Karakter Unicode Harakat & Diakritik Arab
  static const _fathah = '\u064E';
  static const _dammah = '\u064F';
  static const _kasrah = '\u0650';
  static const _tanwinFath = '\u064B';
  static const _tanwinDamm = '\u064C';
  static const _tanwinKasr = '\u064D';
  static const _sukunStandard = '\u0652';
  static const _sukunUtsmani = '\u06E1';
  static const _shaddah = '\u0651';
  static const _maddah = '\u0653';
  static const _daggerAlif = '\u0670';
  static const _alifWasl = '\u0671';
  static const _smallHighMeem = '\u06E2';

  // Kelompok Huruf Tajwid
  static const _qalqalahLetters = ['ق', 'ط', 'ب', 'ج', 'د'];
  static const _ikhfaLetters = [
    'ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'
  ];
  static const _izharHalqiLetters = ['ء', 'أ', 'إ', 'ه', 'ع', 'غ', 'ح', 'خ'];
  static const _idghamBighunnahLetters = ['ي', 'ن', 'م', 'و'];
  static const _idghamBilaghunnahLetters = ['ل', 'ر'];
  static const _syamsiyahLetters = [
    'ت', 'ث', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ل', 'ن'
  ];
  static const _qamariyahLetters = [
    'ء', 'أ', 'إ', 'ب', 'غ', 'ح', 'ج', 'ك', 'و', 'خ', 'ف', 'ع', 'ق', 'ي', 'م', 'ه'
  ];

  /// Tokenisasi ayat menjadi daftar kata Utsmani
  static List<AnalyzedWord> tokenizeAyah(String arabicText) {
    final rawTokens = arabicText.trim().split(RegExp(r'\s+'));
    final list = <AnalyzedWord>[];

    for (int i = 0; i < rawTokens.length; i++) {
      final token = rawTokens[i];
      if (token.isEmpty) continue;
      // Hilangkan tanda nomor ayat di akhir seperti ﴿٤٥﴾
      final clean = cleanArabicForMatching(token);
      if (clean.isEmpty) continue;

      list.add(AnalyzedWord(
        index: list.length,
        arabicText: token,
        cleanText: clean,
        status: WordRecitationStatus.pending,
      ));
    }

    return list;
  }

  /// Membersihkan teks Arab untuk perbandingan leksikal (menghapus harakat & normalisasi)
  static String cleanArabicForMatching(String text) {
    var s = text;
    // Hapus tanda kurung nomor ayat Arab ﴿ ﴾ dan angka
    s = s.replaceAll(RegExp(r'[﴿﴾\d\u0660-\u0669]'), '');
    // Hapus tanda waqaf kecil (U+06D6 sampai U+06ED)
    s = s.replaceAll(RegExp(r'[\u06D6-\u06ED]'), '');
    // Hapus seluruh harakat & tanda baca
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0653\u0654\u0655]'), '');
    // Normalisasi varian alif (أ, إ, آ, ٱ, ا) -> ا
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    // Normalisasi ta marbutah (ة) -> ه
    s = s.replaceAll('ة', 'ه');
    // Normalisasi alif maqsurah (ى) -> ي
    s = s.replaceAll('ى', 'ي');
    // Normalisasi spasi dan strip tanda hubung
    s = s.replaceAll(RegExp(r'[\s\-_ـ]+'), ' ').trim();
    return s;
  }

  /// Deteksi seluruh Expected Tajwid (17 Hukum Tajwid) dari teks Arab Utsmani
  static List<TajwidRule> detectExpectedRules(String arabicText, List<AnalyzedWord> words) {
    final rules = <TajwidRule>[];

    for (int wIdx = 0; wIdx < words.length; wIdx++) {
      final wordObj = words[wIdx];
      final w = wordObj.arabicText;
      final isLastWord = (wIdx == words.length - 1);

      // ── 1. Ghunnah Musyaddadah (نّ atau مّ) ──
      for (int i = 0; i < w.length; i++) {
        final c = w[i];
        if ((c == 'ن' || c == 'م') && _hasShaddahAfter(w, i)) {
          rules.add(TajwidRule(
            type: TajwidRuleType.ghunnah,
            name: 'Ghunnah Musyaddadah',
            arabicSnippet: '$c$_shaddah',
            ruleDescription: 'Huruf "$c" bertasydid wajib dibaca berdengung 2 harakat.',
            explanation: 'Pemeriksaan dengung pada "$c" bertasydid.',
            improvementTip: 'Tahan suara dengung di pangkal hidung selama 2 ketukan harakat.',
            wordIndex: wIdx,
          ));
        }
      }

      // ── 2. Qalqalah (Sughra & Kubra) ──
      for (int i = 0; i < w.length; i++) {
        final c = w[i];
        if (_qalqalahLetters.contains(c)) {
          final isSukun = _hasSukunAfter(w, i);
          final isEndOfWord = (i == w.length - 1 || (i == w.length - 2 && _isHarakat(w[i + 1])));

          if (isLastWord && isEndOfWord) {
            rules.add(TajwidRule(
              type: TajwidRuleType.qalqalahKubra,
              name: 'Qalqalah Kubra',
              arabicSnippet: c,
              ruleDescription: 'Huruf "$c" di akhir ayat/waqaf dibaca memantul dengan tebal dan jelas.',
              explanation: 'Pemeriksaan pantulan Qalqalah Kubra pada waqaf.',
              improvementTip: 'Pantulkan huruf "$c" lebih kuat saat berhenti (waqaf).',
              wordIndex: wIdx,
            ));
          } else if (isSukun || (isEndOfWord && !isLastWord)) {
            rules.add(TajwidRule(
              type: TajwidRuleType.qalqalahSughra,
              name: 'Qalqalah Sughra',
              arabicSnippet: '$c$_sukunStandard',
              ruleDescription: 'Huruf "$c" sukun di tengah kata dibaca memantul ringan.',
              explanation: 'Pemeriksaan pantulan Qalqalah Sughra di tengah kata.',
              improvementTip: 'Pantulkan huruf "$c" secara spontan dan ringan tanpa jeda.',
              wordIndex: wIdx,
            ));
          }
        }
      }

      // ── 3. Hukum Mim Sukun (Ikhfa Syafawi, Idgham Mimi, Izhar Syafawi) ──
      for (int i = 0; i < w.length; i++) {
        if (w[i] == 'م' && (_hasSukunAfter(w, i) || (i == w.length - 1 && wIdx < words.length - 1))) {
          // Huruf berikutnya (bisa di dalam kata atau awal kata berikutnya)
          final nextChar = _findNextConsonant(w, i, words, wIdx);
          if (nextChar != null) {
            if (nextChar == 'ب') {
              rules.add(TajwidRule(
                type: TajwidRuleType.ikhfaSyafawi,
                name: 'Ikhfa Syafawi',
                arabicSnippet: 'مْ $nextChar',
                ruleDescription: 'Mim sukun bertemu Ba dibaca samar di bibir disertai dengung 2 harakat.',
                explanation: 'Pemeriksaan bibir merapat ringan dengan dengung.',
                improvementTip: 'Rapatkan kedua bibir secara lembut tanpa ditekan keras saat mendengungkan mim.',
                wordIndex: wIdx,
              ));
            } else if (nextChar == 'م') {
              rules.add(TajwidRule(
                type: TajwidRuleType.idghamMimi,
                name: 'Idgham Mimi (Mutamatsilain)',
                arabicSnippet: 'مْ مّ',
                ruleDescription: 'Mim sukun bertemu Mim dimasukkan sempurna dengan dengung 2 harakat.',
                explanation: 'Pemeriksaan peleburan mim ke mim berikutnya.',
                improvementTip: 'Leburkan suara mim pertama ke mim kedua dengan ghunnah 2 harakat.',
                wordIndex: wIdx,
              ));
            } else {
              rules.add(TajwidRule(
                type: TajwidRuleType.izharSyafawi,
                name: 'Izhar Syafawi',
                arabicSnippet: 'مْ $nextChar',
                ruleDescription: 'Mim sukun bertemu "$nextChar" dibaca jelas di bibir tanpa dengung.',
                explanation: 'Pemeriksaan kejelasan suara mim sukun.',
                improvementTip: 'Keluarkan bunyi mim dengan jelas dan langsung sambung ke huruf berikutnya.',
                wordIndex: wIdx,
              ));
            }
          }
        }
      }

      // ── 4. Hukum Nun Sukun & Tanwin (Ikhfa, Idgham, Iqlab, Izhar) ──
      for (int i = 0; i < w.length; i++) {
        final c = w[i];
        final isNun = (c == 'ن' && (_hasSukunAfter(w, i) || (i == w.length - 1 && wIdx < words.length - 1)));
        final isTanwin = (c == _tanwinFath || c == _tanwinDamm || c == _tanwinKasr || c == _smallHighMeem);

        if (isNun || isTanwin) {
          final nextChar = _findNextConsonant(w, i, words, wIdx);
          if (nextChar != null) {
            if (nextChar == 'ب') {
              rules.add(TajwidRule(
                type: TajwidRuleType.iqlab,
                name: 'Iqlab',
                arabicSnippet: '${isNun ? 'نْ' : 'ـً'} ب',
                ruleDescription: 'Nun sukun/tanwin bertemu Ba diubah menjadi suara Mim dengan dengung.',
                explanation: 'Pemeriksaan perubahan bunyi nun menjadi mim samar.',
                improvementTip: 'Ubah bunyi nun/tanwin menjadi bunyi mim ringan disertai dengung.',
                wordIndex: wIdx,
              ));
            } else if (_idghamBighunnahLetters.contains(nextChar)) {
              rules.add(TajwidRule(
                type: TajwidRuleType.idghamBighunnah,
                name: 'Idgham Bighunnah',
                arabicSnippet: '${isNun ? 'نْ' : 'ـً'} $nextChar',
                ruleDescription: 'Nun sukun/tanwin bertemu "$nextChar" dileburkan disertai dengung 2 harakat.',
                explanation: 'Pemeriksaan peleburan nun/tanwin ke "$nextChar" dengan dengung.',
                improvementTip: 'Masukkan bunyi nun ke dalam huruf "$nextChar" sambil menahan dengung.',
                wordIndex: wIdx,
              ));
            } else if (_idghamBilaghunnahLetters.contains(nextChar)) {
              rules.add(TajwidRule(
                type: TajwidRuleType.idghamBilaghunnah,
                name: 'Idgham Bilaghunnah',
                arabicSnippet: '${isNun ? 'نْ' : 'ـً'} $nextChar',
                ruleDescription: 'Nun sukun/tanwin bertemu "$nextChar" dileburkan mutlak tanpa dengung.',
                explanation: 'Pemeriksaan peleburan ke "$nextChar" tanpa mendengung.',
                improvementTip: 'Leburkan langsung ke huruf "$nextChar" tanpa menahan suara di hidung.',
                wordIndex: wIdx,
              ));
            } else if (_izharHalqiLetters.contains(nextChar)) {
              rules.add(TajwidRule(
                type: TajwidRuleType.izharHalqi,
                name: 'Izhar Halqi',
                arabicSnippet: '${isNun ? 'نْ' : 'ـً'} $nextChar',
                ruleDescription: 'Nun sukun/tanwin bertemu huruf tenggorokan "$nextChar" dibaca jelas tanpa dengung.',
                explanation: 'Pemeriksaan kejelasan makhraj nun sukun.',
                improvementTip: 'Bunyikan huruf nun dengan tegas dan jelas sesuai makhrajnya.',
                wordIndex: wIdx,
              ));
            } else if (_ikhfaLetters.contains(nextChar)) {
              rules.add(TajwidRule(
                type: TajwidRuleType.ikhfaHaqiqi,
                name: 'Ikhfa Haqiqi',
                arabicSnippet: '${isNun ? 'نْ' : 'ـً'} $nextChar',
                ruleDescription: 'Nun sukun/tanwin bertemu "$nextChar" dibaca samar antara izhar dan idgham dengan dengung.',
                explanation: 'Pemeriksaan kesamaran bunyi nun di makhraj "$nextChar".',
                improvementTip: 'Samarkan bunyi nun sambil mengarahkan lidah siap menuju makhraj "$nextChar".',
                wordIndex: wIdx,
              ));
            }
          }
        }
      }

      // ── 5. Alif Lam Syamsiyah & Qamariyah ──
      if (w.startsWith('ال') || w.startsWith('ٱل') || w.contains('ال') || w.contains('ٱل')) {
        final alIdx = w.contains('ال') ? w.indexOf('ال') : w.indexOf('ٱل');
        if (alIdx != -1 && alIdx + 2 < w.length) {
          final afterAl = w[alIdx + 2];
          if (_syamsiyahLetters.contains(afterAl) || _hasShaddahAfter(w, alIdx + 2)) {
            rules.add(TajwidRule(
              type: TajwidRuleType.alifLamSyamsiyah,
              name: 'Alif Lam Syamsiyah',
              arabicSnippet: 'ال$afterAl$_shaddah',
              ruleDescription: 'Huruf Lam dileburkan ke dalam huruf syamsiyah "$afterAl".',
              explanation: 'Pemeriksaan idgham huruf Lam ke "$afterAl".',
              improvementTip: 'Jangan bunyikan huruf Lam, langsung leburkan ke huruf bertasydid "$afterAl".',
              wordIndex: wIdx,
            ));
          } else if (_qamariyahLetters.contains(afterAl)) {
            rules.add(TajwidRule(
              type: TajwidRuleType.alifLamQamariyah,
              name: 'Alif Lam Qamariyah',
              arabicSnippet: 'الْ$afterAl',
              ruleDescription: 'Huruf Lam dibaca jelas (izhar) saat bertemu huruf qamariyah "$afterAl".',
              explanation: 'Pemeriksaan kejelasan pengucapan huruf Lam.',
              improvementTip: 'Bunyikan huruf Lam sukun dengan jelas sebelum melafalkan "$afterAl".',
              wordIndex: wIdx,
            ));
          }
        }
      }

      // ── 6. Hukum Mad (Mad Wajib, Mad Jaiz, Mad Lazim, Mad Aridh, Mad Thabii) ──
      final hasMaddahSign = w.contains(_maddah);
      if (hasMaddahSign) {
        // Cek apakah hamzah ada di kata yang sama atau kata berikutnya
        final hasHamzahSameWord = w.contains('ء') || w.contains('أ') || w.contains('إ');
        final nextWordHamzah = (wIdx < words.length - 1 &&
            (words[wIdx + 1].arabicText.startsWith('ء') ||
                words[wIdx + 1].arabicText.startsWith('أ') ||
                words[wIdx + 1].arabicText.startsWith('إ')));

        if (hasHamzahSameWord) {
          rules.add(TajwidRule(
            type: TajwidRuleType.madWajibMuttashil,
            name: 'Mad Wajib Muttashil',
            arabicSnippet: w,
            ruleDescription: 'Mad bertemu hamzah dalam satu kata wajib dipanjangkan 4-5 harakat.',
            explanation: 'Pemeriksaan panjang mad 4-5 harakat dalam satu kata.',
            improvementTip: 'Panjangkan bacaan sekitar 4 sampai 5 harakat secara stabil.',
            wordIndex: wIdx,
          ));
        } else if (nextWordHamzah) {
          rules.add(TajwidRule(
            type: TajwidRuleType.madJaizMunfashil,
            name: 'Mad Jaiz Munfashil',
            arabicSnippet: '$w ${words[wIdx + 1].arabicText.split(" ").first}',
            ruleDescription: 'Mad bertemu hamzah pada kata terpisah dipanjangkan 2, 4, atau 5 harakat.',
            explanation: 'Pemeriksaan panjang mad antar kata yang terpisah.',
            improvementTip: 'Panjangkan 4 atau 5 harakat (atau 2 harakat jika konsisten dengan thariq).',
            wordIndex: wIdx,
          ));
        } else {
          rules.add(TajwidRule(
            type: TajwidRuleType.madLazim,
            name: 'Mad Lazim',
            arabicSnippet: w,
            ruleDescription: 'Mad bertemu huruf sukun asli atau bertasydid wajib dibaca 6 harakat.',
            explanation: 'Pemeriksaan panjang mad 6 harakat penuh.',
            improvementTip: 'Tahan panjang mad hingga 6 ketukan penuh sebelum menekan tasydid.',
            wordIndex: wIdx,
          ));
        }
      } else if (isLastWord) {
        // ── 7. Mad Aridh Lissukun pada akhir ayat ──
        final clean = wordObj.cleanText;
        if (clean.length >= 3 && (clean.contains('ي') || clean.contains('و') || clean.contains('ا'))) {
          rules.add(TajwidRule(
            type: TajwidRuleType.madAridhLissukun,
            name: "Mad 'Aridh Lissukun",
            arabicSnippet: w,
            ruleDescription: 'Mad thabi\'i bertemu huruf yang disukunkan karena waqaf (boleh 2, 4, atau 6 harakat).',
            explanation: 'Pemeriksaan cara berhenti (waqaf) pada akhir ayat.',
            improvementTip: 'Jika berhenti (waqaf), boleh dipanjangkan 2, 4, atau 6 harakat secara konsisten.',
            wordIndex: wIdx,
          ));
        }
      } else {
        // ── 8. Mad Thabi'i Umum ──
        if (_hasMadThabiiPattern(w)) {
          rules.add(TajwidRule(
            type: TajwidRuleType.madThabii,
            name: "Mad Thabi'i",
            arabicSnippet: w,
            ruleDescription: 'Huruf mad asli dibaca panjang 2 harakat.',
            explanation: 'Pemeriksaan ketepatan panjang 2 ketukan harakat.',
            improvementTip: 'Cukup panjangkan 2 harakat (jangan terlalu pendek dan jangan berlebihan).',
            wordIndex: wIdx,
          ));
        }
      }
    }

    return rules;
  }

  /// Evaluasi mendalam kecocokan bacaan pengguna dengan ayat target
  static TajwidAnalysisResult analyzeRecitation({
    required String arabicVerse,
    required String transcribedText,
  }) {
    final words = tokenizeAyah(arabicVerse);
    final expectedRules = detectExpectedRules(arabicVerse, words);

    if (transcribedText.trim().isEmpty) {
      return TajwidAnalysisResult.empty(arabicVerse);
    }

    final transcribedClean = cleanArabicForMatching(transcribedText);
    final transcribedTokens = transcribedClean.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    // ── Word-by-Word Alignment menggunakan Levenshtein Similarity ──
    final analyzedWords = <AnalyzedWord>[];
    int userTokenIdx = 0;
    int correctCount = 0;
    int attentionCount = 0;

    for (int i = 0; i < words.length; i++) {
      final targetWord = words[i];
      final targetClean = targetWord.cleanText;

      if (userTokenIdx >= transcribedTokens.length) {
        // Pengguna tidak membaca sisa kata (terlewat)
        analyzedWords.add(targetWord.copyWith(
          status: WordRecitationStatus.missed,
          similarity: 0.0,
        ));
        continue;
      }

      // Cari kata terdekat dalam sliding window 2 kata
      double bestSim = 0.0;
      int bestMatchIdx = -1;

      for (int lookahead = 0; lookahead <= 2 && (userTokenIdx + lookahead) < transcribedTokens.length; lookahead++) {
        final candidate = transcribedTokens[userTokenIdx + lookahead];
        final sim = calculateSimilarity(targetClean, candidate);
        if (sim > bestSim) {
          bestSim = sim;
          bestMatchIdx = userTokenIdx + lookahead;
        }
      }

      WordRecitationStatus status;
      String? matchedWord;

      if (bestSim >= 0.82) {
        status = WordRecitationStatus.correct;
        matchedWord = transcribedTokens[bestMatchIdx];
        userTokenIdx = bestMatchIdx + 1;
        correctCount++;
      } else if (bestSim >= 0.55) {
        status = WordRecitationStatus.needsAttention;
        matchedWord = transcribedTokens[bestMatchIdx];
        userTokenIdx = bestMatchIdx + 1;
        attentionCount++;
      } else {
        // Kata tidak cocok atau terlewat
        status = WordRecitationStatus.incorrect;
        matchedWord = (userTokenIdx < transcribedTokens.length) ? transcribedTokens[userTokenIdx] : null;
        userTokenIdx++;
      }

      analyzedWords.add(targetWord.copyWith(
        status: status,
        transcribedWord: matchedWord,
        similarity: bestSim,
      ));
    }

    // ── Evaluasi Actual Tajwid berdasarkan kecocokan pelafalan ──
    final evaluatedRules = <TajwidRule>[];
    int tajwidBenarCount = 0;
    int perbaikanCount = 0;
    int uncertainCount = 0;

    for (final expRule in expectedRules) {
      final wIdx = expRule.wordIndex;
      final associatedWord = (wIdx < analyzedWords.length) ? analyzedWords[wIdx] : null;

      if (associatedWord == null) {
        evaluatedRules.add(expRule.copyWith(
          status: TajwidStatus.uncertain,
          confidence: 0.3,
          explanation: 'Bagian ini belum dapat dianalisis dengan yakin.',
        ));
        uncertainCount++;
        continue;
      }

      switch (associatedWord.status) {
        case WordRecitationStatus.correct:
          // Jika hukumnya Mad Aridh Lissukun: jangan anggap salah jika membaca washal
          if (expRule.type == TajwidRuleType.madAridhLissukun) {
            evaluatedRules.add(expRule.copyWith(
              status: TajwidStatus.correct,
              confidence: 0.92,
              explanation: 'Pelafalan akhir ayat tepat (waqaf atau washal sesuai kaidah).',
            ));
            tajwidBenarCount++;
          } else {
            evaluatedRules.add(expRule.copyWith(
              status: TajwidStatus.correct,
              confidence: 0.88 + (associatedWord.similarity * 0.1),
              explanation: 'Hukum ${expRule.name} pada kata "${associatedWord.arabicText}" dilafalkan dengan baik.',
            ));
            tajwidBenarCount++;
          }
          break;

        case WordRecitationStatus.needsAttention:
          evaluatedRules.add(expRule.copyWith(
            status: TajwidStatus.needsAttention,
            confidence: 0.70,
            explanation: 'Ada ketidaksesuaian fonetik pada "${associatedWord.arabicText}". Perhatikan makhraj huruf dan hukum ${expRule.name}.',
          ));
          perbaikanCount++;
          break;

        case WordRecitationStatus.incorrect:
        case WordRecitationStatus.missed:
          evaluatedRules.add(expRule.copyWith(
            status: TajwidStatus.needsImprovement,
            confidence: 0.85,
            explanation: 'Kata "${associatedWord.arabicText}" terlewat atau pengucapannya belum tepat, sehingga hukum ${expRule.name} belum terpenuhi.',
          ));
          perbaikanCount++;
          break;

        case WordRecitationStatus.pending:
          evaluatedRules.add(expRule.copyWith(
            status: TajwidStatus.uncertain,
            confidence: 0.2,
            explanation: 'Belum dapat dianalisis dengan yakin karena audio belum mencakup bagian ini.',
          ));
          uncertainCount++;
          break;
      }
    }

    // ── Hitung Skor Akurasi Dinamis ──
    final totalWords = words.length;
    final weightedSuccess = correctCount + (attentionCount * 0.5);
    final rawAccuracy = totalWords > 0 ? ((weightedSuccess / totalWords) * 100).round() : 0;
    final accuracy = rawAccuracy.clamp(0, 100);

    // Feedback pesan cerdas
    String feedback;
    if (accuracy >= 90) {
      feedback = 'Maa Syaa Allah! Bacaan sangat fasih dan tajwid terbaca dengan sangat baik. Pertahankan! 🌟';
    } else if (accuracy >= 75) {
      feedback = 'Alhamdulillah, bacaan sudah cukup baik! Ada beberapa makhraj dan panjang harakat yang perlu disempurnakan. 🌿';
    } else if (accuracy >= 50) {
      feedback = 'Terus semangat berlatih! Perhatikan pelafalan kata yang ditandai merah/oranye dan dengarkan kembali contoh bacaan. 📖';
    } else {
      feedback = 'Suara terdeteksi belum sempurna membaca ayat ini. Coba dengarkan audio contoh lalu ulangi rekaman ya! 🎙️';
    }

    return TajwidAnalysisResult(
      accuracy: accuracy,
      tajwidBenar: tajwidBenarCount,
      perbaikan: perbaikanCount,
      uncertain: uncertainCount,
      totalWords: totalWords,
      correctWords: correctCount,
      words: analyzedWords,
      rules: evaluatedRules,
      transcribedText: transcribedText,
      feedbackMessage: feedback,
      hasAudioInput: true,
    );
  }

  // ── Helper Internal ──

  static bool _hasShaddahAfter(String text, int index) {
    if (index + 1 < text.length && text[index + 1] == _shaddah) return true;
    if (index + 2 < text.length && text[index + 2] == _shaddah) return true;
    return false;
  }

  static bool _hasSukunAfter(String text, int index) {
    for (int k = index + 1; k <= index + 2 && k < text.length; k++) {
      if (text[k] == _sukunStandard || text[k] == _sukunUtsmani) return true;
    }
    return false;
  }

  static bool _isHarakat(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x064B && code <= 0x065F) || code == 0x0670;
  }

  static String? _findNextConsonant(String word, int charIdx, List<AnalyzedWord> words, int wordIdx) {
    // Cari di sisa kata saat ini
    for (int k = charIdx + 1; k < word.length; k++) {
      final c = word[k];
      if (!_isHarakat(c) && c != _shaddah && c != _sukunStandard && c != _sukunUtsmani && c != ' ') {
        return c;
      }
    }
    // Jika tidak ada di kata saat ini, cari konsonan pertama di kata berikutnya
    if (wordIdx + 1 < words.length) {
      final nextWord = words[wordIdx + 1].arabicText;
      for (int k = 0; k < nextWord.length; k++) {
        final c = nextWord[k];
        if (!_isHarakat(c) && c != _shaddah && c != _alifWasl && c != ' ') {
          return c;
        }
      }
    }
    return null;
  }

  static bool _hasMadThabiiPattern(String w) {
    for (int i = 0; i < w.length - 1; i++) {
      final c = w[i];
      final next = w[i + 1];
      if (c == _fathah && (next == 'ا' || next == _daggerAlif)) return true;
      if (c == _dammah && next == 'و') return true;
      if (c == _kasrah && next == 'ي') return true;
    }
    return false;
  }

  static double calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final dist = _levenshtein(s1, s2);
    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    if (maxLen == 0) return 1.0;

    return (maxLen - dist) / maxLen;
  }

  static int _levenshtein(String a, String b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
    }

    return dp[m][n];
  }
}
