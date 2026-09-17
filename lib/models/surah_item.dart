class SurahItem {
  final int number;
  final String nameLatin;
  final String nameArabic;
  final String nameId;
  final String translation;
  final int numberOfAyahs;
  final String revelation;
  final String? audioUrl;

  SurahItem({
    required this.number,
    required this.nameLatin,
    required this.nameArabic,
    required this.nameId,
    required this.translation,
    required this.numberOfAyahs,
    required this.revelation,
    this.audioUrl,
  });

  factory SurahItem.fromJson(Map<String, dynamic> json) {
    final numVal = int.tryParse(json['number']?.toString() ?? '') ?? 1;
    final ayahsVal = int.tryParse(
          json['number_of_verses']?.toString() ??
              json['number_of_ayahs']?.toString() ??
              '',
        ) ??
        7;

    return SurahItem(
      number: numVal,
      nameLatin: json['name_en'] as String? ??
          json['name_latin'] as String? ??
          json['nama_latin'] as String? ??
          'Surah $numVal',
      nameArabic: json['name_short'] as String? ??
          json['name_long'] as String? ??
          json['arab'] as String? ??
          '',
      nameId: json['name_id'] as String? ??
          json['name'] as String? ??
          'Surah $numVal',
      translation: json['translation'] as String? ??
          json['arti'] as String? ??
          json['name_id'] as String? ??
          '',
      numberOfAyahs: ayahsVal,
      revelation: json['revelation'] as String? ??
          json['tempat_turun'] as String? ??
          'Makkiyah',
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name_en': nameLatin,
        'name_short': nameArabic,
        'name_id': nameId,
        'translation': translation,
        'number_of_verses': numberOfAyahs,
        'revelation': revelation,
        'audio_url': audioUrl,
      };

  /// Fallback static metadata for popular surahs
  static List<SurahItem> get fallbackSurahList => [
        SurahItem(
          number: 1,
          nameLatin: 'Al-Faatiha',
          nameArabic: 'الفاتحة',
          nameId: 'Al-Fatihah',
          translation: 'Pembukaan',
          numberOfAyahs: 7,
          revelation: 'Makkiyah',
        ),
        SurahItem(
          number: 2,
          nameLatin: 'Al-Baqarah',
          nameArabic: 'البقرة',
          nameId: 'Al-Baqarah',
          translation: 'Sapi Betina',
          numberOfAyahs: 286,
          revelation: 'Madaniyah',
        ),
        SurahItem(
          number: 3,
          nameLatin: 'Ali-Imran',
          nameArabic: 'آل عمران',
          nameId: 'Ali-Imran',
          translation: 'Keluarga Imran',
          numberOfAyahs: 200,
          revelation: 'Madaniyah',
        ),
        SurahItem(
          number: 4,
          nameLatin: 'An-Nisaa',
          nameArabic: 'النساء',
          nameId: 'An-Nisa',
          translation: 'Wanita',
          numberOfAyahs: 176,
          revelation: 'Madaniyah',
        ),
        SurahItem(
          number: 5,
          nameLatin: 'Al-Maaida',
          nameArabic: 'المائدة',
          nameId: 'Al-Maidah',
          translation: 'Jamuan',
          numberOfAyahs: 120,
          revelation: 'Madaniyah',
        ),
        SurahItem(
          number: 6,
          nameLatin: "Al-An'aam",
          nameArabic: 'الأنعام',
          nameId: "Al-An'am",
          translation: 'Binatang Ternak',
          numberOfAyahs: 165,
          revelation: 'Makkiyah',
        ),
        SurahItem(
          number: 7,
          nameLatin: "Al-A'raaf",
          nameArabic: 'الأعراف',
          nameId: "Al-A'raf",
          translation: 'Tempat Tertinggi',
          numberOfAyahs: 206,
          revelation: 'Makkiyah',
        ),
        SurahItem(
          number: 8,
          nameLatin: 'Al-Anfaal',
          nameArabic: 'الأنفال',
          nameId: 'Al-Anfal',
          translation: 'Rampasan Perang',
          numberOfAyahs: 75,
          revelation: 'Madaniyah',
        ),
        SurahItem(
          number: 9,
          nameLatin: 'At-Tawba',
          nameArabic: 'التوبة',
          nameId: 'At-Taubah',
          translation: 'Pengampunan',
          numberOfAyahs: 129,
          revelation: 'Madaniyah',
        ),
      ];
}
