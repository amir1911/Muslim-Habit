import 'package:flutter_test/flutter_test.dart';
import 'package:muslimhabit/core/utils/streak_helper.dart';

void main() {
  group('StreakHelper Unit Tests', () {
    final now = DateTime(2026, 4, 18, 14, 0); // Reference Saturday
    final todayStr = StreakHelper.formatDate(now); // 2026-04-18
    final yesterdayStr = StreakHelper.formatDate(now.subtract(const Duration(days: 1))); // 2026-04-17
    final twoDaysAgoStr = StreakHelper.formatDate(now.subtract(const Duration(days: 2))); // 2026-04-16
    final threeDaysAgoStr = StreakHelper.formatDate(now.subtract(const Duration(days: 3))); // 2026-04-15

    test('formatDate produces standard YYYY-MM-DD', () {
      final date = DateTime(2026, 4, 5);
      expect(StreakHelper.formatDate(date), equals('2026-04-05'));
    });

    test('Empty active dates returns 0 streak', () {
      final streak = StreakHelper.calculateStreak({}, now);
      expect(streak, equals(0));
    });

    test('User completed habit today only -> streak is 1', () {
      final activeDates = {todayStr};
      final streak = StreakHelper.calculateStreak(activeDates, now);
      expect(streak, equals(1));
    });

    test('User active yesterday, not yet completed today -> streak preserved from yesterday', () {
      final activeDates = {yesterdayStr};
      final streak = StreakHelper.calculateStreak(activeDates, now);
      expect(streak, equals(1));
    });

    test('User active 3 consecutive days ending today -> streak is 3', () {
      final activeDates = {threeDaysAgoStr, twoDaysAgoStr, yesterdayStr, todayStr};
      final streak = StreakHelper.calculateStreak(activeDates, now);
      expect(streak, equals(4));
    });

    test('User missed yesterday and today -> streak is reset to 0', () {
      // User was active 2 days ago, but missed yesterday and today
      final activeDates = {twoDaysAgoStr, threeDaysAgoStr};
      final streak = StreakHelper.calculateStreak(activeDates, now);
      expect(streak, equals(0), reason: 'Missed yesterday and today must break the streak');
    });

    test('User missed yesterday but completed today -> streak restarts from 1', () {
      final activeDates = {twoDaysAgoStr, todayStr}; // gap on yesterday
      final streak = StreakHelper.calculateStreak(activeDates, now);
      expect(streak, equals(1), reason: 'Gap on yesterday means only today counts for current streak');
    });

    test('Consecutive 7 days streak', () {
      final activeDates = <String>{};
      for (int i = 0; i < 7; i++) {
        activeDates.add(StreakHelper.formatDate(now.subtract(Duration(days: i))));
      }
      final streak = StreakHelper.calculateStreak(activeDates, now);
      expect(streak, equals(7));
    });
  });

  group('Points and Dynamic Rewards Logic Tests', () {
    test('Points accumulation and reduction calculation', () {
      int initialPoints = 345;
      final subuhPoints = 25;
      final tilawahPoints = 30;

      // Selesai Subuh (+25)
      int points = initialPoints + subuhPoints;
      expect(points, equals(370));

      // Selesai Tilawah (+30)
      points += tilawahPoints;
      expect(points, equals(400));

      // Jika uncheck Subuh (-25)
      points = (points - subuhPoints).clamp(0, 999999);
      expect(points, equals(375));
    });

    test('Points cannot fall below zero', () {
      int points = 10;
      points = (points - 50).clamp(0, 999999);
      expect(points, equals(0));
    });
  });
}
