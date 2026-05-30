import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';

part 'onboarding_state.freezed.dart';

/// Length of the readiness questionnaire. Lives next to [OnboardingState] so
/// the screen and the seeded `readinessAnswers` default stay in lock-step.
///
/// NIB-83: redesign drops the pediatrician question — 5 developmental signs
/// only (head control, sit upright, tongue-thrust, food interest, bring
/// objects to mouth).
const int readinessQuestionCount = 5;

/// Hoisted state for the post-auth onboarding flow (name -> DOB -> readiness ->
/// result -> consent). Held by `OnboardingController` (keepAlive) so back-nav
/// between stages does not lose user input.
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(BabyNameInput.pure()) BabyNameInput babyName,
    DateTime? dob,
    // Seeded as a length-5 nullable list so the readiness screen can index
    // safely on first build; kept in sync with [readinessQuestionCount].
    @Default(<bool?>[null, null, null, null, null])
    List<bool?> readinessAnswers,
    @Default(false) bool readinessReady,
    @Default(false) bool consentAccepted,
    @Default(false) bool isSubmitting,
    String? submitErrorMessage,
  }) = _OnboardingState;
}
