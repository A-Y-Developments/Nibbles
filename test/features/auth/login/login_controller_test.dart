import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/login/login_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

void main() {
  late MockAuthRepository mockRepo;
  late MockLocalFlagService mockFlags;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockFlags = MockLocalFlagService();
    when(() => mockRepo.isLoggedIn).thenReturn(false);
    when(
      () => mockRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(mockFlags.isOnboardingBabySetupDone).thenReturn(true);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        localFlagServiceProvider.overrideWithValue(mockFlags),
      ],
    );
  });

  tearDown(() => container.dispose());

  LoginController readController() =>
      container.read(loginControllerProvider.notifier);

  group('signInWithGoogle', () {
    test('clears loading + no error on Success(true)', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(true));

      await readController().signInWithGoogle();

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('clears loading + no error on Success(false) (cancel)', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(false));

      await readController().signInWithGoogle();

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('sets errorMessage on Failure', () async {
      when(() => mockRepo.signInWithGoogle()).thenAnswer(
        (_) async => const Result.failure(ServerException('Google failed')),
      );

      await readController().signInWithGoogle();

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Google failed');
    });
  });

  group('signInWithApple', () {
    test('clears loading + no error on Success(true)', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(true));

      await readController().signInWithApple();

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('clears loading + no error on Success(false) (cancel)', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(false));

      await readController().signInWithApple();

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('sets errorMessage on Failure', () async {
      when(() => mockRepo.signInWithApple()).thenAnswer(
        (_) async => const Result.failure(ServerException('Apple failed')),
      );

      await readController().signInWithApple();

      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Apple failed');
    });
  });
}
