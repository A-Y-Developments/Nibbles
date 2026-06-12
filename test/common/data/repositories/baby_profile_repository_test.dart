import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/baby_profile_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _FakeUser extends Fake implements User {
  @override
  String get id => 'user-1';
}

class _FakeChain<T> implements PostgrestFilterBuilder<T> {
  _FakeChain({Object? payload, Object? error, List<(String, Object)>? filters})
    : _payload = payload,
      _error = error,
      _recordedFilters = filters ?? [];

  final Object? _payload;
  final Object? _error;
  final List<(String, Object)> _recordedFilters;

  Future<T> get _future =>
      _error != null ? Future<T>.error(_error) : Future<T>.value(_payload as T);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    _recordedFilters.add((column, value));
    return this;
  }

  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(
        payload: _payload,
        error: _error,
        filters: _recordedFilters,
      );

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeChain<PostgrestMap>(
        payload: _payload,
        error: _error,
        filters: _recordedFilters,
      );

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() =>
      _FakeChain<PostgrestMap?>(
        payload: _payload,
        error: _error,
        filters: _recordedFilters,
      );

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
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Unexpected call on _FakeChain: ${invocation.memberName}',
    );
  }
}

// ignore: must_be_immutable // mutable tracking fields are intentional for test assertions
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  _FakeQueryBuilder({Object? payload, Object? error})
    : _payload = payload,
      _error = error;

  final Object? _payload;
  final Object? _error;

  final List<(String, Object)> filters = [];
  Object? inserted;
  Map<dynamic, dynamic>? updated;

  _FakeChain<PostgrestList> get _chain => _FakeChain<PostgrestList>(
    payload: _payload,
    error: _error,
    filters: filters,
  );

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _chain;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    inserted = values;
    return _chain;
  }

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> values) {
    updated = values;
    return _chain;
  }
}

Map<String, dynamic> _babyRow({
  String id = 'baby-1',
  String userId = 'user-1',
  String name = 'Lily',
  String dateOfBirth = '2024-06-01',
  String gender = 'female',
  bool onboardingCompleted = false,
}) => <String, dynamic>{
  'id': id,
  'user_id': userId,
  'name': name,
  'date_of_birth': dateOfBirth,
  'gender': gender,
  'onboarding_completed': onboardingCompleted,
};

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(_FakeUser());
  });

  tearDown(resetMocktailState);

  BabyProfileRepositoryImpl buildSut() =>
      BabyProfileRepositoryImpl(supabaseClient: mockSupabase);

  void stubTable(String table, {Object? payload, Object? error}) {
    final builder = _FakeQueryBuilder(payload: payload, error: error);
    when(() => mockSupabase.from(table)).thenAnswer((_) => builder);
  }

  group('createBaby', () {
    test('returns Success<Baby> when RPC responds with a Map row', () async {
      when(
        () => mockSupabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer((_) => _FakeChain<dynamic>(payload: _babyRow()));

      final result = await buildSut().createBaby('Lily', DateTime(2024, 6));

      expect(result, isA<Success<Baby>>());
      expect((result as Success<Baby>).data.name, 'Lily');
    });

    test('returns Success<Baby> when RPC responds with a List row', () async {
      when(
        () => mockSupabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer((_) => _FakeChain<dynamic>(payload: [_babyRow()]));

      final result = await buildSut().createBaby('Lily', DateTime(2024, 6));

      expect(result, isA<Success<Baby>>());
      expect((result as Success<Baby>).data.name, 'Lily');
    });

    test('maps PostgrestException to Failure(ServerException)', () async {
      when(
        () => mockSupabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer(
        (_) => _FakeChain<dynamic>(
          error: const PostgrestException(message: 'rls denied', code: '42501'),
        ),
      );

      final result = await buildSut().createBaby('Lily', DateTime(2024, 6));

      expect(result, isA<Failure<Baby>>());
      expect((result as Failure<Baby>).error, isA<ServerException>());
      expect(result.error.message, 'rls denied');
    });

    test('maps unknown error to Failure(UnknownException)', () async {
      when(
        () => mockSupabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer((_) => _FakeChain<dynamic>(error: Exception('boom')));

      final result = await buildSut().createBaby('Lily', DateTime(2024, 6));

      expect(result, isA<Failure<Baby>>());
      expect((result as Failure<Baby>).error, isA<UnknownException>());
    });
  });

  group('getBaby', () {
    test('returns Baby when a row exists', () async {
      stubTable('babies', payload: _babyRow());

      final baby = await buildSut().getBaby();

      expect(baby, isNotNull);
      expect(baby!.name, 'Lily');
    });

    test('returns null when no row exists', () async {
      stubTable('babies');

      final baby = await buildSut().getBaby();

      expect(baby, isNull);
    });

    test('returns null when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      stubTable('babies');

      final baby = await buildSut().getBaby();

      expect(baby, isNull);
    });

    test('returns null on Postgrest error', () async {
      stubTable(
        'babies',
        error: const PostgrestException(message: 'table not found'),
      );

      final baby = await buildSut().getBaby();

      expect(baby, isNull);
    });
  });

  group('updateBaby', () {
    test('returns Success<Baby> with correct update payload', () async {
      final builder = _FakeQueryBuilder(
        payload: _babyRow(name: 'Max', gender: 'male'),
      );
      when(
        () => mockSupabase.from('babies'),
      ).thenAnswer((_) => builder);

      final result = await buildSut().updateBaby(
        'baby-1',
        'Max',
        DateTime(2024, 3, 15),
        Gender.male,
      );

      expect(result, isA<Success<Baby>>());
      expect((result as Success<Baby>).data.name, 'Max');
      expect(builder.updated, containsPair('name', 'Max'));
      expect(builder.updated, containsPair('date_of_birth', '2024-03-15'));
      expect(builder.updated, containsPair('gender', 'male'));
    });

    test('maps PostgrestException to Failure(ServerException)', () async {
      stubTable(
        'babies',
        error: const PostgrestException(message: 'not found'),
      );

      final result = await buildSut().updateBaby(
        'baby-1',
        'Max',
        DateTime(2024, 3),
        Gender.male,
      );

      expect(result, isA<Failure<Baby>>());
      expect((result as Failure<Baby>).error, isA<ServerException>());
    });

    test('maps unknown error to Failure(UnknownException)', () async {
      stubTable('babies', error: Exception('crash'));

      final result = await buildSut().updateBaby(
        'baby-1',
        'Max',
        DateTime(2024, 3),
        Gender.male,
      );

      expect(result, isA<Failure<Baby>>());
      expect((result as Failure<Baby>).error, isA<UnknownException>());
    });
  });

  group('createAllergenProgramState', () {
    test('returns Result.success and inserts correct row', () async {
      final builder = _FakeQueryBuilder(payload: <Map<String, dynamic>>[]);
      when(
        () => mockSupabase.from('allergen_program_state'),
      ).thenAnswer((_) => builder);

      final result = await buildSut().createAllergenProgramState('baby-1');

      expect(result.isSuccess, isTrue);
      final inserted = builder.inserted! as Map<String, dynamic>;
      expect(inserted['baby_id'], 'baby-1');
      expect(inserted['current_allergen_key'], 'peanut');
      expect(inserted['current_sequence_order'], 1);
      expect(inserted['status'], 'in_progress');
    });

    test('maps PostgrestException to Failure(ServerException)', () async {
      stubTable(
        'allergen_program_state',
        error: const PostgrestException(message: 'fk violation'),
      );

      final result = await buildSut().createAllergenProgramState('baby-1');

      expect(result.isFailure, isTrue);
      expect((result as Failure<void>).error, isA<ServerException>());
      expect(result.error.message, 'fk violation');
    });

    test('maps unknown error to Failure(UnknownException)', () async {
      stubTable('allergen_program_state', error: Exception('crash'));

      final result = await buildSut().createAllergenProgramState('baby-1');

      expect(result.isFailure, isTrue);
      expect((result as Failure<void>).error, isA<UnknownException>());
    });
  });

  group('isOnboardingCompleted', () {
    test('returns true when flag is set', () async {
      stubTable('babies', payload: {'onboarding_completed': true});

      final result = await buildSut().isOnboardingCompleted();

      expect(result, isTrue);
    });

    test('returns false when flag is not set', () async {
      stubTable('babies', payload: {'onboarding_completed': false});

      final result = await buildSut().isOnboardingCompleted();

      expect(result, isFalse);
    });

    test('returns false when no row exists', () async {
      stubTable('babies');

      final result = await buildSut().isOnboardingCompleted();

      expect(result, isFalse);
    });

    test('returns false on error', () async {
      stubTable(
        'babies',
        error: const PostgrestException(message: 'db error'),
      );

      final result = await buildSut().isOnboardingCompleted();

      expect(result, isFalse);
    });

    test('returns false when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      stubTable('babies');

      final result = await buildSut().isOnboardingCompleted();

      expect(result, isFalse);
    });
  });
}
