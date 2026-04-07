import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/features/auth/register/register_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  @override
  RegisterState build() => const RegisterState();

  void updateName(String value) {
    state = state.copyWith(name: value, errorMessage: null);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: EmailInput.dirty(value), errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: PasswordInput.dirty(value),
      errorMessage: null,
    );
  }

  Future<bool> submit() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(authServiceProvider.notifier)
        .signUp(state.name, state.email.value, state.password.value);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        return false;
      },
    );
  }
}
