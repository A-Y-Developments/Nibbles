import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/account_service.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_account_controller.g.dart';

/// Injectable Crashlytics recorder so unit tests can assert the non-fatal
/// payload without touching real Firebase. Mirrors the
/// `AllergenCrashRecorderFn` pattern from NIB-125.
typedef DeleteAccountCrashRecorderFn =
    Future<void> Function(
      Object error,
      StackTrace stack, {
      String? reason,
      List<String>? information,
    });

Future<void> _defaultDeleteAccountCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
  List<String>? information,
}) => FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  reason: reason,
  information: information ?? const <Object>[],
  // Non-fatal: deleteAccount failures still surface a P1 inline error + retry.
  // ignore: avoid_redundant_argument_values
  fatal: false,
);

/// Provider for the [DeleteAccountCrashRecorderFn]. Tests override this to
/// capture the recorded payload without hitting Crashlytics.
@Riverpod(keepAlive: true)
DeleteAccountCrashRecorderFn deleteAccountCrashRecorder(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  DeleteAccountCrashRecorderRef ref,
) => _defaultDeleteAccountCrashRecorder;

/// Drives the delete-account flow opened from Profile (NIB-78).
///
/// `submit(reason)` orchestrates the destructive sequence:
///  1. `AccountService.deleteAccount(reason)` (NIB-85 RPC).
///  2. On success: `LocalFlagService.clearAll()` wipes onboarding/completion
///     flags so a re-register on the same device replays onboarding cleanly.
///  3. Then `AuthService.signOut()` — the GoRouter redirect handles the
///     navigation to `/auth/login` (or `/onboarding/intro` since flags are
///     cleared).
///
/// On failure: `errorMessage` is set so the overlay can render an inline P1
/// error + retry CTA without dismissing.
@riverpod
class DeleteAccountController extends _$DeleteAccountController {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  Future<bool> submit(String reason) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref
        .read(accountServiceProvider)
        .deleteAccount(reason);

    switch (result) {
      case Success<void>():
        await ref.read(localFlagServiceProvider).clearAll();
        await ref.read(authServiceProvider.notifier).signOut();
        // Success — fire-and-forget. No PII (reason is logged on intent fire).
        unawaited(
          ref.read(analyticsProvider).logAccountDeletionCompleted(),
        );
        // Don't touch `state` after signOut — the provider is likely disposed
        // by the time the redirect tears the profile subtree down.
        return true;
      case Failure<void>(:final error):
        // P1 path: record non-fatal BEFORE the inline error SnackBar fires.
        // information = ['reason=<reason>'] for triage; no PII.
        await ref.read(deleteAccountCrashRecorderProvider)(
          'profile_account_deletion_failure: ${error.message}',
          StackTrace.current,
          reason: 'profile_account_deletion_failure',
          information: <String>['reason=$reason'],
        );
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        return false;
    }
  }
}
