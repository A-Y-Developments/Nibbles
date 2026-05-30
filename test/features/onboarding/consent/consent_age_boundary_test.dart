import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/utils/age_in_months.dart';

/// NIB-105 — unit pins for the 6-month boundary that drives the consent
/// screen's 2-vs-3 checkbox variant.
///
/// The consent widget's private `_countFor` is `age >= 6 ? 2 : 3` — verbatim
/// from `onboarding_consent_screen.dart`. We mirror that rule here against
/// the public [ageInMonths] helper so the boundary semantics (today's DOB,
/// EXACTLY 6 months, just-under-6, way-over) are pinned without reaching
/// into the widget. The actual 2-vs-3 RENDER is verified by the consent
/// widget test (`onboarding_consent_screen_test.dart`).
///
/// `ageInMonths` itself has separate calendar-arithmetic coverage in
/// `test/utils/age_in_months_test.dart`; this file is just the consent-
/// flow boundary contract.
int _checkboxCountFor(int ageMonths) => ageMonths >= 6 ? 2 : 3;

void main() {
  group('consent checkbox count from DOB (>= 6mo -> 2; < 6mo -> 3)', () {
    final now = DateTime(2026, 5, 30);

    test('today (0mo) -> 3 checkboxes (early-solids variant)', () {
      final dob = now;
      final months = ageInMonths(dob, now: now);
      expect(months, 0);
      expect(_checkboxCountFor(months), 3);
    });

    test('5 months -> 3 checkboxes (still below the gate)', () {
      final dob = DateTime(2025, 12, 30);
      final months = ageInMonths(dob, now: now);
      expect(months, 5);
      expect(_checkboxCountFor(months), 3);
    });

    test(
      'EXACTLY 6 months (boundary; consent flips to the 2-checkbox variant)',
      () {
        final dob = DateTime(2025, 11, 30);
        final months = ageInMonths(dob, now: now);
        expect(months, 6);
        expect(_checkboxCountFor(months), 2);
      },
    );

    test('7 months -> 2 checkboxes', () {
      final dob = DateTime(2025, 10, 30);
      final months = ageInMonths(dob, now: now);
      expect(months, 7);
      expect(_checkboxCountFor(months), 2);
    });

    test('12 months -> 2 checkboxes', () {
      final dob = DateTime(2025, 5, 30);
      final months = ageInMonths(dob, now: now);
      expect(months, 12);
      expect(_checkboxCountFor(months), 2);
    });

    test('24 months -> 2 checkboxes', () {
      final dob = DateTime(2024, 5, 30);
      final months = ageInMonths(dob, now: now);
      expect(months, 24);
      expect(_checkboxCountFor(months), 2);
    });
  });
}
