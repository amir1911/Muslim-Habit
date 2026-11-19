// Hijri Calendar Converter & Helper — Muslim Habbit
// Mengonversi kalender Masehi ke Hijriah secara dinamis dengan nama bulan Hijriah lengkap.

class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const List<String> monthNames = [
    'Muharram',
    'Safar',
    "Rabi'ul Awwal",
    "Rabi'ul Akhir",
    'Jumadil Awwal',
    'Jumadil Akhir',
    'Rajab',
    "Sya'ban",
    'Ramadhan',
    'Syawal',
    "Dzulqa'dah",
    'Dzulhijjah',
  ];

  String get monthName => (month >= 1 && month <= 12) ? monthNames[month - 1] : '';

  String toFormattedString() => '$day $monthName $year H';

  @override
  String toString() => '$day $monthName $year';
}

class HijriHelper {
  /// Mengonversi DateTime Gregorian (Masehi) ke HijriDate
  static HijriDate fromGregorian(DateTime date) {
    // Algoritma konversi astronomis Kuwaiti / Tabular Hijri
    final y = date.year;
    final m = date.month;
    final d = date.day;

    int jd;
    if (m > 2) {
      jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d - 1524;
    } else {
      jd = (365.25 * (y - 1 + 4716)).floor() + (30.6001 * (m + 12 + 1)).floor() + d - 1524;
    }

    // Koreksi kalender Gregorian
    if (jd > 2299160) {
      final a = (y / 100).floor();
      final b = 2 - a + (a / 4).floor();
      jd += b;
    }

    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l1 = l - 10631 * n + 354;
    final j = ((10985 - l1) / 5316).floor() * ((50 * l1) / 17719).floor() +
        (l1 / 5670).floor() * ((43 * l1) / 15238).floor();
    final l2 = l1 - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    final mHijri = ((24 * l2) / 709).floor();
    final dHijri = l2 - ((709 * mHijri) / 24).floor();
    final yHijri = 30 * n + j - 30;

    return HijriDate(
      year: yHijri,
      month: mHijri.clamp(1, 12),
      day: dHijri.clamp(1, 30),
    );
  }

  /// Menghasilkan rentang bulan Hijriah untuk satu bulan Masehi (misal "Syawal 1447 - Dzulqa'dah 1447")
  static String getHijriMonthRangeForGregorianMonth(int year, int month) {
    final start = fromGregorian(DateTime(year, month, 1));
    final end = fromGregorian(DateTime(year, month, DateTime(year, month + 1, 0).day));

    if (start.month == end.month && start.year == end.year) {
      return '${start.monthName} ${start.year} H';
    } else if (start.year == end.year) {
      return '${start.monthName} - ${end.monthName} ${start.year} H';
    } else {
      return '${start.monthName} ${start.year} - ${end.monthName} ${end.year} H';
    }
  }

  /// Menghitung hari-hari Senin dan Kamis dalam bulan dan tahun tertentu
  static List<DateTime> getMondaysAndThursdays(int year, int month) {
    final list = <DateTime>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == DateTime.monday || date.weekday == DateTime.thursday) {
        list.add(date);
      }
    }
    return list;
  }

  /// Menghitung jadwal Puasa Daud (berselang 1 hari) mulai dari startDate
  static List<DateTime> getDaudFastingDays(DateTime startDate, int totalDays) {
    final list = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);

    for (int i = 0; i < totalDays; i++) {
      list.add(current);
      // Selang 2 hari (hari ini puasa, besok tidak, lusa puasa lagi)
      current = current.add(const Duration(days: 2));
    }
    return list;
  }

  /// Format nama hari Indonesia
  static String getDayNameIndonesian(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[date.weekday - 1];
  }

  /// Format nama bulan Masehi Indonesia
  static String getMonthNameIndonesian(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
