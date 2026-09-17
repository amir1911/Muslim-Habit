class SurahAyah {
  final int ayahNumber;
  final String arabicText;
  final String translation;
  final String? audioUrl;
  final String? tafsir;
  final int? juz;
  final int? page;

  SurahAyah({
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    this.audioUrl,
    this.tafsir,
    this.juz,
    this.page,
  });

  factory SurahAyah.fromJson(Map<String, dynamic> json) {
    String? tafsirText;
    if (json['tafsir'] is Map) {
      final t = json['tafsir'] as Map<String, dynamic>;
      if (t['kemenag'] is Map) {
        tafsirText = t['kemenag']['short'] as String? ?? t['kemenag']['long'] as String?;
      }
    } else if (json['tafsir'] is String) {
      tafsirText = json['tafsir'] as String;
    }

    int? juzVal;
    int? pageVal;
    if (json['meta'] is Map) {
      final m = json['meta'] as Map<String, dynamic>;
      juzVal = m['juz'] as int?;
      pageVal = m['page'] as int?;
    }

    return SurahAyah(
      ayahNumber: json['ayah_number'] as int? ??
          json['verse_number'] as int? ??
          json['nomor'] as int? ??
          1,
      arabicText: json['arab'] as String? ?? json['arabic_text'] as String? ?? '',
      translation: json['translation'] as String? ??
          json['terjemah'] as String? ??
          json['id'] as String? ??
          '',
      audioUrl: json['audio_url'] as String?,
      tafsir: tafsirText,
      juz: juzVal,
      page: pageVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'ayah_number': ayahNumber,
        'arab': arabicText,
        'translation': translation,
        'audio_url': audioUrl,
        'tafsir': tafsir,
        'meta': {'juz': juz, 'page': page},
      };
}

class SurahDetail {
  final int number;
  final String nameLatin;
  final String nameArabic;
  final int numberOfAyahs;
  final String translation;
  final String revelation;
  final String description;
  final String? audioUrl;
  final List<SurahAyah> ayahs;

  SurahDetail({
    required this.number,
    required this.nameLatin,
    required this.nameArabic,
    required this.numberOfAyahs,
    required this.translation,
    required this.revelation,
    required this.description,
    this.audioUrl,
    required this.ayahs,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final ayahsList = <SurahAyah>[];
    if (data['ayahs'] is List) {
      for (final a in data['ayahs'] as List) {
        if (a is Map<String, dynamic>) {
          ayahsList.add(SurahAyah.fromJson(a));
        }
      }
    } else if (data['ayat'] is List) {
      for (final a in data['ayat'] as List) {
        if (a is Map<String, dynamic>) {
          ayahsList.add(SurahAyah.fromJson(a));
        }
      }
    }

    return SurahDetail(
      number: data['number'] as int? ?? 1,
      nameLatin: data['name_latin'] as String? ??
          data['name'] as String? ??
          data['name_en'] as String? ??
          'Surah 1',
      nameArabic: data['name'] as String? ??
          data['name_short'] as String? ??
          data['name_long'] as String? ??
          '',
      numberOfAyahs: data['number_of_ayahs'] as int? ??
          data['number_of_verses'] as int? ??
          ayahsList.length,
      translation: data['translation'] as String? ??
          data['name_id'] as String? ??
          '',
      revelation: data['revelation'] as String? ?? 'Makkiyah',
      description: data['description'] as String? ?? '',
      audioUrl: data['audio_url'] as String?,
      ayahs: ayahsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name_latin': nameLatin,
        'name': nameArabic,
        'number_of_ayahs': numberOfAyahs,
        'translation': translation,
        'revelation': revelation,
        'description': description,
        'audio_url': audioUrl,
        'ayahs': ayahs.map((a) => a.toJson()).toList(),
      };
}
