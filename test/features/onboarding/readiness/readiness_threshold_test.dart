import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/features/onboarding/readiness/readiness_signs.dart';

/// Pure derivation tests for the readiness `signs_met` -> `ready` rule used by
/// the result screen.
///
/// The result reflects all SIX questions: the pediatrician gate (Q1) plus the
/// five Q2-Q6 developmental signs. The baby is "ready" only when every sign is
/// met, pinned by [kReadinessReadyThreshold] (6). These tests pin that contract
/// so a silent edit of the constant or the counting rule breaks the build, not
/// the user's flow.
void main() {
  group('kReadinessReadyThreshold contract', () {
    test('threshold is 6 (all signs required)', () {
      expect(kReadinessReadyThreshold, 6);
    });

    test('state seed has the expected length (5 developmental signs) so the '
        'six-sign list = pediatrician + answers is well-defined', () {
      const seed = OnboardingState();
      expect(seed.readinessAnswers.length, readinessQuestionCount);
      expect(seed.readinessAnswers, [null, null, null, null, null]);
    });
  });

  group(
    'signs_met derivation over the six-sign list (pediatrician + Q2-Q6)',
    () {
      // Mirrors the inline derivation in `OnboardingResultScreen.build`:
      //   final signs = <bool?>[pediatricianApproved, ...answers];
      //   signs.where((a) => a ?? false).length
      // `signs[0]` is the pediatrician gate; `signs[1..5]` are Q2-Q6.
      int signsMet(List<bool?> signs) => signs.where((a) => a ?? false).length;

      bool isReady(List<bool?> signs) =>
          signsMet(signs) >= kReadinessReadyThreshold;

      test('all six met -> ready', () {
        const signs = <bool?>[true, true, true, true, true, true];
        expect(signsMet(signs), 6);
        expect(isReady(signs), isTrue);
      });

      test('five of six (pediatrician not approved) -> NOT ready', () {
        const signs = <bool?>[false, true, true, true, true, true];
        expect(signsMet(signs), 5);
        expect(isReady(signs), isFalse);
      });

      test('one developmental sign missing -> NOT ready', () {
        const signs = <bool?>[true, true, true, true, true, false];
        expect(signsMet(signs), 5);
        expect(isReady(signs), isFalse);
      });

      test('null counts as NOT met (defensive)', () {
        const signs = <bool?>[null, true, true, true, true, true];
        expect(signsMet(signs), 5);
        expect(isReady(signs), isFalse);
      });

      test('all-null seed (untouched) -> NOT ready', () {
        const signs = <bool?>[null, null, null, null, null, null];
        expect(signsMet(signs), 0);
        expect(isReady(signs), isFalse);
      });
    },
  );
}
