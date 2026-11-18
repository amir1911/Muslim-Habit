
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/widget_update_service.dart';
import 'providers/habit_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/tilawah_provider.dart';
import 'providers/prayer_time_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/hadith_provider.dart';
import 'providers/doa_provider.dart';
import 'providers/qibla_provider.dart';
import 'services/qibla_service.dart';
import 'features/ai_companion/providers/ai_chat_provider.dart';
import 'presentation/splash/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Muat konfigurasi environment dari file .env lokal (jika ada)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env tidak ditemukan atau dilewati: $e');
  }

  try {
    await Firebase.initializeApp();

    // App Check otomatis aktif menggunakan Play Integrity untuk mode Production.
    // Di mode Debug, dinonaktifkan sementara agar tidak memblokir request selama development.
    if (!kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }
  } catch (e) {
    debugPrint('Firebase / App Check init error: $e');
  }

  final storageService = await StorageService.init();

  // Inisialisasi Home Screen Widget service
  await WidgetUpdateService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => HabitProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TasbihProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TilawahProvider(storageService)),
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => QuranProvider(storageService)),
        ChangeNotifierProvider(create: (_) => HadithProvider(storageService)),
        ChangeNotifierProvider(create: (_) => DoaProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => QiblaProvider(
            service: QiblaService(storageService: storageService),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
      ],
      child: const MuslimHabitApp(),
    ),
  );
}

class MuslimHabitApp extends StatelessWidget {
  const MuslimHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Habit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AnimatedSplashScreen(),
    );
  }
}
