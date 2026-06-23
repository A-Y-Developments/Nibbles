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

  /// True when the confirm field has any text AND matches password value.
  bool get passwordsMatch =>
      password.value == confirmPassword && confirmPassword.isNotEmpty;

  /// True when the user has typed in the password field and it is too short
  /// (formz [PasswordInput] minimum is 8 chars).
  bool get passwordTooShort => password.value.isNotEmpty && password.isNotValid;

  /// True when the confirm field has text and the password field is also
  /// too short — mirrors the Figma "Password is too short" helper on the
  /// retype field (state 4 / node 971:10148).
  bool get confirmTooShort => confirmPassword.isNotEmpty && password.isNotValid;

  /// True when the confirm field has text, the password field is valid
  /// (≥8 chars), and the two values disagree — mirrors the Figma
  /// "Password doesn't match" helper (state 5 / node 971:10160).
  bool get confirmMismatch =>
      confirmPassword.isNotEmpty &&
      !password.isNotValid &&
      password.value != confirmPassword;
}
