import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';

void main() {
  group('BabyNameInput', () {
    test('1 char passes', () {
      const input = BabyNameInput.dirty('A');
      expect(input.isValid, isTrue);
    });

    test('empty string fails with empty error', () {
      const input = BabyNameInput.dirty();
      expect(input.isValid, isFalse);
      expect(input.error, BabyNameValidationError.empty);
    });

    test('exactly 50 chars passes', () {
      final input = BabyNameInput.dirty('A' * 50);
      expect(input.isValid, isTrue);
    });

    test('51 chars fails with tooLong error', () {
      final input = BabyNameInput.dirty('A' * 51);
      expect(input.isValid, isFalse);
      expect(input.error, BabyNameValidationError.tooLong);
    });

    test('typical baby name passes', () {
      const input = BabyNameInput.dirty('Oliver');
      expect(input.isValid, isTrue);
    });

    test('pure input is not validated', () {
      const input = BabyNameInput.pure();
      expect(input.isPure, isTrue);
    });
  });
}
