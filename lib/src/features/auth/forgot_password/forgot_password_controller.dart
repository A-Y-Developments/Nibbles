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
    final email = EmailInput.dirty(state.email.value);
    if (email.isNotValid) {
      state = state.copyWith(
        email: email,
        errorMessage: 'Please enter a valid email address.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .resetPassword(state.email.value);

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false, sent: true);
        _fireAndForget(
          ref.read(analyticsProvider).logPasswordResetRequested(),
        );
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
