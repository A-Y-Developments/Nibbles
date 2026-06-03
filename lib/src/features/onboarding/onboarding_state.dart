import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';

part 'onboarding_state.freezed.dart';

/// Length of the readiness *signs* questionnaire (Q2-Q6 in the Figma
/// flow). Lives next to [OnboardingState] so the screen and the seeded
/// `readinessAnswers` default stay in lock-step.
///
/// NIB-83 redesign (Figma 971:10293..971:10363): the questionnaire is now
/// SIX sequential screens — Q1 is a pediatrician-approval gate, captured
/// separately on [OnboardingState.pediatricianApproved]. Q2-Q6 are the
/// FIVE developmental signs (head control, sit upright, tongue-thrust,
/// food interest, hand-to-mouth) tracked here. This keeps the downstream
/// 3/5 majority gate (NIB-91 / NIB-120) and result-card sign labels
/// unchanged — the gate flips the questionnaire entry point, not the
/// score.
const int readinessQuestionCount = 5;

/// Hoisted state for the post-auth onboarding flow (name -> DOB -> readiness ->
/// result -> consent). Held by `OnboardingController` (keepAlive) so back-nav
/// between stages does not lose user input.
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(BabyNameInput.pure()) BabyNameInput babyName,
    DateTime? dob,
    // NIB-83 Q1 gate. Null = not answered yet, true = pediatrician approved,
    // false = unsure. Not counted toward `signs_met` — see the result screen.
    bool? pediatricianApproved,
    // Seeded as a length-5 nullable list so the readiness screen can index
    // safely on first build; kept in sync with [readinessQuestionCount].
    @Default(<bool?>[null, null, null, null, null])
    List<bool?> readinessAnswers,
    @Default(false) bool isSubmitting,
    String? submitErrorMessage,
  }) = _OnboardingState;
}
