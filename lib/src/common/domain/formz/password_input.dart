import 'package:formz/formz.dart';

enum PasswordValidationError { tooShort }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.length >= 8 ? null : PasswordValidationError.tooShort;
  }
}
