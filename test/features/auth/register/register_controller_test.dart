import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/register/register_controller.dart';

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

  RegisterController readController() =>
      container.read(registerControllerProvider.notifier);

  group('signInWithGoogle', () {
    test('returns true on Success(true), no error', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(true));

      final ok = await readController().signInWithGoogle();

      expect(ok, isTrue);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('returns false on Success(false) (cancel), no error', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(false));

      final ok = await readController().signInWithGoogle();

      expect(ok, isFalse);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('returns false on Failure and sets errorMessage', () async {
      when(() => mockRepo.signInWithGoogle()).thenAnswer(
        (_) async => const Result.failure(ServerException('Google failed')),
      );

      final ok = await readController().signInWithGoogle();

      expect(ok, isFalse);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Google failed');
    });
  });

  group('signInWithApple', () {
    test('returns true on Success(true), no error', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(true));

      final ok = await readController().signInWithApple();

      expect(ok, isTrue);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('returns false on Success(false) (cancel), no error', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(false));

      final ok = await readController().signInWithApple();

      expect(ok, isFalse);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('returns false on Failure and sets errorMessage', () async {
      when(() => mockRepo.signInWithApple()).thenAnswer(
        (_) async => const Result.failure(ServerException('Apple failed')),
      );

      final ok = await readController().signInWithApple();

      expect(ok, isFalse);
      final state = container.read(registerControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Apple failed');
    });
  });
}
