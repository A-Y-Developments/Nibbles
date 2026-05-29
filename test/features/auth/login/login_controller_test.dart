import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/login/login_controller.dart';
import 'package:nibbles/src/features/auth/login/login_state.dart';
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

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        localFlagServiceProvider.overrideWithValue(mockFlags),
        analyticsProvider.overrideWithValue(fakeAnalytics),
      ],
    )
    // Hold the controller alive across awaits so state isn't lost to
    // auto-dispose between assertions.
    ..listen<LoginState>(loginControllerProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  LoginController readController() =>
      container.read(loginControllerProvider.notifier);

  // ---------------------------------------------------------------------------
  // submit() — email login
  // ---------------------------------------------------------------------------

  group('submit (email)', () {
    test('fires method_selected + success on Success', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      await readController().submit();

      // Drain pending fire-and-forget microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'login_success'],
      );
      expect(
        fakeAnalytics.calls[0].parameters,
        {'method': 'email'},
      );
      expect(
        fakeAnalytics.calls[1].parameters,
        {'method': 'email'},
      );
    });

    test('fires method_selected + failure on Failure', () async {
      when(() => mockRepo.signIn(any(), any())).thenAnswer(
        (_) async => const Result.failure(ServerException('bad creds')),
      );

      await readController().submit();
      await Future<void>.delayed(Duration.zero);

      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'login_failure'],
      );
      expect(
        fakeAnalytics.calls[1].parameters,
        {'method': 'email', 'error_code': 'server_exception'},
      );
    });

    test('maps NetworkException to network error_code', () async {
      when(() => mockRepo.signIn(any(), any())).thenAnswer(
        (_) async => const Result.failure(NetworkException()),
      );

      await readController().submit();
      await Future<void>.delayed(Duration.zero);

      expect(
        fakeAnalytics.calls.last.parameters,
        {'method': 'email', 'error_code': 'network'},
      );
    });

    test('maps UnknownException to unknown error_code', () async {
      when(() => mockRepo.signIn(any(), any())).thenAnswer(
        (_) async => const Result.failure(UnknownException()),
      );

      await readController().submit();
      await Future<void>.delayed(Duration.zero);

      expect(
        fakeAnalytics.calls.last.parameters,
        {'method': 'email', 'error_code': 'unknown'},
      );
    });
  });

  // ---------------------------------------------------------------------------
  // signInWithGoogle
  // ---------------------------------------------------------------------------

  group('signInWithGoogle', () {
    test('clears loading + no error on Success(true)', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(true));

      await readController().signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'login_success'],
      );
      expect(
        fakeAnalytics.calls[0].parameters,
        {'method': 'google'},
      );
    });

    test('clears loading + no error on Success(false) (cancel)', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(false));

      await readController().signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'social_login_cancelled'],
      );
      expect(
        fakeAnalytics.calls.last.parameters,
        {'provider': 'google'},
      );
    });

    test('sets errorMessage on Failure and fires login_failure', () async {
      when(() => mockRepo.signInWithGoogle()).thenAnswer(
        (_) async => const Result.failure(ServerException('Google failed')),
      );

      await readController().signInWithGoogle();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Google failed');
      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'login_failure'],
      );
      expect(
        fakeAnalytics.calls.last.parameters,
        {'method': 'google', 'error_code': 'server_exception'},
      );
    });
  });

  // ---------------------------------------------------------------------------
  // signInWithApple
  // ---------------------------------------------------------------------------

  group('signInWithApple', () {
    test('clears loading + no error on Success(true)', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(true));

      await readController().signInWithApple();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'login_success'],
      );
      expect(
        fakeAnalytics.calls[0].parameters,
        {'method': 'apple'},
      );
    });

    test('clears loading + no error on Success(false) (cancel)', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(false));

      await readController().signInWithApple();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'social_login_cancelled'],
      );
      expect(
        fakeAnalytics.calls.last.parameters,
        {'provider': 'apple'},
      );
    });

    test('sets errorMessage on Failure and fires login_failure', () async {
      when(() => mockRepo.signInWithApple()).thenAnswer(
        (_) async => const Result.failure(ServerException('Apple failed')),
      );

      await readController().signInWithApple();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Apple failed');
      expect(
        fakeAnalytics.eventNames,
        ['login_method_selected', 'login_failure'],
      );
      expect(
        fakeAnalytics.calls.last.parameters,
        {'method': 'apple', 'error_code': 'server_exception'},
      );
    });
  });

  // ---------------------------------------------------------------------------
  // PII guard
  // ---------------------------------------------------------------------------

  test('no PII in any logged parameters', () async {
    when(
      () => mockRepo.signIn(any(), any()),
    ).thenAnswer((_) async => const Result.success(null));

    readController().updateEmail('secret@example.com');
    readController().updatePassword('hunter2');
    await readController().submit();
    await Future<void>.delayed(Duration.zero);

    final allValues = fakeAnalytics.calls
        .expand((e) => e.parameters.values)
        .toList();
    for (final v in allValues) {
      expect(v, isNot(contains('@')));
      expect(v, isNot('hunter2'));
    }
    // Only allow-listed keys.
    final allKeys = fakeAnalytics.calls
        .expand((e) => e.parameters.keys)
        .toSet();
    expect(allKeys, {'method'});
  });
}
