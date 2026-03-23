import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'shopping_list_repository.g.dart';

abstract interface class ShoppingListRepository {
  /// SL-01: Fetch all items for baby, ordered by creation time.
  Future<Result<List<ShoppingListItem>>> getItems(String babyId);

  /// SL-02: Insert one or more items. Supabase auto-generates IDs.
  Future<Result<void>> addItems(List<ShoppingListItem> items);

  /// SL-03: Update is_checked for a single item.
  Future<Result<void>> setChecked(String itemId, {required bool isChecked});

  /// SL-04: Delete a single item.
  Future<Result<void>> deleteItem(String itemId);

  /// SL-05: Delete all items for baby regardless of checked state.
  Future<Result<void>> clearAll(String babyId);
}

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  ShoppingListRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<Result<List<ShoppingListItem>>> getItems(String babyId) async {
    try {
      final data = await _supabase
          .from('shopping_list_items')
          .select()
          .eq('baby_id', babyId)
          .order('created_at');

      return Result.success(
        (data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(_itemFromRow)
            .toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> addItems(List<ShoppingListItem> items) async {
    if (items.isEmpty) return const Result.success(null);
    try {
      await _supabase.from('shopping_list_items').insert(
            items.map(_itemToRow).toList(),
          );
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> setChecked(
    String itemId, {
    required bool isChecked,
  }) async {
    try {
      await _supabase
          .from('shopping_list_items')
          .update({'is_checked': isChecked}).eq('id', itemId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> deleteItem(String itemId) async {
    try {
      await _supabase
          .from('shopping_list_items')
          .delete()
          .eq('id', itemId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> clearAll(String babyId) async {
    try {
      await _supabase
          .from('shopping_list_items')
          .delete()
          .eq('baby_id', babyId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  // ---------------------------------------------------------------------------
  // Row mappers
  // ---------------------------------------------------------------------------

  ShoppingListItem _itemFromRow(Map<String, dynamic> row) => ShoppingListItem(
        id: row['id'] as String,
        babyId: row['baby_id'] as String,
        name: row['name'] as String,
        isChecked: row['is_checked'] as bool,
        source: ShoppingListSourceX.fromJson(row['source'] as String),
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  /// Omits the id field so Supabase auto-generates a UUID on insert.
  Map<String, dynamic> _itemToRow(ShoppingListItem item) => {
        'baby_id': item.babyId,
        'name': item.name,
        'is_checked': item.isChecked,
        'source': item.source.toJson(),
      };
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
ShoppingListRepository shoppingListRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  ShoppingListRepositoryRef ref,
) =>
    ShoppingListRepositoryImpl();
