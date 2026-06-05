import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_controller.dart';
import 'package:nibbles/src/features/profile/delete/delete_account_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// Captures the (reason, information, error string) tuple recorded by the
/// controller's non-fatal Crashlytics path so NIB-99 can assert the P1
/// telemetry payload without touching real Firebase.
class _CrashCapture {
  final List<({String? reason, List<String>? information, String error})>
      calls = [];

  Future<void> record(
    Object error,
    StackTrace stack, {
    String? reason,
    List<String>? information,
  }) async {
    calls.add(
      (reason: reason, information: information, error: error.toString()),
    );
  }
}

void main() {
  late _MockAccountRepository mockAccountRepo;
  late _MockAuthRepository mockAuthRepo;
  late _MockLocalFlagService mockFlags;
  late FakeAnalytics fakeAnalytics;
  late _CrashCapture crashCapture;
  late ProviderContainer container;

  setUp(() {
    mockAccountRepo = _MockAccountRepository();
    mockAuthRepo = _MockAuthRepository();
    mockFlags = _MockLocalFlagService();
    fakeAnalytics = FakeAnalytics();
    crashCapture = _CrashCapture();

    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(
      () => mockAuthRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.signOut())
        .thenAnswer((_) async => const Result.success(null));
    when(mockFlags.clearAll).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        accountRepositoryProvider.overrideWithValue(mockAccountRepo),
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        localFlagServiceProvider.overrideWithValue(mockFlags),
        analyticsProvider.overrideWithValue(fakeAnalytics),
        // NIB-99: capturing recorder so payload (reason + information) is
        // asserted alongside the failure path.
        deleteAccountCrashRecorderProvider.overrideWithValue(
          crashCapture.record,
        ),
      ],
    )
    // Hold the controller alive across awaits so state isn't lost to
    // auto-dispose between assertions.
    ..listen<DeleteAccountState>(
      deleteAccountControllerProvider,
      (_, __) {},
    );
  });

  tearDown(() => container.dispose());

  DeleteAccountController readController() =>
      container.read(deleteAccountControllerProvider.notifier);

  group('DeleteAccountController.submit', () {
    test(
      'success: calls deleteAccount → clearAll → signOut, records '
      'logAccountDeletionCompleted, returns true',
      () async {
        when(() => mockAccountRepo.requestAccountDeletion(any()))
            .thenAnswer((_) async => const Result.success(null));

        final ok = await readController().submit('I achieved my goal already');

        // Drain pending fire-and-forget analytics microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(ok, isTrue);
        verify(
          () => mockAccountRepo.requestAccountDeletion(
            'I achieved my goal already',
          ),
        ).called(1);
        verify(mockFlags.clearAll).called(1);
        verify(() => mockAuthRepo.signOut()).called(1);

        expect(
          fakeAnalytics.eventNames,
          contains('account_deletion_completed'),
        );
        expect(crashCapture.calls, isEmpty);
      },
    );

    test(
      'failure: sets errorMessage, records crash with reason + '
      'information=[reason=<reason>], returns false, does NOT clear flags '
      'or sign out',
      () async {
        when(() => mockAccountRepo.requestAccountDeletion(any())).thenAnswer(
          (_) async =>
              const Result.failure(ServerException('deletion failed')),
        );

        const reason = 'Other';
        final ok = await readController().submit(reason);

        expect(ok, isFalse);
        final state = container.read(deleteAccountControllerProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, 'deletion failed');
        verifyNever(mockFlags.clearAll);
        verifyNever(() => mockAuthRepo.signOut());

        expect(crashCapture.calls, hasLength(1));
        final crash = crashCapture.calls.single;
        expect(crash.reason, 'profile_account_deletion_failure');
        expect(crash.information, equals(['reason=$reason']));
        expect(crash.error, contains('profile_account_deletion_failure'));
        expect(crash.error, contains('deletion failed'));

        expect(
          fakeAnalytics.eventNames,
          isNot(contains('account_deletion_completed')),
        );
      },
    );

    test(
      'submit clears any prior errorMessage before calling the service',
      () async {
        when(() => mockAccountRepo.requestAccountDeletion(any())).thenAnswer(
          (_) async => const Result.failure(NetworkException('offline')),
        );

        // First attempt fails — errorMessage gets set.
        await readController().submit('Other');
        expect(
          container.read(deleteAccountControllerProvider).errorMessage,
          'offline',
        );

        // Retry succeeds — errorMessage must be cleared by the time we
        // reach the success branch.
        when(() => mockAccountRepo.requestAccountDeletion(any()))
            .thenAnswer((_) async => const Result.success(null));

        final ok = await readController().submit('Other');

        expect(ok, isTrue);
        // After success, signOut was called so the provider state's final
        // observable value is whatever was set before the success branch:
        // {isSubmitting: true, errorMessage: null}.
        final state = container.read(deleteAccountControllerProvider);
        expect(state.errorMessage, isNull);
      },
    );

    test(
      're-entrancy: a second submit while one is in-flight returns false and '
      'does NOT fire the destructive deleteAccount twice',
      () async {
        final gate = Completer<Result<void>>();
        when(() => mockAccountRepo.requestAccountDeletion(any()))
            .thenAnswer((_) => gate.future);

        final controller = readController();
        // First submit runs synchronously up to the deleteAccount await, so
        // isSubmitting is already true when the second (double-tap) lands.
        final first = controller.submit('Other');
        final second = await controller.submit('Other');

        // The in-flight guard rejects the second tap immediately.
        expect(second, isFalse);

        gate.complete(const Result.success(null));
        expect(await first, isTrue);

        // Exactly one destructive RPC despite the double-tap.
        verify(
          () => mockAccountRepo.requestAccountDeletion('Other'),
        ).called(1);
      },
    );
  });
}
