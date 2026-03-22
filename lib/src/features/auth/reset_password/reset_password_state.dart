import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';

part 'reset_password_state.freezed.dart';

@freezed
class ResetPasswordState with _$ResetPasswordState {
  const factory ResetPasswordState({
    @Default(PasswordInput.pure()) PasswordInput password,
    @Default('') String confirmPassword,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool success,
  }) = _ResetPasswordState;

  const ResetPasswordState._();

  bool get passwordsMatch =>
      password.value == confirmPassword && confirmPassword.isNotEmpty;
}
