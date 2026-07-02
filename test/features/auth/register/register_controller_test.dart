import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/register/register_controller.dart';
import 'package:nibbles/src/features/auth/register/register_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

void main() {
  late MockAuthRepository mockRepo;
  late MockLocalFlagService mockFlags;
  late FakeAnalytics fakeAnalytics;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockFlags = MockLocalFlagService();
    fakeAnalytics = FakeAnalytics();
    when(() => mockRepo.isLoggedIn).thenReturn(false);
    when(
      () => mockRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(mockFlags.isOnboardingBabySetupDone).thenReturn(true);

    container =
        ProviderContainer(
            overrides: [
              authRepositoryProvider.overrideWithValue(mockRepo),
              localFlagServiceProvider.overrideWithValue(mockFlags),
              analyticsProvider.overrideWithValue(fakeAnalytics),
            ],
          )
          // Hold the controller alive across awaits so state isn't lost to
          // auto-dispose between assertions.
          ..listen<RegisterState>(registerControllerProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  RegisterController readController() =>
      container.read(registerControllerProvider.notifier);

  RegisterState readState() => container.read(registerControllerProvider);

  // ---------------------------------------------------------------------------
  // field mutations + derived validity
  // ---------------------------------------------------------------------------

  group('field mutations', () {
    test('update* set their fields and clear any error', () {
      readController()
        ..updateEmail('jane@example.com')
        ..updatePassword('password123')
        ..updateConfirmPassword('password123');

      final state = readState();
      expect(state.email.value, 'jane@example.com');
      expect(state.password.value, 'password123');
      expect(state.confirmPassword, 'password123');
      expect(state.errorMessage, isNull);
    });

    test('toggleObscure / toggleObscureConfirm flip independently', () {
      expect(readState().obscure, isTrue);
      expect(readState().obscureConfirm, isTrue);

      readController().toggleObscure();
      expect(readState().obscure, isFalse);
      expect(readState().obscureConfirm, isTrue);

      readController().toggleObscureConfirm();
      expect(readState().obscureConfirm, isFalse);
    });
  });

  group('derived validity', () {
    test('passwordsMatch is false until confirm equals a non-empty password',
        () {
      final ctrl = readController()..updatePassword('password123');
      expect(readState().passwordsMatch, isFalse);

      ctrl.updateConfirmPassword('nope');
      expect(readState().passwordsMatch, isFalse);

      ctrl.updateConfirmPassword('password123');
      expect(readState().passwordsMatch, isTrue);
    });

    test('isValid requires valid email + valid password + matching confirm',
        () {
      final ctrl = readController()
        ..updateEmail('not-an-email')
        ..updatePassword('short')
        ..updateConfirmPassword('short');
      expect(readState().isValid, isFalse);

      ctrl
        ..updateEmail('jane@example.com')
        ..updatePassword('password123')
        ..updateConfirmPassword('password123');
      expect(readState().isValid, isTrue);
    });

    test('submit failure stores the backend message in errorMessage', () async {
      when(() => mockRepo.signUp(any(), any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('Email already in use.')),
      );

      final ok = await readController().submit();

      expect(ok, isFalse);
      expect(readState().errorMessage, 'Email already in use.');
      expect(readState().isLoading, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // submit() — email sign up
  // ---------------------------------------------------------------------------

  group('submit (email)', () {
    test(
      'returns true on Success and fires method_selected + success',
      () async {
        when(
          () => mockRepo.signUp(any(), any()),
        ).thenAnswer((_) async => const Result.success(null));

        final ok = await readController().submit();
        await Future<void>.delayed(Duration.zero);

        expect(ok, isTrue);
        expect(fakeAnalytics.eventNames, [
          'sign_up_method_selected',
          'sign_up_success',
        ]);
        expect(fakeAnalytics.calls[0].parameters, {'method': 'email'});
      },
    );

    test('returns false on Failure and fires sign_up_failure', () async {
      when(() => mockRepo.signUp(any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('email in use')),
      );

      final ok = await readController().submit();
      await Future<void>.delayed(Duration.zero);

      expect(ok, isFalse);
      expect(fakeAnalytics.eventNames, [
        'sign_up_method_selected',
        'sign_up_failure',
      ]);
      expect(fakeAnalytics.calls[1].parameters, {
        'method': 'email',
        'error_code': 'server_exception',
      });
    });
  });

  // ---------------------------------------------------------------------------
  // signInWithGoogle
  // ---------------------------------------------------------------------------

  group('signInWithGoogle', () {
    test('returns true on Success(true), no error', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(true));

      final ok = await readController().signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      expect(ok, isTrue);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(fakeAnalytics.eventNames, [
        'sign_up_method_selected',
        'sign_up_success',
      ]);
      expect(fakeAnalytics.calls[0].parameters, {'method': 'google'});
    });

    test(
      'returns false on Success(false) (cancel) and fires cancel event',
      () async {
        when(
          () => mockRepo.signInWithGoogle(),
        ).thenAnswer((_) async => const Result.success(false));

        final ok = await readController().signInWithGoogle();
        await Future<void>.delayed(Duration.zero);

        expect(ok, isFalse);
        final state = container.read(registerControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
        expect(fakeAnalytics.eventNames, [
          'sign_up_method_selected',
          'social_login_cancelled',
        ]);
        expect(fakeAnalytics.calls.last.parameters, {'provider': 'google'});
      },
    );

    test(
      'returns false on Failure, sets errorMessage and fires failure event',
      () async {
        when(() => mockRepo.signInWithGoogle()).thenAnswer(
          (_) async => const Result.failure(ServerException('Google failed')),
        );

        final ok = await readController().signInWithGoogle();
        await Future<void>.delayed(Duration.zero);

        expect(ok, isFalse);
        final state = container.read(registerControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, 'Google failed');
        expect(fakeAnalytics.eventNames, [
          'sign_up_method_selected',
          'sign_up_failure',
        ]);
        expect(fakeAnalytics.calls.last.parameters, {
          'method': 'google',
          'error_code': 'server_exception',
        });
      },
    );
  });

  // ---------------------------------------------------------------------------
  // signInWithApple
  // ---------------------------------------------------------------------------

  group('signInWithApple', () {
    test('returns true on Success(true), no error', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(true));

      final ok = await readController().signInWithApple();
      await Future<void>.delayed(Duration.zero);

      expect(ok, isTrue);
      expect(fakeAnalytics.eventNames, [
        'sign_up_method_selected',
        'sign_up_success',
      ]);
      expect(fakeAnalytics.calls[0].parameters, {'method': 'apple'});
    });

    test(
      'returns false on Success(false) (cancel) and fires cancel event',
      () async {
        when(
          () => mockRepo.signInWithApple(),
        ).thenAnswer((_) async => const Result.success(false));

        final ok = await readController().signInWithApple();
        await Future<void>.delayed(Duration.zero);

        expect(ok, isFalse);
        expect(fakeAnalytics.eventNames, [
          'sign_up_method_selected',
          'social_login_cancelled',
        ]);
        expect(fakeAnalytics.calls.last.parameters, {'provider': 'apple'});
      },
    );

    test('returns false on Failure and sets errorMessage', () async {
      when(() => mockRepo.signInWithApple()).thenAnswer(
        (_) async => const Result.failure(ServerException('Apple failed')),
      );

      final ok = await readController().signInWithApple();
      await Future<void>.delayed(Duration.zero);

      expect(ok, isFalse);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Apple failed');
      expect(fakeAnalytics.eventNames, [
        'sign_up_method_selected',
        'sign_up_failure',
      ]);
      expect(fakeAnalytics.calls.last.parameters, {
        'method': 'apple',
        'error_code': 'server_exception',
      });
    });
  });
}
