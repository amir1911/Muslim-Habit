import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_habit/core/utils/tajwid_engine.dart';

void main() {
  group('TajwidEngine Unit Tests', () {
    test('Tokenize and clean Arabic Utsmani text', () {
      const verse = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ﴿١﴾';
      final tokens = TajwidEngine.tokenizeAyah(verse);

      expect(tokens.length, equals(4));
      expect(tokens[0].cleanText, equals('بسم'));
      expect(tokens[1].cleanText, equals('الله'));
    });

    test('Detect Expected Tajwid Rules in Al-Fatihah 1', () {
      const verse = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      final tokens = TajwidEngine.tokenizeAyah(verse);
      final rules = TajwidEngine.detectExpectedRules(verse, tokens);

      expect(rules.isNotEmpty, isTrue);
      // Harus mendeteksi Alif Lam Syamsiyah pada الرحمن dan الرحيم
      final hasSyamsiyah = rules.any((r) => r.type == TajwidRuleType.alifLamSyamsiyah);
      expect(hasSyamsiyah, isTrue);
    });

    test('Detect Qalqalah Kubra on Al-Ikhlas 1', () {
      const verse = 'قُلْ هُوَ اللَّهُ أَحَدٌ';
      final tokens = TajwidEngine.tokenizeAyah(verse);
      final rules = TajwidEngine.detectExpectedRules(verse, tokens);

      final hasQalqalahKubra = rules.any((r) => r.type == TajwidRuleType.qalqalahKubra);
      expect(hasQalqalahKubra, isTrue);
    });

    test('Analyze Recitation with exact match produces 100% accuracy', () {
      const verse = 'قُلْ هُوَ اللَّهُ أَحَدٌ';
      final result = TajwidEngine.analyzeRecitation(
        arabicVerse: verse,
        transcribedText: 'قل هو الله احد',
      );

      expect(result.accuracy, equals(100));
      expect(result.correctWords, equals(4));
      expect(result.perbaikan, equals(0));
      expect(result.words.every((w) => w.status == WordRecitationStatus.correct), isTrue);
    });

    test('Analyze Recitation with missing words reduces accuracy dynamically', () {
      const verse = 'قُلْ هُوَ اللَّهُ أَحَدٌ';
      // User only reads first 2 words
      final result = TajwidEngine.analyzeRecitation(
        arabicVerse: verse,
        transcribedText: 'قل هو',
      );

      expect(result.accuracy, equals(50));
      expect(result.correctWords, equals(2));
      expect(result.words[2].status, equals(WordRecitationStatus.missed));
      expect(result.words[3].status, equals(WordRecitationStatus.missed));
    });

    test('Analyze Recitation with empty input produces empty result', () {
      const verse = 'قُلْ هُوَ اللَّهُ أَحَدٌ';
      final result = TajwidEngine.analyzeRecitation(
        arabicVerse: verse,
        transcribedText: '',
      );

      expect(result.accuracy, equals(0));
      expect(result.hasAudioInput, isFalse);
    });
  });
}
