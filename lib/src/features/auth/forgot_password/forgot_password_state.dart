import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';

part 'forgot_password_state.freezed.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    @Default(EmailInput.pure()) EmailInput email,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool sent,
  }) = _ForgotPasswordState;
}
