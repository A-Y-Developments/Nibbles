import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/meal_plan_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _FakeChain<T> implements PostgrestFilterBuilder<T> {
  _FakeChain({required _FakeQueryBuilder owner, Object? payload, Object? error})
    : _owner = owner,
      _payload = payload,
      _error = error;

  final _FakeQueryBuilder _owner;
  final Object? _payload;
  final Object? _error;

  Future<T> get _future =>
      _error != null
          ? Future<T>.error(_error)
          : Future<T>.value(_payload as T);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    _owner.filters.add((column, value));
    return this;
  }

  @override
  PostgrestFilterBuilder<T> gte(String column, Object value) {
    _owner.gteFilters.add((column, value));
    return this;
  }

  @override
  PostgrestFilterBuilder<T> lte(String column, Object value) {
    _owner.lteFilters.add((column, value));
    return this;
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    _owner.orderedBy = column;
    return this;
  }

  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(
        owner: _owner,
        payload: _payload,
        error: _error,
      );

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeChain<PostgrestMap>(
        owner: _owner,
        payload: _payload,
        error: _error,
      );

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() =>
      _FakeChain<PostgrestMap?>(
        owner: _owner,
        payload: _payload,
        error: _error,
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
  final List<(String, Object)> gteFilters = [];
  final List<(String, Object)> lteFilters = [];
  String? orderedBy;
  Object? inserted;
  bool deleteCalled = false;

  _FakeChain<PostgrestList> get _chain =>
      _FakeChain<PostgrestList>(owner: this, payload: _payload, error: _error);

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
  PostgrestFilterBuilder<PostgrestList> delete() {
    deleteCalled = true;
    return _chain;
  }
}

Map<String, dynamic> _entryRow({
  String id = 'entry-1',
  String babyId = 'baby-1',
  String recipeId = 'recipe-1',
  String planDate = '2026-06-10',
  String? mealTime,
}) => <String, dynamic>{
  'id': id,
  'baby_id': babyId,
  'recipe_id': recipeId,
  'plan_date': planDate,
  'meal_time': mealTime,
};

Matcher _failsWith<E extends AppException>([String? message]) =>
    isA<E>().having((e) => e.message, 'message', message ?? anything);

void main() {
  late _MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
  });

  tearDown(resetMocktailState);

  MealPlanRepositoryImpl buildSut() =>
      MealPlanRepositoryImpl(supabaseClient: mockSupabase);

  _FakeQueryBuilder stubTable(
    String table, {
    Object? payload,
    Object? error,
  }) {
    final builder = _FakeQueryBuilder(payload: payload, error: error);
    when(() => mockSupabase.from(table)).thenAnswer((_) => builder);
    return builder;
  }

  group('getEntriesInRange', () {
    test('returns mapped entries with correct filters', () async {
      final rows = [
        _entryRow(id: 'e1'),
        _entryRow(id: 'e2', planDate: '2026-06-11', mealTime: '09:00:00'),
      ];
      final builder = stubTable('meal_plan_entries', payload: rows);

      final result = await buildSut().getEntriesInRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 16),
      );

      expect(result.isSuccess, isTrue);
      final entries = result.dataOrNull!;
      expect(entries, hasLength(2));
      expect(entries[0].id, 'e1');
      expect(entries[1].mealTime, '09:00');
      expect(builder.filters, [('baby_id', 'baby-1')]);
      expect(builder.gteFilters, [('plan_date', '2026-06-10')]);
      expect(builder.lteFilters, [('plan_date', '2026-06-16')]);
      expect(builder.orderedBy, 'plan_date');
    });

    test('mealTime null stays null', () async {
      final _ = stubTable('meal_plan_entries', payload: [_entryRow()]);

      final result = await buildSut().getEntriesInRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 10),
      );

      expect(result.dataOrNull!.single.mealTime, isNull);
    });

    test('mealTime exactly 5 chars is kept as-is', () async {
      final _ = stubTable(
        'meal_plan_entries',
        payload: [_entryRow(mealTime: '08:30')],
      );

      final result = await buildSut().getEntriesInRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 10),
      );

      expect(result.dataOrNull!.single.mealTime, '08:30');
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'meal_plan_entries',
        error: const PostgrestException(message: 'db error'),
      );

      final result = await buildSut().getEntriesInRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 10),
      );

      expect(result.errorOrNull, _failsWith<ServerException>('db error'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('meal_plan_entries', error: Exception('boom'));

      final result = await buildSut().getEntriesInRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 10),
      );

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('getWeekMeals', () {
    test('delegates to getEntriesInRange with same date range', () async {
      final builder = stubTable(
        'meal_plan_entries',
        payload: [_entryRow()],
      );

      final result = await buildSut().getWeekMeals(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 16),
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, hasLength(1));
      expect(builder.gteFilters, [('plan_date', '2026-06-10')]);
      expect(builder.lteFilters, [('plan_date', '2026-06-16')]);
    });
  });

  group('assignRecipe', () {
    test('inserts payload with mealTime and returns mapped entry', () async {
      final row = _entryRow(mealTime: '09:00');
      final builder = stubTable('meal_plan_entries', payload: row);

      final result = await buildSut().assignRecipe(
        'baby-1',
        'recipe-1',
        DateTime(2026, 6, 10),
        const TimeOfDay(hour: 9, minute: 0),
      );

      expect(result.isSuccess, isTrue);
      final entry = result.dataOrNull!;
      expect(entry.babyId, 'baby-1');
      expect(entry.recipeId, 'recipe-1');
      expect(entry.planDate, DateTime.parse('2026-06-10'));
      expect(entry.mealTime, '09:00');
      final inserted = builder.inserted! as Map<String, dynamic>;
      expect(inserted['plan_date'], '2026-06-10');
      expect(inserted['meal_time'], '09:00');
    });

    test('inserts payload without meal_time key when null', () async {
      final builder = stubTable('meal_plan_entries', payload: _entryRow());

      final result = await buildSut().assignRecipe(
        'baby-1',
        'recipe-1',
        DateTime(2026, 6, 10),
        null,
      );

      expect(result.isSuccess, isTrue);
      final inserted = builder.inserted! as Map<String, dynamic>;
      expect(inserted.containsKey('meal_time'), isFalse);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'meal_plan_entries',
        error: const PostgrestException(message: 'conflict'),
      );

      final result = await buildSut().assignRecipe(
        'baby-1',
        'recipe-1',
        DateTime(2026, 6, 10),
        null,
      );

      expect(result.errorOrNull, _failsWith<ServerException>('conflict'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('meal_plan_entries', error: Exception('oops'));

      final result = await buildSut().assignRecipe(
        'baby-1',
        'recipe-1',
        DateTime(2026, 6, 10),
        null,
      );

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('appendBulk', () {
    test('empty list returns success without hitting Supabase', () async {
      final result = await buildSut().appendBulk([]);

      verifyNever(() => mockSupabase.from(any()));
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('inserts all entries and returns mapped list', () async {
      final rows = [
        _entryRow(id: 'e1', recipeId: 'r1'),
        _entryRow(
          id: 'e2',
          recipeId: 'r2',
          planDate: '2026-06-11',
          mealTime: '12:00',
        ),
      ];
      final builder = stubTable('meal_plan_entries', payload: rows);

      final result = await buildSut().appendBulk([
        MealPlanEntryInsert(
          babyId: 'baby-1',
          recipeId: 'r1',
          planDate: DateTime(2026, 6, 10),
        ),
        MealPlanEntryInsert(
          babyId: 'baby-1',
          recipeId: 'r2',
          planDate: DateTime(2026, 6, 11),
          mealTime: const TimeOfDay(hour: 12, minute: 0),
        ),
      ]);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, hasLength(2));
      final inserted = builder.inserted! as List<Map<String, dynamic>>;
      expect(inserted[0]['recipe_id'], 'r1');
      expect(inserted[0].containsKey('meal_time'), isFalse);
      expect(inserted[1]['meal_time'], '12:00');
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'meal_plan_entries',
        error: const PostgrestException(message: 'insert failed'),
      );

      final result = await buildSut().appendBulk([
        MealPlanEntryInsert(
          babyId: 'baby-1',
          recipeId: 'r1',
          planDate: DateTime(2026, 6, 10),
        ),
      ]);

      expect(
        result.errorOrNull,
        _failsWith<ServerException>('insert failed'),
      );
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('meal_plan_entries', error: Exception('boom'));

      final result = await buildSut().appendBulk([
        MealPlanEntryInsert(
          babyId: 'baby-1',
          recipeId: 'r1',
          planDate: DateTime(2026, 6, 10),
        ),
      ]);

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('deleteRange', () {
    test('deletes with correct filters', () async {
      final builder = stubTable(
        'meal_plan_entries',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().deleteRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 16),
      );

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.filters, [('baby_id', 'baby-1')]);
      expect(builder.gteFilters, [('plan_date', '2026-06-10')]);
      expect(builder.lteFilters, [('plan_date', '2026-06-16')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'meal_plan_entries',
        error: const PostgrestException(message: 'delete failed'),
      );

      final result = await buildSut().deleteRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 16),
      );

      expect(result.errorOrNull, _failsWith<ServerException>('delete failed'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('meal_plan_entries', error: Exception('boom'));

      final result = await buildSut().deleteRange(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 16),
      );

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('clearWeek', () {
    test('delegates to deleteRange with same date range', () async {
      final builder = stubTable(
        'meal_plan_entries',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().clearWeek(
        'baby-1',
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 16),
      );

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.gteFilters, [('plan_date', '2026-06-10')]);
      expect(builder.lteFilters, [('plan_date', '2026-06-16')]);
    });
  });

  group('removeEntry', () {
    test('deletes by entry id', () async {
      final builder = stubTable(
        'meal_plan_entries',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().removeEntry('entry-42');

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.filters, [('id', 'entry-42')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'meal_plan_entries',
        error: const PostgrestException(message: 'not found'),
      );

      final result = await buildSut().removeEntry('entry-42');

      expect(result.errorOrNull, _failsWith<ServerException>('not found'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('meal_plan_entries', error: Exception('boom'));

      final result = await buildSut().removeEntry('entry-42');

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('clearDay', () {
    test('deletes with baby_id and formatted plan_date', () async {
      final builder = stubTable(
        'meal_plan_entries',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().clearDay('baby-1', DateTime(2026, 6, 10));

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.filters, [
        ('baby_id', 'baby-1'),
        ('plan_date', '2026-06-10'),
      ]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'meal_plan_entries',
        error: const PostgrestException(message: 'rls error'),
      );

      final result = await buildSut().clearDay('baby-1', DateTime(2026, 6, 10));

      expect(result.errorOrNull, _failsWith<ServerException>('rls error'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('meal_plan_entries', error: Exception('boom'));

      final result = await buildSut().clearDay('baby-1', DateTime(2026, 6, 10));

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });
}
