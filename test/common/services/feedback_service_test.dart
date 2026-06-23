import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/feedback_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/feedback_service.dart';

class _MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late _MockFeedbackRepository mockRepo;
  late FeedbackService sut;

  setUp(() {
    mockRepo = _MockFeedbackRepository();
    sut = FeedbackService(mockRepo);
  });

  group('FeedbackService.submit', () {
    test(
      'forwards the message to the repository and returns success',
      () async {
        when(
          () => mockRepo.submit(any()),
        ).thenAnswer((_) async => const Result.success(null));

        final result = await sut.submit('love the app!');

        expect(result, isA<Success<void>>());
        verify(() => mockRepo.submit('love the app!')).called(1);
      },
    );

    test('returns Result.failure when repository fails', () async {
      when(() => mockRepo.submit(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('rls denied')),
      );

      final result = await sut.submit('something');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<ServerException>());
      expect(result.error.message, 'rls denied');
    });
  });
}
