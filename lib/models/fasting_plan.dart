import 'package:flutter/material.dart';

enum FastingType {
  seninKamis,
  daud,
  syawal,
  ayyamulBidh,
  qadha,
  custom,
}

extension FastingTypeExt on FastingType {
  String get displayName {
    switch (this) {
      case FastingType.seninKamis:
        return 'Puasa Senin - Kamis';
      case FastingType.daud:
        return 'Puasa Daud';
      case FastingType.syawal:
        return 'Puasa Syawal';
      case FastingType.ayyamulBidh:
        return 'Puasa Ayyamul Bidh';
      case FastingType.qadha:
        return 'Puasa Qadha';
      case FastingType.custom:
        return 'Puasa Sunnah';
    }
  }

  String get description {
    switch (this) {
      case FastingType.seninKamis:
        return 'Sesuai sunnah Rasulullah SAW.';
      case FastingType.daud:
        return 'Sehari berpuasa, sehari berbuka.';
      case FastingType.syawal:
        return '6 hari setelah Idul Fitri.';
      case FastingType.ayyamulBidh:
        return 'Pertengahan bulan Hijriah (13, 14, 15).';
      case FastingType.qadha:
        return 'Mengganti puasa wajib yang tertinggal.';
      case FastingType.custom:
        return 'Puasa sunnah pilihan.';
    }
  }
}

enum FastingStatus {
  planned, // Direncanakan (Lingkaran hijau bergaris / centang)
  fasting, // Sedang Berpuasa
  completed, // Selesai (Hijau tua pekat)
  skipped, // Tidak Berpuasa / Batal (Pink / Merah)
}

enum SkippedReason {
  sakit,
  musafir,
  haid,
  nifas,
  hamilMenyusui,
  lainnya,
}

extension SkippedReasonExt on SkippedReason {
  String get displayName {
    switch (this) {
      case SkippedReason.sakit:
        return 'Sakit';
      case SkippedReason.musafir:
        return 'Musafir (Perjalanan)';
      case SkippedReason.haid:
        return 'Haid';
      case SkippedReason.nifas:
        return 'Nifas';
      case SkippedReason.hamilMenyusui:
        return 'Hamil atau Menyusui';
      case SkippedReason.lainnya:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case SkippedReason.sakit:
        return Icons.healing_rounded;
      case SkippedReason.musafir:
        return Icons.luggage_rounded;
      case SkippedReason.haid:
        return Icons.water_drop_rounded;
      case SkippedReason.nifas:
        return Icons.child_care_rounded;
      case SkippedReason.hamilMenyusui:
        return Icons.pregnant_woman_rounded;
      case SkippedReason.lainnya:
        return Icons.more_horiz_rounded;
    }
  }
}

class FastingPlan {
  final String id;
  final DateTime date;
  final FastingType type;
  final FastingStatus status;
  final SkippedReason? skippedReason;
  final String? skippedNotes;
  final DateTime? completedAt;

  const FastingPlan({
    required this.id,
    required this.date,
    required this.type,
    this.status = FastingStatus.planned,
    this.skippedReason,
    this.skippedNotes,
    this.completedAt,
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  FastingPlan copyWith({
    FastingStatus? status,
    SkippedReason? skippedReason,
    String? skippedNotes,
    DateTime? completedAt,
  }) {
    return FastingPlan(
      id: id,
      date: date,
      type: type,
      status: status ?? this.status,
      skippedReason: skippedReason ?? this.skippedReason,
      skippedNotes: skippedNotes ?? this.skippedNotes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.name,
        'status': status.name,
        'skippedReason': skippedReason?.name,
        'skippedNotes': skippedNotes,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory FastingPlan.fromJson(Map<String, dynamic> json) {
    return FastingPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: FastingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FastingType.seninKamis,
      ),
      status: FastingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FastingStatus.planned,
      ),
      skippedReason: json['skippedReason'] != null
          ? SkippedReason.values.firstWhere(
              (e) => e.name == json['skippedReason'],
              orElse: () => SkippedReason.lainnya,
            )
          : null,
      skippedNotes: json['skippedNotes'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class FastingAlarmConfig {
  final bool sahurAlarmEnabled;
  final int sahurHour;
  final int sahurMinute;
  final String sahurRingtone;
  final int snoozeDurationMinutes;
  final bool imsakWarningEnabled;

  final bool iftarAlarmEnabled;
  final String iftarRingtone;
  final bool iftarPreparationReminder;
  final int iftarPreparationMinutes;

  final bool applyToAllFastingDays;

  const FastingAlarmConfig({
    this.sahurAlarmEnabled = true,
    this.sahurHour = 3,
    this.sahurMinute = 30,
    this.sahurRingtone = 'Adzan Makkah',
    this.snoozeDurationMinutes = 5,
    this.imsakWarningEnabled = true,
    this.iftarAlarmEnabled = true,
    this.iftarRingtone = 'Bedug & Adzan',
    this.iftarPreparationReminder = true,
    this.iftarPreparationMinutes = 15,
    this.applyToAllFastingDays = true,
  });

  String get sahurTimeFormatted =>
      '${sahurHour.toString().padLeft(2, '0')}:${sahurMinute.toString().padLeft(2, '0')}';

  FastingAlarmConfig copyWith({
    bool? sahurAlarmEnabled,
    int? sahurHour,
    int? sahurMinute,
    String? sahurRingtone,
    int? snoozeDurationMinutes,
    bool? imsakWarningEnabled,
    bool? iftarAlarmEnabled,
    String? iftarRingtone,
    bool? iftarPreparationReminder,
    int? iftarPreparationMinutes,
    bool? applyToAllFastingDays,
  }) {
    return FastingAlarmConfig(
      sahurAlarmEnabled: sahurAlarmEnabled ?? this.sahurAlarmEnabled,
      sahurHour: sahurHour ?? this.sahurHour,
      sahurMinute: sahurMinute ?? this.sahurMinute,
      sahurRingtone: sahurRingtone ?? this.sahurRingtone,
      snoozeDurationMinutes: snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      imsakWarningEnabled: imsakWarningEnabled ?? this.imsakWarningEnabled,
      iftarAlarmEnabled: iftarAlarmEnabled ?? this.iftarAlarmEnabled,
      iftarRingtone: iftarRingtone ?? this.iftarRingtone,
      iftarPreparationReminder:
          iftarPreparationReminder ?? this.iftarPreparationReminder,
      iftarPreparationMinutes:
          iftarPreparationMinutes ?? this.iftarPreparationMinutes,
      applyToAllFastingDays:
          applyToAllFastingDays ?? this.applyToAllFastingDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'sahurAlarmEnabled': sahurAlarmEnabled,
        'sahurHour': sahurHour,
        'sahurMinute': sahurMinute,
        'sahurRingtone': sahurRingtone,
        'snoozeDurationMinutes': snoozeDurationMinutes,
        'imsakWarningEnabled': imsakWarningEnabled,
        'iftarAlarmEnabled': iftarAlarmEnabled,
        'iftarRingtone': iftarRingtone,
        'iftarPreparationReminder': iftarPreparationReminder,
        'iftarPreparationMinutes': iftarPreparationMinutes,
        'applyToAllFastingDays': applyToAllFastingDays,
      };

  factory FastingAlarmConfig.fromJson(Map<String, dynamic> json) {
    return FastingAlarmConfig(
      sahurAlarmEnabled: json['sahurAlarmEnabled'] as bool? ?? true,
      sahurHour: json['sahurHour'] as int? ?? 3,
      sahurMinute: json['sahurMinute'] as int? ?? 30,
      sahurRingtone: json['sahurRingtone'] as String? ?? 'Adzan Makkah',
      snoozeDurationMinutes: json['snoozeDurationMinutes'] as int? ?? 5,
      imsakWarningEnabled: json['imsakWarningEnabled'] as bool? ?? true,
      iftarAlarmEnabled: json['iftarAlarmEnabled'] as bool? ?? true,
      iftarRingtone: json['iftarRingtone'] as String? ?? 'Bedug & Adzan',
      iftarPreparationReminder:
          json['iftarPreparationReminder'] as bool? ?? true,
      iftarPreparationMinutes: json['iftarPreparationMinutes'] as int? ?? 15,
      applyToAllFastingDays: json['applyToAllFastingDays'] as bool? ?? true,
    );
  }
}
