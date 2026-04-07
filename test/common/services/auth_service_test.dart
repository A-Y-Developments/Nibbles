import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

void main() {
  late MockAuthRepository mockRepo;
  late MockLocalFlagService mockFlags;
  late ProviderContainer container;
  late AuthService sut;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockFlags = MockLocalFlagService();
    when(() => mockRepo.isLoggedIn).thenReturn(false);
    when(
      () => mockRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    // Backfill short-circuits when onboarding is already marked done.
    when(mockFlags.isOnboardingBabySetupDone).thenReturn(true);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        localFlagServiceProvider.overrideWithValue(mockFlags),
      ],
    );
    sut = container.read(authServiceProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('AuthService.signUp', () {
    test('returns Result.success on success', () async {
      when(
        () => mockRepo.signUp(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.signUp(
        'Alice',
        'alice@example.com',
        'password123',
      );

      expect(result.isSuccess, isTrue);
    });

    test(
      'returns Result.failure with error message on duplicate email',
      () async {
        when(() => mockRepo.signUp(any(), any(), any())).thenAnswer(
          (_) async =>
              const Result.failure(ServerException('Email already in use.')),
        );

        final result = await sut.signUp(
          'Alice',
          'alice@example.com',
          'password123',
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull!.message, 'Email already in use.');
      },
    );
  });

  group('AuthService.signIn', () {
    test('isLoggedIn becomes true on success', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => const Result.success(null));

      await sut.signIn('alice@example.com', 'password123');

      expect(container.read(authServiceProvider), isTrue);
    });

    test(
      'returns Result.failure and does not change state on wrong password',
      () async {
        when(() => mockRepo.signIn(any(), any())).thenAnswer(
          (_) async => const Result.failure(
            ServerException('Invalid login credentials.'),
          ),
        );

        final result = await sut.signIn('alice@example.com', 'wrong');

        expect(result.isFailure, isTrue);
        expect(container.read(authServiceProvider), isFalse);
      },
    );
  });

  group('AuthService.signOut', () {
    test('isLoggedIn becomes false on success', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => const Result.success(null));
      await sut.signIn('alice@example.com', 'password123');
      expect(container.read(authServiceProvider), isTrue);

      when(
        () => mockRepo.signOut(),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.signOut();

      expect(result.isSuccess, isTrue);
      expect(container.read(authServiceProvider), isFalse);
    });
  });

  group('AuthService.resetPassword', () {
    test('delegates to repository with correct redirect URL', () async {
      when(
        () => mockRepo.resetPassword(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.resetPassword('alice@example.com');

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.resetPassword('alice@example.com')).called(1);
    });
  });

  group('AuthService.updatePassword', () {
    test('returns Result.success on success', () async {
      when(
        () => mockRepo.updatePassword(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.updatePassword('newpassword123');

      expect(result.isSuccess, isTrue);
    });

    test('returns Result.failure with error message on failure', () async {
      when(() => mockRepo.updatePassword(any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('Password too weak.')),
      );

      final result = await sut.updatePassword('short');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.message, 'Password too weak.');
    });
  });
}
