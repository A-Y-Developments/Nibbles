import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String name,
    @Default(EmailInput.pure()) EmailInput email,
    @Default(PasswordInput.pure()) PasswordInput password,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RegisterState;

  const RegisterState._();

  bool get isValid =>
      name.isNotEmpty && email.isValid && password.isValid;
}
