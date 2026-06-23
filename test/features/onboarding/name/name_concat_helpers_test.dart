import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

/// Mirrors `_onNext` in `onboarding_name_screen.dart`:
///   final joined = last.isEmpty ? first : '$first $last';
///
/// Pinned here so a future refactor of the screen helper reads as a diff
/// against this file rather than silently changing what gets stored in
/// `state.babyName.value`.
String joinFirstLast(String firstRaw, String lastRaw) {
  final first = firstRaw.trim();
  final last = lastRaw.trim();
  return last.isEmpty ? first : '$first $last';
}

ProviderContainer _makeContainer() {
  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(_MockBabyProfileService()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group(
    'name concat helper (screen owns trim + join, controller stores raw)',
    () {
      test('first only -> stored as first (no trailing space)', () {
        expect(joinFirstLast('Lily', ''), 'Lily');
      });

      test('first + last -> "first last"', () {
        expect(joinFirstLast('Lily', 'Putra'), 'Lily Putra');
      });

      test('outer whitespace on either token is trimmed before join', () {
        expect(joinFirstLast('  Lily  ', '  Putra  '), 'Lily Putra');
        expect(joinFirstLast('  Lily  ', ''), 'Lily');
      });

      test('whitespace-only last is treated as empty', () {
        expect(joinFirstLast('Lily', '   '), 'Lily');
      });
    },
  );

  group('OnboardingController.updateName <-> babyName.value contract', () {
    test('updateName stores the joined string verbatim on babyName.value', () {
      final container = _makeContainer();
      container
          .read(onboardingControllerProvider.notifier)
          .updateName(joinFirstLast('Lily', 'Putra'));
      expect(
        container.read(onboardingControllerProvider).babyName.value,
        'Lily Putra',
      );
    });

    test('updateName with empty value flips babyName.isValid to false (formz '
        "empty rule) so submit's defensive guard fires", () {
      final container = _makeContainer();
      container
          .read(onboardingControllerProvider.notifier)
          .updateName(joinFirstLast('', ''));
      final state = container.read(onboardingControllerProvider);
      expect(state.babyName.value, '');
      expect(state.babyName.isValid, isFalse);
    });

    test('updateName with non-empty value flips babyName.isValid to true', () {
      final container = _makeContainer();
      container
          .read(onboardingControllerProvider.notifier)
          .updateName(joinFirstLast('Lily', ''));
      expect(
        container.read(onboardingControllerProvider).babyName.isValid,
        isTrue,
      );
    });
  });
}
