import 'package:nibbles/src/common/domain/formz/password_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_password_controller.g.dart';

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
        errorMessage: 'Password must be at least 8 characters.',
      );
      return;
    }
    if (!state.passwordsMatch) {
      state = state.copyWith(errorMessage: 'Passwords do not match.');
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
