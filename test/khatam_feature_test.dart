import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_habit/services/storage_service.dart';
import 'package:muslim_habit/services/khatam_service.dart';
import 'package:muslim_habit/models/khatam/khatam_plan_model.dart';
import 'package:muslim_habit/models/surah_detail.dart';
import 'package:muslim_habit/providers/khatam_provider.dart';
import 'package:muslim_habit/providers/habit_provider.dart';
import 'package:muslim_habit/providers/prayer_time_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pengujian Fitur Mode Khatam Al-Qur\'an', () {
    late StorageService storageService;
    late KhatamService khatamService;
    late HabitProvider habitProvider;
    late PrayerTimeProvider prayerProvider;
    late KhatamProvider khatamProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      khatamService = KhatamService();
      habitProvider = HabitProvider(storageService);
      prayerProvider = PrayerTimeProvider(storageService);
      khatamProvider = KhatamProvider(khatamService: khatamService);
      khatamProvider.updateDependencies(habitProvider, prayerProvider);
      await khatamProvider.init();
    });

    test('Memverifikasi metadata 30 Juz lengkap dan akurat', () {
      expect(JuzMetadata.allJuz.length, 30);

      final juz1 = JuzMetadata.getByJuzNumber(1);
      expect(juz1.name, 'Al-Fatihah');
      expect(juz1.startSurah, 1);
      expect(juz1.endSurah, 2);

      final juz14 = JuzMetadata.getByJuzNumber(14);
      expect(juz14.name, 'Al-Hijr');
      expect(juz14.startSurah, 15);
      expect(juz14.endSurah, 16);

      final juz30 = JuzMetadata.getByJuzNumber(30);
      expect(juz30.name, 'An-Naba\'');
      expect(juz30.startSurah, 78);
      expect(juz30.endSurah, 114);
    });

    test('Perhitungan Target Harian otomatis berdasarkan durasi dan unit', () {
      // 1 Juz / 1 Hari
      final target1 = khatamService.calculateDailyJuzTarget(
        quantity: 1,
        unit: 'juz',
        period: 'hari',
      );
      expect(target1, 1.0);
      expect(khatamService.calculateTotalDaysNeeded(target1), 30);

      // 2 Juz / 1 Hari
      final target2 = khatamService.calculateDailyJuzTarget(
        quantity: 2,
        unit: 'juz',
        period: 'hari',
      );
      expect(target2, 2.0);
      expect(khatamService.calculateTotalDaysNeeded(target2), 15);

      // 7 Juz / 1 Minggu (1 Juz/hari)
      final target3 = khatamService.calculateDailyJuzTarget(
        quantity: 7,
        unit: 'juz',
        period: 'minggu',
      );
      expect(target3, 1.0);
    });

    test('Membuat Rencana Khatam baru dan menyimpan ke SharedPreferences', () async {
      await khatamProvider.startOrUpdatePlan(
        startDate: DateTime(2026, 3, 10),
        targetDuration: 30,
        targetQuantity: 1,
        targetUnit: 'juz',
        targetPeriod: 'hari',
        reminderMaghrib: true,
        reminderFajr: true,
      );

      expect(khatamProvider.hasActivePlan, true);
      final plan = khatamProvider.activePlan!;
      expect(plan.targetDuration, 30);
      expect(plan.dailyJuzTarget, 1.0);
      expect(plan.currentJuz, 1);
      expect(plan.reminderMaghrib, true);
      expect(plan.reminderFajr, true);

      // Verifikasi tersimpan di service
      final saved = await khatamService.getActivePlan();
      expect(saved != null, true);
      expect(saved!.targetDuration, 30);
    });

    test('Pencatatan progres membaca ayat dan integrasi Habit Tilawah', () async {
      await khatamProvider.startOrUpdatePlan(
        startDate: DateTime.now(),
        targetDuration: 30,
        targetQuantity: 1,
        targetUnit: 'juz',
        targetPeriod: 'hari',
        reminderMaghrib: true,
        reminderFajr: false,
      );

      final dummyEntry = JuzAyahEntry(
        surahNumber: 1,
        surahNameLatin: 'Al-Fatihah',
        ayah: SurahAyah(
          ayahNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
        ),
        globalIndexInJuz: 0,
      );

      await khatamProvider.markAyahRead(dummyEntry);

      final planAfter = khatamProvider.activePlan!;
      expect(planAfter.readAyahKeys.contains('1:1'), true);

      // Habit tilawah harus otomatis tercentang
      final tilawahHabit = habitProvider.habits.firstWhere((h) => h.id == 'tilawah');
      expect(tilawahHabit.isCompleted, true);
    });

    test('Estimasi hari tersisa dihitung secara akurat berdasarkan Juz selesai', () {
      final plan = KhatamPlanModel(
        planId: 'plan_test',
        startDate: DateTime.now(),
        dailyJuzTarget: 1.0,
        completedJuzList: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}, // 13 Juz selesai
      );

      // 30 - 13 = 17 hari tersisa
      expect(plan.completedJuzCount, 13);
      expect(plan.estimatedDaysRemaining, 17);
    });
  });
}
