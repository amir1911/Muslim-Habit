import 'dart:convert';

/// Metadata range Juz Al-Qur'an (1..30)
class JuzMetadata {
  final int juzNumber;
  final String name; // Misal: "Al-Baqarah", "Al-Hijr"
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final int totalAyahs;

  const JuzMetadata({
    required this.juzNumber,
    required this.name,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.totalAyahs,
  });

  /// Daftar lengkap 30 Juz Al-Qur'an
  static const List<JuzMetadata> allJuz = [
    JuzMetadata(juzNumber: 1, name: 'Al-Fatihah', startSurah: 1, startAyah: 1, endSurah: 2, endAyah: 141, totalAyahs: 148),
    JuzMetadata(juzNumber: 2, name: 'Al-Baqarah', startSurah: 2, startAyah: 142, endSurah: 2, endAyah: 252, totalAyahs: 111),
    JuzMetadata(juzNumber: 3, name: 'Ali \'Imran', startSurah: 2, startAyah: 253, endSurah: 3, endAyah: 92, totalAyahs: 126),
    JuzMetadata(juzNumber: 4, name: 'An-Nisa\'', startSurah: 3, startAyah: 93, endSurah: 4, endAyah: 23, totalAyahs: 131),
    JuzMetadata(juzNumber: 5, name: 'An-Nisa\'', startSurah: 4, startAyah: 24, endSurah: 4, endAyah: 147, totalAyahs: 124),
    JuzMetadata(juzNumber: 6, name: 'Al-Ma\'idah', startSurah: 4, startAyah: 148, endSurah: 5, endAyah: 81, totalAyahs: 110),
    JuzMetadata(juzNumber: 7, name: 'Al-An\'am', startSurah: 5, startAyah: 82, endSurah: 6, endAyah: 110, totalAyahs: 149),
    JuzMetadata(juzNumber: 8, name: 'Al-A\'raf', startSurah: 6, startAyah: 111, endSurah: 7, endAyah: 87, totalAyahs: 142),
    JuzMetadata(juzNumber: 9, name: 'Al-Anfal', startSurah: 7, startAyah: 88, endSurah: 8, endAyah: 40, totalAyahs: 159),
    JuzMetadata(juzNumber: 10, name: 'At-Taubah', startSurah: 8, startAyah: 41, endSurah: 9, endAyah: 92, totalAyahs: 127),
    JuzMetadata(juzNumber: 11, name: 'Yunus', startSurah: 9, startAyah: 93, endSurah: 11, endAyah: 5, totalAyahs: 151),
    JuzMetadata(juzNumber: 12, name: 'Hud', startSurah: 11, startAyah: 6, endSurah: 12, endAyah: 52, totalAyahs: 170),
    JuzMetadata(juzNumber: 13, name: 'Yusuf', startSurah: 12, startAyah: 53, endSurah: 14, endAyah: 52, totalAyahs: 154),
    JuzMetadata(juzNumber: 14, name: 'Al-Hijr', startSurah: 15, startAyah: 1, endSurah: 16, endAyah: 128, totalAyahs: 227),
    JuzMetadata(juzNumber: 15, name: 'Al-Isra\'', startSurah: 17, startAyah: 1, endSurah: 18, endAyah: 74, totalAyahs: 185),
    JuzMetadata(juzNumber: 16, name: 'Al-Kahf', startSurah: 18, startAyah: 75, endSurah: 20, endAyah: 135, totalAyahs: 269),
    JuzMetadata(juzNumber: 17, name: 'Al-Anbiya\'', startSurah: 21, startAyah: 1, endSurah: 22, endAyah: 78, totalAyahs: 190),
    JuzMetadata(juzNumber: 18, name: 'Al-Mu\'minun', startSurah: 23, startAyah: 1, endSurah: 25, endAyah: 20, totalAyahs: 202),
    JuzMetadata(juzNumber: 19, name: 'Al-Furqan', startSurah: 25, startAyah: 21, endSurah: 27, endAyah: 55, totalAyahs: 339),
    JuzMetadata(juzNumber: 20, name: 'An-Naml', startSurah: 27, startAyah: 56, endSurah: 29, endAyah: 45, totalAyahs: 171),
    JuzMetadata(juzNumber: 21, name: 'Al-\'Ankabut', startSurah: 29, startAyah: 46, endSurah: 33, endAyah: 30, totalAyahs: 178),
    JuzMetadata(juzNumber: 22, name: 'Al-Ahzab', startSurah: 33, startAyah: 31, endSurah: 36, endAyah: 27, totalAyahs: 169),
    JuzMetadata(juzNumber: 23, name: 'Ya Sin', startSurah: 36, startAyah: 28, endSurah: 39, endAyah: 31, totalAyahs: 357),
    JuzMetadata(juzNumber: 24, name: 'Az-Zumar', startSurah: 39, startAyah: 32, endSurah: 41, endAyah: 46, totalAyahs: 175),
    JuzMetadata(juzNumber: 25, name: 'Fussilat', startSurah: 41, startAyah: 47, endSurah: 45, endAyah: 37, totalAyahs: 246),
    JuzMetadata(juzNumber: 26, name: 'Al-Ahqaf', startSurah: 46, startAyah: 1, endSurah: 51, endAyah: 30, totalAyahs: 195),
    JuzMetadata(juzNumber: 27, name: 'Az-Zariyat', startSurah: 51, startAyah: 31, endSurah: 57, endAyah: 29, totalAyahs: 399),
    JuzMetadata(juzNumber: 28, name: 'Al-Mujadilah', startSurah: 58, startAyah: 1, endSurah: 66, endAyah: 12, totalAyahs: 137),
    JuzMetadata(juzNumber: 29, name: 'Al-Mulk', startSurah: 67, startAyah: 1, endSurah: 77, endAyah: 50, totalAyahs: 431),
    JuzMetadata(juzNumber: 30, name: 'An-Naba\'', startSurah: 78, startAyah: 1, endSurah: 114, endAyah: 6, totalAyahs: 564),
  ];

  static JuzMetadata getByJuzNumber(int juz) {
    if (juz < 1) return allJuz.first;
    if (juz > 30) return allJuz.last;
    return allJuz[juz - 1];
  }
}

/// Rencana & Progres Mode Khatam Al-Qur'an
class KhatamPlanModel {
  final String planId;
  final String userId;
  final DateTime startDate;
  final int targetDuration; // Durasi total dalam hari (misal 30)
  final int targetQuantity; // Jumlah target (misal 1 atau 2)
  final String targetUnit; // 'juz' atau 'ayat'
  final String targetPeriod; // 'hari' atau 'minggu'
  final double dailyJuzTarget; // Dihitung: target Juz per hari (misal 1.0)
  final int currentJuz; // Juz yang sedang aktif dibaca (1..30)
  final int currentSurah;
  final int currentAyah;
  final double progressPercentage; // 0.0 .. 100.0
  final String status; // 'active', 'completed', 'paused'
  final DateTime createdAt;
  final DateTime? completedAt;
  final Set<int> completedJuzList;
  final Set<String> readAyahKeys; // Format: 'surahNumber:ayahNumber'
  final bool reminderMaghrib;
  final bool reminderFajr;

  KhatamPlanModel({
    required this.planId,
    this.userId = 'user_default',
    required this.startDate,
    this.targetDuration = 30,
    this.targetQuantity = 1,
    this.targetUnit = 'juz',
    this.targetPeriod = 'hari',
    this.dailyJuzTarget = 1.0,
    this.currentJuz = 1,
    this.currentSurah = 1,
    this.currentAyah = 1,
    this.progressPercentage = 0.0,
    this.status = 'active',
    DateTime? createdAt,
    this.completedAt,
    Set<int>? completedJuzList,
    Set<String>? readAyahKeys,
    this.reminderMaghrib = true,
    this.reminderFajr = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        completedJuzList = completedJuzList ?? <int>{},
        readAyahKeys = readAyahKeys ?? <String>{};

  int get completedJuzCount => completedJuzList.length;

  int get estimatedDaysRemaining {
    final remainingJuz = (30 - completedJuzCount).clamp(0, 30);
    if (dailyJuzTarget <= 0) return 30;
    return (remainingJuz / dailyJuzTarget).ceil();
  }

  int get nextAchievementJuz {
    final next = currentJuz + 1;
    return next <= 30 ? next : 30;
  }

  KhatamPlanModel copyWith({
    String? planId,
    String? userId,
    DateTime? startDate,
    int? targetDuration,
    int? targetQuantity,
    String? targetUnit,
    String? targetPeriod,
    double? dailyJuzTarget,
    int? currentJuz,
    int? currentSurah,
    int? currentAyah,
    double? progressPercentage,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    Set<int>? completedJuzList,
    Set<String>? readAyahKeys,
    bool? reminderMaghrib,
    bool? reminderFajr,
  }) {
    return KhatamPlanModel(
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      targetDuration: targetDuration ?? this.targetDuration,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      targetUnit: targetUnit ?? this.targetUnit,
      targetPeriod: targetPeriod ?? this.targetPeriod,
      dailyJuzTarget: dailyJuzTarget ?? this.dailyJuzTarget,
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completedJuzList: completedJuzList ?? Set<int>.from(this.completedJuzList),
      readAyahKeys: readAyahKeys ?? Set<String>.from(this.readAyahKeys),
      reminderMaghrib: reminderMaghrib ?? this.reminderMaghrib,
      reminderFajr: reminderFajr ?? this.reminderFajr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'targetDuration': targetDuration,
      'targetQuantity': targetQuantity,
      'targetUnit': targetUnit,
      'targetPeriod': targetPeriod,
      'dailyJuzTarget': dailyJuzTarget,
      'currentJuz': currentJuz,
      'currentSurah': currentSurah,
      'currentAyah': currentAyah,
      'progressPercentage': progressPercentage,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completedJuzList': completedJuzList.toList(),
      'readAyahKeys': readAyahKeys.toList(),
      'reminderMaghrib': reminderMaghrib,
      'reminderFajr': reminderFajr,
    };
  }

  factory KhatamPlanModel.fromJson(Map<String, dynamic> json) {
    return KhatamPlanModel(
      planId: json['planId'] as String? ?? 'plan_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['userId'] as String? ?? 'user_default',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      targetDuration: json['targetDuration'] as int? ?? 30,
      targetQuantity: json['targetQuantity'] as int? ?? 1,
      targetUnit: json['targetUnit'] as String? ?? 'juz',
      targetPeriod: json['targetPeriod'] as String? ?? 'hari',
      dailyJuzTarget: (json['dailyJuzTarget'] as num?)?.toDouble() ?? 1.0,
      currentJuz: json['currentJuz'] as int? ?? 1,
      currentSurah: json['currentSurah'] as int? ?? 1,
      currentAyah: json['currentAyah'] as int? ?? 1,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      completedJuzList: json['completedJuzList'] is List
          ? (json['completedJuzList'] as List).map((e) => (e as num).toInt()).toSet()
          : <int>{},
      readAyahKeys: json['readAyahKeys'] is List
          ? (json['readAyahKeys'] as List).map((e) => e.toString()).toSet()
          : <String>{},
      reminderMaghrib: json['reminderMaghrib'] as bool? ?? true,
      reminderFajr: json['reminderFajr'] as bool? ?? false,
    );
  }
}
