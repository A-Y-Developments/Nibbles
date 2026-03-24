import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';

part 'shopping_list_state.freezed.dart';

@freezed
class ShoppingListState with _$ShoppingListState {
  const factory ShoppingListState({
    required List<ShoppingListItem> items,
  }) = _ShoppingListState;

  const ShoppingListState._();

  List<ShoppingListItem> get listItems =>
      items.where((i) => !i.isChecked).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ShoppingListItem> get boughtItems =>
      items.where((i) => i.isChecked).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
