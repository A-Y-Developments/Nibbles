import 'package:formz/formz.dart';

enum BabyNameValidationError { empty, tooLong }

class BabyNameInput extends FormzInput<String, BabyNameValidationError> {
  const BabyNameInput.pure() : super.pure('');
  const BabyNameInput.dirty([super.value = '']) : super.dirty();

  @override
  BabyNameValidationError? validator(String value) {
    if (value.isEmpty) return BabyNameValidationError.empty;
    if (value.length > 50) return BabyNameValidationError.tooLong;
    return null;
  }
}
