import 'dart:async';

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

/// See `onboarding_controller_test.dart` for the matcher-queue rationale.
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

/// NIB-105 — submit timing/flag contract for `OnboardingController.submit`.
///
/// `onboarding_controller_test.dart` already covers the BOOLEAN return of
/// `submit` on success / failure / pre-condition violation. This file pins
/// the IN-FLIGHT shape (`isSubmitting` flips at the right edges) so the
/// consent widget can safely gate its CTA on `state.isSubmitting`.
void main() {
  late _MockBabyProfileService babyProfile;

  setUp(() {
    babyProfile = _MockBabyProfileService();
  });

  test(
    'submit flips isSubmitting true on entry, false on success completion',
    () async {
      final completer = Completer<Result<Baby>>();
      when(
        () => babyProfile.createBaby(any(), any()),
      ).thenAnswer((_) => completer.future);

      final container = _makeContainer(babyProfile);
      final controller = container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(DateTime(2025, 6));

      expect(
        container.read(onboardingControllerProvider).isSubmitting,
        isFalse,
        reason: 'starts idle',
      );

      final pending = controller.submit();
      // Mid-flight: the createBaby future has not resolved yet, isSubmitting
      // must be observable so the consent widget can disable its CTA.
      expect(
        container.read(onboardingControllerProvider).isSubmitting,
        isTrue,
      );

      completer.complete(Result.success(_fakeBaby));
      await pending;

      expect(
        container.read(onboardingControllerProvider).isSubmitting,
        isFalse,
      );
    },
  );

  test(
    'submit flips isSubmitting back to false on failure (so the user can '
    'retry from the inline P1 surface)',
    () async {
      when(() => babyProfile.createBaby(any(), any())).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      final container = _makeContainer(babyProfile);
      final controller = container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(DateTime(2025, 6));

      await controller.submit();

      final state = container.read(onboardingControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.submitErrorMessage, 'offline');
    },
  );

  test(
    'submit clears any prior submitErrorMessage on entry (retry path)',
    () async {
      var calls = 0;
      when(() => babyProfile.createBaby(any(), any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) return const Result.failure(NetworkException('boom'));
        return Result.success(_fakeBaby);
      });

      final container = _makeContainer(babyProfile);
      final controller = container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(DateTime(2025, 6));

      await controller.submit();
      expect(
        container.read(onboardingControllerProvider).submitErrorMessage,
        'boom',
      );

      final ok = await controller.submit();
      expect(ok, isTrue);
      expect(
        container.read(onboardingControllerProvider).submitErrorMessage,
        isNull,
      );
    },
  );

  test(
    're-entrant submit while in-flight returns false and never calls '
    'createBaby twice (no orphan baby rows)',
    () async {
      final completer = Completer<Result<Baby>>();
      when(
        () => babyProfile.createBaby(any(), any()),
      ).thenAnswer((_) => completer.future);

      final container = _makeContainer(babyProfile);
      final controller = container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        ..updateDob(DateTime(2025, 6));

      // First call is in-flight (isSubmitting=true, awaiting createBaby).
      final pending = controller.submit();
      // Second call before the first resolves must be rejected by the guard.
      final reentrant = await controller.submit();
      expect(reentrant, isFalse);

      completer.complete(Result.success(_fakeBaby));
      await pending;

      verify(() => babyProfile.createBaby(any(), any())).called(1);
    },
  );
}
