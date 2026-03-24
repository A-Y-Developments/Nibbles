import 'package:flutter/services.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_controller.g.dart';

@riverpod
class ShoppingListController extends _$ShoppingListController {
  @override
  Future<ShoppingListState> build(String babyId) async {
    final result =
        await ref.read(shoppingListServiceProvider).getItems(babyId);
    if (result.isFailure) throw result.errorOrNull!;
    return ShoppingListState(items: result.dataOrNull!);
  }

  Future<void> addManual(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final result = await ref
        .read(shoppingListServiceProvider)
        .addManualItem(babyId, trimmed);

    if (result.isFailure) {
      throw result.errorOrNull!;
    }

    // Optimistic: reload
    ref.invalidateSelf();
    await future;
  }

  Future<void> check(String itemId) async {
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(
          items: current.items
              .map(
                (i) => i.id == itemId ? i.copyWith(isChecked: true) : i,
              )
              .toList(),
        ),
      );
    }

    final result =
        await ref.read(shoppingListServiceProvider).checkItem(itemId);
    if (result.isFailure) {
      // Revert
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }
  }

  Future<void> uncheck(String itemId) async {
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(
          items: current.items
              .map(
                (i) => i.id == itemId ? i.copyWith(isChecked: false) : i,
              )
              .toList(),
        ),
      );
    }

    final result =
        await ref.read(shoppingListServiceProvider).uncheckItem(itemId);
    if (result.isFailure) {
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }
  }

  Future<void> delete(String itemId) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(
          items: current.items.where((i) => i.id != itemId).toList(),
        ),
      );
    }

    final result =
        await ref.read(shoppingListServiceProvider).deleteItem(itemId);
    if (result.isFailure) {
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }
  }

  Future<void> clearAll() async {
    final result =
        await ref.read(shoppingListServiceProvider).clearAll(babyId);
    if (result.isFailure) throw result.errorOrNull!;

    final current = state.valueOrNull;
    if (current != null) {
      state = const AsyncData(ShoppingListState(items: []));
    }
  }

  Future<void> copyToClipboard() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final text = ref
        .read(shoppingListServiceProvider)
        .copyToClipboard(current.listItems);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
