import 'package:flutter/material.dart';

enum HabitCategory {
  wajib,
  sunnah,
}

class HabitItem {
  final String id;
  final String title;
  final String subtitle;
  final HabitCategory category;
  final String categoryGroup; // 'Sholat Wajib', 'Sholat Sunnah', 'Puasa', 'Target Baca Al-Qur\'an', 'Doa', 'Dzikir'
  final IconData icon;
  final int points;
  final String timeSuggestion;
  final String timeSlot; // 'pagi', 'siang', 'sore', 'malam'
  final String scheduledTime; // e.g. '10:15 AM'
  final String? recordedTime; // e.g. '05:10 AM'
  final String frequency; // e.g. '1x Setiap Hari'
  bool isCompleted;
  bool isMuted;
  int streak;

  HabitItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.categoryGroup = 'Sholat Wajib',
    required this.icon,
    required this.points,
    required this.timeSuggestion,
    this.timeSlot = 'pagi',
    this.scheduledTime = '10:15 AM',
    this.recordedTime,
    this.frequency = '1x Setiap Hari',
    this.isCompleted = false,
    this.isMuted = false,
    this.streak = 0,
  });

  HabitItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    HabitCategory? category,
    String? categoryGroup,
    IconData? icon,
    int? points,
    String? timeSuggestion,
    String? timeSlot,
    String? scheduledTime,
    String? recordedTime,
    String? frequency,
    bool? isCompleted,
    bool? isMuted,
    int? streak,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      categoryGroup: categoryGroup ?? this.categoryGroup,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      timeSuggestion: timeSuggestion ?? this.timeSuggestion,
      timeSlot: timeSlot ?? this.timeSlot,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recordedTime: recordedTime ?? this.recordedTime,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      isMuted: isMuted ?? this.isMuted,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryGroup': categoryGroup,
      'isCompleted': isCompleted,
      'isMuted': isMuted,
      'recordedTime': recordedTime,
      'streak': streak,
    };
  }
}
