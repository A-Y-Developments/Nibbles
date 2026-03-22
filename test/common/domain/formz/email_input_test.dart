import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/formz/email_input.dart';

void main() {
  group('EmailInput', () {
    test('valid email passes', () {
      const input = EmailInput.dirty('test@example.com');
      expect(input.isValid, isTrue);
    });

    test('invalid format fails', () {
      const input = EmailInput.dirty('notanemail');
      expect(input.isValid, isFalse);
      expect(input.error, EmailValidationError.invalid);
    });

    test('empty string fails', () {
      const input = EmailInput.dirty('');
      expect(input.isValid, isFalse);
      expect(input.error, EmailValidationError.invalid);
    });

    test('email without TLD fails', () {
      const input = EmailInput.dirty('test@example');
      expect(input.isValid, isFalse);
      expect(input.error, EmailValidationError.invalid);
    });

    test('email with subdomain passes', () {
      const input = EmailInput.dirty('user@mail.example.com');
      expect(input.isValid, isTrue);
    });

    test('pure input is not validated', () {
      const input = EmailInput.pure();
      expect(input.isPure, isTrue);
    });
  });
}
