import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/shopping_list_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
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
      _error != null ? Future<T>.error(_error) : Future<T>.value(_payload as T);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    _owner.filters.add((column, value));
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
      _FakeChain<PostgrestMap>(owner: _owner, payload: _payload, error: _error);

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
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

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
  String? orderedBy;
  Object? inserted;
  Map<dynamic, dynamic>? updated;
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
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> values) {
    updated = values;
    return _chain;
  }

  @override
  PostgrestFilterBuilder<PostgrestList> delete() {
    deleteCalled = true;
    return _chain;
  }
}

Map<String, dynamic> _itemRow({
  String id = 'item-1',
  String babyId = 'baby-1',
  String name = 'Peanut butter',
  bool isChecked = false,
  String source = 'manual',
  String createdAt = '2026-06-10T10:00:00.000Z',
}) => <String, dynamic>{
  'id': id,
  'baby_id': babyId,
  'name': name,
  'is_checked': isChecked,
  'source': source,
  'created_at': createdAt,
};

ShoppingListItem _item({
  String id = 'item-1',
  String babyId = 'baby-1',
  String name = 'Peanut butter',
  bool isChecked = false,
  ShoppingListSource source = ShoppingListSource.manual,
}) => ShoppingListItem(
  id: id,
  babyId: babyId,
  name: name,
  isChecked: isChecked,
  source: source,
  createdAt: DateTime.parse('2026-06-10T10:00:00.000Z'),
);

Matcher _failsWith<E extends AppException>([String? message]) =>
    isA<E>().having((e) => e.message, 'message', message ?? anything);

void main() {
  late _MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
  });

  tearDown(resetMocktailState);

  ShoppingListRepositoryImpl buildSut() =>
      ShoppingListRepositoryImpl(supabaseClient: mockSupabase);

  _FakeQueryBuilder stubTable(String table, {Object? payload, Object? error}) {
    final builder = _FakeQueryBuilder(payload: payload, error: error);
    when(() => mockSupabase.from(table)).thenAnswer((_) => builder);
    return builder;
  }

  group('getItems', () {
    test('returns mapped items with correct filters and order', () async {
      final rows = [
        _itemRow(name: 'Eggs'),
        _itemRow(id: 'item-2', name: 'Milk', isChecked: true, source: 'recipe'),
      ];
      final builder = stubTable('shopping_list_items', payload: rows);

      final result = await buildSut().getItems('baby-1');

      expect(result.isSuccess, isTrue);
      final items = result.dataOrNull!;
      expect(items, hasLength(2));
      expect(items[0].id, 'item-1');
      expect(items[0].name, 'Eggs');
      expect(items[1].isChecked, isTrue);
      expect(items[1].source, ShoppingListSource.recipe);
      expect(builder.filters, [('baby_id', 'baby-1')]);
      expect(builder.orderedBy, 'created_at');
    });

    test('returns empty list when no items exist', () async {
      final _ = stubTable(
        'shopping_list_items',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().getItems('baby-1');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('maps all ShoppingListSource variants', () async {
      final rows = [
        _itemRow(id: 'i1', source: 'recipe'),
        _itemRow(id: 'i2', source: 'mealPlan'),
        _itemRow(id: 'i3'),
      ];
      final _ = stubTable('shopping_list_items', payload: rows);

      final result = await buildSut().getItems('baby-1');

      final items = result.dataOrNull!;
      expect(items[0].source, ShoppingListSource.recipe);
      expect(items[1].source, ShoppingListSource.mealPlan);
      expect(items[2].source, ShoppingListSource.manual);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'shopping_list_items',
        error: const PostgrestException(message: 'db error'),
      );

      final result = await buildSut().getItems('baby-1');

      expect(result.errorOrNull, _failsWith<ServerException>('db error'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('shopping_list_items', error: Exception('boom'));

      final result = await buildSut().getItems('baby-1');

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('addItems', () {
    test('empty list returns success without hitting Supabase', () async {
      final result = await buildSut().addItems([]);

      verifyNever(() => mockSupabase.from(any()));
      expect(result.isSuccess, isTrue);
    });

    test('inserts rows omitting the id field', () async {
      final builder = stubTable(
        'shopping_list_items',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().addItems([
        _item(name: 'Eggs', source: ShoppingListSource.recipe),
        _item(id: 'item-2', name: 'Milk', isChecked: true),
      ]);

      expect(result.isSuccess, isTrue);
      final rows = builder.inserted! as List<Map<String, dynamic>>;
      expect(rows, hasLength(2));
      expect(rows[0].containsKey('id'), isFalse);
      expect(rows[0]['name'], 'Eggs');
      expect(rows[0]['source'], 'recipe');
      expect(rows[1]['is_checked'], isTrue);
      expect(rows[1]['source'], 'manual');
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'shopping_list_items',
        error: const PostgrestException(message: 'insert failed'),
      );

      final result = await buildSut().addItems([_item()]);

      expect(result.errorOrNull, _failsWith<ServerException>('insert failed'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('shopping_list_items', error: Exception('boom'));

      final result = await buildSut().addItems([_item()]);

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('setChecked', () {
    test('updates is_checked to true with correct id filter', () async {
      final builder = stubTable(
        'shopping_list_items',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().setChecked('item-1', isChecked: true);

      expect(result.isSuccess, isTrue);
      expect(builder.updated, <String, dynamic>{'is_checked': true});
      expect(builder.filters, [('id', 'item-1')]);
    });

    test('updates is_checked to false', () async {
      final builder = stubTable(
        'shopping_list_items',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().setChecked('item-2', isChecked: false);

      expect(result.isSuccess, isTrue);
      expect(builder.updated, <String, dynamic>{'is_checked': false});
      expect(builder.filters, [('id', 'item-2')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'shopping_list_items',
        error: const PostgrestException(message: 'update failed'),
      );

      final result = await buildSut().setChecked('item-1', isChecked: true);

      expect(result.errorOrNull, _failsWith<ServerException>('update failed'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('shopping_list_items', error: Exception('boom'));

      final result = await buildSut().setChecked('item-1', isChecked: true);

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('deleteItem', () {
    test('deletes with correct id filter', () async {
      final builder = stubTable(
        'shopping_list_items',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().deleteItem('item-1');

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.filters, [('id', 'item-1')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'shopping_list_items',
        error: const PostgrestException(message: 'not found'),
      );

      final result = await buildSut().deleteItem('item-1');

      expect(result.errorOrNull, _failsWith<ServerException>('not found'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('shopping_list_items', error: Exception('boom'));

      final result = await buildSut().deleteItem('item-1');

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });

  group('clearAll', () {
    test('deletes all items for baby with correct baby_id filter', () async {
      final builder = stubTable(
        'shopping_list_items',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().clearAll('baby-1');

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.filters, [('baby_id', 'baby-1')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'shopping_list_items',
        error: const PostgrestException(message: 'rls error'),
      );

      final result = await buildSut().clearAll('baby-1');

      expect(result.errorOrNull, _failsWith<ServerException>('rls error'));
    });

    test('unknown error maps to UnknownException', () async {
      final _ = stubTable('shopping_list_items', error: Exception('boom'));

      final result = await buildSut().clearAll('baby-1');

      expect(result.errorOrNull, isA<UnknownException>());
    });
  });
}
