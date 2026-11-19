import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_habit/services/storage_service.dart';
import 'package:muslim_habit/services/dzikir_service.dart';
import 'package:muslim_habit/providers/dzikir_provider.dart';
import 'package:muslim_habit/providers/habit_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fitur Dzikir & Habit Integration Tests', () {
    late StorageService storageService;
    late DzikirService dzikirService;
    late HabitProvider habitProvider;
    late DzikirProvider dzikirProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      dzikirService = DzikirService();
      habitProvider = HabitProvider(storageService);
      dzikirProvider = DzikirProvider(service: dzikirService);
      dzikirProvider.updateHabitProvider(habitProvider);
      await dzikirProvider.init();
    });

    test('Memuat seluruh 7 kategori dzikir dengan benar', () {
      final categories = dzikirProvider.categories;
      expect(categories.length, 7);

      final names = categories.map((c) => c.name).toList();
      expect(names, contains('Kalimat Thayyibah'));
      expect(names, contains('Zikir Shalat'));
      expect(names, contains('Zikir Pagi'));
      expect(names, contains('Zikir Petang'));
      expect(names, contains('Zikir Sebelum Tidur'));
      expect(names, contains('Zikir Penyembuh'));
      expect(names, contains('Zikir Perjalanan'));
    });

    test('Setiap bacaan dzikir memiliki teks Arab berharakat dan transliterasi Latin', () {
      final categories = dzikirProvider.categories;
      for (final cat in categories) {
        expect(cat.items.isNotEmpty, true, reason: 'Kategori ${cat.name} tidak boleh kosong');
        for (final item in cat.items) {
          expect(item.arabic.trim().isNotEmpty, true);
          expect(item.transliteration.trim().isNotEmpty, true);
          expect(item.translation.trim().isNotEmpty, true);
          expect(item.defaultTarget > 0, true);
        }
      }
    });

    test('Pencarian dzikir bekerja multi-parameter (nama, arab, transliterasi)', () {
      final searchSubhanallah = dzikirProvider.searchDzikir('subhanallah');
      expect(searchSubhanallah.isNotEmpty, true);

      final searchArab = dzikirProvider.searchDzikir('سُبْحَانَ');
      expect(searchArab.isNotEmpty, true);

      final searchTidur = dzikirProvider.searchDzikir('tidur');
      expect(searchTidur.isNotEmpty, true);
    });

    test('Tasbih digital: increment count dan penandaan target sesi tercapai', () {
      final firstCategory = dzikirProvider.categories.first;
      dzikirProvider.selectCategory(firstCategory, initialIndex: 0);
      dzikirProvider.setTarget(3); // set target kecil untuk pengujian

      expect(dzikirProvider.sessionCount, 0);

      final r1 = dzikirProvider.incrementCount();
      expect(r1, false);
      expect(dzikirProvider.sessionCount, 1);
      expect(dzikirProvider.todayTotalCount, 1);

      final r2 = dzikirProvider.incrementCount();
      expect(r2, false);
      expect(dzikirProvider.sessionCount, 2);

      final r3 = dzikirProvider.incrementCount();
      expect(r3, true); // target 3x tercapai!
      expect(dzikirProvider.sessionCount, 3);
    });

    test('Reset sesi mengosongkan hitungan sesi tapi mempertahankan total harian', () {
      final firstCategory = dzikirProvider.categories.first;
      dzikirProvider.selectCategory(firstCategory, initialIndex: 0);
      dzikirProvider.incrementCount();
      dzikirProvider.incrementCount();

      expect(dzikirProvider.sessionCount, 2);
      expect(dzikirProvider.todayTotalCount, 2);

      dzikirProvider.resetSessionCount();
      expect(dzikirProvider.sessionCount, 0);
      expect(dzikirProvider.todayTotalCount, 2); // tetap 2
    });

    test('Integrasi Habit: mencapai target daily goal otomatis menyelesaikan habit dzikir', () async {
      // Set daily goal target ke 5 untuk pengujian integrasi
      await dzikirProvider.setDailyGoalTarget(5);

      final dzikirHabitBefore = habitProvider.habits.firstWhere((h) => h.id == 'dzikir');
      expect(dzikirHabitBefore.isCompleted, false);

      // Increment 4 kali (belum mencapai 5)
      for (int i = 0; i < 4; i++) {
        dzikirProvider.incrementCount();
      }
      expect(dzikirProvider.todayTotalCount, 4);
      final dzikirHabitMid = habitProvider.habits.firstWhere((h) => h.id == 'dzikir');
      expect(dzikirHabitMid.isCompleted, false);

      // Increment ke-5 (mencapai target 5)
      dzikirProvider.incrementCount();
      expect(dzikirProvider.todayTotalCount, 5);

      // Habit dzikir harus otomatis menjadi completed!
      final dzikirHabitAfter = habitProvider.habits.firstWhere((h) => h.id == 'dzikir');
      expect(dzikirHabitAfter.isCompleted, true);
    });
  });
}
