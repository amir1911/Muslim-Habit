import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'storage_service.dart';
import '../models/prayer_schedule.dart';
import '../models/fasting_plan.dart';
import '../models/habit_item.dart';

/// Payload tipe navigasi saat notifikasi diklik pengguna
class SmartNotificationPayload {
  final String target; // 'dzikir_pagi', 'dzikir_petang', 'quran', 'sholat', 'puasa', 'habit', 'streak', 'progress'
  final String? habitId;
  final Map<String, dynamic>? extra;

  const SmartNotificationPayload({
    required this.target,
    this.habitId,
    this.extra,
  });

  Map<String, dynamic> toMap() => {
        'target': target,
        if (habitId != null) 'habitId': habitId,
        if (extra != null) 'extra': extra,
      };

  factory SmartNotificationPayload.fromMap(Map<String, dynamic> map) => SmartNotificationPayload(
        target: map['target'] ?? '',
        habitId: map['habitId'],
        extra: map['extra'],
      );

  String toJson() => jsonEncode(toMap());

  static SmartNotificationPayload? fromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr);
      if (map is Map<String, dynamic>) {
        return SmartNotificationPayload.fromMap(map);
      }
    } catch (_) {}
    return null;
  }
}

/// Model riwayat notifikasi lokal yang tersimpan
class SmartNotificationHistoryItem {
  final String id;
  final String title;
  final String body;
  final String target;
  final DateTime timestamp;
  final bool isRead;

  SmartNotificationHistoryItem({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'target': target,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory SmartNotificationHistoryItem.fromJson(Map<String, dynamic> json) =>
      SmartNotificationHistoryItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        target: json['target'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        isRead: json['isRead'] ?? false,
      );
}

/// Core Smart Notification Engine untuk Muslim Habit
class SmartNotificationService extends ChangeNotifier {
  static final SmartNotificationService _instance = SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  StorageService? _storageService;
  bool _isInitialized = false;

  // Global navigator key untuk mengarahkan pengguna saat notifikasi diklik
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Stream controller untuk aksi notifikasi klik
  final StreamController<SmartNotificationPayload> _payloadController =
      StreamController<SmartNotificationPayload>.broadcast();
  Stream<SmartNotificationPayload> get onNotificationClick => _payloadController.stream;

  // ID Channels & Notification IDs
  static const String channelSmartReminders = 'muslim_habit_smart_reminders';
  static const String channelAdzanShubuh = 'adzan_subuh_channel';
  static const String channelAdzanRegular = 'adzan_regular_channel';
  static const String channelProgress = 'muslim_habit_progress_channel';

  // Base IDs
  static const int idAdzanSubuh = 1001;
  static const int idAdzanDzuhur = 1002;
  static const int idAdzanAshar = 1003;
  static const int idAdzanMaghrib = 1004;
  static const int idAdzanIsya = 1005;

  static const int idSahurReminder = 2001;
  static const int idImsakReminder = 2002;
  static const int idBukaPuasaReminder = 2003;

  static const int idDzikirPagi = 3001;
  static const int idDzikirPetang = 3002;
  static const int idDoaPagi = 3003;
  static const int idTilawahReminder = 3004;
  static const int idStreakReminder = 3005;
  static const int idDailyProgress = 3006;
  static const int idDailyAppreciation = 3007;

  // Riwayat notifikasi
  List<SmartNotificationHistoryItem> _history = [];
  List<SmartNotificationHistoryItem> get history => List.unmodifiable(_history);

  // Variasi Pesan Ramah Maskot Nunu
  final List<String> _nunuGreetingMorning = [
    "Assalamu'alaikum! Nunu mau mengingatkanmu untuk memulai hari dengan mengingat Allah.",
    "Pagi yang penuh berkah! Yuk, luangkan waktu sejenak untuk Dzikir Pagi bersama Nunu.",
    "Bismillah! Awali harimu dengan zikir agar langkahmu selalu dimudahkan Allah.",
  ];

  final List<String> _nunuGreetingQuran = [
    "Yuk, luangkan sedikit waktu untuk tilawah Al-Qur'an hari ini. Satu ayat penuh pahala!",
    "Al-Qur'an adalah penyejuk hati. Nunu temani kamu membaca lembaran berkah hari ini ya.",
    "Sudahkah membaca Al-Qur'an hari ini? Yuk, jangan biarkan harimu berlalu tanpa kalam-Nya.",
  ];

  final List<String> _nunuStreakEncouragement = [
    "Jangan sampai streak ibadahmu terputus! Nunu selalu mendukung keistiqamahanmu.",
    "Keren banget konsistensimu! Yuk selesaikan habit hari ini agar streak-mu terus bertambah.",
    "Sedikit lagi target hari ini selesai! Pertahankan streak kebaikanmu ya sahabatku.",
  ];

  final List<String> _nunuProgressReminder = [
    "Semangat! Masih ada beberapa target ibadah yang belum kamu selesaikan hari ini.",
    "Hari hampir berganti, yuk tuntaskan sisa habitmu hari ini bersama Nunu!",
  ];

  final List<String> _nunuCompletedPraise = [
    "MasyaAllah! Semua target ibadah hari ini berhasil diselesaikan. Nunu bangga banget sama kamu!",
    "Alhamdulillah, tuntas 100%! Semoga Allah menerima semua amal ibadahmu hari ini.",
  ];

  // Inisialisasi Service
  Future<void> init(StorageService storageService) async {
    if (_isInitialized) return;
    _storageService = storageService;

    // Timezone
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}

    // Android & iOS Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _notificationBackgroundTapHandler,
    );

    await _createChannels();
    _loadHistory();
    _isInitialized = true;
  }

  // Buat Notification Channels di Android
  Future<void> _createChannels() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl == null) return;

    // 1. Channel Smart Reminders (Default/Silent/Sound)
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        channelSmartReminders,
        'Pengingat Ibadah Muslim Habit',
        description: 'Notifikasi pintar pengingat habit, dzikir, doa, dan Al-Quran.',
        importance: Importance.high,
        enableVibration: true,
      ),
    );

    // 2. Channel Adzan Shubuh dengan Sound khusus adzan_shubuh
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        channelAdzanShubuh,
        'Adzan Shubuh',
        description: 'Panggilan adzan waktu sholat Shubuh',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('adzan_shubuh'),
        playSound: true,
        enableVibration: true,
      ),
    );

    // 3. Channel Adzan Regular dengan Sound adzan
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        channelAdzanRegular,
        'Waktu Sholat & Adzan',
        description: 'Panggilan adzan waktu sholat Dzuhur, Ashar, Maghrib, dan Isya',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('adzan'),
        playSound: true,
        enableVibration: true,
      ),
    );

    // 4. Channel Progres & Streak
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        channelProgress,
        'Progres & Streak Ibadah',
        description: 'Apresiasi dan pengingat target harian serta streak ibadah.',
        importance: Importance.defaultImportance,
      ),
    );
  }

  // =========================================================================
  // 1. EVALUASI DAN SINKRONISASI PINTAR HABIT & DZIKIR & DOA & AL-QUR'AN
  // =========================================================================
  Future<void> syncSmartHabitReminders({
    required List<HabitItem> habits,
    required int streakCount,
    required bool hasReadQuranToday,
    required bool hasReadDzikirPagiToday,
    required bool hasReadDzikirPetangToday,
    required bool hasReadDoaToday,
  }) async {
    final bool remindersEnabled = _storageService?.getHabitRemindersEnabled() ?? true;
    if (!remindersEnabled) {
      await cancelAllSmartReminders();
      return;
    }

    final now = DateTime.now();

    // ── A. DZIKIR PAGI PINTAR (Contoh: jam 06.00) ──
    if (hasReadDzikirPagiToday) {
      // Jika sudah selesai, BATALKAN notifikasi
      await cancelNotification(idDzikirPagi);
    } else {
      // Jika belum selesai dan waktu sekarang belum melewati batas pagi (misal jam 09.00)
      if (now.hour < 9) {
        final randomGreeting = _nunuGreetingMorning[Random().nextInt(_nunuGreetingMorning.length)];
        await scheduleSmartReminder(
          id: idDzikirPagi,
          title: "Nunu • Waktunya Dzikir Pagi 🌅",
          body: randomGreeting,
          targetTime: _nextInstanceOfTime(6, 0),
          payload: const SmartNotificationPayload(target: 'dzikir_pagi'),
        );
      }
    }

    // ── B. DZIKIR PETANG PINTAR (Contoh: jam 16.30) ──
    if (hasReadDzikirPetangToday) {
      await cancelNotification(idDzikirPetang);
    } else {
      if (now.hour < 18) {
        await scheduleSmartReminder(
          id: idDzikirPetang,
          title: "Nunu • Dzikir Petang Menjelang Senja 🌇",
          body: "Sore yang tenang. Yuk luangkan waktu membaca Dzikir Petang agar hati selalu tenteram.",
          targetTime: _nextInstanceOfTime(16, 30),
          payload: const SmartNotificationPayload(target: 'dzikir_petang'),
        );
      }
    }

    // ── C. AL-QUR'AN / TILAWAH PINTAR ──
    if (hasReadQuranToday) {
      await cancelNotification(idTilawahReminder);
    } else {
      if (now.hour < 21) {
        final randomQuran = _nunuGreetingQuran[Random().nextInt(_nunuGreetingQuran.length)];
        await scheduleSmartReminder(
          id: idTilawahReminder,
          title: "Nunu • Sudahkah Tilawah Hari Ini? 📖",
          body: randomQuran,
          targetTime: _nextInstanceOfTime(19, 30),
          payload: const SmartNotificationPayload(target: 'quran'),
        );
      }
    }

    // ── D. PROGRES HARIAN & STREAK EVALUATION (Jam 20:30 Malam) ──
    final int uncompletedCount = habits.where((h) => !h.isCompleted).length;
    final int completedCount = habits.where((h) => h.isCompleted).length;

    if (uncompletedCount == 0 && habits.isNotEmpty) {
      // Semua target selesai: Batalkan pengingat sisa, kirim apresiasi jika belum pernah dikirim hari ini
      await cancelNotification(idDailyProgress);
      await cancelNotification(idStreakReminder);

      final String todayKey = '${now.year}-${now.month}-${now.day}';
      final String lastAppreciation = _storageService?.getString('last_appreciation_date') ?? '';
      if (lastAppreciation != todayKey && now.hour >= 18) {
        await _storageService?.setString('last_appreciation_date', todayKey);
        final randomPraise = _nunuCompletedPraise[Random().nextInt(_nunuCompletedPraise.length)];
        await showInstantNotification(
          id: idDailyAppreciation,
          title: "Nunu • Target Hari Ini Tuntas! 🌟",
          body: randomPraise,
          payload: const SmartNotificationPayload(target: 'progress'),
        );
      }
    } else if (uncompletedCount > 0) {
      // Masih ada target belum selesai: Jadwalkan pengingat jam 20:15
      final randomStreak = _nunuStreakEncouragement[Random().nextInt(_nunuStreakEncouragement.length)];
      final streakText = streakCount > 0 ? " Jaga streak $streakCount harimu!" : "";

      await scheduleSmartReminder(
        id: idDailyProgress,
        title: "Nunu • Masih ada $uncompletedCount Target Hari Ini 🌿",
        body: "Semangat! Selesaikan $uncompletedCount habit sebelum hari berakhir.$streakText",
        targetTime: _nextInstanceOfTime(20, 15),
        payload: const SmartNotificationPayload(target: 'habit'),
      );
    }
  }

  // =========================================================================
  // 2. SINKRONISASI NOTIFIKASI PUASA PINTAR (SAHUR, IMSAK, BUKA)
  // =========================================================================
  Future<void> syncSmartFastingReminders({
    required FastingPlan? todayPlan,
    required FastingPlan? tomorrowPlan,
    required PrayerSchedule? prayerSchedule,
    required bool alarmSahurEnabled,
    required bool alarmIftarEnabled,
    required String ringtoneSahur,
    required String ringtoneIftar,
  }) async {
    // A. Buka Puasa Hari Ini
    if (todayPlan != null && todayPlan.status != FastingStatus.skipped) {
      if (alarmIftarEnabled && prayerSchedule != null) {
        final maghribTime = _parseTimeOnDate(todayPlan.date, prayerSchedule.maghrib);
        if (maghribTime.isAfter(DateTime.now())) {
          await scheduleSmartReminder(
            id: idBukaPuasaReminder,
            title: "Selamat Berbuka Puasa! 🌙",
            body: "Waktu Maghrib telah tiba. Selamat menunaikan ibadah buka puasa untuk ${todayPlan.type.displayName}.",
            targetTime: maghribTime,
            payload: const SmartNotificationPayload(target: 'puasa'),
            channelId: channelAdzanRegular,
          );
        }
      }
    } else {
      // Pengguna tidak puasa hari ini → Jangan kirim notifikasi buka puasa
      await cancelNotification(idBukaPuasaReminder);
    }

    // B. Sahur & Imsak Besok (hanya jika ada rencana puasa besok)
    if (tomorrowPlan != null && tomorrowPlan.status != FastingStatus.skipped) {
      if (alarmSahurEnabled && prayerSchedule != null) {
        final shubuhTomorrow = _parseTimeOnDate(tomorrowPlan.date, prayerSchedule.subuh);

        // Sahur: 1 jam 15 menit sebelum Shubuh
        final sahurTime = shubuhTomorrow.subtract(const Duration(minutes: 75));
        if (sahurTime.isAfter(DateTime.now())) {
          await scheduleSmartReminder(
            id: idSahurReminder,
            title: "Nunu • Waktunya Sahur 🥣",
            body: "Bangun yuk! Persiapkan santap sahur untuk puasa ${tomorrowPlan.type.displayName} hari ini.",
            targetTime: sahurTime,
            payload: const SmartNotificationPayload(target: 'puasa'),
            channelId: channelSmartReminders,
          );
        }

        // Imsak: 10 menit sebelum Shubuh
        final imsakTime = shubuhTomorrow.subtract(const Duration(minutes: 10));
        if (imsakTime.isAfter(DateTime.now())) {
          await scheduleSmartReminder(
            id: idImsakReminder,
            title: "Peringatan Waktu Imsak ⏳",
            body: "10 menit menuju waktu Shubuh. Segera selesaikan sahur dan bersiap shalat Shubuh.",
            targetTime: imsakTime,
            payload: const SmartNotificationPayload(target: 'puasa'),
            channelId: channelSmartReminders,
          );
        }
      }
    } else {
      // Tidak ada jadwal puasa besok → Batalkan sahur & imsak
      await cancelNotification(idSahurReminder);
      await cancelNotification(idImsakReminder);
    }
  }

  // =========================================================================
  // 3. SINKRONISASI NOTIFIKASI WAKTU SHOLAT & ADZAN
  // =========================================================================
  Future<void> syncSmartPrayerNotifications({
    required PrayerSchedule schedule,
    required bool Function(String prayerKey) isAlarmActive,
  }) async {
    final now = DateTime.now();

    final prayers = [
      {'key': 'shubuh', 'name': 'Shubuh', 'time': schedule.subuh, 'id': idAdzanSubuh, 'channel': channelAdzanShubuh},
      {'key': 'dzuhur', 'name': 'Dzuhur', 'time': schedule.dzuhur, 'id': idAdzanDzuhur, 'channel': channelAdzanRegular},
      {'key': 'ashar', 'name': 'Ashar', 'time': schedule.ashar, 'id': idAdzanAshar, 'channel': channelAdzanRegular},
      {'key': 'maghrib', 'name': 'Maghrib', 'time': schedule.maghrib, 'id': idAdzanMaghrib, 'channel': channelAdzanRegular},
      {'key': 'isya', 'name': 'Isya', 'time': schedule.isya, 'id': idAdzanIsya, 'channel': channelAdzanRegular},
    ];

    for (final prayer in prayers) {
      final key = prayer['key'] as String;
      final name = prayer['name'] as String;
      final timeStr = prayer['time'] as String;
      final id = prayer['id'] as int;
      final channel = prayer['channel'] as String;

      // Hormati preferensi alarm pengguna
      final active = isAlarmActive(key);
      if (!active) {
        await cancelNotification(id);
        continue;
      }

      final prayerDate = _parseTimeOnDate(now, timeStr);
      if (prayerDate.isAfter(now)) {
        await scheduleSmartReminder(
          id: id,
          title: "Waktu Sholat $name Telah Tiba 🕌",
          body: "Hayya 'alash-shalaah. Mari dirikan sholat $name tepat waktu.",
          targetTime: prayerDate,
          payload: SmartNotificationPayload(target: 'sholat', extra: {'prayerKey': key}),
          channelId: channel,
        );
      }
    }
  }

  // =========================================================================
  // HELPER METODE NOTIFIKASI
  // =========================================================================
  Future<void> scheduleSmartReminder({
    required int id,
    required String title,
    required String body,
    required DateTime targetTime,
    required SmartNotificationPayload payload,
    String channelId = channelSmartReminders,
  }) async {
    // Jangan jadwalkan jika target waktu sudah lewat
    if (targetTime.isBefore(DateTime.now())) return;

    final tzTarget = tz.TZDateTime.from(targetTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == channelAdzanShubuh
          ? 'Adzan Shubuh'
          : channelId == channelAdzanRegular
              ? 'Waktu Sholat & Adzan'
              : 'Pengingat Ibadah Muslim Habit',
      importance: Importance.max,
      priority: Priority.high,
      sound: channelId == channelAdzanShubuh
          ? const RawResourceAndroidNotificationSound('adzan_shubuh')
          : channelId == channelAdzanRegular
              ? const RawResourceAndroidNotificationSound('adzan')
              : null,
      playSound: channelId == channelAdzanShubuh || channelId == channelAdzanRegular,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTarget,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload.toJson(),
    );

    _recordHistory(id.toString(), title, body, payload.target, targetTime);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required SmartNotificationPayload payload,
    String channelId = channelProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Progres & Streak Ibadah',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload.toJson(),
    );

    _recordHistory(id.toString(), title, body, payload.target, DateTime.now());
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllSmartReminders() async {
    await _notifications.cancelAll();
  }

  // =========================================================================
  // NAVIGASI INTERAKTIF SAAT NOTIFIKASI DIKLIK
  // =========================================================================
  void _handleNotificationResponse(NotificationResponse response) {
    final payloadStr = response.payload;
    if (payloadStr == null || payloadStr.isEmpty) return;

    final payload = SmartNotificationPayload.fromJson(payloadStr);
    if (payload != null) {
      _payloadController.add(payload);
      _executeNavigation(payload);
    }
  }

  void _executeNavigation(SmartNotificationPayload payload) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // Routing sesuai target spesifikasi nomor 9
    switch (payload.target) {
      case 'dzikir_pagi':
      case 'dzikir_petang':
        // Arahkan ke tab atau layar Dzikir
        nav.pushNamed('/dzikir');
        break;
      case 'quran':
        // Arahkan ke Al-Qur'an
        nav.pushNamed('/quran');
        break;
      case 'sholat':
        // Arahkan ke jadwal salat
        nav.pushNamed('/sholat');
        break;
      case 'puasa':
        // Arahkan ke fitur Puasa
        nav.pushNamed('/puasa');
        break;
      case 'habit':
      case 'progress':
      case 'streak':
      default:
        // Arahkan ke halaman Habits
        nav.pushNamed('/habits');
        break;
    }
  }

  // =========================================================================
  // RIWAYAT NOTIFIKASI
  // =========================================================================
  void _loadHistory() {
    final raw = _storageService?.getString('smart_notification_history_v1');
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _history = list.map((e) => SmartNotificationHistoryItem.fromJson(e)).toList();
      } catch (_) {}
    }
  }

  void _recordHistory(String id, String title, String body, String target, DateTime time) {
    final item = SmartNotificationHistoryItem(
      id: id,
      title: title,
      body: body,
      target: target,
      timestamp: time,
    );

    _history.insert(0, item);
    if (_history.length > 50) {
      _history = _history.sublist(0, 50); // Maksimal simpan 50 riwayat terakhir
    }

    _storageService?.setString(
      'smart_notification_history_v1',
      jsonEncode(_history.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  // Utility Parsing Waktu
  DateTime _parseTimeOnDate(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0].trim()) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

// Background handler callback
@pragma('vm:entry-point')
void _notificationBackgroundTapHandler(NotificationResponse response) {
  // Diproses di background jika diperlukan
}
