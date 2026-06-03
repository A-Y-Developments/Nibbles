import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/consent_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/consent_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

/// Hand-rolled no-op repo — see consent screen test for the rationale; mixing
/// a Mock'd ConsentService that uses NAMED matchers with the existing
/// `babyProfile.createBaby(any(), any())` POSITIONAL matchers in this file
/// would trip mocktail's matcher accounting. NIB-145's wiring behaviour is
/// asserted in `onboarding_controller_consent_persistence_test.dart`.
class _NoopConsentRepository implements ConsentRepository {
  const _NoopConsentRepository();

  @override
  Future<Result<void>> recordConsent({
    required String babyId,
    required ConsentType type,
  }) async => const Result.success(null);
}

Future<void> _noopCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
  List<String>? information,
}) async {}

final _fakeBaby = Baby(
  id: 'baby-001',
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.preferNotToSay,
  onboardingCompleted: false,
);

ProviderContainer _makeContainer(BabyProfileService service) {
  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(service),
      consentServiceProvider.overrideWithValue(
        const ConsentService(_NoopConsentRepository()),
      ),
      onboardingCrashRecorderProvider.overrideWithValue(_noopCrashRecorder),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('OnboardingController.submit (P1 createBaby contract)', () {
    late _MockBabyProfileService babyProfile;

    setUp(() {
      babyProfile = _MockBabyProfileService();
    });

    test('returns false, sets inline error, and is a no-op when name + dob are '
        'not captured yet (defensive guard — splash reset should make this '
        'unreachable but it must NOT silently no-op if hit)', () async {
      final container = _makeContainer(babyProfile);
      final controller = container.read(onboardingControllerProvider.notifier);

      final ok = await controller.submit();

      expect(ok, isFalse);
      verifyNever(() => babyProfile.createBaby(any(), any()));
      final state = container.read(onboardingControllerProvider);
      expect(state.submitErrorMessage, isNotNull);
      expect(state.submitErrorMessage, contains('name'));
    });

    test('success path returns true and clears error', () async {
      when(
        () => babyProfile.createBaby(any(), any()),
      ).thenAnswer((_) async => Result.success(_fakeBaby));

      final container = _makeContainer(babyProfile);
      final controller = container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(DateTime(2025, 6));

      final ok = await controller.submit();

      expect(ok, isTrue);
      final state = container.read(onboardingControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.submitErrorMessage, isNull);
    });

    test(
      'failure path returns false, populates inline error, resets isSubmitting',
      () async {
        when(() => babyProfile.createBaby(any(), any())).thenAnswer(
          (_) async => const Result.failure(NetworkException('offline')),
        );

        final container = _makeContainer(babyProfile);
        final controller = container.read(onboardingControllerProvider.notifier)
          ..updateName('Lily')
          ..updateDob(DateTime(2025, 6));

        final ok = await controller.submit();

        expect(ok, isFalse);
        final state = container.read(onboardingControllerProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.submitErrorMessage, 'offline');
      },
    );
  });

  group('OnboardingController state hoisting (keepAlive contract)', () {
    test('updateName + updateDob are preserved across reads', () {
      final container = _makeContainer(_MockBabyProfileService());
      container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(DateTime(2025, 6));

      final state = container.read(onboardingControllerProvider);
      expect(state.babyName.value, 'Lily');
      expect(state.dob, DateTime(2025, 6));
    });

    test('setReadinessAnswers updates state', () {
      final container = _makeContainer(_MockBabyProfileService());
      container
          .read(onboardingControllerProvider.notifier)
          .setReadinessAnswers(<bool?>[true, false, null]);

      final state = container.read(onboardingControllerProvider);
      expect(state.readinessAnswers, [true, false, null]);
    });

    test(
      'answerReadinessQuestion writes a single answer in place and preserves '
      'the seeded length-5 list (back-nav contract)',
      () {
        final container = _makeContainer(_MockBabyProfileService());
        final notifier = container.read(onboardingControllerProvider.notifier)
          ..answerReadinessQuestion(0, isYes: true)
          ..answerReadinessQuestion(3, isYes: false);

        final state = container.read(onboardingControllerProvider);
        expect(state.readinessAnswers.length, 5);
        expect(state.readinessAnswers[0], isTrue);
        expect(state.readinessAnswers[3], isFalse);
        expect(state.readinessAnswers[4], isNull);

        // Out-of-range indices are a no-op (defensive).
        notifier.answerReadinessQuestion(99, isYes: true);
        expect(
          container.read(onboardingControllerProvider).readinessAnswers.length,
          5,
        );
      },
    );

  });
}
