import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/baby_setup/baby_setup_controller.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

final _baby = Baby(
  id: 'baby-1',
  userId: 'user-1',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: false,
);

final _dob = DateTime(2025, 6);

void main() {
  late _MockBabyProfileService babyProfile;
  late _MockLocalFlagService localFlags;

  setUpAll(() {
    registerFallbackValue(Gender.female);
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    babyProfile = _MockBabyProfileService();
    localFlags = _MockLocalFlagService();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        babyProfileServiceProvider.overrideWithValue(babyProfile),
        localFlagServiceProvider.overrideWithValue(localFlags),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('build()', () {
    test('initial state has step 0, pure name, null gender', () {
      final state = container().read(babySetupControllerProvider);

      expect(state.step, 0);
      expect(state.babyName.isPure, true);
      expect(state.gender, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('initial dob is roughly 180 days ago', () {
      final state = container().read(babySetupControllerProvider);

      final diff = DateTime.now().difference(state.dob!).inDays;
      expect(diff, inInclusiveRange(179, 181));
    });
  });

  group('updateName()', () {
    test('sets babyName to dirty value and clears error', () {
      final c = container();
      c.read(babySetupControllerProvider.notifier).updateName('Lily');

      final state = c.read(babySetupControllerProvider);
      expect(state.babyName.value, 'Lily');
      expect(state.babyName.isPure, false);
      expect(state.errorMessage, isNull);
    });
  });

  group('updateDob()', () {
    test('sets dob and clears error', () {
      final c = container();
      c.read(babySetupControllerProvider.notifier).updateDob(_dob);

      final state = c.read(babySetupControllerProvider);
      expect(state.dob, _dob);
      expect(state.errorMessage, isNull);
    });
  });

  group('updateGender()', () {
    test('sets gender and clears error', () {
      final c = container();
      c.read(babySetupControllerProvider.notifier).updateGender(Gender.female);

      final state = c.read(babySetupControllerProvider);
      expect(state.gender, Gender.female);
      expect(state.errorMessage, isNull);
    });
  });

  group('nextStep()', () {
    test('increments step', () {
      final c = container();
      c.read(babySetupControllerProvider.notifier).nextStep();

      expect(c.read(babySetupControllerProvider).step, 1);
    });
  });

  group('previousStep()', () {
    test('decrements step when step > 0', () {
      final c = container();
      c.read(babySetupControllerProvider.notifier).nextStep();
      c.read(babySetupControllerProvider.notifier).previousStep();

      expect(c.read(babySetupControllerProvider).step, 0);
    });

    test('is a no-op at step 0', () {
      final c = container();
      c.read(babySetupControllerProvider.notifier).previousStep();

      expect(c.read(babySetupControllerProvider).step, 0);
    });
  });

  group('submit()', () {
    test('returns false immediately when dob is null', () async {
      final c = container();
      c.read(babySetupControllerProvider.notifier).updateGender(Gender.female);

      c.read(babySetupControllerProvider.notifier).updateDob(DateTime(2000));
      final notifier = c.read(babySetupControllerProvider.notifier);
      notifier.state = notifier.state.copyWith(dob: null);

      final result = await notifier.submit();
      expect(result, false);
      verifyNever(() => babyProfile.createBaby(any(), any(), any()));
    });

    test('returns false immediately when gender is null', () async {
      final c = container();
      c.read(babySetupControllerProvider.notifier).updateDob(_dob);

      final result = await c
          .read(babySetupControllerProvider.notifier)
          .submit();
      expect(result, false);
      verifyNever(() => babyProfile.createBaby(any(), any(), any()));
    });

    test('returns true and sets flag on success', () async {
      when(
        () => babyProfile.createBaby(any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_baby));
      when(localFlags.setOnboardingBabySetupDone).thenAnswer((_) {});

      final c = container();
      c.read(babySetupControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(_dob)
        ..updateGender(Gender.female);

      final result = await c
          .read(babySetupControllerProvider.notifier)
          .submit();

      expect(result, true);
      expect(c.read(babySetupControllerProvider).isLoading, false);
      verify(localFlags.setOnboardingBabySetupDone).called(1);
    });

    test('returns false and sets errorMessage on failure', () async {
      const error = NetworkException('Baby creation failed.');
      when(
        () => babyProfile.createBaby(any(), any(), any()),
      ).thenAnswer((_) async => const Result.failure(error));

      final c = container();
      c.read(babySetupControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(_dob)
        ..updateGender(Gender.female);

      final result = await c
          .read(babySetupControllerProvider.notifier)
          .submit();

      expect(result, false);
      expect(
        c.read(babySetupControllerProvider).errorMessage,
        'Baby creation failed.',
      );
      expect(c.read(babySetupControllerProvider).isLoading, false);
    });
  });
}
