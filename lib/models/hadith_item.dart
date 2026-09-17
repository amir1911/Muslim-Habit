class HadithItem {
  final int id;
  final String arabicText;
  final String translation;
  final String takhrij;
  final String grade;
  final String? hikmah;

  HadithItem({
    required this.id,
    required this.arabicText,
    required this.translation,
    required this.takhrij,
    required this.grade,
    this.hikmah,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    String ar = '';
    String idText = '';

    if (json['text'] is Map) {
      final t = json['text'] as Map<String, dynamic>;
      ar = t['ar'] as String? ?? '';
      idText = t['id'] as String? ?? '';
    } else if (json['arabic_text'] != null || json['translation'] != null) {
      ar = json['arabic_text'] as String? ?? '';
      idText = json['translation'] as String? ?? '';
    }

    // Pembersihan teks jika ada tag HTML
    idText = idText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    ar = ar.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return HadithItem(
      id: json['id'] as int? ?? 1,
      arabicText: ar,
      translation: idText,
      takhrij: json['takhrij'] as String? ?? 'HR. Bukhari & Muslim',
      grade: json['grade'] as String? ?? 'Hadis sahih',
      hikmah: json['hikmah'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic_text': arabicText,
      'translation': translation,
      'takhrij': takhrij,
      'grade': grade,
      'hikmah': hikmah,
    };
  }

  factory HadithItem.defaultHadith() {
    return HadithItem(
      id: 1,
      arabicText: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      translation: 'Sebaik-baik kalian adalah orang yang mempelajari Al-Qur\'an dan mengajarkannya.',
      takhrij: 'HR. Bukhari',
      grade: 'Hadis sahih',
      hikmah: 'Menuntut ilmu Al-Qur\'an dan mengamalkannya serta mengajarkannya kepada sesama adalah amalan yang paling mulia.',
    );
  }
}
