import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/baby_profile_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';

class MockBabyProfileRepository extends Mock implements BabyProfileRepository {}

final _fakeBaby = Baby(
  id: 'baby-001',
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2024, 6, 1),
  gender: Gender.female,
  onboardingCompleted: false,
);

void main() {
  late MockBabyProfileRepository mockRepo;
  late BabyProfileService sut;

  setUpAll(() {
    registerFallbackValue(Gender.female);
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    mockRepo = MockBabyProfileRepository();
    sut = BabyProfileService(mockRepo);
  });

  group('BabyProfileService.createBaby', () {
    test('returns Result.success(baby) and calls both repo methods on success', () async {
      when(() => mockRepo.createBaby(any(), any(), any()))
          .thenAnswer((_) async => Result.success(_fakeBaby));
      when(() => mockRepo.createAllergenProgramState(any()))
          .thenAnswer((_) async => const Result.success(null));

      final result = await sut.createBaby('Lily', DateTime(2024, 6, 1), Gender.female);

      expect(result.isSuccess, isTrue);
      expect((result as Success<Baby>).data.name, 'Lily');
      verify(() => mockRepo.createBaby('Lily', DateTime(2024, 6, 1), Gender.female)).called(1);
      verify(() => mockRepo.createAllergenProgramState('baby-001')).called(1);
    });

    test('returns Result.failure when createAllergenProgramState fails', () async {
      when(() => mockRepo.createBaby(any(), any(), any()))
          .thenAnswer((_) async => Result.success(_fakeBaby));
      when(() => mockRepo.createAllergenProgramState(any())).thenAnswer(
        (_) async => Result.failure(const ServerException('Failed to create program state')),
      );

      final result = await sut.createBaby('Lily', DateTime(2024, 6, 1), Gender.female);

      expect(result.isFailure, isTrue);
    });

    test('returns Result.failure without calling createAllergenProgramState when baby creation fails',
        () async {
      when(() => mockRepo.createBaby(any(), any(), any())).thenAnswer(
        (_) async => Result.failure(const ServerException('DB error')),
      );

      final result = await sut.createBaby('Lily', DateTime(2024, 6, 1), Gender.female);

      expect(result.isFailure, isTrue);
      verifyNever(() => mockRepo.createAllergenProgramState(any()));
    });
  });

  group('BabyProfileService.getBaby', () {
    test('delegates to repository and returns baby', () async {
      when(() => mockRepo.getBaby()).thenAnswer((_) async => _fakeBaby);

      final baby = await sut.getBaby();

      expect(baby, equals(_fakeBaby));
      verify(() => mockRepo.getBaby()).called(1);
    });

    test('returns null when no baby exists', () async {
      when(() => mockRepo.getBaby()).thenAnswer((_) async => null);

      final baby = await sut.getBaby();

      expect(baby, isNull);
    });
  });

  group('BabyProfileService.updateBaby', () {
    test('delegates to repository with correct args', () async {
      when(() => mockRepo.updateBaby(any(), any(), any(), any()))
          .thenAnswer((_) async => Result.success(_fakeBaby));

      final result = await sut.updateBaby('baby-001', 'Lily', DateTime(2024, 6, 1), Gender.female);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.updateBaby('baby-001', 'Lily', DateTime(2024, 6, 1), Gender.female))
          .called(1);
    });

    test('returns Result.failure when repository fails', () async {
      when(() => mockRepo.updateBaby(any(), any(), any(), any())).thenAnswer(
        (_) async => Result.failure(const ServerException('Update failed')),
      );

      final result = await sut.updateBaby('baby-001', 'Lily', DateTime(2024, 6, 1), Gender.female);

      expect(result.isFailure, isTrue);
    });
  });

  group('BabyProfileService.onboardingCompleted', () {
    test('calls isOnboardingCompleted on repository', () async {
      when(() => mockRepo.isOnboardingCompleted()).thenAnswer((_) async => true);

      final result = await sut.onboardingCompleted;

      expect(result, isTrue);
      verify(() => mockRepo.isOnboardingCompleted()).called(1);
    });

    test('reads from DB each time — not cached in memory', () async {
      when(() => mockRepo.isOnboardingCompleted()).thenAnswer((_) async => false);

      await sut.onboardingCompleted;
      await sut.onboardingCompleted;

      verify(() => mockRepo.isOnboardingCompleted()).called(2);
    });
  });
}
