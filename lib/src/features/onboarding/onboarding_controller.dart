import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Single hoisted controller for the new onboarding flow.
///
/// keepAlive so back-nav (e.g. consent -> result -> readiness) does not lose
/// the name/dob/readiness/consent state captured at earlier stages.
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() => const OnboardingState();

  // ---------------------------------------------------------------------------
  // Name + DOB stages
  // ---------------------------------------------------------------------------

  void updateName(String value) {
    state = state.copyWith(babyName: BabyNameInput.dirty(value));
  }

  void updateDob(DateTime value) {
    state = state.copyWith(dob: value);
  }

  // ---------------------------------------------------------------------------
  // Readiness + result stages
  // ---------------------------------------------------------------------------

  void setReadinessAnswers(List<bool?> answers) {
    state = state.copyWith(
      readinessAnswers: List<bool?>.unmodifiable(answers),
    );
  }

  /// Records a single answer in-place. The screen owns the active question
  /// index; the controller owns the durable answers list.
  void answerReadinessQuestion(int index, {required bool isYes}) {
    final next = List<bool?>.from(state.readinessAnswers);
    if (index < 0 || index >= next.length) return;
    next[index] = isYes;
    state = state.copyWith(readinessAnswers: List<bool?>.unmodifiable(next));
  }

  void setReadinessReady({required bool ready}) {
    state = state.copyWith(readinessReady: ready);
  }

  // ---------------------------------------------------------------------------
  // Consent + submit stage (P1)
  // ---------------------------------------------------------------------------

  void setConsentAccepted({required bool accepted}) {
    state = state.copyWith(
      consentAccepted: accepted,
      submitErrorMessage: null,
    );
  }

  /// Persists the baby on consent submit. Returns true on success — caller is
  /// expected to set `onboarding_done` and navigate to `/home`. On failure the
  /// error message is exposed on state (inline P1 surface) and the flag is
  /// intentionally NOT set so the user resumes at the consent stage.
  ///
  /// Defensive guard: name/DOB SHOULD always be captured by the time the user
  /// reaches consent. Splash's reset-on-no-baby branch closes the kill-mid-flow
  /// hole, but if any future path lands a user here with missing input we
  /// surface an inline P1 message instead of silently no-op'ing.
  Future<bool> submit() async {
    if (state.dob == null || !state.babyName.isValid) {
      state = state.copyWith(
        submitErrorMessage: "We're missing your baby's name or date of birth. "
            'Please go back and complete those steps.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, submitErrorMessage: null);

    final result = await ref
        .read(babyProfileServiceProvider)
        .createBaby(state.babyName.value, state.dob!);

    return result.when(
      success: (_) {
        state = state.copyWith(isSubmitting: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          isSubmitting: false,
          submitErrorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Resets to empty state. Reserved for sign-out / test setup.
  void reset() => state = const OnboardingState();
}
