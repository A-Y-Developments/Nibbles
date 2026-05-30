import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

void main() {
  group('ageInMonths (NIB-74)', () {
    test('same day returns 0', () {
      final dob = DateTime(2026, 1, 15);
      expect(ageInMonths(dob, now: dob), 0);
    });

    test('one calendar month later, same day-of-month returns 1', () {
      expect(
        ageInMonths(DateTime(2026, 1, 15), now: DateTime(2026, 2, 15)),
        1,
      );
    });

    test(
      'one calendar month later but earlier day-of-month returns 0 (the dob '
      'day-of-month has not been reached yet)',
      () {
        expect(
          ageInMonths(DateTime(2026, 1, 31), now: DateTime(2026, 2, 15)),
          0,
        );
      },
    );

    test('exact six-month diff returns 6', () {
      expect(
        ageInMonths(DateTime(2025, 11, 30), now: DateTime(2026, 5, 30)),
        6,
      );
    });

    test('year wrap with month-of-year regression handled correctly', () {
      expect(
        ageInMonths(DateTime(2025, 11, 30), now: DateTime(2026, 5, 29)),
        5,
      );
    });

    test('future dob clamps to 0', () {
      expect(
        ageInMonths(DateTime(2026, 12), now: DateTime(2026, 6)),
        0,
      );
    });

    test('three years exact returns 36', () {
      expect(
        ageInMonths(DateTime(2023, 5, 30), now: DateTime(2026, 5, 30)),
        36,
      );
    });
  });
}
