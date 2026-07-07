import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late _MockSupabaseClient client;
  late _MockFunctionsClient functions;

  setUp(() {
    client = _MockSupabaseClient();
    functions = _MockFunctionsClient();
    when(() => client.functions).thenReturn(functions);
  });

  AccountRepositoryImpl sut() => AccountRepositoryImpl(supabaseClient: client);

  group('AccountRepositoryImpl.requestAccountDeletion', () {
    test(
      'invokes delete-account with the reason and returns success',
      () async {
        when(
          () => functions.invoke(any(), body: any(named: 'body')),
        ).thenAnswer(
          (_) async => FunctionResponse(data: {'success': true}, status: 200),
        );

        final result = await sut().requestAccountDeletion('too_expensive');

        expect(result, isA<Success<void>>());
        final captured = verify(
          () => functions.invoke(captureAny(), body: captureAny(named: 'body')),
        ).captured;
        expect(captured[0], 'delete-account');
        expect(captured[1], {'reason': 'too_expensive'});
      },
    );

    test(
      'maps FunctionException(details.error) to Failure(ServerException)',
      () async {
        when(() => functions.invoke(any(), body: any(named: 'body'))).thenThrow(
          const FunctionException(
            status: 500,
            details: {'error': 'Could not delete account. Please try again.'},
          ),
        );

        final result = await sut().requestAccountDeletion('not_useful');

        expect(result, isA<Failure<void>>());
        final failure = result as Failure<void>;
        expect(failure.error, isA<ServerException>());
        expect(
          failure.error.message,
          'Could not delete account. Please try again.',
        );
      },
    );

    test(
      'FunctionException without a string error uses a fallback message',
      () async {
        when(
          () => functions.invoke(any(), body: any(named: 'body')),
        ).thenThrow(const FunctionException(status: 500));

        final result = await sut().requestAccountDeletion('other');

        expect(result, isA<Failure<void>>());
        final failure = result as Failure<void>;
        expect(failure.error, isA<ServerException>());
        expect(
          failure.error.message,
          'Account deletion failed. Please try again.',
        );
      },
    );

    test('maps any other thrown Object to Failure(UnknownException)', () async {
      when(
        () => functions.invoke(any(), body: any(named: 'body')),
      ).thenThrow(Exception('boom'));

      final result = await sut().requestAccountDeletion('other');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });
}
