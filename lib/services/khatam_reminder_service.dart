import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class KhatamReminderService {
  static final KhatamReminderService _instance = KhatamReminderService._internal();
  factory KhatamReminderService() => _instance;
  KhatamReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const int notificationIdMaghrib = 4001;
  static const int notificationIdFajr = 4002;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notifications.initialize(initSettings);

      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        await android.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('KhatamReminderService init error: $e');
    }
  }

  /// Menjadwalkan Pengingat Ba'da Maghrib
  Future<void> scheduleMaghribReminder({
    required String maghribTimeStr, // format: "18:15"
    required int currentJuz,
  }) async {
    await init();
    try {
      final parts = maghribTimeStr.split(':');
      if (parts.length < 2) return;
      int hour = int.tryParse(parts[0]) ?? 18;
      int minute = int.tryParse(parts[1]) ?? 15;

      // Tambah 15 menit (Ba'da Maghrib)
      minute += 15;
      if (minute >= 60) {
        hour = (hour + (minute ~/ 60)) % 24;
        minute = minute % 60;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'khatam_maghrib_channel',
        'Pengingat Khatam Ba\'da Maghrib',
        channelDescription: 'Pengingat membaca Al-Qur\'an setelah shalat Maghrib',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        notificationIdMaghrib,
        'Waktunya Murojaah Al-Qur\'an 🌙',
        'Waktunya melanjutkan perjalanan khatam Al-Qur\'an. Yuk, lanjutkan bacaan Juz $currentJuz hari ini.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling Maghrib reminder: $e');
    }
  }

  /// Menjadwalkan Pengingat Ba'da Fajr
  Future<void> scheduleFajrReminder({
    required String subuhTimeStr, // format: "04:35"
    required int currentJuz,
  }) async {
    await init();
    try {
      final parts = subuhTimeStr.split(':');
      if (parts.length < 2) return;
      int hour = int.tryParse(parts[0]) ?? 4;
      int minute = int.tryParse(parts[1]) ?? 35;

      // Tambah 20 menit (Ba'da Subuh / Fajr)
      minute += 20;
      if (minute >= 60) {
        hour = (hour + (minute ~/ 60)) % 24;
        minute = minute % 60;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'khatam_fajr_channel',
        'Pengingat Khatam Ba\'da Fajr',
        channelDescription: 'Pengingat membaca Al-Qur\'an setelah shalat Subuh',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        notificationIdFajr,
        'Waktu Terbaik Menghafal & Tilawah ☀️',
        'Awali pagimu dengan keberkahan kalam Ilahi. Lanjutkan bacaan Juz $currentJuz.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling Fajr reminder: $e');
    }
  }

  Future<void> cancelMaghribReminder() async {
    await _notifications.cancel(notificationIdMaghrib);
  }

  Future<void> cancelFajrReminder() async {
    await _notifications.cancel(notificationIdFajr);
  }

  Future<void> cancelAll() async {
    await _notifications.cancel(notificationIdMaghrib);
    await _notifications.cancel(notificationIdFajr);
  }
}
