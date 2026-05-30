import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/account_service.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_account_controller.g.dart';

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
        // Don't touch `state` after signOut — the provider is likely disposed
        // by the time the redirect tears the profile subtree down.
        return true;
      case Failure<void>(:final error):
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        return false;
    }
  }
}
