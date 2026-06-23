import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/account_service.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late _MockAccountRepository mockRepo;
  late AccountService sut;

  setUp(() {
    mockRepo = _MockAccountRepository();
    sut = AccountService(mockRepo);
  });

  group('AccountService.deleteAccount', () {
    test('forwards the reason to the repository and returns success', () async {
      when(
        () => mockRepo.requestAccountDeletion(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.deleteAccount('too_expensive');

      expect(result, isA<Success<void>>());
      verify(() => mockRepo.requestAccountDeletion('too_expensive')).called(1);
    });

    test('returns Result.failure when repository fails', () async {
      when(() => mockRepo.requestAccountDeletion(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('rpc failed')),
      );

      final result = await sut.deleteAccount('not_useful');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<ServerException>());
      expect(result.error.message, 'rpc failed');
    });
  });
}
