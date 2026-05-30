import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/account_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

/// Test seam: a SupabaseClient whose `rpc(...)` is intercepted by a
/// behaviour closure. The closure decides whether the awaited rpc resolves
/// with a value or throws (the repo only cares about that distinction).
///
/// We can't easily construct a real `PostgrestFilterBuilder<T>` in tests, so
/// the closure returns a `_FakeBuilder<T>` which implements `Future<T>` and
/// `PostgrestFilterBuilder<T>` via `noSuchMethod`.
class _SupabaseClientWithRpc extends _MockSupabaseClient {
  _SupabaseClientWithRpc(this._behaviour);

  final FutureOr<Object?> Function(String fn, Map<String, dynamic>? params)
      _behaviour;

  @override
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
    dynamic get = false,
  }) {
    return _FakeBuilder<T>(() async => await _behaviour(fn, params) as T);
  }
}

// PostgrestFilterBuilder is @immutable but we need to memoise the awaited
// future once. Lint suppression matches other test fakes in the codebase.
// ignore: must_be_immutable
class _FakeBuilder<T> implements PostgrestFilterBuilder<T> {
  _FakeBuilder(this._run);

  final Future<T> Function() _run;
  Future<T>? _cached;
  Future<T> get _future => _cached ??= _run();

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) => _future.then(onValue, onError: onError);

  @override
  Future<T> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => _future.catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<T> timeout(
    Duration timeLimit, {
    FutureOr<T> Function()? onTimeout,
  }) => _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AccountRepositoryImpl.requestAccountDeletion', () {
    test(
        'returns Result.success(null) on a clean rpc call '
        'and forwards reason as p_reason', () async {
      String? capturedFn;
      Map<String, dynamic>? capturedParams;
      final client = _SupabaseClientWithRpc((fn, params) {
        capturedFn = fn;
        capturedParams = params;
        return null;
      });
      final sut = AccountRepositoryImpl(supabaseClient: client);

      final result = await sut.requestAccountDeletion('too_expensive');

      expect(result, isA<Success<void>>());
      expect(capturedFn, 'request_account_deletion');
      expect(capturedParams, {'p_reason': 'too_expensive'});
    });

    test('maps PostgrestException to Failure(ServerException)', () async {
      final client = _SupabaseClientWithRpc((_, __) {
        throw const PostgrestException(message: 'rls denied', code: '42501');
      });
      final sut = AccountRepositoryImpl(supabaseClient: client);

      final result = await sut.requestAccountDeletion('not_useful');

      expect(result, isA<Failure<void>>());
      final failure = result as Failure<void>;
      expect(failure.error, isA<ServerException>());
      expect(failure.error.message, 'rls denied');
    });

    test('maps any other thrown Object to Failure(UnknownException)',
        () async {
      final client = _SupabaseClientWithRpc((_, __) {
        throw Exception('boom');
      });
      final sut = AccountRepositoryImpl(supabaseClient: client);

      final result = await sut.requestAccountDeletion('other');

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });
}
