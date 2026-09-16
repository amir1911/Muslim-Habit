import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_habit/services/storage_service.dart';
import 'package:muslim_habit/providers/habit_provider.dart';
import 'package:muslim_habit/providers/tasbih_provider.dart';
import 'package:muslim_habit/providers/tilawah_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Muslim Habit Providers Unit Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
    });

    test('HabitProvider toggles habit and calculates streak & XP points', () {
      final habitProvider = HabitProvider(storageService);
      final initialPoints = habitProvider.userPoints;

      // Find 'ashar' which is initially not completed
      final ashar = habitProvider.habits.firstWhere((h) => h.id == 'ashar');
      expect(ashar.isCompleted, isFalse);

      habitProvider.toggleHabit('ashar');

      final asharUpdated = habitProvider.habits.firstWhere((h) => h.id == 'ashar');
      expect(asharUpdated.isCompleted, isTrue);
      expect(habitProvider.userPoints, initialPoints + ashar.points);
    });

    test('TasbihProvider increments count and cycles upon reaching target', () {
      final tasbihProvider = TasbihProvider(storageService);
      tasbihProvider.setTarget(3);

      expect(tasbihProvider.currentDhikr.currentCount, 0);

      tasbihProvider.incrementCount(); // 1
      tasbihProvider.incrementCount(); // 2
      final reachedTarget = tasbihProvider.incrementCount(); // 3 -> reaches target

      expect(reachedTarget, isTrue);
      expect(tasbihProvider.currentDhikr.totalCompletedCycles, 1);
      expect(tasbihProvider.currentDhikr.currentCount, 0);
    });

    test('TilawahProvider tracks pages read and calculates khatam estimate', () {
      final tilawahProvider = TilawahProvider(storageService);
      final initialPages = tilawahProvider.pagesReadToday;

      tilawahProvider.addPagesRead(5);

      expect(tilawahProvider.pagesReadToday, initialPages + 5);
      expect(tilawahProvider.remainingDaysToKhatam, greaterThan(0));
    });
  });
}
