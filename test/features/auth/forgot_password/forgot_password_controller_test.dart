import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_controller.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_state.dart';
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
          ..listen<ForgotPasswordState>(
            forgotPasswordControllerProvider,
            (_, __) {},
          );
  });

  tearDown(() => container.dispose());

  ForgotPasswordController readController() =>
      container.read(forgotPasswordControllerProvider.notifier);

  test('invalid email short-circuits and does NOT fire any event', () async {
    readController().updateEmail('not-an-email');

    await readController().submit();
    await Future<void>.delayed(Duration.zero);

    expect(fakeAnalytics.calls, isEmpty);
    verifyNever(() => mockRepo.resetPassword(any()));
  });

  test('fires password_reset_requested on success', () async {
    when(
      () => mockRepo.resetPassword(any()),
    ).thenAnswer((_) async => const Result.success(null));

    readController().updateEmail('jane@example.com');
    await readController().submit();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(forgotPasswordControllerProvider).sent, isTrue);
    expect(fakeAnalytics.eventNames, ['password_reset_requested']);
    expect(fakeAnalytics.calls.single.parameters, isEmpty);
  });

  test('does NOT fire on Failure', () async {
    when(() => mockRepo.resetPassword(any())).thenAnswer(
      (_) async => const Result.failure(ServerException('rate-limited')),
    );

    readController().updateEmail('jane@example.com');
    await readController().submit();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(forgotPasswordControllerProvider).sent, isFalse);
    expect(fakeAnalytics.calls, isEmpty);
  });

  test('updateEmail clears a prior backend errorMessage', () async {
    when(() => mockRepo.resetPassword(any())).thenAnswer(
      (_) async => const Result.failure(ServerException('rate-limited')),
    );

    readController().updateEmail('jane@example.com');
    await readController().submit();
    expect(
      container.read(forgotPasswordControllerProvider).errorMessage,
      'rate-limited',
    );

    readController().updateEmail('jane2@example.com');
    expect(
      container.read(forgotPasswordControllerProvider).errorMessage,
      isNull,
    );
  });

  test('concurrent submit while a request is in flight is a no-op (isLoading '
      'guard) — the repository is hit exactly once', () async {
    final completer = Completer<Result<void>>();
    when(
      () => mockRepo.resetPassword(any()),
    ).thenAnswer((_) => completer.future);

    readController().updateEmail('jane@example.com');

    final first = readController().submit();
    // Second call sees isLoading == true and returns before awaiting.
    final second = readController().submit();

    completer.complete(const Result.success(null));
    await Future.wait([first, second]);
    await Future<void>.delayed(Duration.zero);

    verify(() => mockRepo.resetPassword('jane@example.com')).called(1);
  });
}
