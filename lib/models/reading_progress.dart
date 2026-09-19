/// Model untuk menyimpan progress membaca Al-Qur'an per surah.
/// Dirancang agar mudah di-migrate ke backend/database.
class ReadingProgress {
  final String userId;
  final int surahId;
  final String surahName;
  final int totalAyahs;

  /// Kumpulan nomor ayat yang sudah dibaca (idempotent — tidak double count)
  final Set<int> readVerseNumbers;

  /// Nomor ayat terakhir yang dibaca
  final int lastReadVerse;

  final DateTime? readAt;
  final DateTime updatedAt;

  ReadingProgress({
    required this.userId,
    required this.surahId,
    required this.surahName,
    required this.totalAyahs,
    Set<int>? readVerseNumbers,
    this.lastReadVerse = 0,
    this.readAt,
    DateTime? updatedAt,
  })  : readVerseNumbers = readVerseNumbers ?? {},
        updatedAt = updatedAt ?? DateTime.now();

  int get readCount => readVerseNumbers.length;

  double get progress =>
      totalAyahs > 0 ? (readVerseNumbers.length / totalAyahs).clamp(0.0, 1.0) : 0.0;

  double get progressPercent => progress * 100;

  bool isRead(int ayahNumber) => readVerseNumbers.contains(ayahNumber);

  /// Tandai ayat sebagai sudah dibaca — idempotent, tidak double count
  ReadingProgress markRead(int ayahNumber) {
    if (readVerseNumbers.contains(ayahNumber)) return this;
    return copyWith(
      readVerseNumbers: {...readVerseNumbers, ayahNumber},
      lastReadVerse: ayahNumber,
      updatedAt: DateTime.now(),
    );
  }

  ReadingProgress copyWith({
    String? userId,
    int? surahId,
    String? surahName,
    int? totalAyahs,
    Set<int>? readVerseNumbers,
    int? lastReadVerse,
    DateTime? readAt,
    DateTime? updatedAt,
  }) {
    return ReadingProgress(
      userId: userId ?? this.userId,
      surahId: surahId ?? this.surahId,
      surahName: surahName ?? this.surahName,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      readVerseNumbers: readVerseNumbers ?? Set.from(this.readVerseNumbers),
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
      readAt: readAt ?? this.readAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'surah_id': surahId,
        'surah_name': surahName,
        'total_ayahs': totalAyahs,
        'read_verse_numbers': readVerseNumbers.toList(),
        'last_read_verse': lastReadVerse,
        'read_at': readAt?.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    final readList = (json['read_verse_numbers'] as List?)
            ?.map((e) => e as int)
            .toSet() ??
        {};
    return ReadingProgress(
      userId: json['user_id'] as String? ?? 'local',
      surahId: json['surah_id'] as int? ?? 1,
      surahName: json['surah_name'] as String? ?? '',
      totalAyahs: json['total_ayahs'] as int? ?? 0,
      readVerseNumbers: readList,
      lastReadVerse: json['last_read_verse'] as int? ?? 0,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory ReadingProgress.empty({
    required int surahId,
    required String surahName,
    required int totalAyahs,
  }) {
    return ReadingProgress(
      userId: 'local',
      surahId: surahId,
      surahName: surahName,
      totalAyahs: totalAyahs,
      readVerseNumbers: {},
      lastReadVerse: 0,
      readAt: DateTime.now(),
    );
  }
}
