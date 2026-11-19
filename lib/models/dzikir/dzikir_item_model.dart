class DzikirItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String arabic;
  final String transliteration;
  final String translation;
  final int defaultTarget;
  final String source;
  final String note;

  DzikirItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.defaultTarget = 33,
    required this.source,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'defaultTarget': defaultTarget,
      'source': source,
      'note': note,
    };
  }

  factory DzikirItemModel.fromJson(Map<String, dynamic> json) {
    return DzikirItemModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      defaultTarget: json['defaultTarget'] as int? ?? 33,
      source: json['source'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }
}
