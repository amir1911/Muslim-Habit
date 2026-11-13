class PrayerAlarmModel {
  final String prayerKey; // 'subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'
  final String name; // 'Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'
  final String customTime; // '18:10'
  final bool isAlarmActive;
  final bool isSnoozeActive;
  final int snoozeMinutes; // 5
  final bool isVibrateActive;
  final bool applyToAllDays;

  const PrayerAlarmModel({
    required this.prayerKey,
    required this.name,
    required this.customTime,
    this.isAlarmActive = true,
    this.isSnoozeActive = true,
    this.snoozeMinutes = 5,
    this.isVibrateActive = true,
    this.applyToAllDays = true,
  });

  PrayerAlarmModel copyWith({
    String? customTime,
    bool? isAlarmActive,
    bool? isSnoozeActive,
    int? snoozeMinutes,
    bool? isVibrateActive,
    bool? applyToAllDays,
  }) {
    return PrayerAlarmModel(
      prayerKey: prayerKey,
      name: name,
      customTime: customTime ?? this.customTime,
      isAlarmActive: isAlarmActive ?? this.isAlarmActive,
      isSnoozeActive: isSnoozeActive ?? this.isSnoozeActive,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      isVibrateActive: isVibrateActive ?? this.isVibrateActive,
      applyToAllDays: applyToAllDays ?? this.applyToAllDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayerKey': prayerKey,
      'name': name,
      'customTime': customTime,
      'isAlarmActive': isAlarmActive,
      'isSnoozeActive': isSnoozeActive,
      'snoozeMinutes': snoozeMinutes,
      'isVibrateActive': isVibrateActive,
      'applyToAllDays': applyToAllDays,
    };
  }

  factory PrayerAlarmModel.fromJson(Map<String, dynamic> json) {
    return PrayerAlarmModel(
      prayerKey: json['prayerKey'] as String? ?? 'subuh',
      name: json['name'] as String? ?? 'Subuh',
      customTime: json['customTime'] as String? ?? '05:15',
      isAlarmActive: json['isAlarmActive'] as bool? ?? true,
      isSnoozeActive: json['isSnoozeActive'] as bool? ?? true,
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      isVibrateActive: json['isVibrateActive'] as bool? ?? true,
      applyToAllDays: json['applyToAllDays'] as bool? ?? true,
    );
  }
}
