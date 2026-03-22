import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default(EmailInput.pure()) EmailInput email,
    @Default(PasswordInput.pure()) PasswordInput password,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _LoginState;
}
