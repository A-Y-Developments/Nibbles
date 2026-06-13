import 'dart:async';

import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forgot_password_controller.g.dart';

@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void updateEmail(String value) {
    state = state.copyWith(email: EmailInput.dirty(value), errorMessage: null);
  }

  Future<void> submit() async {
    if (state.isLoading) return;
    final email = EmailInput.dirty(state.email.value);
    if (email.isNotValid) {
      // NIB-200: surface the invalid email via the formz state, not
      // `errorMessage` — the screen reserves `errorMessage` for the generic
      // anti-enumeration backend-failure caption and would otherwise mask the
      // real validation message behind "Couldn't send the reset link…".
      state = state.copyWith(email: email, errorMessage: null);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .resetPassword(state.email.value);

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false, sent: true);
        _fireAndForget(ref.read(analyticsProvider).logPasswordResetRequested());
      },
      failure: (error) =>
          state = state.copyWith(isLoading: false, errorMessage: error.message),
    );
  }

  /// Analytics is best-effort. Swallow any rejected future so it never blocks
  /// navigation or escalates to the root zone.
  void _fireAndForget(Future<void> future) {
    unawaited(future.catchError((Object _) {}));
  }
}
