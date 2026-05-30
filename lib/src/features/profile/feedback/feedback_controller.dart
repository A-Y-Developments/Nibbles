import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/feedback_service.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_controller.g.dart';

/// Injectable Crashlytics recorder so unit tests can assert the non-fatal
/// payload without touching real Firebase. Mirrors the
/// `AllergenCrashRecorderFn` pattern from NIB-125.
typedef FeedbackCrashRecorderFn =
    Future<void> Function(Object error, StackTrace stack, {String? reason});

Future<void> _defaultFeedbackCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
}) => FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  reason: reason,
  // Non-fatal: feedback submit failures still surface a P2 SnackBar retry.
  // ignore: avoid_redundant_argument_values
  fatal: false,
);

/// Provider for the [FeedbackCrashRecorderFn]. Tests override this to capture
/// the recorded payload without hitting Crashlytics.
@Riverpod(keepAlive: true)
FeedbackCrashRecorderFn feedbackCrashRecorder(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  FeedbackCrashRecorderRef ref,
) => _defaultFeedbackCrashRecorder;

@riverpod
class FeedbackController extends _$FeedbackController {
  @override
  FeedbackState build() => const FeedbackState();

  void updateMessage(String value) {
    state = state.copyWith(message: value, errorMessage: null);
  }

  /// Submits the current message. Returns true on success, false on
  /// failure. The Send button is gated on a non-blank message + not
  /// already submitting, so we only need to short-circuit those here as
  /// belt-and-braces.
  Future<bool> submit() async {
    final trimmed = state.message.trim();
    if (trimmed.isEmpty || state.phase == FeedbackPhase.submitting) {
      return false;
    }

    state = state.copyWith(
      phase: FeedbackPhase.submitting,
      errorMessage: null,
    );

    final result = await ref.read(feedbackServiceProvider).submit(trimmed);

    switch (result) {
      case Success<void>():
        state = state.copyWith(phase: FeedbackPhase.success);
        // Success — fire-and-forget. NO message text in the event.
        unawaited(ref.read(analyticsProvider).logFeedbackSubmitted());
        return true;
      case Failure<void>(:final error):
        // P2 path: record non-fatal BEFORE the SnackBar fires. Reason is a
        // stable enum string — no message text, no PII.
        await ref.read(feedbackCrashRecorderProvider)(
          'profile_feedback_submit_failure: ${error.message}',
          StackTrace.current,
          reason: 'profile_feedback_submit_failure',
        );
        state = state.copyWith(
          phase: FeedbackPhase.idle,
          errorMessage: error.message,
        );
        return false;
    }
  }
}
