import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/consent_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_state.dart';
import 'package:nibbles/src/utils/age_in_months.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Age cutoff (in whole months) for the early-solids responsibility consent.
/// Babies younger than this at submit time are recorded against the second
/// consent type per NIB-145.
const int onboardingEarlySolidsThresholdMonths = 6;

/// Injectable Crashlytics recorder so unit tests can assert the non-fatal
/// payload without touching real Firebase. Mirrors the
/// `DeleteAccountCrashRecorderFn` pattern from NIB-85.
typedef OnboardingCrashRecorderFn =
    Future<void> Function(
      Object error,
      StackTrace stack, {
      String? reason,
      List<String>? information,
    });

Future<void> _defaultOnboardingCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
  List<String>? information,
}) => FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  reason: reason,
  information: information ?? const <Object>[],
  // Non-fatal: consent receipt is supplementary; in-app gate already enforced.
  // ignore: avoid_redundant_argument_values
  fatal: false,
);

/// Provider for the [OnboardingCrashRecorderFn]. Tests override this to
/// capture the recorded payload without hitting Crashlytics.
@Riverpod(keepAlive: true)
OnboardingCrashRecorderFn onboardingCrashRecorder(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  OnboardingCrashRecorderRef ref,
) => _defaultOnboardingCrashRecorder;

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

  /// NIB-83 Q1 — pediatrician-approval gate. Captured separately from the
  /// developmental-sign answers; not counted toward `signs_met`.
  void setPediatricianApproved({required bool approved}) {
    state = state.copyWith(pediatricianApproved: approved);
  }

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

  /// Persists the readiness-done local flag from inside the controller so it is
  /// flipped before the router redirect runs — avoids the race between a
  /// fire-and-forget flag write and GoRouter reading the stale value. The
  /// readiness outcome is derived independently on the result screen (majority
  /// gate), so no state field is written here.
  void completeReadiness() {
    ref.read(localFlagServiceProvider).setOnboardingReadinessDone();
  }

  // ---------------------------------------------------------------------------
  // Consent + submit stage (P1)
  // ---------------------------------------------------------------------------

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
      success: (baby) async {
        // NIB-145 — P2 best-effort DB receipt for the consent acknowledgements
        // gated by the consent screen. Failures here MUST NOT block onboarding
        // (the in-app gate is already satisfied); they are logged to
        // Crashlytics for triage and we proceed regardless.
        await _recordOnboardingConsents(babyId: baby.id, dob: state.dob!);
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

  /// Persists the consent acknowledgements taken on the consent screen
  /// (NIB-145). Always records `solidsIntroduction`. If the baby is younger
  /// than [onboardingEarlySolidsThresholdMonths] at submit time, also records
  /// `under6MoResponsibility` (matches the extra checkbox surfaced for <6mo
  /// DOB on the consent screen).
  ///
  /// P2 — failures are recorded to Crashlytics and swallowed; the caller does
  /// not surface an inline error and the flow proceeds to /home.
  Future<void> _recordOnboardingConsents({
    required String babyId,
    required DateTime dob,
  }) async {
    final consents = <ConsentType>[
      ConsentType.solidsIntroduction,
      if (ageInMonths(dob) < onboardingEarlySolidsThresholdMonths)
        ConsentType.under6MoResponsibility,
    ];

    final consentService = ref.read(consentServiceProvider);
    for (final type in consents) {
      final result = await consentService.recordConsent(
        babyId: babyId,
        type: type,
      );
      if (result case Failure<void>(:final error)) {
        // information carries non-PII triage hints.
        unawaited(
          ref.read(onboardingCrashRecorderProvider)(
            'onboarding_consent_record_failure: ${error.message}',
            StackTrace.current,
            reason: 'onboarding_consent_record_failure',
            information: <String>['consent_type=${type.dbValue}'],
          ),
        );
      }
    }
  }

  /// Resets to empty state. Reserved for sign-out / test setup.
  void reset() => state = const OnboardingState();
}
