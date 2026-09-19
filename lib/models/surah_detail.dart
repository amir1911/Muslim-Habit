class SurahAyah {
  final int ayahNumber;
  final String arabicText;
  final String translation;
  final String? audioUrl;
  final Map<String, String>? audioMap;
  final String? tafsir;
  final int? juz;
  final int? page;

  SurahAyah({
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    this.audioUrl,
    this.audioMap,
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

    // Audio extraction
    String? resolvedAudio;
    Map<String, String> resolvedAudioMap = {};
    if (json['audio'] is Map) {
      final aMap = json['audio'] as Map;
      aMap.forEach((k, v) {
        if (v is String) resolvedAudioMap[k.toString()] = v;
      });
      // Default: '05' (Misyari Rasyid) atau audio pertama
      resolvedAudio = resolvedAudioMap['05'] ??
          resolvedAudioMap['01'] ??
          (resolvedAudioMap.isNotEmpty ? resolvedAudioMap.values.first : null);
    } else if (json['audio'] is String) {
      resolvedAudio = json['audio'] as String;
    } else if (json['audio_url'] is String) {
      resolvedAudio = json['audio_url'] as String;
    }

    return SurahAyah(
      ayahNumber: json['nomorAyat'] as int? ??
          json['ayah_number'] as int? ??
          json['verse_number'] as int? ??
          json['nomor'] as int? ??
          1,
      arabicText: json['teksArab'] as String? ??
          json['arab'] as String? ??
          json['arabic_text'] as String? ??
          '',
      translation: json['teksIndonesia'] as String? ??
          json['translation'] as String? ??
          json['terjemah'] as String? ??
          json['id'] as String? ??
          '',
      audioUrl: resolvedAudio,
      audioMap: resolvedAudioMap.isNotEmpty ? resolvedAudioMap : null,
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
        'audio': audioMap,
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
  final Map<String, String>? audioFullMap;
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
    this.audioFullMap,
    required this.ayahs,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final ayahsList = <SurahAyah>[];
    if (data['ayat'] is List) {
      for (final a in data['ayat'] as List) {
        if (a is Map<String, dynamic>) {
          ayahsList.add(SurahAyah.fromJson(a));
        }
      }
    } else if (data['ayahs'] is List) {
      for (final a in data['ayahs'] as List) {
        if (a is Map<String, dynamic>) {
          ayahsList.add(SurahAyah.fromJson(a));
        }
      }
    }

    // Audio Full
    String? fullAudio;
    Map<String, String> fullAudioMap = {};
    if (data['audioFull'] is Map) {
      final aMap = data['audioFull'] as Map;
      aMap.forEach((k, v) {
        if (v is String) fullAudioMap[k.toString()] = v;
      });
      fullAudio = fullAudioMap['05'] ?? fullAudioMap['01'] ?? (fullAudioMap.isNotEmpty ? fullAudioMap.values.first : null);
    } else if (data['audio_url'] is String) {
      fullAudio = data['audio_url'] as String;
    }

    return SurahDetail(
      number: data['nomor'] as int? ?? data['number'] as int? ?? 1,
      nameLatin: data['namaLatin'] as String? ??
          data['name_latin'] as String? ??
          data['name'] as String? ??
          data['name_en'] as String? ??
          'Surah 1',
      nameArabic: data['nama'] as String? ??
          data['name_short'] as String? ??
          data['name_long'] as String? ??
          '',
      numberOfAyahs: data['jumlahAyat'] as int? ??
          data['number_of_ayahs'] as int? ??
          data['number_of_verses'] as int? ??
          ayahsList.length,
      translation: data['arti'] as String? ??
          data['translation'] as String? ??
          data['name_id'] as String? ??
          '',
      revelation: data['tempatTurun'] as String? ??
          data['revelation'] as String? ??
          'Makkiyah',
      description: data['deskripsi'] as String? ??
          data['description'] as String? ??
          '',
      audioUrl: fullAudio,
      audioFullMap: fullAudioMap.isNotEmpty ? fullAudioMap : null,
      ayahs: ayahsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'nomor': number,
        'namaLatin': nameLatin,
        'nama': nameArabic,
        'jumlahAyat': numberOfAyahs,
        'arti': translation,
        'tempatTurun': revelation,
        'deskripsi': description,
        'audio_url': audioUrl,
        'audioFull': audioFullMap,
        'ayat': ayahs.map((a) => a.toJson()).toList(),
      };
}
