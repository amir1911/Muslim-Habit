import '../../../providers/habit_provider.dart';
import '../../../providers/prayer_time_provider.dart';

class HabitContextService {
  /// Menyusun ringkasan habit terkini pengguna untuk disuplai ke AI Context
  static String buildHabitSummary(HabitProvider habitProvider) {
    final completed = habitProvider.completedHabitsCount;
    final total = habitProvider.totalHabitsCount;
    final streak = habitProvider.streakCount;
    final level = habitProvider.userLevel;

    final completedHabits = habitProvider.habits
        .where((h) => h.isCompleted)
        .map((h) => h.title)
        .join(', ');

    final pendingHabits = habitProvider.habits
        .where((h) => !h.isCompleted)
        .map((h) => h.title)
        .join(', ');

    return '''
Level Pengguna: Level $level
Streak Ibadah: $streak Hari Berturut-turut
Progres Hari Ini: $completed dari $total Target Terselesaikan.
Habit Sudah Selesai: ${completedHabits.isEmpty ? 'Belum ada aktivitas tercatat hari ini' : completedHabits}
Habit Belum Selesai: ${pendingHabits.isEmpty ? 'Semua target hari ini sudah tuntas!' : pendingHabits}
''';
  }

  /// Menghasilkan evaluasi ibadah harian terstruktur berdasarkan riwayat nyata
  static Map<String, dynamic> generateDailyEvaluation(HabitProvider habitProvider) {
    final completed = habitProvider.completedHabitsCount;
    final total = habitProvider.totalHabitsCount;
    final pct = total > 0 ? (completed / total * 100).round() : 0;

    String advice;
    if (pct == 100) {
      advice = 'MasyaAllah, seluruh target ibadah hari ini telah terlaksana dengan sempurna! Pertahankan istiqomahmu.';
    } else if (pct >= 50) {
      advice = 'Alhamdulillah, sebagian besar target sudah kamu selesaikan. Luangkan waktu sejenak untuk menuntaskan sisanya sebelum beristirahat.';
    } else {
      advice = 'Hari ini masih ada kesempatan. Mari mulai dari satu ibadah ringan terlebih dahulu, seperti membaca beberapa ayat atau berdzikir sejenak.';
    }

    return {
      'percentage': pct,
      'completedCount': completed,
      'totalCount': total,
      'advice': advice,
      'streak': habitProvider.streakCount,
    };
  }

  /// Mengambil nama dan waktu sholat terdekat
  static String getActivePrayerContext(PrayerTimeProvider prayerProvider) {
    final next = prayerProvider.nextPrayer;
    final name = next['name'] ?? 'Sholat';
    final time = next['time'] ?? '';
    final city = prayerProvider.currentCity;
    return '$name pukul $time WIB (Kota $city)';
  }
}

