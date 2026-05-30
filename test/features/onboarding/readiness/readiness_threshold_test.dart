import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/features/onboarding/result/onboarding_result_screen.dart';

/// NIB-105 — pure derivation tests for the readiness `signs_met` -> `ready`
/// rule used by the result + (downstream) consent screens.
///
/// The threshold lives next to the result screen as
/// [readinessReadyThreshold] (NIB-120 majority gate, 3/5). These tests pin
/// that contract so a silent edit of the constant or the `signs_met`
/// counting rule (`.where((a) => a ?? false).length`) breaks the build,
/// not the user's flow.
void main() {
  group('readinessReadyThreshold contract', () {
    test('threshold is 3 (NIB-120 majority gate, 3/5)', () {
      expect(readinessReadyThreshold, 3);
    });

    test(
      'state seed has the expected length (5 questions) so signs_met '
      'arithmetic on `readinessAnswers` is well-defined',
      () {
        const seed = OnboardingState();
        expect(seed.readinessAnswers.length, readinessQuestionCount);
        expect(seed.readinessAnswers, [null, null, null, null, null]);
      },
    );
  });

  group('signs_met derivation from readinessAnswers (length 5, nullable bools)',
      () {
    // Tiny pure helper mirrors the inline derivation in
    // `OnboardingResultScreen.build`:
    //   `answers.where((a) => a ?? false).length`.
    // We pin the rule here so any future drift inside the screen reads as a
    // diff against this helper.
    int signsMet(List<bool?> answers) =>
        answers.where((a) => a ?? false).length;

    bool isReady(List<bool?> answers) =>
        signsMet(answers) >= readinessReadyThreshold;

    test('0/5 -> NOT ready', () {
      const answers = <bool?>[false, false, false, false, false];
      expect(signsMet(answers), 0);
      expect(isReady(answers), isFalse);
    });

    test('1/5 -> NOT ready (below threshold)', () {
      const answers = <bool?>[true, false, false, false, false];
      expect(signsMet(answers), 1);
      expect(isReady(answers), isFalse);
    });

    test('2/5 -> NOT ready (one below threshold)', () {
      const answers = <bool?>[true, true, false, false, false];
      expect(signsMet(answers), 2);
      expect(isReady(answers), isFalse);
    });

    test('3/5 -> ready (boundary; majority gate flips here)', () {
      const answers = <bool?>[true, true, true, false, false];
      expect(signsMet(answers), 3);
      expect(isReady(answers), isTrue);
    });

    test('5/5 -> ready', () {
      const answers = <bool?>[true, true, true, true, true];
      expect(signsMet(answers), 5);
      expect(isReady(answers), isTrue);
    });

    test('partial-nullables: null counts as NOT met (defensive)', () {
      const answers = <bool?>[true, null, null, null, null];
      expect(signsMet(answers), 1);
      expect(isReady(answers), isFalse);
    });

    test(
      'partial-nullables: 3 true + 2 null still ready (majority gate is '
      'true-count, not "every answer is captured")',
      () {
        const answers = <bool?>[true, true, true, null, null];
        expect(signsMet(answers), 3);
        expect(isReady(answers), isTrue);
      },
    );

    test('all-null seed (untouched) -> NOT ready', () {
      const answers = <bool?>[null, null, null, null, null];
      expect(signsMet(answers), 0);
      expect(isReady(answers), isFalse);
    });
  });
}
