import 'dart:math';

/// Status kecocokan kata antara bacaan pengguna dan target ayat
enum WordMatchStatus {
  correct,   // Sesuai / benar (Hijau)
  incorrect, // Salah baca / keliru (Merah)
  missing,   // Terlewat / belum dibaca (Kuning/Oranye)
}

/// Model untuk merepresentasikan sebuah kata dalam ayat beserta status evaluasinya
class EvaluatedWord {
  final String originalText;      // Teks asli berharakat
  final String normalizedText;    // Teks ternormalisasi tanpa harakat
  final WordMatchStatus status;   // Status kecocokan
  final String? recognizedSpoken; // Kata yang diucapkan (jika ada)
  final double similarity;        // Tingkat kemiripan 0.0 - 1.0

  const EvaluatedWord({
    required this.originalText,
    required this.normalizedText,
    required this.status,
    this.recognizedSpoken,
    this.similarity = 0.0,
  });
}

/// Kategori nilai evaluasi hafalan
enum HafalanGrade {
  sangatBaik,   // 95 - 100%
  baik,         // 80 - 94%
  perluLatihan, // 60 - 79%
  ulangiHafalan // < 60%
}

/// Hasil evaluasi komprehensif pencocokan hafalan
class HafalanEvaluationResult {
  final int surahNumber;
  final String surahName;
  final int startAyah;
  final int endAyah;
  final String targetOriginalArabic;
  final String recognizedTranscript;
  final List<EvaluatedWord> evaluatedWords;
  final int correctCount;
  final int incorrectCount;
  final int missingCount;
  final int totalTargetWords;
  final double matchPercentage;
  final HafalanGrade grade;
  final bool isEmptyOrTooShort;
  final String feedbackMessage;

  const HafalanEvaluationResult({
    required this.surahNumber,
    required this.surahName,
    required this.startAyah,
    required this.endAyah,
    required this.targetOriginalArabic,
    required this.recognizedTranscript,
    required this.evaluatedWords,
    required this.correctCount,
    required this.incorrectCount,
    required this.missingCount,
    required this.totalTargetWords,
    required this.matchPercentage,
    required this.grade,
    this.isEmptyOrTooShort = false,
    required this.feedbackMessage,
  });

  String get gradeTitle {
    switch (grade) {
      case HafalanGrade.sangatBaik:
        return 'Sangat Baik';
      case HafalanGrade.baik:
        return 'Baik';
      case HafalanGrade.perluLatihan:
        return 'Perlu Latihan';
      case HafalanGrade.ulangiHafalan:
        return 'Ulangi Hafalan';
    }
  }

  String get ayahDisplayLabel {
    if (startAyah == endAyah) {
      return '$surahName: Ayat $startAyah';
    }
    return '$surahName: Ayat $startAyah–$endAyah';
  }
}

/// Service untuk memproses normalisasi teks Arab dan melakukan perbandingan kata
/// menggunakan algoritma Needleman-Wunsch / Levenshtein Distance yang disesuaikan
class ArabicMatchingService {
  // Regex untuk harakat / tanda tashkeel
  static final RegExp _tashkeelRegex = RegExp(r'[\u064B-\u065F\u0670]');

  // Regex untuk tanda waqaf & ornamen mushaf Al-Qur'an
  static final RegExp _quranicMarksRegex = RegExp(
    r'[\u0610-\u061A\u06D6-\u06ED\u0600-\u0605\uFD3E\uFD3F\u06DD]',
  );

  // Regex untuk karakter non-huruf Arab
  static final RegExp _nonArabicRegex = RegExp(r'[^\u0621-\u064A]');

  /// Menormalkan teks Arab:
  /// 1. Menghapus harakat / tanda baca / tanda waqaf
  /// 2. Menyatukan varian alif (أ, إ, آ, ٱ -> ا)
  /// 3. Menyatukan ya / alif maqsura (ى -> ي)
  /// 4. Menyatukan ta marbuta (ة -> ه)
  /// 5. Menghilangkan tatweel (ـ)
  /// 6. Menghapus tanda baca Latin dan angka
  static String normalizeArabic(String text) {
    if (text.isEmpty) return '';

    String cleaned = text;

    // Hapus tanda waqaf dan simbol Quranic
    cleaned = cleaned.replaceAll(_quranicMarksRegex, '');

    // Hapus tashkeel / harakat
    cleaned = cleaned.replaceAll(_tashkeelRegex, '');

    // Hapus tatweel
    cleaned = cleaned.replaceAll('\u0640', '');

    // Normalisasi variasi Alif: [أ إ آ ٱ] -> ا
    cleaned = cleaned.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalisasi Alif Maqsura: ى -> ي
    cleaned = cleaned.replaceAll('ى', 'ي');

    // Normalisasi Ta Marbuta: ة -> ه
    cleaned = cleaned.replaceAll('ة', 'ه');

    // Normalisasi Hamza bentuk lain: ؤ, ئ -> ء
    cleaned = cleaned.replaceAll(RegExp(r'[ؤئ]'), 'ء');

    // Hapus angka arab (٠-٩) dan angka latin (0-9)
    cleaned = cleaned.replaceAll(RegExp(r'[\u0660-\u06690-9]'), '');

    // Hapus tanda baca
    cleaned = cleaned.replaceAll(RegExp(r'[.,!?:;()\[\]{}""«»_/\-\\]'), ' ');

    // Bersihkan karakter selain huruf Arab standar
    cleaned = cleaned.replaceAll(_nonArabicRegex, ' ');

    // Rapikan spasi berlebih
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Menghitung Levenshtein Distance antara dua kata
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> prev = List<int>.generate(s2.length + 1, (i) => i);
    List<int> curr = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      curr[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        curr[j + 1] = min(
          curr[j] + 1, // insertion
          min(
            prev[j + 1] + 1, // deletion
            prev[j] + cost, // substitution
          ),
        );
      }
      for (int k = 0; k <= s2.length; k++) {
        prev[k] = curr[k];
      }
    }
    return prev[s2.length];
  }

  /// Menghitung kemiripan (0.0 sampai 1.0) antara dua kata
  static double calculateWordSimilarity(String w1, String w2) {
    if (w1.isEmpty && w2.isEmpty) return 1.0;
    if (w1.isEmpty || w2.isEmpty) return 0.0;
    if (w1 == w2) return 1.0;

    final distance = levenshteinDistance(w1, w2);
    final maxLen = max(w1.length, w2.length);
    if (maxLen == 0) return 1.0;
    return max(0.0, 1.0 - (distance / maxLen));
  }

  /// Membandingkan bacaan suara pengguna dengan teks target ayat
  static HafalanEvaluationResult evaluate({
    required int surahNumber,
    required String surahName,
    required int startAyah,
    required int endAyah,
    required String targetOriginalArabic,
    required String recognizedTranscript,
  }) {
    // 1. Ekstrak kata asli dari target (hanya token yang memiliki huruf Arab bermakna)
    final rawTokens = targetOriginalArabic.trim().split(RegExp(r'\s+'));
    final targetWords = <Map<String, String>>[];

    for (final raw in rawTokens) {
      final norm = normalizeArabic(raw);
      if (norm.isNotEmpty) {
        targetWords.add({
          'original': raw,
          'normalized': norm,
        });
      }
    }

    // 2. Ekstrak kata dari transkripsi suara pengguna
    final spokenNorm = normalizeArabic(recognizedTranscript);
    final spokenWords = spokenNorm.isNotEmpty
        ? spokenNorm.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList()
        : <String>[];

    // Jika transkripsi kosong atau tidak mendeteksi suara
    if (spokenWords.isEmpty || targetWords.isEmpty) {
      final evaluated = targetWords.map((t) {
        return EvaluatedWord(
          originalText: t['original']!,
          normalizedText: t['normalized']!,
          status: WordMatchStatus.missing,
          similarity: 0.0,
        );
      }).toList();

      return HafalanEvaluationResult(
        surahNumber: surahNumber,
        surahName: surahName,
        startAyah: startAyah,
        endAyah: endAyah,
        targetOriginalArabic: targetOriginalArabic,
        recognizedTranscript: recognizedTranscript,
        evaluatedWords: evaluated,
        correctCount: 0,
        incorrectCount: 0,
        missingCount: targetWords.length,
        totalTargetWords: targetWords.length,
        matchPercentage: 0.0,
        grade: HafalanGrade.ulangiHafalan,
        isEmptyOrTooShort: true,
        feedbackMessage: 'Suara tidak terdeteksi atau terlalu singkat. Silakan coba lagi dan membaca dengan jelas.',
      );
    }

    final n = targetWords.length;
    final m = spokenWords.length;

    // 3. Algoritma Needleman-Wunsch Global Sequence Alignment pada level kata
    // Matriks skor DP
    final dp = List.generate(n + 1, (_) => List<double>.filled(m + 1, 0.0));

    const gapPenalty = -1.0;

    for (int i = 0; i <= n; i++) {
      dp[i][0] = i * gapPenalty;
    }
    for (int j = 0; j <= m; j++) {
      dp[0][j] = j * gapPenalty;
    }

    for (int i = 1; i <= n; i++) {
      final tWord = targetWords[i - 1]['normalized']!;
      for (int j = 1; j <= m; j++) {
        final sWord = spokenWords[j - 1];
        final sim = calculateWordSimilarity(tWord, sWord);

        // Skor pencocokan:
        // Jika kemiripan sangat tinggi (>= 0.82) -> skor positif tinggi (+2.0)
        // Jika kemiripan sedang (>= 0.65) -> skor positif sedang (+0.8)
        // Jika beda -> penalti (-1.2)
        double matchScore;
        if (sim >= 0.82) {
          matchScore = 2.0;
        } else if (sim >= 0.65) {
          matchScore = 0.8;
        } else {
          matchScore = -1.2;
        }

        final scoreMatch = dp[i - 1][j - 1] + matchScore;
        final scoreDelete = dp[i - 1][j] + gapPenalty; // kata target tidak dibaca
        final scoreInsert = dp[i][j - 1] + gapPenalty; // ada kata ekstra dibaca

        dp[i][j] = max(scoreMatch, max(scoreDelete, scoreInsert));
      }
    }

    // 4. Backtracking untuk menentukan status setiap kata target
    int i = n;
    int j = m;
    final alignments = <int, EvaluatedWord>{};

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final tWord = targetWords[i - 1]['normalized']!;
        final sWord = spokenWords[j - 1];
        final sim = calculateWordSimilarity(tWord, sWord);

        double matchScore;
        if (sim >= 0.82) {
          matchScore = 2.0;
        } else if (sim >= 0.65) {
          matchScore = 0.8;
        } else {
          matchScore = -1.2;
        }

        if ((dp[i][j] - (dp[i - 1][j - 1] + matchScore)).abs() < 1e-6) {
          // Alignment kata target i-1 dengan kata suara j-1
          WordMatchStatus status;
          if (sim >= 0.75) {
            status = WordMatchStatus.correct;
          } else {
            status = WordMatchStatus.incorrect;
          }

          alignments[i - 1] = EvaluatedWord(
            originalText: targetWords[i - 1]['original']!,
            normalizedText: tWord,
            status: status,
            recognizedSpoken: sWord,
            similarity: sim,
          );

          i--;
          j--;
          continue;
        }
      }

      if (i > 0 && (dp[i][j] - (dp[i - 1][j] + gapPenalty)).abs() < 1e-6) {
        // Kata target i-1 terlewat (missing)
        final tWord = targetWords[i - 1]['normalized']!;
        alignments[i - 1] = EvaluatedWord(
          originalText: targetWords[i - 1]['original']!,
          normalizedText: tWord,
          status: WordMatchStatus.missing,
          similarity: 0.0,
        );
        i--;
        continue;
      }

      // Kata ekstra dari ucapan (insertion)
      j--;
    }

    // Bangun list urut sesuai target
    final evaluatedList = <EvaluatedWord>[];
    int correctCount = 0;
    int incorrectCount = 0;
    int missingCount = 0;
    double weightedScore = 0.0;

    for (int idx = 0; idx < n; idx++) {
      final item = alignments[idx] ??
          EvaluatedWord(
            originalText: targetWords[idx]['original']!,
            normalizedText: targetWords[idx]['normalized']!,
            status: WordMatchStatus.missing,
            similarity: 0.0,
          );

      evaluatedList.add(item);

      if (item.status == WordMatchStatus.correct) {
        correctCount++;
        weightedScore += 1.0;
      } else if (item.status == WordMatchStatus.incorrect) {
        incorrectCount++;
        // Berikan sebagian bobot jika pelafalan hampir tepat
        if (item.similarity >= 0.60) {
          weightedScore += (item.similarity * 0.4);
        }
      } else {
        missingCount++;
      }
    }

    // Hitung persentase kecocokan (0–100%)
    double matchPercentage = (weightedScore / n) * 100.0;
    matchPercentage = matchPercentage.clamp(0.0, 100.0);
    // Bulatkan ke 1 desimal
    matchPercentage = (matchPercentage * 10).round() / 10.0;

    // Klasifikasi Penilaian sesuai instruksi
    final HafalanGrade grade;
    final String feedback;

    if (matchPercentage >= 95.0) {
      grade = HafalanGrade.sangatBaik;
      feedback = 'Māsyā Allāh! Hafalan Anda sangat baik dan lancar.';
    } else if (matchPercentage >= 80.0) {
      grade = HafalanGrade.baik;
      feedback = 'Alhamdulillah! Hafalan Anda sudah baik, perhatikan beberapa kata yang keliru.';
    } else if (matchPercentage >= 60.0) {
      grade = HafalanGrade.perluLatihan;
      feedback = 'Bagus! Masih ada beberapa bagian kata yang terlewat atau keliru. Perbanyak latihan.';
    } else {
      grade = HafalanGrade.ulangiHafalan;
      feedback = 'Perlu diulang kembali. Simak dan baca berulang kali sebelum mencoba mengetes lagi.';
    }

    return HafalanEvaluationResult(
      surahNumber: surahNumber,
      surahName: surahName,
      startAyah: startAyah,
      endAyah: endAyah,
      targetOriginalArabic: targetOriginalArabic,
      recognizedTranscript: recognizedTranscript,
      evaluatedWords: evaluatedList,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      missingCount: missingCount,
      totalTargetWords: n,
      matchPercentage: matchPercentage,
      grade: grade,
      isEmptyOrTooShort: false,
      feedbackMessage: feedback,
    );
  }
}
