import 'package:flutter/material.dart';

/// Kategori notifikasi dalam aplikasi Muslim Habit
enum AppNotificationCategory {
  ibadah, // Pengingat sholat, adzan, sahur, dsb.
  habit,  // Target habit harian belum selesai
  streak, // Motivasi streak & istiqomah
  info,   // Pengumuman, inspirasi ayat/hadits
}

/// Model Notifikasi Aplikasi Muslim Habit
class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final AppNotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String? route; // Route tujuan ketika notifikasi diklik
  final Map<String, dynamic>? data;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.route,
    this.data,
  });

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    AppNotificationCategory? category,
    DateTime? timestamp,
    bool? isRead,
    String? route,
    Map<String, dynamic>? data,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'route': route,
      'data': data,
    };
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    AppNotificationCategory cat = AppNotificationCategory.info;
    final catStr = map['category'] as String?;
    if (catStr != null) {
      for (final c in AppNotificationCategory.values) {
        if (c.name == catStr) {
          cat = c;
          break;
        }
      }
    }

    DateTime dt = DateTime.now();
    if (map['timestamp'] != null) {
      dt = DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now();
    }

    return AppNotificationModel(
      id: map['id']?.toString() ?? UniqueKey().toString(),
      title: map['title']?.toString() ?? 'Pemberitahuan',
      message: map['message']?.toString() ?? '',
      category: cat,
      timestamp: dt,
      isRead: map['isRead'] as bool? ?? false,
      route: map['route']?.toString(),
      data: map['data'] != null ? Map<String, dynamic>.from(map['data'] as Map) : null,
    );
  }

  IconData get iconData {
    switch (category) {
      case AppNotificationCategory.ibadah:
        return Icons.mosque_rounded;
      case AppNotificationCategory.habit:
        return Icons.check_circle_outline_rounded;
      case AppNotificationCategory.streak:
        return Icons.local_fire_department_rounded;
      case AppNotificationCategory.info:
        return Icons.info_outline_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case AppNotificationCategory.ibadah:
        return const Color(0xFF518427);
      case AppNotificationCategory.habit:
        return const Color(0xFF2563EB);
      case AppNotificationCategory.streak:
        return const Color(0xFFF59E0B);
      case AppNotificationCategory.info:
        return const Color(0xFF8B5CF6);
    }
  }
}
