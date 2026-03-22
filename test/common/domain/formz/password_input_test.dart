import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/formz/password_input.dart';

void main() {
  group('PasswordInput', () {
    test('8+ chars passes', () {
      const input = PasswordInput.dirty('password');
      expect(input.isValid, isTrue);
    });

    test('11 chars passes', () {
      const input = PasswordInput.dirty('password123');
      expect(input.isValid, isTrue);
    });

    test('7 chars fails with tooShort', () {
      const input = PasswordInput.dirty('passwor');
      expect(input.isValid, isFalse);
      expect(input.error, PasswordValidationError.tooShort);
    });

    test('empty string fails with tooShort', () {
      const input = PasswordInput.dirty();
      expect(input.isValid, isFalse);
      expect(input.error, PasswordValidationError.tooShort);
    });

    test('exactly 8 chars passes', () {
      const input = PasswordInput.dirty('12345678');
      expect(input.isValid, isTrue);
    });

    test('pure input is not validated', () {
      const input = PasswordInput.pure();
      expect(input.isPure, isTrue);
    });
  });
}
