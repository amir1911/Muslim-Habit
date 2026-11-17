import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Widget Update Service
//
// Bertanggung jawab untuk:
//   1. Menulis data jadwal salat ke SharedPreferences (dibaca widget Android)
//   2. Mendaftarkan Workmanager task untuk update berkala (tiap 30 menit)
//   3. Memaksa refresh tampilan widget
// ─────────────────────────────────────────────────────────────────────────────

const String _androidWidgetName =
    'com.muslimhabit.muslim_habit.PrayerWidgetProvider';

/// Task name yang didaftarkan di Workmanager
const String kWidgetUpdateTask = 'muslimhabit.widget.update';

/// Callback untuk event background dari HomeWidget (misal klik aksi interaktif)
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (Platform.isAndroid) {
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }
}

/// Callback yang dipanggil oleh Workmanager di isolate terpisah.
/// Harus berupa top-level function.
@pragma('vm:entry-point')
void workmanagerBackgroundCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == kWidgetUpdateTask) {
      if (Platform.isAndroid) {
        await HomeWidget.updateWidget(
          androidName: _androidWidgetName,
        );
      }
    }
    return true;
  });
}

class WidgetUpdateService {
  WidgetUpdateService._();

  /// Inisialisasi — panggil sekali saat app start (di main.dart)
  static Future<void> init() async {
    if (!Platform.isAndroid) return;

    await HomeWidget.setAppGroupId('com.muslimhabit.muslim_habit');
    await HomeWidget.registerBackgroundCallback(homeWidgetBackgroundCallback);

    // Daftarkan periodic task tiap 30 menit (minimum interval WorkManager)
    await Workmanager().initialize(
      workmanagerBackgroundCallback,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      kWidgetUpdateTask,
      kWidgetUpdateTask,
      frequency: const Duration(minutes: 30),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  /// Tulis data salat ke SharedPreferences lalu paksa refresh widget.
  ///
  /// [subuh] .. [isya]        → string waktu format "HH:mm"
  /// [currentLabel]           → label status salat, cth: "Sekarang" atau "Berikutnya"
  /// [currentPrayerName]      → nama salat yang sedang berlangsung, cth: "Ashar"
  /// [currentPrayerTime]      → jam mulainya salat tersebut, cth: "15:30"
  /// [nextPrayerName]         → nama salat berikutnya, cth: "Maghrib"
  /// [nextPrayerTime]         → waktu salat berikutnya, cth: "17:50"
  /// [timezone]               → singkatan zona waktu, cth: "WIB"
  static Future<void> updatePrayerData({
    required String subuh,
    required String dzuhur,
    required String ashar,
    required String maghrib,
    required String isya,
    String currentLabel = 'Sekarang',
    required String currentPrayerName,
    required String currentPrayerTime,
    required String nextPrayerName,
    required String nextPrayerTime,
    String timezone = 'WIB',
  }) async {
    if (!Platform.isAndroid) return;

    // Simpan ke SharedPreferences (key harus cocok dengan yang dibaca Kotlin)
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_subuh',   subuh),
      HomeWidget.saveWidgetData<String>('widget_dzuhur',  dzuhur),
      HomeWidget.saveWidgetData<String>('widget_ashar',   ashar),
      HomeWidget.saveWidgetData<String>('widget_maghrib', maghrib),
      HomeWidget.saveWidgetData<String>('widget_isya',    isya),
      HomeWidget.saveWidgetData<String>('widget_current_label', currentLabel),
      HomeWidget.saveWidgetData<String>('widget_current_prayer_name', currentPrayerName),
      HomeWidget.saveWidgetData<String>('widget_current_prayer_time', currentPrayerTime),
      HomeWidget.saveWidgetData<String>('widget_next_prayer_name', nextPrayerName),
      HomeWidget.saveWidgetData<String>('widget_next_prayer_time', nextPrayerTime),
      HomeWidget.saveWidgetData<String>('widget_timezone', timezone),
    ]);

    // Trigger update tampilan widget
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }
}
