import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/consent_service.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockConsentService extends Mock implements ConsentService {}

class _CrashRecorderSpy {
  final captured = <_CrashCall>[];

  Future<void> call(
    Object error,
    StackTrace stack, {
    String? reason,
    List<String>? information,
  }) async {
    captured.add(
      _CrashCall(
        error: error,
        reason: reason,
        information: information ?? const <String>[],
      ),
    );
  }
}

class _CrashCall {
  _CrashCall({
    required this.error,
    required this.reason,
    required this.information,
  });

  final Object error;
  final String? reason;
  final List<String> information;
}

final _fakeBaby = Baby(
  id: 'baby-001',
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.preferNotToSay,
  onboardingCompleted: false,
);

ProviderContainer _makeContainer({
  required BabyProfileService babyProfile,
  required ConsentService consent,
  required _CrashRecorderSpy crashRecorder,
}) {
  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(babyProfile),
      consentServiceProvider.overrideWithValue(consent),
      onboardingCrashRecorderProvider.overrideWithValue(crashRecorder.call),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// NIB-145 — `OnboardingController.submit` must persist the consent
/// acknowledgements after a successful baby creation. Always records
/// `solidsIntroduction`; additionally records `under6MoResponsibility` when
/// the baby is younger than 6 months at submit time. P2 — failures log to
/// Crashlytics and never block onboarding.
void main() {
  late _MockBabyProfileService babyProfile;
  late _MockConsentService consent;
  late _CrashRecorderSpy crashRecorder;

  setUpAll(() {
    registerFallbackValue(ConsentType.solidsIntroduction);
    registerFallbackValue(Gender.preferNotToSay);
    registerFallbackValue(<bool>[]);
  });

  setUp(() {
    babyProfile = _MockBabyProfileService();
    consent = _MockConsentService();
    crashRecorder = _CrashRecorderSpy();

    when(
      () => babyProfile.createBaby(any(), any(), any(), any()),
    ).thenAnswer((_) async => Result.success(_fakeBaby));
    when(
      () => consent.recordConsent(
        babyId: any(named: 'babyId'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
  });

  test(
    'records solidsIntroduction only when baby DOB >= 6 months at submit time',
    () async {
      final container = _makeContainer(
        babyProfile: babyProfile,
        consent: consent,
        crashRecorder: crashRecorder,
      );
      final controller = container.read(onboardingControllerProvider.notifier)
        ..updateName('Lily')
        // 8 months old: clearly >= 6mo at "today" — exact day doesn't matter
        // as long as the diff is >= 6 whole months.
        ..updateDob(DateTime.now().subtract(const Duration(days: 250)));

      final ok = await controller.submit();

      expect(ok, isTrue);
      verify(
        () => consent.recordConsent(
          babyId: 'baby-001',
          type: ConsentType.solidsIntroduction,
        ),
      ).called(1);
      verifyNever(
        () => consent.recordConsent(
          babyId: any(named: 'babyId'),
          type: ConsentType.under6MoResponsibility,
        ),
      );
    },
  );

  test('records BOTH solidsIntroduction and under6MoResponsibility when baby '
      'DOB is younger than 6 months at submit time', () async {
    final container = _makeContainer(
      babyProfile: babyProfile,
      consent: consent,
      crashRecorder: crashRecorder,
    );
    final controller = container.read(onboardingControllerProvider.notifier)
      ..updateName('Lily')
      // 2 months old — well under the 6mo cutoff.
      ..updateDob(DateTime.now().subtract(const Duration(days: 60)));

    final ok = await controller.submit();

    expect(ok, isTrue);
    verify(
      () => consent.recordConsent(
        babyId: 'baby-001',
        type: ConsentType.solidsIntroduction,
      ),
    ).called(1);
    verify(
      () => consent.recordConsent(
        babyId: 'baby-001',
        type: ConsentType.under6MoResponsibility,
      ),
    ).called(1);
  });

  test('P2 — consent insert failure does NOT block submit and logs to '
      'Crashlytics with the consent_type for triage', () async {
    when(
      () => consent.recordConsent(
        babyId: any(named: 'babyId'),
        type: any(named: 'type'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(ServerException('rls denied')),
    );

    final container = _makeContainer(
      babyProfile: babyProfile,
      consent: consent,
      crashRecorder: crashRecorder,
    );
    final controller = container.read(onboardingControllerProvider.notifier)
      ..updateName('Lily')
      ..updateDob(DateTime.now().subtract(const Duration(days: 60)));

    final ok = await controller.submit();

    // Still succeeds — DB receipt failure must not surface as a blocker.
    expect(ok, isTrue);
    final state = container.read(onboardingControllerProvider);
    expect(state.submitErrorMessage, isNull);
    expect(state.isSubmitting, isFalse);

    // Both calls were attempted (the second consent didn't short-circuit
    // on the first failure — they're independent receipts).
    verify(
      () => consent.recordConsent(
        babyId: 'baby-001',
        type: ConsentType.solidsIntroduction,
      ),
    ).called(1);
    verify(
      () => consent.recordConsent(
        babyId: 'baby-001',
        type: ConsentType.under6MoResponsibility,
      ),
    ).called(1);

    expect(crashRecorder.captured, hasLength(2));
    for (final call in crashRecorder.captured) {
      expect(call.reason, 'onboarding_consent_record_failure');
      expect(call.error.toString(), contains('rls denied'));
    }
    expect(
      crashRecorder.captured.expand((c) => c.information).toList(),
      containsAll(<String>[
        'consent_type=solids_introduction',
        'consent_type=under_6mo_responsibility',
      ]),
    );
  });

  test('when createBaby fails, no consent receipts are attempted', () async {
    when(() => babyProfile.createBaby(any(), any(), any(), any())).thenAnswer(
      (_) async => const Result.failure(NetworkException('offline')),
    );

    final container = _makeContainer(
      babyProfile: babyProfile,
      consent: consent,
      crashRecorder: crashRecorder,
    );
    final controller = container.read(onboardingControllerProvider.notifier)
      ..updateName('Lily')
      ..updateDob(DateTime.now().subtract(const Duration(days: 60)));

    final ok = await controller.submit();

    expect(ok, isFalse);
    verifyNever(
      () => consent.recordConsent(
        babyId: any(named: 'babyId'),
        type: any(named: 'type'),
      ),
    );
    expect(crashRecorder.captured, isEmpty);
  });
}
