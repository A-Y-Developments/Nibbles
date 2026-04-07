import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/login/login_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void updateEmail(String value) {
    state = state.copyWith(email: EmailInput.dirty(value), errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: PasswordInput.dirty(value),
      errorMessage: null,
    );
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .signIn(state.email.value, state.password.value);

    result.when(
      success: (_) => state = state.copyWith(isLoading: false),
      failure: (error) =>
          state = state.copyWith(isLoading: false, errorMessage: error.message),
    );
    // On success: GoRouter redirect picks up authServiceProvider state change
  }
}
