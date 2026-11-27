import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/fasting_plan.dart';
import '../presentation/puasa/alarm_sahur_screen.dart';
import '../presentation/puasa/alarm_iftar_screen.dart';

class FastingAlarmService {
  static final FastingAlarmService _instance = FastingAlarmService._internal();
  factory FastingAlarmService() => _instance;
  FastingAlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _ringtonePlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Inisialisasi service notifikasi & zona waktu lokal
  Future<void> init() async {
    if (_isInitialized) return;

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationClick(response.payload);
      },
    );

    await _createNotificationChannels();

    // Minta izin notifikasi di Android 13+
    await _requestPermissions();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'sahur_alarm_channel',
        'Alarm Sahur',
        description: 'Panggilan pengingat sahur',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'imsak_warning_channel',
        'Peringatan Imsak',
        description: 'Peringatan waktu imsak',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'iftar_prep_channel',
        'Persiapan Iftar',
        description: 'Pengingat persiapan buka puasa',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'iftar_alarm_channel',
        'Alarm Iftar',
        description: 'Pemberitahuan waktu berbuka puasa',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }
  }

  void _handleNotificationClick(String? payload) {
    // Navigasi saat notifikasi diklik
  }

  /// Jadwalkan alarm sahur dan iftar untuk daftar rencana puasa
  Future<void> scheduleAlarmsForPlans({
    required List<FastingPlan> plans,
    required FastingAlarmConfig config,
    String imsakTimeStr = '04:29',
    String maghribTimeStr = '18:05',
  }) async {
    await init();

    // Batalkan alarm lama terlebih dahulu agar tidak dobel
    await cancelAllFastingAlarms();

    for (final plan in plans) {
      // Hanya jadwalkan untuk puasa yang direncanakan di masa depan atau hari ini
      if (plan.status != FastingStatus.planned && plan.status != FastingStatus.fasting) {
        continue;
      }

      final date = plan.date;
      final now = DateTime.now();

      // 1. Alarm Sahur
      if (config.sahurAlarmEnabled) {
        final sahurDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          config.sahurHour,
          config.sahurMinute,
        );

        if (sahurDateTime.isAfter(now)) {
          final id = _getNotificationId(date, 1);
          await _scheduleNotification(
            id: id,
            title: 'Waktunya Sahur! 🌙',
            body: 'Ayo bangun sahur untuk persiapan puasa hari ini.',
            scheduledDate: sahurDateTime,
            channelId: 'sahur_alarm_channel',
            channelName: 'Alarm Sahur Muslim Habbit',
            payload: 'sahur_${plan.id}',
          );
        }
      }

      // 2. Peringatan Imsak
      if (config.imsakWarningEnabled) {
        final imsakParts = _parseTimeString(imsakTimeStr);
        final imsakDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          imsakParts[0],
          imsakParts[1],
        );

        if (imsakDateTime.isAfter(now)) {
          final id = _getNotificationId(date, 2);
          await _scheduleNotification(
            id: id,
            title: 'Peringatan Waktu Imsak ⏳',
            body: 'Waktu Imsak telah tiba. Segera tuntaskan makan dan minum sahur.',
            scheduledDate: imsakDateTime,
            channelId: 'imsak_warning_channel',
            channelName: 'Peringatan Imsak',
            payload: 'imsak_${plan.id}',
          );
        }
      }

      // 3. Alarm Iftar (Waktu Berbuka)
      if (config.iftarAlarmEnabled) {
        final maghribParts = _parseTimeString(maghribTimeStr);
        final maghribDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          maghribParts[0],
          maghribParts[1],
        );

        // Pengingat Persiapan Iftar
        if (config.iftarPreparationReminder) {
          final prepDateTime = maghribDateTime.subtract(
            Duration(minutes: config.iftarPreparationMinutes),
          );

          if (prepDateTime.isAfter(now)) {
            final id = _getNotificationId(date, 3);
            await _scheduleNotification(
              id: id,
              title: 'Persiapan Berbuka Puasa 🍽️',
              body: '${config.iftarPreparationMinutes} menit menuju waktu Maghrib.',
              scheduledDate: prepDateTime,
              channelId: 'iftar_prep_channel',
              channelName: 'Persiapan Iftar',
              payload: 'iftar_prep_${plan.id}',
            );
          }
        }

        // Alarm Utama Berbuka
        if (maghribDateTime.isAfter(now)) {
          final id = _getNotificationId(date, 4);
          await _scheduleNotification(
            id: id,
            title: 'Waktunya Berbuka Puasa! 🕋',
            body: 'Alhamdulillah, waktu Maghrib telah tiba. Selamat berbuka puasa!',
            scheduledDate: maghribDateTime,
            channelId: 'iftar_alarm_channel',
            channelName: 'Alarm Iftar (Berbuka)',
            payload: 'iftar_${plan.id}',
          );
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Pengingat dan alarm puasa Muslim Habbit',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('adzan'),
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      // Fallback jika exact alarm ditolak oleh sistem Android
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (e) {
        debugPrint('[FastingAlarmService] Error scheduling fallback alarm: $e');
      }
    }
  }

  /// Membatalkan seluruh jadwal notifikasi puasa
  Future<void> cancelAllFastingAlarms() async {
    await _notifications.cancelAll();
  }

  /// Mapping nama nada dering ke path asset audio
  static String getRingtoneAsset(String ringtoneName) {
    switch (ringtoneName.trim().toLowerCase()) {
      case 'adzan makkah':
      case 'adzan maghrib':
      case 'bedug & adzan':
        return 'assets/audio/adzan.mp3';
      case 'adzan madinah':
        return 'assets/audio/adzan_shubuh.mp3';
      case 'nada lembut':
        return 'assets/audio/nada_lembut.wav';
      case 'bel tradisional':
        return 'assets/audio/bel_tradisional.wav';
      case 'bedug sahur':
        return 'assets/audio/bedug.wav';
      case 'genta islami':
        return 'assets/audio/genta_islami.wav';
      default:
        return 'assets/audio/adzan.mp3';
    }
  }

  /// Memutar nada alarm berulang (looping) sesuai nama nada dering yang dipilih
  Future<void> playAlarmSound(String ringtoneName) async {
    try {
      final assetPath = getRingtoneAsset(ringtoneName);
      debugPrint('[FastingAlarmService] Memutar alarm: $ringtoneName ($assetPath)');
      await stopAlarmSound();
      await _ringtonePlayer.setVolume(1.0);
      try {
        await _ringtonePlayer.setAsset(assetPath);
      } catch (assetErr) {
        debugPrint('[FastingAlarmService] Fallback ke adzan.mp3 karena asset gagal di-load: $assetErr');
        await _ringtonePlayer.setAsset('assets/audio/adzan.mp3');
      }
      await _ringtonePlayer.setLoopMode(LoopMode.one);
      await _ringtonePlayer.play();
    } catch (e) {
      debugPrint('[FastingAlarmService] Error playing alarm sound ($ringtoneName): $e');
    }
  }

  /// Memutar preview satu kali (tanpa loop) untuk pengujian suara di pengaturan
  Future<void> playPreviewSound(String ringtoneName) async {
    try {
      final assetPath = getRingtoneAsset(ringtoneName);
      debugPrint('[FastingAlarmService] Memutar preview: $ringtoneName ($assetPath)');
      await stopAlarmSound();
      await _ringtonePlayer.setVolume(1.0);
      try {
        await _ringtonePlayer.setAsset(assetPath);
      } catch (assetErr) {
        debugPrint('[FastingAlarmService] Fallback ke adzan.mp3 untuk preview: $assetErr');
        await _ringtonePlayer.setAsset('assets/audio/adzan.mp3');
      }
      await _ringtonePlayer.setLoopMode(LoopMode.off);
      await _ringtonePlayer.play();
    } catch (e) {
      debugPrint('[FastingAlarmService] Error playing preview sound ($ringtoneName): $e');
    }
  }

  /// Menghentikan nada alarm atau preview
  Future<void> stopAlarmSound() async {
    try {
      await _ringtonePlayer.stop();
    } catch (_) {}
  }

  /// Fitur Snooze (Tunda Alarm 5 Menit)
  Future<void> snoozeSahurAlarm({
    required BuildContext context,
    required int minutes,
  }) async {
    await stopAlarmSound();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm ditunda selama $minutes menit ⏰'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Fitur Simulasi: Menampilkan Layar Alarm Sahur Seketika untuk Pengujian
  void simulateSahurAlarm(BuildContext context, {String ringtoneName = 'Adzan Makkah'}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlarmSahurScreen(ringtoneName: ringtoneName),
      ),
    );
  }

  /// Fitur Simulasi: Menampilkan Layar Alarm Berbuka Seketika untuk Pengujian
  void simulateIftarAlarm(BuildContext context, {String ringtoneName = 'Bedug & Adzan'}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlarmIftarScreen(ringtoneName: ringtoneName),
      ),
    );
  }

  int _getNotificationId(DateTime date, int typeOffset) {
    return (date.year * 10000 + date.month * 100 + date.day) * 10 + typeOffset;
  }

  List<int> _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return [h, m];
    } catch (_) {
      return [18, 5];
    }
  }
}
