class StreakHelper {
  /// Format tanggal standar YYYY-MM-DD
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Menghitung streak aktif berturut-turut berdasarkan himpunan tanggal aktif (activeDates)
  /// Aturan:
  /// 1. Jika hari ini ada habit yang selesai (today aktif), streak dihitung dari hari ini mundur ke belakang.
  /// 2. Jika hari ini belum ada habit yang selesai, tetapi kemarin aktif, streak kemarin tetap dipertahankan
  ///    (memberi kesempatan pengguna menyelesaikan habit hari ini).
  /// 3. Jika hari kemarin terlewat (tidak aktif) dan hari ini belum ada habit selesai, streak putus (0).
  /// 4. Setiap hari berturut-turut yang tercatat menambah +1 pada streak.
  static int calculateStreak(Set<String> activeDates, [DateTime? referenceDate]) {
    if (activeDates.isEmpty) return 0;

    final now = referenceDate ?? DateTime.now();
    final todayStr = formatDate(now);
    final yesterdayStr = formatDate(now.subtract(const Duration(days: 1)));

    DateTime checkDate;
    if (activeDates.contains(todayStr)) {
      checkDate = now;
    } else if (activeDates.contains(yesterdayStr)) {
      checkDate = now.subtract(const Duration(days: 1));
    } else {
      // Melewatkan kemarin dan hari ini belum selesai -> streak reset
      return 0;
    }

    int streak = 0;
    while (true) {
      final dateKey = formatDate(checkDate);
      if (activeDates.contains(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
