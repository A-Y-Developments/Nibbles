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

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

void main() {
  late _MockAccountRepository mockAccountRepo;
  late _MockAuthRepository mockAuthRepo;
  late _MockLocalFlagService mockFlags;
  late ProviderContainer container;

  setUp(() {
    mockAccountRepo = _MockAccountRepository();
    mockAuthRepo = _MockAuthRepository();
    mockFlags = _MockLocalFlagService();

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
      'success: calls deleteAccount → clearAll → signOut and returns true',
      () async {
        when(() => mockAccountRepo.requestAccountDeletion(any()))
            .thenAnswer((_) async => const Result.success(null));

        final ok = await readController().submit('Privacy concerns');

        expect(ok, isTrue);
        verify(
          () => mockAccountRepo.requestAccountDeletion('Privacy concerns'),
        ).called(1);
        verify(mockFlags.clearAll).called(1);
        verify(() => mockAuthRepo.signOut()).called(1);
      },
    );

    test(
      'failure: sets errorMessage, returns false, does NOT clear flags or '
      'sign out',
      () async {
        when(() => mockAccountRepo.requestAccountDeletion(any())).thenAnswer(
          (_) async =>
              const Result.failure(ServerException('deletion failed')),
        );

        final ok = await readController().submit('Other');

        expect(ok, isFalse);
        final state = container.read(deleteAccountControllerProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, 'deletion failed');
        verifyNever(mockFlags.clearAll);
        verifyNever(() => mockAuthRepo.signOut());
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
  });
}
