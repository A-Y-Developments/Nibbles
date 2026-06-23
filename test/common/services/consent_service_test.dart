import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/consent_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:nibbles/src/common/services/consent_service.dart';

class _MockConsentRepository extends Mock implements ConsentRepository {}

void main() {
  late _MockConsentRepository mockRepo;
  late ConsentService sut;

  setUpAll(() {
    registerFallbackValue(ConsentType.solidsIntroduction);
  });

  setUp(() {
    mockRepo = _MockConsentRepository();
    sut = ConsentService(mockRepo);
  });

  group('ConsentService.recordConsent', () {
    test('forwards solidsIntroduction to the repository unchanged', () async {
      when(
        () => mockRepo.recordConsent(
          babyId: any(named: 'babyId'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.recordConsent(
        babyId: 'baby-1',
        type: ConsentType.solidsIntroduction,
      );

      expect(result, isA<Success<void>>());
      verify(
        () => mockRepo.recordConsent(
          babyId: 'baby-1',
          type: ConsentType.solidsIntroduction,
        ),
      ).called(1);
    });

    test(
      'forwards under6MoResponsibility to the repository unchanged',
      () async {
        when(
          () => mockRepo.recordConsent(
            babyId: any(named: 'babyId'),
            type: any(named: 'type'),
          ),
        ).thenAnswer((_) async => const Result.success(null));

        final result = await sut.recordConsent(
          babyId: 'baby-2',
          type: ConsentType.under6MoResponsibility,
        );

        expect(result, isA<Success<void>>());
        verify(
          () => mockRepo.recordConsent(
            babyId: 'baby-2',
            type: ConsentType.under6MoResponsibility,
          ),
        ).called(1);
      },
    );

    test('returns Result.failure when repository fails', () async {
      when(
        () => mockRepo.recordConsent(
          babyId: any(named: 'babyId'),
          type: any(named: 'type'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('rls denied')),
      );

      final result = await sut.recordConsent(
        babyId: 'baby-1',
        type: ConsentType.solidsIntroduction,
      );

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<ServerException>());
      expect(result.error.message, 'rls denied');
    });
  });
}
