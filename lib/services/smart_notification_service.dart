import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  static const MethodChannel _customNotifChannel = MethodChannel('com.muslimhabit/custom_notification');
  StorageService? _storageService;
  bool _isInitialized = false;

  // Global navigator key untuk mengarahkan pengguna saat notifikasi diklik
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Stream controller untuk aksi notifikasi klik
  final StreamController<SmartNotificationPayload> _payloadController =
      StreamController<SmartNotificationPayload>.broadcast();
  Stream<SmartNotificationPayload> get onNotificationClick => _payloadController.stream;

  // ID Channels & Notification IDs
  static const String channelSmartReminders = 'muslim_habit_smart_reminders_v2';
  static const String channelAdzanShubuh = 'adzan_subuh_channel_v2';
  static const String channelAdzanRegular = 'adzan_regular_channel_v2';
  static const String channelProgress = 'muslim_habit_progress_channel_v2';

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
    } catch (e) {
      debugPrint('[SmartNotification] TimeZone init error: $e');
    }

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
    await requestPermissions();
    _loadHistory();

    // Batalkan notifikasi tes lama agar tidak muncul kembali di notification tray
    for (final testId in [9001, 9002, 9003, 9999]) {
      try {
        await cancelNotification(testId);
      } catch (_) {}
    }

    // Setup listener untuk notifikasi custom yang diklik pengguna
    _customNotifChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationClicked') {
        final payloadStr = call.arguments as String?;
        if (payloadStr != null && payloadStr.isNotEmpty) {
          final payload = SmartNotificationPayload.fromJson(payloadStr);
          if (payload != null) {
            _payloadController.add(payload);
            _executeNavigation(payload);
          }
        }
      }
    });

    // Periksa apakah aplikasi dibuka dari custom notification
    try {
      final pending = await _customNotifChannel.invokeMethod<String>('getPendingPayload');
      if (pending != null && pending.isNotEmpty) {
        final payload = SmartNotificationPayload.fromJson(pending);
        if (payload != null) {
          Future.delayed(const Duration(milliseconds: 600), () {
            _payloadController.add(payload);
            _executeNavigation(payload);
          });
        }
      }
    } catch (_) {}

    _isInitialized = true;
  }

  /// Meminta izin notifikasi & exact alarm secara resmi di Android 13+ (API 33+)
  Future<bool> requestPermissions() async {
    try {
      final androidImpl = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final notifGranted = await androidImpl.requestNotificationsPermission() ?? false;
        await androidImpl.requestExactAlarmsPermission();
        debugPrint('[SmartNotification] Notification permission granted: $notifGranted');
        return notifGranted;
      }
    } catch (e) {
      debugPrint('[SmartNotification] Error requesting permissions: $e');
    }
    return true;
  }

  /// Cek apakah notifikasi diaktifkan di level OS
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImpl = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        return await androidImpl.areNotificationsEnabled() ?? false;
      }
    } catch (_) {}
    return true;
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
        'Pengingat Ibadah Muslim Habbit',
        description: 'Notifikasi pintar pengingat habit, dzikir, doa, dan Al-Quran.',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
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
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
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

    // ── A. DZIKIR PAGI PINTAR (Target jam 06:00 atau adaptif) ──
    if (hasReadDzikirPagiToday) {
      await cancelNotification(idDzikirPagi);
    } else {
      var targetDzikirPagi = _parseTimeOnDate(now, "06:00");
      if (targetDzikirPagi.isBefore(now)) {
        // Jika sudah siang/sore (jam 11 ke atas), jadwalkan besok pagi jam 06:00
        if (now.hour >= 11) {
          targetDzikirPagi = targetDzikirPagi.add(const Duration(days: 1));
        } else {
          // Masih pagi tapi lewat jam 6 (misal jam 7-10), jadwalkan 5 menit lagi
          targetDzikirPagi = now.add(const Duration(minutes: 5));
        }
      }
      final randomGreeting = _nunuGreetingMorning[Random().nextInt(_nunuGreetingMorning.length)];
      await scheduleSmartReminder(
        id: idDzikirPagi,
        title: "Muslim Habbit",
        body: randomGreeting,
        targetTime: targetDzikirPagi,
        payload: const SmartNotificationPayload(target: 'dzikir_pagi'),
      );
    }

    // ── B. DZIKIR PETANG PINTAR (Target jam 16:30 atau adaptif) ──
    if (hasReadDzikirPetangToday) {
      await cancelNotification(idDzikirPetang);
    } else {
      var targetDzikirPetang = _parseTimeOnDate(now, "16:30");
      if (targetDzikirPetang.isBefore(now)) {
        if (now.hour >= 19) {
          targetDzikirPetang = targetDzikirPetang.add(const Duration(days: 1));
        } else {
          targetDzikirPetang = now.add(const Duration(minutes: 5));
        }
      }
      await scheduleSmartReminder(
        id: idDzikirPetang,
        title: "Muslim Habbit",
        body: "Sore yang tenang. Yuk luangkan waktu membaca Dzikir Petang agar hati selalu tenteram.",
        targetTime: targetDzikirPetang,
        payload: const SmartNotificationPayload(target: 'dzikir_petang'),
      );
    }

    // ── C. AL-QUR'AN / TILAWAH PINTAR ──
    if (hasReadQuranToday) {
      await cancelNotification(idTilawahReminder);
    } else {
      var targetTilawah = _parseTimeOnDate(now, "19:30");
      if (targetTilawah.isBefore(now)) {
        if (now.hour >= 22) {
          targetTilawah = targetTilawah.add(const Duration(days: 1));
        } else {
          targetTilawah = now.add(const Duration(minutes: 5));
        }
      }
      final randomQuran = _nunuGreetingQuran[Random().nextInt(_nunuGreetingQuran.length)];
      await scheduleSmartReminder(
        id: idTilawahReminder,
        title: "Muslim Habbit",
        body: randomQuran,
        targetTime: targetTilawah,
        payload: const SmartNotificationPayload(target: 'quran'),
      );
    }

    // ── D. PROGRES HARIAN & STREAK EVALUATION (Malam) ──
    final int uncompletedCount = habits.where((h) => !h.isCompleted).length;

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
          title: "Muslim Habbit",
          body: randomPraise,
          payload: const SmartNotificationPayload(target: 'progress'),
        );
      }
    } else if (uncompletedCount > 0) {
      // Masih ada target belum selesai: Jadwalkan pengingat jam 20:15
      var targetProgress = _parseTimeOnDate(now, "20:15");
      if (targetProgress.isBefore(now)) {
        if (now.hour < 22) {
          targetProgress = now.add(const Duration(minutes: 5));
        } else {
          targetProgress = targetProgress.add(const Duration(days: 1));
        }
      }

      final streakText = streakCount > 0 ? " Jaga streak $streakCount harimu!" : "";

      await scheduleSmartReminder(
        id: idDailyProgress,
        title: "Muslim Habbit",
        body: "Semangat! Selesaikan $uncompletedCount habit sebelum hari berakhir.$streakText",
        targetTime: targetProgress,
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
            title: "Muslim Habbit",
            body: "Waktu Maghrib telah tiba. Selamat menunaikan ibadah berbuka puasa ${todayPlan.type.displayName}.",
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
            title: "Muslim Habbit",
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
            title: "Muslim Habbit",
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
      {'key': 'shubuh', 'name': 'Subuh', 'time': schedule.subuh, 'id': idAdzanSubuh, 'channel': channelAdzanShubuh},
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

      var prayerDate = _parseTimeOnDate(now, timeStr);
      // Jika waktu shalat hari ini sudah lewat, jadwalkan untuk besok
      if (prayerDate.isBefore(now)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }

      await scheduleSmartReminder(
        id: id,
        title: "Muslim Habbit",
        body: "Hayya 'alash-shalaah. Waktu sholat $name telah tiba. Mari dirikan sholat tepat waktu.",
        targetTime: prayerDate,
        payload: SmartNotificationPayload(target: 'sholat', extra: {'prayerKey': key}),
        channelId: channel,
      );
    }
  }

  // =========================================================================
  // HELPER METODE NOTIFIKASI & SAFE SCHEDULER
  // =========================================================================
  Future<void> scheduleSmartReminder({
    required int id,
    required String title,
    required String body,
    required DateTime targetTime,
    required SmartNotificationPayload payload,
    String channelId = channelSmartReminders,
  }) async {
    // Pastikan target waktu berada di masa depan
    if (targetTime.isBefore(DateTime.now())) return;

    final tzTarget = tz.TZDateTime.from(targetTime, tz.local);
    final tzNow = tz.TZDateTime.now(tz.local);
    if (tzTarget.isBefore(tzNow)) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == channelAdzanShubuh
          ? 'Adzan Shubuh'
          : channelId == channelAdzanRegular
              ? 'Waktu Sholat & Adzan'
              : channelId == channelProgress
                  ? 'Progres & Streak Ibadah'
                  : 'Pengingat Ibadah Muslim Habbit',
      channelDescription: 'Pengingat pintar ibadah Muslim Habbit',
      icon: '@mipmap/launcher_icon',
      importance: Importance.max,
      priority: Priority.high,
      sound: channelId == channelAdzanShubuh
          ? const RawResourceAndroidNotificationSound('adzan_shubuh')
          : channelId == channelAdzanRegular
              ? const RawResourceAndroidNotificationSound('adzan')
              : null,
      playSound: channelId == channelAdzanShubuh || channelId == channelAdzanRegular,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // 1. Coba jadwalkan Custom Notification Layout (Maskot Nunu & Gradasi Ungu-Hijau) via Android AlarmManager
    bool customScheduled = false;
    try {
      final res = await _customNotifChannel.invokeMethod<bool>('scheduleCustomNotification', {
        'id': id,
        'title': "Muslim Habbit",
        'message': body,
        'targetEpochMillis': targetTime.millisecondsSinceEpoch,
        'payload': payload.toJson(),
      });
      customScheduled = res ?? false;
      if (customScheduled) {
        _recordHistory(id.toString(), title, body, payload.target, targetTime);
        debugPrint('[SmartNotification] Custom layout scheduled via AlarmManager #$id at $targetTime');
      }
    } catch (e) {
      debugPrint('[SmartNotification] Custom schedule native failed, fallback to flutter_local_notifications: $e');
    }

    // 2. Jika bukan Android atau custom layout gagal, gunakan fallback standar
    if (!customScheduled) {
      try {
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
        debugPrint('[SmartNotification] Berhasil menjadwalkan #$id "$title" pada $tzTarget (exact)');
      } catch (e) {
        debugPrint('[SmartNotification] Exact schedule gagal #$id: $e. Mencoba fallback inexact...');
        try {
          await _notifications.zonedSchedule(
            id,
            title,
            body,
            tzTarget,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload.toJson(),
          );
          _recordHistory(id.toString(), title, body, payload.target, targetTime);
          debugPrint('[SmartNotification] Fallback berhasil #$id "$title" pada $tzTarget (inexact)');
        } catch (fallbackErr) {
          debugPrint('[SmartNotification] Fallback juga gagal #$id: $fallbackErr');
        }
      }
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required SmartNotificationPayload payload,
    String channelId = channelSmartReminders,
  }) async {
    // 1. Tampilkan menggunakan Custom Layout Android (RemoteViews: Maskot Nunu + Gradasi Ungu-Hijau)
    bool customShown = false;
    try {
      final nowStr = DateFormat('HH:mm').format(DateTime.now());
      final res = await _customNotifChannel.invokeMethod<bool>(
        'showCustomNotification',
        {
          'id': id,
          'title': "Muslim Habbit",
          'message': body,
          'time': nowStr,
          'payload': payload.toJson(),
        },
      );
      customShown = res ?? false;
      if (customShown) {
        _recordHistory(id.toString(), title, body, payload.target, DateTime.now());
        debugPrint('[SmartNotification] Custom notification shown: #$id "$body"');
      }
    } catch (e) {
      debugPrint('[SmartNotification] Custom notification failed, fallback to standard: $e');
    }

    if (!customShown) {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == channelProgress
            ? 'Progres & Streak Ibadah'
            : 'Pengingat Ibadah Muslim Habbit',
        channelDescription: 'Notifikasi langsung Muslim Habbit',
        icon: '@mipmap/launcher_icon',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      try {
        await _notifications.show(
          id,
          title,
          body,
          details,
          payload: payload.toJson(),
        );
        _recordHistory(id.toString(), title, body, payload.target, DateTime.now());
        debugPrint('[SmartNotification] Notifikasi instan terkirim: #$id "$title"');
      } catch (e) {
        debugPrint('[SmartNotification] Error kirim notifikasi instan: $e');
      }
    }
  }

  // =========================================================================
  // METODE PENGUJIAN NOTIFIKASI (TEST SUITE)
  // =========================================================================

  /// 1. Tes Notifikasi Sekarang (Muncul Langsung dengan Desain Kustom Maskot Nunu)
  Future<bool> testInstantNotification() async {
    try {
      await requestPermissions();
      await showInstantNotification(
        id: 9001,
        title: "Muslim Habbit",
        body: "Jangan Lupa Untuk Melanjutkan Streakmu!",
        payload: const SmartNotificationPayload(target: 'streak'),
        channelId: channelSmartReminders,
      );
      return true;
    } catch (e) {
      debugPrint('[SmartNotification] Error testInstantNotification: $e');
      return false;
    }
  }

  /// 2. Tes Notifikasi 1 Menit Lagi
  Future<bool> testNotificationInOneMinute() async {
    try {
      await requestPermissions();
      final targetTime = DateTime.now().add(const Duration(minutes: 1));
      await scheduleSmartReminder(
        id: 9002,
        title: "Muslim Habbit",
        body: "Yuk, jangan lupa Dzikir Pagi hari ini!",
        targetTime: targetTime,
        payload: const SmartNotificationPayload(target: 'dzikir_pagi'),
        channelId: channelSmartReminders,
      );
      return true;
    } catch (e) {
      debugPrint('[SmartNotification] Error testNotificationInOneMinute: $e');
      return false;
    }
  }

  /// 3. Tes Notifikasi Terjadwal (Custom seconds, default 10 detik)
  Future<bool> testScheduledNotification({int seconds = 10}) async {
    try {
      await requestPermissions();
      final targetTime = DateTime.now().add(Duration(seconds: seconds));
      await scheduleSmartReminder(
        id: 9003,
        title: "Muslim Habbit",
        body: "Sudahkah kamu membaca Al-Qur'an hari ini?",
        targetTime: targetTime,
        payload: const SmartNotificationPayload(target: 'quran'),
        channelId: channelSmartReminders,
      );
      return true;
    } catch (e) {
      debugPrint('[SmartNotification] Error testScheduledNotification: $e');
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _customNotifChannel.invokeMethod('cancelCustomNotification', {'id': id});
    } catch (_) {}
    await _notifications.cancel(id);
  }

  Future<void> cancelAllSmartReminders() async {
    // Batalkan semua custom notification via AlarmManager (ID yang sudah diketahui saja)
    const knownIds = [
      idAdzanSubuh, idAdzanDzuhur, idAdzanAshar, idAdzanMaghrib, idAdzanIsya,
      idSahurReminder, idImsakReminder, idBukaPuasaReminder,
      idDzikirPagi, idDzikirPetang, idDoaPagi, idTilawahReminder,
      idStreakReminder, idDailyProgress, idDailyAppreciation,
      9001, 9002, 9003,
    ];
    for (final id in knownIds) {
      try {
        await _customNotifChannel.invokeMethod('cancelCustomNotification', {'id': id});
      } catch (_) {}
    }
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
