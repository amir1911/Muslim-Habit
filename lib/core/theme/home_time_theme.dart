import 'package:flutter/material.dart';

enum HomeTimeThemeType {
  morning, // 04.00 - 09.59 (pagi hari cerah)
  day,     // 10.00 - 14.59 (siang hari cerah dan matahari)
  sunset,  // 15.00 - 17.59 (langit sunset berwarna jingga)
  night,   // 18.00 - 03.59 (langit malam dengan bulan dan bintang)
}

class HomeTimeTheme {
  final HomeTimeThemeType type;
  final String backgroundImage;
  
  // Greeting Text
  final Color greetingColor;
  final Color userNameColor;
  
  // Status Badges (Fire & XP)
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  
  // Notification Bell Button
  final Color bellBackgroundColor;
  final Color bellIconColor;
  
  // Ayah Card styling
  final Color ayahCardBg;
  final Color ayahCardBorder;
  final Color ayahTextColor;
  final Color ayahTranslationColor;
  final Color ayahSurahColor;
  final Color ayahBadgeBg;
  
  // Next Prayer Widget Styling
  final List<Color> prayerGradient;
  final Color prayerTagBg;
  final Color prayerNextTextColor;
  final Color prayerTimeColor;
  final Color prayerCompassBg;
  final Color prayerCompassBorder;
  final Color prayerCompassIconColor;
  
  // Speech Bubble Styling
  final Color speechBubbleBg;
  final Color speechTextColor;

  // Bottom gradient transition to body
  final Color bottomFadeColor;

  const HomeTimeTheme({
    required this.type,
    required this.backgroundImage,
    required this.greetingColor,
    required this.userNameColor,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.bellBackgroundColor,
    required this.bellIconColor,
    required this.ayahCardBg,
    required this.ayahCardBorder,
    required this.ayahTextColor,
    required this.ayahTranslationColor,
    required this.ayahSurahColor,
    required this.ayahBadgeBg,
    required this.prayerGradient,
    required this.prayerTagBg,
    required this.prayerNextTextColor,
    required this.prayerTimeColor,
    required this.prayerCompassBg,
    required this.prayerCompassBorder,
    required this.prayerCompassIconColor,
    required this.speechBubbleBg,
    required this.speechTextColor,
    required this.bottomFadeColor,
  });

  /// Factory untuk mendeteksi waktu lokal perangkat:
  /// - Pagi: 04.00 - 09.59
  /// - Siang: 10.00 - 14.59
  /// - Sore: 15.00 - 17.59
  /// - Malam: 18.00 - 03.59
  factory HomeTimeTheme.fromDateTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 4 && hour < 10) {
      return HomeTimeTheme.morning();
    } else if (hour >= 10 && hour < 15) {
      return HomeTimeTheme.day();
    } else if (hour >= 15 && hour < 18) {
      return HomeTimeTheme.sunset();
    } else {
      return HomeTimeTheme.night();
    }
  }

  /// 1. Pagi (04.00 - 09.59) - Suasana pagi cerah
  factory HomeTimeTheme.morning() {
    return const HomeTimeTheme(
      type: HomeTimeThemeType.morning,
      backgroundImage: 'assets/images/home_bg_morning.png',
      greetingColor: Color(0xFF1E3710),
      userNameColor: Color(0xFF1E3710),
      badgeBackgroundColor: Color(0xFF4A7220),
      badgeTextColor: Colors.white,
      bellBackgroundColor: Color(0xFF4A7220),
      bellIconColor: Colors.white,
      ayahCardBg: Color(0xBFFFFFFF), // White 75%
      ayahCardBorder: Color(0xD9FFFFFF),
      ayahTextColor: Color(0xFF1E3710),
      ayahTranslationColor: Color(0xFF334B22),
      ayahSurahColor: Color(0xFF557C2B),
      ayahBadgeBg: Color(0xFFE8F5E9),
      prayerGradient: [Color(0xFF7CB83E), Color(0xFF538622)],
      prayerTagBg: Color(0x2E000000),
      prayerNextTextColor: Colors.white,
      prayerTimeColor: Colors.white,
      prayerCompassBg: Color(0x33FFFFFF),
      prayerCompassBorder: Color(0x4DFFFFFF),
      prayerCompassIconColor: Colors.white,
      speechBubbleBg: Colors.white,
      speechTextColor: Color(0xFF233615),
      bottomFadeColor: Color(0xFFF9F8F2),
    );
  }

  /// 2. Siang (10.00 - 14.59) - Langit biru cerah & padang rumput hijau
  factory HomeTimeTheme.day() {
    return const HomeTimeTheme(
      type: HomeTimeThemeType.day,
      backgroundImage: 'assets/images/home_bg_day.png',
      greetingColor: Color(0xFF1E3710),
      userNameColor: Color(0xFF1E3710),
      badgeBackgroundColor: Color(0xFF4A7220),
      badgeTextColor: Colors.white,
      bellBackgroundColor: Color(0xFF4A7220),
      bellIconColor: Colors.white,
      ayahCardBg: Color(0xBFFFFFFF), // White 75%
      ayahCardBorder: Color(0xD9FFFFFF),
      ayahTextColor: Color(0xFF1E3710),
      ayahTranslationColor: Color(0xFF334B22),
      ayahSurahColor: Color(0xFF557C2B),
      ayahBadgeBg: Color(0xFFE8F5E9),
      prayerGradient: [Color(0xFF7CB83E), Color(0xFF538622)],
      prayerTagBg: Color(0x2E000000),
      prayerNextTextColor: Colors.white,
      prayerTimeColor: Colors.white,
      prayerCompassBg: Color(0x33FFFFFF),
      prayerCompassBorder: Color(0x4DFFFFFF),
      prayerCompassIconColor: Colors.white,
      speechBubbleBg: Colors.white,
      speechTextColor: Color(0xFF233615),
      bottomFadeColor: Color(0xFFF9F8F2),
    );
  }

  /// 3. Sore (15.00 - 17.59) - Sunset jingga keemasan
  factory HomeTimeTheme.sunset() {
    return const HomeTimeTheme(
      type: HomeTimeThemeType.sunset,
      backgroundImage: 'assets/images/home_bg_sunset.jpg',
      greetingColor: Color(0xFF2A1C0E),
      userNameColor: Color(0xFF2A1C0E),
      badgeBackgroundColor: Color(0xFF557C2B),
      badgeTextColor: Colors.white,
      bellBackgroundColor: Color(0xFF557C2B),
      bellIconColor: Colors.white,
      ayahCardBg: Color(0xCCFFF7ED), // Warm amber tint 80%
      ayahCardBorder: Color(0xE6FED7AA),
      ayahTextColor: Color(0xFF2A1C0E),
      ayahTranslationColor: Color(0xFF432D15),
      ayahSurahColor: Color(0xFF6A4B1A),
      ayahBadgeBg: Color(0xFFFDE68A),
      prayerGradient: [Color(0xFF7CB83E), Color(0xFF538622)],
      prayerTagBg: Color(0x2E000000),
      prayerNextTextColor: Colors.white,
      prayerTimeColor: Colors.white,
      prayerCompassBg: Color(0x33FFFFFF),
      prayerCompassBorder: Color(0x4DFFFFFF),
      prayerCompassIconColor: Colors.white,
      speechBubbleBg: Color(0xFFFFFBEB),
      speechTextColor: Color(0xFF2E2211),
      bottomFadeColor: Color(0xFFF9F8F2),
    );
  }

  /// 4. Malam (18.00 - 03.59) - Langit malam bulan & bintang biru gelap
  factory HomeTimeTheme.night() {
    return const HomeTimeTheme(
      type: HomeTimeThemeType.night,
      backgroundImage: 'assets/images/home_bg_night.jpg',
      greetingColor: Color(0xFFF1F5F9), // Light text on night sky
      userNameColor: Colors.white,
      badgeBackgroundColor: Color(0xFF557C2B),
      badgeTextColor: Colors.white,
      bellBackgroundColor: Color(0xFF557C2B),
      bellIconColor: Colors.white,
      ayahCardBg: Color(0xB31E293B), // Dark slate frosted glass 70%
      ayahCardBorder: Color(0x4D94A3B8),
      ayahTextColor: Color(0xFFF8FAFC),
      ayahTranslationColor: Color(0xFFCBD5E1),
      ayahSurahColor: Color(0xFF86EFAC),
      ayahBadgeBg: Color(0x3314532D),
      prayerGradient: [Color(0xFF659832), Color(0xFF456B1E)],
      prayerTagBg: Color(0x40000000),
      prayerNextTextColor: Colors.white,
      prayerTimeColor: Colors.white,
      prayerCompassBg: Color(0x33FFFFFF),
      prayerCompassBorder: Color(0x4DFFFFFF),
      prayerCompassIconColor: Colors.white,
      speechBubbleBg: Colors.white,
      speechTextColor: Color(0xFF1E293B),
      bottomFadeColor: Color(0xFFF9F8F2),
    );
  }
}

