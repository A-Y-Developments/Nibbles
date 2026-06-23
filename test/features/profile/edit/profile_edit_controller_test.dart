import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_controller.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily Park',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

/// Captures the (reason, error string) tuple recorded by the controller's
/// non-fatal Crashlytics path so tests can assert the P1 telemetry payload
/// without touching real Firebase.
class _CrashCapture {
  final List<({String? reason, String error})> calls = [];

  Future<void> record(Object error, StackTrace stack, {String? reason}) async {
    calls.add((reason: reason, error: error.toString()));
  }
}

void main() {
  late _MockBabyProfileService mockBabyService;
  late _MockAuthRepository mockAuthRepo;
  late FakeAnalytics fakeAnalytics;
  late _CrashCapture crashCapture;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(Gender.female);
    registerFallbackValue(DateTime(2025));
  });

  setUp(() {
    mockBabyService = _MockBabyProfileService();
    mockAuthRepo = _MockAuthRepository();
    fakeAnalytics = FakeAnalytics();
    crashCapture = _CrashCapture();

    // AuthService.build() subscribes to the stream and reads isLoggedIn — stub
    // both so the real notifier boots in the container without touching
    // Supabase.
    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(
      () => mockAuthRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.currentUserEmail).thenReturn('lily@example.com');
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);

    container =
        ProviderContainer(
            overrides: [
              babyProfileServiceProvider.overrideWithValue(mockBabyService),
              authRepositoryProvider.overrideWithValue(mockAuthRepo),
              analyticsProvider.overrideWithValue(fakeAnalytics),
              profileEditCrashRecorderProvider.overrideWithValue(
                crashCapture.record,
              ),
            ],
          )
          // Hold the AsyncNotifier alive across awaits.
          ..listen<AsyncValue<ProfileEditState>>(
            profileEditControllerProvider(_babyId),
            (_, __) {},
          );
  });

  tearDown(() => container.dispose());

  Future<ProfileEditController> readController() async {
    // Force the AsyncNotifier to finish its build() before tests interact.
    await container.read(profileEditControllerProvider(_babyId).future);
    return container.read(profileEditControllerProvider(_babyId).notifier);
  }

  group('ProfileEditController.build', () {
    test(
      'seeds firstName/lastName from baby.name split and email from auth',
      () async {
        await container.read(profileEditControllerProvider(_babyId).future);
        final state = container
            .read(profileEditControllerProvider(_babyId))
            .requireValue;

        expect(state.firstName, 'Lily');
        expect(state.lastName, 'Park');
        expect(state.email, 'lily@example.com');
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
      },
    );

    test('single-token name leaves lastName empty', () async {
      // Re-stub before the AsyncNotifier builds, then invalidate so the
      // listener-triggered build picks up the new stub.
      when(
        () => mockBabyService.getBaby(),
      ).thenAnswer((_) async => _fakeBaby.copyWith(name: 'Lily'));
      container.invalidate(profileEditControllerProvider(_babyId));

      await container.read(profileEditControllerProvider(_babyId).future);
      final state = container
          .read(profileEditControllerProvider(_babyId))
          .requireValue;

      expect(state.firstName, 'Lily');
      expect(state.lastName, '');
    });
  });

  group('ProfileEditController.save — name-only branch', () {
    test('calls updateBaby, does NOT call updateEmail, records '
        'logProfileEditSaved(emailChanged=false)', () async {
      when(
        () => mockBabyService.updateBaby(any(), any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_fakeBaby));

      final ctrl = await readController();
      ctrl.updateFirstName('Lilyan');
      final result = await ctrl.save();

      await Future<void>.delayed(Duration.zero);

      expect(result.success, isTrue);
      expect(result.emailChanged, isFalse);
      verify(
        () => mockBabyService.updateBaby(
          _babyId,
          'Lilyan Park',
          _fakeBaby.dateOfBirth,
          _fakeBaby.gender,
        ),
      ).called(1);
      verifyNever(() => mockAuthRepo.updateEmail(any()));

      final state = container
          .read(profileEditControllerProvider(_babyId))
          .requireValue;
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);

      expect(fakeAnalytics.eventNames, contains('profile_edit_saved'));
      final evt = fakeAnalytics.calls.firstWhere(
        (c) => c.name == 'profile_edit_saved',
      );
      expect(evt.parameters['email_changed'], isFalse);
      expect(crashCapture.calls, isEmpty);
    });

    test('emits empty lastName as single-token name', () async {
      when(
        () => mockBabyService.updateBaby(any(), any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_fakeBaby));

      final ctrl = await readController();
      ctrl
        ..updateFirstName('Lily')
        ..updateLastName('   '); // whitespace -> trimmed empty
      final result = await ctrl.save();

      expect(result.success, isTrue);
      verify(
        () => mockBabyService.updateBaby(_babyId, 'Lily', any(), any()),
      ).called(1);
    });
  });

  group('ProfileEditController.save — email-change branch', () {
    test('calls updateBaby AND updateEmail; records '
        'logProfileEditSaved(emailChanged=true)', () async {
      when(
        () => mockBabyService.updateBaby(any(), any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_fakeBaby));
      when(
        () => mockAuthRepo.updateEmail(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final ctrl = await readController();
      ctrl.updateEmail('lily.new@example.com');
      final result = await ctrl.save();

      await Future<void>.delayed(Duration.zero);

      expect(result.success, isTrue);
      expect(result.emailChanged, isTrue);
      verify(
        () => mockBabyService.updateBaby(any(), any(), any(), any()),
      ).called(1);
      verify(() => mockAuthRepo.updateEmail('lily.new@example.com')).called(1);

      final evt = fakeAnalytics.calls.firstWhere(
        (c) => c.name == 'profile_edit_saved',
      );
      expect(evt.parameters['email_changed'], isTrue);
      expect(crashCapture.calls, isEmpty);
    });
  });

  group('ProfileEditController.save — failure branches', () {
    test('updateEmail failure: sets errorMessage; records crash recorder; '
        'analytics success NOT fired', () async {
      when(
        () => mockBabyService.updateBaby(any(), any(), any(), any()),
      ).thenAnswer((_) async => Result.success(_fakeBaby));
      when(() => mockAuthRepo.updateEmail(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('email taken')),
      );

      final ctrl = await readController();
      ctrl.updateEmail('lily.new@example.com');
      final result = await ctrl.save();

      expect(result.success, isFalse);
      expect(result.emailChanged, isFalse);

      final state = container
          .read(profileEditControllerProvider(_babyId))
          .requireValue;
      expect(state.errorMessage, 'email taken');
      expect(state.isLoading, isFalse);

      expect(crashCapture.calls, hasLength(1));
      expect(crashCapture.calls.first.reason, 'profile_email_update_failure');
      expect(
        crashCapture.calls.first.error,
        contains('profile_email_update_failure'),
      );
      expect(crashCapture.calls.first.error, contains('email taken'));

      expect(fakeAnalytics.eventNames, isNot(contains('profile_edit_saved')));
    });

    test(
      'updateBaby failure: sets errorMessage; does NOT call updateEmail',
      () async {
        when(
          () => mockBabyService.updateBaby(any(), any(), any(), any()),
        ).thenAnswer(
          (_) async => const Result.failure(NetworkException('offline')),
        );

        final ctrl = await readController();
        // Even with email changed, save should bail before the email call.
        ctrl
          ..updateFirstName('Lilyan')
          ..updateEmail('lily.new@example.com');
        final result = await ctrl.save();

        expect(result.success, isFalse);
        verifyNever(() => mockAuthRepo.updateEmail(any()));

        final state = container
            .read(profileEditControllerProvider(_babyId))
            .requireValue;
        expect(state.errorMessage, 'offline');
        expect(state.isLoading, isFalse);

        expect(crashCapture.calls, isEmpty);
        expect(fakeAnalytics.eventNames, isNot(contains('profile_edit_saved')));
      },
    );

    test(
      'getBaby returns null during save: sets Baby-not-found errorMessage',
      () async {
        final ctrl = await readController();
        when(() => mockBabyService.getBaby()).thenAnswer((_) async => null);

        final result = await ctrl.save();

        expect(result.success, isFalse);
        final state = container
            .read(profileEditControllerProvider(_babyId))
            .requireValue;
        expect(state.errorMessage, 'Baby profile not found.');
        expect(state.isLoading, isFalse);
      },
    );
  });
}
