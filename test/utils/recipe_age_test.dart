import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/utils/recipe_age.dart';

void main() {
  group('minAgeMonths', () {
    test('parses the leading integer across label formats', () {
      expect(minAgeMonths('6m+'), 6);
      expect(minAgeMonths('8m+'), 8);
      expect(minAgeMonths('6+ months'), 6);
      expect(minAgeMonths('10+ months'), 10);
      expect(minAgeMonths('12 months'), 12);
    });

    test('takes the first number from a range', () {
      expect(minAgeMonths('6-9 months'), 6);
    });

    test('returns null when no number is present', () {
      expect(minAgeMonths('any age'), isNull);
      expect(minAgeMonths(''), isNull);
    });
  });
}
