import 'package:nibbles/src/common/domain/formz/password_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_password_controller.g.dart';

/// NIB-115 — Reset password / AU-03 controller.
///
/// Drives the three Figma states for forget-password 3/4/5:
///   971:10136 (initial guidance), 971:10148 (too short),
///   971:10160 (mismatch).
@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  void updatePassword(String value) {
    state = state.copyWith(
      password: PasswordInput.dirty(value),
      errorMessage: null,
    );
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  Future<void> submit() async {
    final password = PasswordInput.dirty(state.password.value);
    if (password.isNotValid) {
      state = state.copyWith(
        password: password,
        errorMessage: 'Password is too short',
      );
      return;
    }
    if (!state.passwordsMatch) {
      state = state.copyWith(errorMessage: "Password doesn't match");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .updatePassword(state.password.value);

    result.when(
      success: (_) => state = state.copyWith(isLoading: false, success: true),
      failure: (error) =>
          state = state.copyWith(isLoading: false, errorMessage: error.message),
    );
  }
}
