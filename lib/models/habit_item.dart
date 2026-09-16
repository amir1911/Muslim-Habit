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
  final IconData icon;
  final int points;
  final String timeSuggestion;
  bool isCompleted;
  int streak;

  HabitItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.points,
    required this.timeSuggestion,
    this.isCompleted = false,
    this.streak = 0,
  });

  HabitItem copyWith({
    bool? isCompleted,
    int? streak,
  }) {
    return HabitItem(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      icon: icon,
      points: points,
      timeSuggestion: timeSuggestion,
      isCompleted: isCompleted ?? this.isCompleted,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isCompleted': isCompleted,
      'streak': streak,
    };
  }
}
