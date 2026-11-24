import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_habit/services/adzan_service.dart';
import 'package:muslim_habit/services/storage_service.dart';
import 'package:muslim_habit/models/prayer_schedule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Adzan Feature & Audio Mapping Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
    });

    test('1. Audio Asset Mapping: Subuh vs Waktu Salat Lainnya', () {
      // Subuh HARUS menggunakan 'assets/audio/adzan shubuh.mp3'
      expect(AdzanService.subuhAudioAsset, 'assets/audio/adzan shubuh.mp3');

      // Salat lainnya HARUS menggunakan 'assets/audio/adzan.mp3'
      expect(AdzanService.regularAudioAsset, 'assets/audio/adzan.mp3');
      expect(AdzanService.subuhAudioAsset, isNot(equals(AdzanService.regularAudioAsset)));
    });

    test('2. StorageService: Default dan Pengaturan Adzan Otomatis', () async {
      // Default Adzan Otomatis aktif
      expect(storage.getAdzanAutoEnabled(), true);

      // Ubah pengaturan global
      await storage.setAdzanAutoEnabled(false);
      expect(storage.getAdzanAutoEnabled(), false);
      await storage.setAdzanAutoEnabled(true);
      expect(storage.getAdzanAutoEnabled(), true);

      // Default per salat (Subuh, Dzuhur, Ashar, Maghrib, Isya)
      for (final p in ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya']) {
        expect(storage.getAdzanPrayerEnabled(p), true);
      }

      // Nonaktifkan salat tertentu (misal: Dzuhur)
      await storage.setAdzanPrayerEnabled('dzuhur', false);
      expect(storage.getAdzanPrayerEnabled('dzuhur'), false);
      expect(storage.getAdzanPrayerEnabled('subuh'), true);

      // Volume audio default 1.0 (100%)
      expect(storage.getAdzanVolume(), 1.0);
      await storage.setAdzanVolume(0.8);
      expect(storage.getAdzanVolume(), 0.8);

      // Pengingat sebelum salat
      expect(storage.getPrayerPreReminderEnabled(), false);
      expect(storage.getPrayerPreReminderMinutes(), 10);
      await storage.setPrayerPreReminderEnabled(true);
      await storage.setPrayerPreReminderMinutes(15);
      expect(storage.getPrayerPreReminderEnabled(), true);
      expect(storage.getPrayerPreReminderMinutes(), 15);
    });

    test('3. Pencegahan Adzan Ganda (Anti Double-Playing)', () async {
      const todayKey = '2026-11-24';
      const prayerKey = 'subuh';

      // Sebelum diputar, belum ada rekam jejak
      expect(storage.getAdzanLastPlayed(todayKey, prayerKey), isNull);

      // Saat diputar, rekam timestamp
      final now = DateTime.now().toIso8601String();
      await storage.setAdzanLastPlayed(todayKey, prayerKey, now);

      // Verifikasi rekam jejak tersimpan
      expect(storage.getAdzanLastPlayed(todayKey, prayerKey), now);

      // Salat lain di hari yang sama belum diputar
      expect(storage.getAdzanLastPlayed(todayKey, 'dzuhur'), isNull);
    });

    test('4. Koordinasi Audio: Al-Qur\'an berhenti saat Adzan dimulai', () {
      bool quranAudioWasStopped = false;

      void mockQuranAudioPause() {
        quranAudioWasStopped = true;
      }

      // Daftarkan callback audio
      AdzanService.registerAudioPauseCallback(mockQuranAudioPause);

      // Panggil penghentian audio lain
      AdzanService.pauseAllOtherAudio();
      expect(quranAudioWasStopped, isTrue);

      // Lepas registrasi
      quranAudioWasStopped = false;
      AdzanService.unregisterAudioPauseCallback(mockQuranAudioPause);
      AdzanService.pauseAllOtherAudio();
      expect(quranAudioWasStopped, isFalse);
    });

    test('5. Jadwal Salat Terintegrasi', () {
      final schedule = PrayerSchedule.defaultSchedule('Jakarta');
      expect(schedule.subuh, isNotEmpty);
      expect(schedule.dzuhur, isNotEmpty);
      expect(schedule.ashar, isNotEmpty);
      expect(schedule.maghrib, isNotEmpty);
      expect(schedule.isya, isNotEmpty);
    });
  });
}
