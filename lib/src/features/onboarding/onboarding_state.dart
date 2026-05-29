import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';

part 'onboarding_state.freezed.dart';

/// Hoisted state for the post-auth onboarding flow (name -> DOB -> readiness ->
/// result -> consent). Held by `OnboardingController` (keepAlive) so back-nav
/// between stages does not lose user input.
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(BabyNameInput.pure()) BabyNameInput babyName,
    DateTime? dob,
    @Default(<bool?>[]) List<bool?> readinessAnswers,
    @Default(false) bool readinessReady,
    @Default(false) bool consentAccepted,
    @Default(false) bool isSubmitting,
    String? submitErrorMessage,
  }) = _OnboardingState;
}
