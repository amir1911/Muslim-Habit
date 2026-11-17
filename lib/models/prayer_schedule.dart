class PrayerSchedule {
  final String city;
  final String date;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  PrayerSchedule({
    required this.city,
    required this.date,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) {
    return PrayerSchedule(
      city: json['city'] as String? ?? 'Palembang',
      date: json['date'] as String? ?? '',
      imsak: json['imsak'] as String? ?? '04:29',
      subuh: json['subuh'] as String? ?? '04:39',
      terbit: json['terbit'] as String? ?? '05:50',
      dhuha: json['dhuha'] as String? ?? '06:17',
      dzuhur: json['dzuhur'] as String? ?? '12:00',
      ashar: json['ashar'] as String? ?? '15:10',
      maghrib: json['maghrib'] as String? ?? '18:05',
      isya: json['isya'] as String? ?? '19:15',
    );
  }

  factory PrayerSchedule.fromMyQuran({
    required String cityName,
    required Map<String, dynamic> jadwalData,
  }) {
    // Format nama kota agar rapi (misal "KOTA PALEMBANG" -> "Palembang")
    String formattedCity = cityName
        .replaceAll(RegExp(r'^(KOTA|KAB\.|KABUPATEN)\s+', caseSensitive: false), '')
        .trim();
    if (formattedCity.isNotEmpty) {
      formattedCity = formattedCity[0].toUpperCase() + formattedCity.substring(1).toLowerCase();
    } else {
      formattedCity = 'Palembang';
    }

    return PrayerSchedule(
      city: formattedCity,
      date: jadwalData['tanggal'] as String? ?? '',
      imsak: jadwalData['imsak'] as String? ?? '04:29',
      subuh: jadwalData['subuh'] as String? ?? '04:39',
      terbit: jadwalData['terbit'] as String? ?? '05:50',
      dhuha: jadwalData['dhuha'] as String? ?? '06:17',
      dzuhur: jadwalData['dzuhur'] as String? ?? '12:00',
      ashar: jadwalData['ashar'] as String? ?? '15:10',
      maghrib: jadwalData['maghrib'] as String? ?? '18:05',
      isya: jadwalData['isya'] as String? ?? '19:15',
    );
  }

  factory PrayerSchedule.defaultSchedule([String cityName = 'Palembang']) {
    return PrayerSchedule(
      city: cityName,
      date: 'Hari Ini',
      imsak: '04:29',
      subuh: '04:39',
      terbit: '05:50',
      dhuha: '06:17',
      dzuhur: '12:00',
      ashar: '15:10',
      maghrib: '18:05',
      isya: '19:15',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'date': date,
      'imsak': imsak,
      'subuh': subuh,
      'terbit': terbit,
      'dhuha': dhuha,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
    };
  }

  /// 5 Sholat Wajib
  Map<String, String> get mainPrayers => {
        'Subuh': subuh,
        'Dzuhur': dzuhur,
        'Ashar': ashar,
        'Maghrib': maghrib,
        'Isya': isya,
      };

  /// Seluruh waktu sholat dan sunnah
  Map<String, String> get allTimes => {
        'Imsak': imsak,
        'Subuh': subuh,
        'Terbit': terbit,
        'Dhuha': dhuha,
        'Dzuhur': dzuhur,
        'Ashar': ashar,
        'Maghrib': maghrib,
        'Isya': isya,
      };

  /// Menentukan waktu sholat yang sedang berlangsung
  Map<String, String> getCurrentPrayer(DateTime now) {
    final nowMinutes = now.hour * 60 + now.minute;

    int parseMinutes(String timeStr) {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
      }
      return 0;
    }

    final subuhMin = parseMinutes(subuh);
    final dzuhurMin = parseMinutes(dzuhur);
    final asharMin = parseMinutes(ashar);
    final maghribMin = parseMinutes(maghrib);
    final isyaMin = parseMinutes(isya);

    if (nowMinutes < subuhMin) {
      return {
        'label': 'Berikutnya',
        'name': 'Subuh',
        'time': subuh,
      };
    } else if (nowMinutes < dzuhurMin) {
      return {
        'label': 'Sekarang',
        'name': 'Subuh',
        'time': subuh,
      };
    } else if (nowMinutes < asharMin) {
      return {
        'label': 'Sekarang',
        'name': 'Dzuhur',
        'time': dzuhur,
      };
    } else if (nowMinutes < maghribMin) {
      return {
        'label': 'Sekarang',
        'name': 'Ashar',
        'time': ashar,
      };
    } else if (nowMinutes < isyaMin) {
      return {
        'label': 'Sekarang',
        'name': 'Maghrib',
        'time': maghrib,
      };
    } else {
      return {
        'label': 'Sekarang',
        'name': 'Isya',
        'time': isya,
      };
    }
  }

  /// Menentukan waktu sholat berikutnya secara dinamis
  Map<String, String> getNextPrayer(DateTime now) {
    final prayers = [
      {'name': 'Subuh', 'time': subuh},
      {'name': 'Dzuhur', 'time': dzuhur},
      {'name': 'Ashar', 'time': ashar},
      {'name': 'Maghrib', 'time': maghrib},
      {'name': 'Isya', 'time': isya},
    ];

    for (final p in prayers) {
      final timeStr = p['time']!;
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

        if (now.isBefore(prayerTime)) {
          return {
            'name': p['name']!,
            'time': timeStr,
          };
        }
      }
    }

    // Jika sudah lewat Isya, sholat berikutnya adalah Subuh besok
    return {
      'name': 'Subuh',
      'time': subuh,
    };
  }
}
