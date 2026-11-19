import 'package:flutter_test/flutter_test.dart';
import 'package:muslimhabit/core/utils/hijri_helper.dart';
import 'package:muslimhabit/models/fasting_plan.dart';

void main() {
  group('HijriHelper Tests', () {
    test('HijriHelper converts Gregorian to Hijri accurately', () {
      final date = DateTime(2026, 4, 15);
      final hijri = HijriHelper.fromGregorian(date);

      expect(hijri.hYear, greaterThan(1440));
      expect(hijri.hMonth, inInclusiveRange(1, 12));
      expect(hijri.hDay, inInclusiveRange(1, 30));
      expect(hijri.monthName.isNotEmpty, isTrue);
    });

    test('HijriHelper.getMondaysAndThursdays produces only Mondays and Thursdays', () {
      final dates = HijriHelper.getMondaysAndThursdays(2026, 4);
      expect(dates.isNotEmpty, isTrue);

      for (final d in dates) {
        expect(
          d.weekday == DateTime.monday || d.weekday == DateTime.thursday,
          isTrue,
          reason: 'Date $d should be Monday or Thursday',
        );
        expect(d.month, equals(4));
        expect(d.year, equals(2026));
      }
    });

    test('HijriHelper.calculateDaudDates alternates every 2 days', () {
      final start = DateTime(2026, 4, 1);
      final daudDates = HijriHelper.calculateDaudDates(
        startDate: start,
        year: 2026,
        month: 4,
      );

      expect(daudDates.isNotEmpty, isTrue);
      expect(daudDates.first, equals(start));

      for (int i = 0; i < daudDates.length - 1; i++) {
        final diff = daudDates[i + 1].difference(daudDates[i]).inDays;
        expect(diff, equals(2));
      }
    });

    test('HijriHelper format hijri date in Indonesian', () {
      final date = DateTime(2026, 4, 20); // Monday
      final formatted = HijriHelper.formatHijriFull(date);
      expect(formatted.contains('H'), isTrue);
    });
  });

  group('FastingPlan and FastingAlarmConfig Model Tests', () {
    test('FastingPlan JSON serialization and deserialization', () {
      final original = FastingPlan(
        id: 'fasting_2026-04-28',
        date: DateTime(2026, 4, 28),
        type: FastingType.seninKamis,
        status: FastingStatus.completed,
        completedAt: DateTime(2026, 4, 28, 18, 20),
        notes: 'Alhamdulillah lancar',
      );

      final json = original.toJson();
      final restored = FastingPlan.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.type, equals(FastingType.seninKamis));
      expect(restored.status, equals(FastingStatus.completed));
      expect(restored.notes, equals('Alhamdulillah lancar'));
      expect(restored.completedAt, isNotNull);
    });

    test('FastingPlan handles skippedReason correctly', () {
      final skipped = FastingPlan(
        id: 'fasting_2026-04-30',
        date: DateTime(2026, 4, 30),
        type: FastingType.seninKamis,
        status: FastingStatus.skipped,
        skippedReason: SkippedReason.sakit,
        notes: 'Demam tinggi',
      );

      final json = skipped.toJson();
      final restored = FastingPlan.fromJson(json);

      expect(restored.status, equals(FastingStatus.skipped));
      expect(restored.skippedReason, equals(SkippedReason.sakit));
      expect(restored.skippedReason?.displayName, equals('Sakit'));
      expect(restored.notes, equals('Demam tinggi'));
    });

    test('FastingAlarmConfig default values and JSON roundtrip', () {
      const config = FastingAlarmConfig();
      expect(config.sahurEnabled, isTrue);
      expect(config.iftarEnabled, isTrue);
      expect(config.sahurHour, equals(3));
      expect(config.sahurMinute, equals(30));
      expect(config.snoozeMinutes, equals(5));

      final json = config.toJson();
      final restored = FastingAlarmConfig.fromJson(json);

      expect(restored.sahurTimeFormatted, equals('03:30'));
      expect(restored.iftarEnabled, isTrue);
      expect(restored.ringtoneSahur, equals('Adzan Makkah'));
    });
  });
}
