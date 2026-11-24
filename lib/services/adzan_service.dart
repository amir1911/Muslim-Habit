import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_schedule.dart';
import 'storage_service.dart';

/// Service koordinasi pemutaran dan penjadwalan Adzan Otomatis
class AdzanService extends ChangeNotifier {
  static final AdzanService _instance = AdzanService._internal();
  factory AdzanService() => _instance;
  AdzanService._internal();

  // Audio Player Adzan
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Asset Audio Adzan sesuai instruksi
  static const String subuhAudioAsset = 'assets/audio/adzan shubuh.mp3';
  static const String regularAudioAsset = 'assets/audio/adzan.mp3';

  // Status & State
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _currentPrayerName;
  String? _currentPrayerKey;
  Timer? _minuteTicker;
  PrayerSchedule? _lastSchedule;
  StorageService? _storageService;

  // Callback koordinasi audio lain (misal: Al-Qur'an)
  static final List<VoidCallback> _pauseCallbacks = [];

  static void registerAudioPauseCallback(VoidCallback cb) {
    if (!_pauseCallbacks.contains(cb)) {
      _pauseCallbacks.add(cb);
    }
  }

  static void unregisterAudioPauseCallback(VoidCallback cb) {
    _pauseCallbacks.remove(cb);
  }

  static void pauseAllOtherAudio() {
    for (final cb in List.of(_pauseCallbacks)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  bool get isPlaying => _isPlaying;
  String? get currentPrayerName => _currentPrayerName;
  String? get currentPrayerKey => _currentPrayerKey;

  /// Inisialisasi service Adzan, notifikasi & background scheduler
  Future<void> init(StorageService storageService) async {
    if (_isInitialized) return;
    _storageService = storageService;

    // Inisialisasi TimeZone
    try {
      tz.initializeTimeZones();
    } catch (_) {}

    // Inisialisasi notifikasi lokal
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
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'STOP_ADZAN' || response.payload == 'STOP') {
          stopAdzan();
        }
      },
    );

    // Setup Notification Channels khusus untuk Adzan dengan Raw Sound
    await _createNotificationChannels();

    // Setup listener audio player
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentPrayerName = null;
        _currentPrayerKey = null;
        notifyListeners();
      }
    });

    // Jalankan ticker setiap detik untuk memantau waktu sholat secara akurat
    _startRealtimeTicker();

    _isInitialized = true;
  }

  /// Membuat notification channels khusus Android untuk Adzan
  Future<void> _createNotificationChannels() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    // Channel Adzan Subuh
    const subuhChannel = AndroidNotificationChannel(
      'adzan_subuh_channel_v2',
      'Adzan Subuh Otomatis',
      description: 'Alarm & Notifikasi Adzan Subuh dengan Audio Penuh',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adzan_shubuh'),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    // Channel Adzan Reguler (Zuhur, Asar, Magrib, Isya)
    const regularChannel = AndroidNotificationChannel(
      'adzan_regular_channel_v2',
      'Adzan Salat Otomatis',
      description: 'Alarm & Notifikasi Adzan Waktu Salat dengan Audio Penuh',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adzan'),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    // Channel Pengingat Sebelum Salat
    const reminderChannel = AndroidNotificationChannel(
      'prayer_pre_reminder_channel',
      'Pengingat Sebelum Salat',
      description: 'Pemberitahuan beberapa menit sebelum waktu salat',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await android.createNotificationChannel(subuhChannel);
    await android.createNotificationChannel(regularChannel);
    await android.createNotificationChannel(reminderChannel);

    // Minta izin notifikasi & exact alarm untuk Android 13+
    await android.requestNotificationsPermission();
    await android.requestExactAlarmsPermission();
  }

  /// Memulai Ticker Realtime untuk memantau waktu salat setiap detiknya
  void _startRealtimeTicker() {
    _minuteTicker?.cancel();
    _minuteTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkRealtimePrayerArrival();
    });
  }

  /// Periksa apakah detik dan menit saat ini bertepatan dengan waktu sholat
  void _checkRealtimePrayerArrival() {
    if (_lastSchedule == null || _storageService == null) return;
    if (_isPlaying) return; // Jangan tumpuk jika sedang memutar

    final autoEnabled = _storageService!.getAdzanAutoEnabled();
    if (!autoEnabled) return;

    final now = DateTime.now();
    // Hanya cek pada detik awal setiap menit (0-3) untuk efisiensi dan kepastian
    if (now.second > 3) return;

    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final currentTimeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayers = {
      'subuh': {'name': 'Subuh', 'time': _lastSchedule!.subuh},
      'dzuhur': {'name': 'Dzuhur', 'time': _lastSchedule!.dzuhur},
      'ashar': {'name': 'Ashar', 'time': _lastSchedule!.ashar},
      'maghrib': {'name': 'Maghrib', 'time': _lastSchedule!.maghrib},
      'isya': {'name': 'Isya', 'time': _lastSchedule!.isya},
    };

    for (final entry in prayers.entries) {
      final key = entry.key;
      final name = entry.value['name']!;
      final prayerTime = entry.value['time']!;

      if (prayerTime == currentTimeStr) {
        // Cek apakah adzan untuk sholat ini diaktifkan
        final prayerEnabled = _storageService!.getAdzanPrayerEnabled(key);
        if (!prayerEnabled) continue;

        // Cek apakah sudah pernah diputar hari ini
        final lastPlayed = _storageService!.getAdzanLastPlayed(todayKey, key);
        if (lastPlayed != null) continue; // Sudah pernah diputar hari ini!

        // Catat langsung bahwa adzan dimulai agar tidak terulang
        _storageService!.setAdzanLastPlayed(todayKey, key, now.toIso8601String());

        // Putar audio adzan otomatis
        playAdzan(key, name);
        break;
      }
    }
  }

  /// Putar adzan untuk sholat tertentu
  Future<void> playAdzan(String prayerKey, String prayerName, {bool isTest = false}) async {
    try {
      // 1. Hentikan audio Al-Qur'an atau audio lain yang sedang berjalan
      pauseAllOtherAudio();

      // 2. Hentikan pemutaran sebelumnya jika ada
      await _audioPlayer.stop();

      // 3. Tentukan file audio sesuai aturan:
      // Subuh -> adzan shubuh.mp3
      // Salat lainnya -> adzan.mp3
      final isSubuh = prayerKey.toLowerCase() == 'subuh';
      final assetPath = isSubuh ? subuhAudioAsset : regularAudioAsset;

      // 4. Set volume sesuai preferensi pengguna
      final volume = _storageService?.getAdzanVolume() ?? 1.0;
      await _audioPlayer.setVolume(volume);

      // 5. Muat asset audio dan putar
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.setLoopMode(LoopMode.off);

      _isPlaying = true;
      _currentPrayerKey = prayerKey;
      _currentPrayerName = prayerName;
      notifyListeners();

      await _audioPlayer.play();

      // 6. Tampilkan notifikasi aktif dengan tombol hentikan jika bukan test
      if (!isTest) {
        _showActiveAdzanNotification(prayerKey, prayerName);
      }
    } catch (e) {
      debugPrint('Error playing Adzan: $e');
      _isPlaying = false;
      _currentPrayerName = null;
      _currentPrayerKey = null;
      notifyListeners();
    }
  }

  /// Hentikan adzan yang sedang berbunyi
  Future<void> stopAdzan() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentPrayerName = null;
    _currentPrayerKey = null;
    notifyListeners();

    // Hapus notifikasi pemutaran aktif
    try {
      await _notifications.cancel(999);
    } catch (_) {}
  }

  /// Tampilkan notifikasi pemutaran adzan aktif dengan tombol "Hentikan"
  Future<void> _showActiveAdzanNotification(String prayerKey, String prayerName) async {
    const androidDetails = AndroidNotificationDetails(
      'adzan_active_playback',
      'Pemutaran Adzan Aktif',
      channelDescription: 'Menampilkan status pemutaran adzan yang sedang berlangsung',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: false, // Suara sudah diputar via AudioPlayer
      enableVibration: false,
      actions: [
        AndroidNotificationAction(
          'STOP_ADZAN',
          'Hentikan Adzan',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      999,
      'Waktu Salat $prayerName Telah Tiba 🕋',
      'Adzan $prayerName sedang berkumandang...',
      details,
      payload: 'STOP',
    );
  }

  /// Sinkronisasi jadwal salat dan jadwalkan Alarm Android Exact
  Future<void> updateScheduleAndSyncAlarms(
    PrayerSchedule schedule,
    StorageService storageService,
  ) async {
    _lastSchedule = schedule;
    _storageService = storageService;

    // Jadwalkan exact alarm untuk kondisi aplikasi ditutup/layar mati
    await scheduleAlarms(schedule);
  }

  /// Jadwalkan notifikasi & alarm exact Android untuk seluruh waktu salat
  Future<void> scheduleAlarms(PrayerSchedule schedule) async {
    if (_storageService == null) return;
    final autoEnabled = _storageService!.getAdzanAutoEnabled();

    // Batalkan seluruh jadwal adzan lama
    await cancelAllAlarms();

    if (!autoEnabled) return;

    final now = DateTime.now();
    final prayers = [
      {'key': 'subuh', 'name': 'Subuh', 'time': schedule.subuh, 'id': 201},
      {'key': 'dzuhur', 'name': 'Dzuhur', 'time': schedule.dzuhur, 'id': 202},
      {'key': 'ashar', 'name': 'Ashar', 'time': schedule.ashar, 'id': 203},
      {'key': 'maghrib', 'name': 'Maghrib', 'time': schedule.maghrib, 'id': 204},
      {'key': 'isya', 'name': 'Isya', 'time': schedule.isya, 'id': 205},
    ];

    final preReminderEnabled = _storageService!.getPrayerPreReminderEnabled();
    final preReminderMins = _storageService!.getPrayerPreReminderMinutes();

    for (final prayer in prayers) {
      final key = prayer['key'] as String;
      final name = prayer['name'] as String;
      final timeStr = prayer['time'] as String;
      final id = prayer['id'] as int;

      final isEnabled = _storageService!.getAdzanPrayerEnabled(key);
      if (!isEnabled) continue;

      final parts = _parseTimeString(timeStr);
      var scheduledDate = DateTime(now.year, now.month, now.day, parts[0], parts[1]);

      // Jika waktu hari ini sudah lewat, jadwalkan untuk besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // 1. Jadwalkan Pengingat Sebelum Salat (jika aktif)
      if (preReminderEnabled) {
        final reminderDate = scheduledDate.subtract(Duration(minutes: preReminderMins));
        if (reminderDate.isAfter(now)) {
          await _schedulePreReminder(
            id: id + 1000,
            prayerName: name,
            minutesBefore: preReminderMins,
            scheduledDate: reminderDate,
          );
        }
      }

      // 2. Jadwalkan Alarm Adzan Utama (dengan sound native di background)
      final isSubuh = key == 'subuh';
      await _scheduleAdzanAlarm(
        id: id,
        prayerKey: key,
        prayerName: name,
        scheduledDate: scheduledDate,
        isSubuh: isSubuh,
      );
    }
  }

  /// Jadwalkan alarm adzan dengan suara native (ketika aplikasi ditutup/layar mati)
  Future<void> _scheduleAdzanAlarm({
    required int id,
    required String prayerKey,
    required String prayerName,
    required DateTime scheduledDate,
    required bool isSubuh,
  }) async {
    final channelId = isSubuh ? 'adzan_subuh_channel_v2' : 'adzan_regular_channel_v2';
    final channelName = isSubuh ? 'Adzan Subuh Otomatis' : 'Adzan Salat Otomatis';
    final soundName = isSubuh ? 'adzan_shubuh' : 'adzan';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Alarm Adzan Otomatis saat waktu salat tiba',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundName),
      enableVibration: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      actions: const [
        AndroidNotificationAction(
          'STOP_ADZAN',
          'Hentikan Adzan',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id,
        'Waktu Salat $prayerName Telah Tiba 🕋',
        'Mari tunaikan ibadah salat $prayerName tepat waktu.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'adzan_$prayerKey',
      );
    } catch (e) {
      debugPrint('Error scheduling exact alarm for $prayerName: $e');
      // Fallback jika exact alarm tidak diizinkan oleh sistem
      try {
        await _notifications.zonedSchedule(
          id,
          'Waktu Salat $prayerName Telah Tiba 🕋',
          'Mari tunaikan ibadah salat $prayerName tepat waktu.',
          tz.TZDateTime.from(scheduledDate, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'adzan_$prayerKey',
        );
      } catch (_) {}
    }
  }

  /// Jadwalkan pengingat sebelum waktu salat
  Future<void> _schedulePreReminder({
    required int id,
    required String prayerName,
    required int minutesBefore,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_pre_reminder_channel',
      'Pengingat Sebelum Salat',
      channelDescription: 'Pemberitahuan beberapa menit sebelum waktu salat tiba',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notifications.zonedSchedule(
        id,
        'Mendekati Waktu Salat $prayerName ⏳',
        'Kurang lebih $minutesBefore menit lagi memasuki waktu salat $prayerName.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'reminder_$prayerName',
      );
    } catch (_) {}
  }

  /// Batalkan seluruh jadwal adzan
  Future<void> cancelAllAlarms() async {
    final ids = [201, 202, 203, 204, 205, 1201, 1202, 1203, 1204, 1205];
    for (final id in ids) {
      try {
        await _notifications.cancel(id);
      } catch (_) {}
    }
  }

  /// Uji coba suara adzan (Testing)
  Future<void> testAdzanSound({required bool isSubuh}) async {
    final key = isSubuh ? 'subuh' : 'dzuhur';
    final name = isSubuh ? 'Subuh' : 'Reguler (Zuhur/Asar/Magrib/Isya)';
    await playAdzan(key, name, isTest: true);
  }

  /// Simulasi waktu salat tiba seketika untuk pengujian
  Future<void> simulatePrayerTime(String prayerKey) async {
    String name = 'Salat';
    switch (prayerKey.toLowerCase()) {
      case 'subuh':
        name = 'Subuh';
        break;
      case 'dzuhur':
        name = 'Dzuhur';
        break;
      case 'ashar':
        name = 'Ashar';
        break;
      case 'maghrib':
        name = 'Maghrib';
        break;
      case 'isya':
        name = 'Isya';
        break;
    }
    await playAdzan(prayerKey, name, isTest: false);
  }

  List<int> _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      return [int.parse(parts[0]), int.parse(parts[1])];
    } catch (_) {
      return [12, 0];
    }
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
