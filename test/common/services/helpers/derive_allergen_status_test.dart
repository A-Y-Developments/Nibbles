import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';

final _now = DateTime(2026, 5, 30);

AllergenLog _log({String id = 'l', bool hadReaction = false}) => AllergenLog(
  id: id,
  babyId: 'baby-1',
  allergenKey: 'peanut',
  hadReaction: hadReaction,
  logDate: _now,
  createdAt: _now,
);

void main() {
  group('deriveStatusForLogs (NIB-126 rule table)', () {
    test('0 logs → notStarted', () {
      expect(deriveStatusForLogs(const []), AllergenStatus.notStarted);
    });

    test('1 clean log → inProgress', () {
      expect(deriveStatusForLogs([_log()]), AllergenStatus.inProgress);
    });

    test('3 clean logs → safe (NEVER completed)', () {
      final logs = [
        _log(id: 'a'),
        _log(id: 'b'),
        _log(id: 'c'),
      ];
      expect(deriveStatusForLogs(logs), AllergenStatus.safe);
      // Canonical rule: passed allergens are `safe`, not `completed`.
      expect(
        AllergenStatus.values.map((e) => e.name),
        isNot(contains('completed')),
      );
    });

    test('1 reaction-flagged log → flagged', () {
      expect(
        deriveStatusForLogs([_log(hadReaction: true)]),
        AllergenStatus.flagged,
      );
    });

    test(
      '3 clean logs THEN 1 reaction-flagged log → flagged '
      '(regression: flagged dominates over safe)',
      () {
        final logs = [
          _log(id: 'a'),
          _log(id: 'b'),
          _log(id: 'c'),
          _log(id: 'd', hadReaction: true),
        ];
        expect(deriveStatusForLogs(logs), AllergenStatus.flagged);
      },
    );
  });

  group('kAllergenKeys', () {
    test('contains all 9 canonical keys in display order', () {
      expect(kAllergenKeys, hasLength(9));
      expect(
        kAllergenKeys,
        equals(const [
          'peanut',
          'egg',
          'dairy',
          'tree_nuts',
          'sesame',
          'soy',
          'wheat',
          'fish',
          'shellfish',
        ]),
      );
    });
  });
}
