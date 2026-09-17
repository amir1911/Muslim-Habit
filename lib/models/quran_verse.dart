class QuranVerse {
  final int id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabicText;
  final String translation;
  final String? tafsirShort;
  final String? tafsirLong;
  final String? audioUrl;

  QuranVerse({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    this.tafsirShort,
    this.tafsirLong,
    this.audioUrl,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    String surah = json['surah_name'] as String? ?? '';
    if (surah.isEmpty && json['surah'] is Map) {
      final s = json['surah'] as Map<String, dynamic>;
      surah = s['name_latin'] as String? ?? s['name'] as String? ?? 'Surah';
    }
    if (surah.isEmpty) surah = 'QS. ${json['surah_number'] ?? ''}';

    String? shortTafsir;
    String? longTafsir;
    if (json['tafsir'] is Map) {
      final t = json['tafsir'] as Map<String, dynamic>;
      if (t['kemenag'] is Map) {
        final k = t['kemenag'] as Map<String, dynamic>;
        shortTafsir = k['short'] as String?;
        longTafsir = k['long'] as String?;
      }
    }

    return QuranVerse(
      id: json['id'] as int? ?? 1,
      surahNumber: json['surah_number'] as int? ?? 1,
      surahName: surah,
      ayahNumber: json['ayah_number'] as int? ?? 1,
      arabicText: json['arab'] as String? ?? json['arabic_text'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      tafsirShort: shortTafsir ?? json['tafsir_short'] as String?,
      tafsirLong: longTafsir ?? json['tafsir_long'] as String?,
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'ayah_number': ayahNumber,
      'arab': arabicText,
      'translation': translation,
      'tafsir_short': tafsirShort,
      'tafsir_long': tafsirLong,
      'audio_url': audioUrl,
    };
  }

  factory QuranVerse.defaultVerse() {
    return QuranVerse(
      id: 282,
      surahNumber: 2,
      surahName: 'Al-Baqarah',
      ayahNumber: 286,
      arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      translation: 'Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya.',
      tafsirShort: 'Allah tidak memikulkan beban kepada hamba-Nya melebihi batas kemampuannya.',
    );
  }

  String get reference => 'QS. $surahName: $ayahNumber';
}
