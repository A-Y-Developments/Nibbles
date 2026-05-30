import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/feedback_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _FakeUser extends Fake implements User {
  @override
  String get id => 'user-1';
}

/// Fake terminal for `.insert(...)` — implements `Future<void>` via a
/// behaviour closure that either resolves or throws. Mirrors the
/// `_FakeSingleTerminal` pattern in `recipe_repository_test.dart`.
class _FakeInsertTerminal implements PostgrestFilterBuilder<void> {
  _FakeInsertTerminal(this._behaviour);

  final FutureOr<void> Function() _behaviour;

  Future<void> get _future => Future<void>.sync(_behaviour);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(void value) onValue, {
    Function? onError,
  }) => _future.then(onValue, onError: onError);

  @override
  Future<void> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => _future.catchError(onError, test: test);

  @override
  Future<void> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<void> timeout(
    Duration timeLimit, {
    FutureOr<void> Function()? onTimeout,
  }) => _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Stream<void> asStream() => _future.asStream();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Unexpected call on _FakeInsertTerminal: ${invocation.memberName}',
    );
  }
}

/// Query builder fake that captures the `.insert(...)` payload and
/// dispatches the awaited future through [behaviour].
//
// SupabaseQueryBuilder is `@immutable` but we need to record the insert
// payload once for assertion. Matches the lint suppression on
// `_FakeBuilder` in `account_repository_test.dart`.
// ignore: must_be_immutable
class _CapturingQueryBuilder extends _MockQueryBuilder {
  _CapturingQueryBuilder(this.behaviour);

  final FutureOr<void> Function() behaviour;
  Map<String, dynamic>? capturedValues;

  @override
  PostgrestFilterBuilder<void> insert(
    Object values, {
    dynamic defaultToNull = true,
  }) {
    capturedValues = values as Map<String, dynamic>;
    return _FakeInsertTerminal(behaviour);
  }
}

void main() {
  group('FeedbackRepositoryImpl.submit', () {
    test(
      'inserts {user_id, trimmed message} into feedback and returns success',
      () async {
        final mockSupabase = _MockSupabaseClient();
        final mockAuth = _MockGoTrueClient();
        final builder = _CapturingQueryBuilder(() {});

        when(() => mockSupabase.auth).thenReturn(mockAuth);
        when(() => mockAuth.currentUser).thenReturn(_FakeUser());
        when(
          () => mockSupabase.from('feedback'),
        ).thenAnswer((_) => builder);

        final sut = FeedbackRepositoryImpl(supabaseClient: mockSupabase);
        final result = await sut.submit('  hello there  ');

        expect(result, isA<Success<void>>());
        expect(builder.capturedValues, {
          'user_id': 'user-1',
          'message': 'hello there',
        });
      },
    );

    test('maps PostgrestException to Failure(ServerException)', () async {
      final mockSupabase = _MockSupabaseClient();
      final mockAuth = _MockGoTrueClient();
      final builder = _CapturingQueryBuilder(() {
        throw const PostgrestException(message: 'rls denied', code: '42501');
      });

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(_FakeUser());
      when(
        () => mockSupabase.from('feedback'),
      ).thenAnswer((_) => builder);

      final sut = FeedbackRepositoryImpl(supabaseClient: mockSupabase);
      final result = await sut.submit('anything');

      expect(result, isA<Failure<void>>());
      final failure = result as Failure<void>;
      expect(failure.error, isA<ServerException>());
      expect(failure.error.message, 'rls denied');
    });

    test('maps any other thrown Object to Failure(UnknownException)',
        () async {
      final mockSupabase = _MockSupabaseClient();
      final mockAuth = _MockGoTrueClient();
      final builder = _CapturingQueryBuilder(() {
        throw Exception('boom');
      });

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(_FakeUser());
      when(
        () => mockSupabase.from('feedback'),
      ).thenAnswer((_) => builder);

      final sut = FeedbackRepositoryImpl(supabaseClient: mockSupabase);
      final result = await sut.submit('boom-message');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });
}
