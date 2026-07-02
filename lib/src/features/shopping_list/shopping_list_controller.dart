import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_controller.g.dart';

@riverpod
class ShoppingListController extends _$ShoppingListController {
  @override
  Future<ShoppingListState> build(String babyId) async {
    final result = await ref.read(shoppingListServiceProvider).getItems(babyId);
    if (result.isFailure) throw result.errorOrNull!;
    return ShoppingListState(items: result.dataOrNull!);
  }

  Future<void> addManual(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    // Optimistic: insert placeholder immediately so the item appears at top.
    // id='' is replaced once the invalidate/refetch brings back the real UUID.
    final now = DateTime.now();
    final placeholder = ShoppingListItem(
      id: '',
      babyId: babyId,
      name: trimmed,
      isChecked: false,
      source: ShoppingListSource.manual,
      createdAt: now,
    );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(items: [...current.items, placeholder]),
      );
    }

    final result = await ref
        .read(shoppingListServiceProvider)
        .addManualItem(babyId, trimmed);

    if (result.isFailure) {
      // Revert placeholder
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }

    _fireAndForget(
      ref.read(analyticsProvider).logShoppingItemAdded(source: 'manual'),
    );

    // Reload to swap the placeholder id for the server-assigned id. The write
    // already succeeded, so a refetch read-failure is P3 (background) — don't
    // let it re-enter the add path and surface a false P2 "add failed" toast.
    ref.invalidateSelf();
    try {
      await future;
    } on Exception catch (_) {
      // Keep the optimistic row; the list reconciles on the next load.
    }
  }

  Future<void> check(String itemId) async {
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(
          items: current.items
              .map((i) => i.id == itemId ? i.copyWith(isChecked: true) : i)
              .toList(),
        ),
      );
    }

    final result = await ref
        .read(shoppingListServiceProvider)
        .checkItem(itemId);
    if (result.isFailure) {
      // Revert
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }

    _fireAndForget(ref.read(analyticsProvider).logShoppingItemChecked());
  }

  Future<void> uncheck(String itemId) async {
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(
          items: current.items
              .map((i) => i.id == itemId ? i.copyWith(isChecked: false) : i)
              .toList(),
        ),
      );
    }

    final result = await ref
        .read(shoppingListServiceProvider)
        .uncheckItem(itemId);
    if (result.isFailure) {
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }

    _fireAndForget(ref.read(analyticsProvider).logShoppingItemUnchecked());
  }

  /// [via] identifies the delete affordance the user tapped: 'swipe' for the
  /// swipe-to-reveal Delete pill, 'button' for the per-row cancel chip.
  Future<void> delete(String itemId, {String via = 'button'}) async {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShoppingListState(
          items: current.items.where((i) => i.id != itemId).toList(),
        ),
      );
    }

    final result = await ref
        .read(shoppingListServiceProvider)
        .deleteItem(itemId);
    if (result.isFailure) {
      if (current != null) state = AsyncData(current);
      throw result.errorOrNull!;
    }

    _fireAndForget(
      ref.read(analyticsProvider).logShoppingItemDeleted(via: via),
    );
  }

  Future<void> clearAll() async {
    final result = await ref.read(shoppingListServiceProvider).clearAll(babyId);
    if (result.isFailure) throw result.errorOrNull!;
    state = const AsyncData(ShoppingListState(items: []));

    _fireAndForget(ref.read(analyticsProvider).logShoppingListCleared());
  }

  /// Returns true if clipboard write succeeded, false otherwise.
  Future<bool> copyToClipboard() async {
    final current = state.valueOrNull;
    if (current == null) return false;

    try {
      final text = ref
          .read(shoppingListServiceProvider)
          .copyToClipboard(current.listItems);
      await Clipboard.setData(ClipboardData(text: text));
      _fireAndForget(ref.read(analyticsProvider).logShoppingListCopied());
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  /// Analytics is best-effort. Swallow any rejected future so it never blocks
  /// the write path or escalates to the root zone.
  void _fireAndForget(Future<void> future) {
    unawaited(future.catchError((Object _) {}));
  }
}
