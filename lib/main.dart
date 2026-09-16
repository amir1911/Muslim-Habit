import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'providers/habit_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/tilawah_provider.dart';
import 'presentation/splash/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TasbihProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TilawahProvider(storageService)),
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
