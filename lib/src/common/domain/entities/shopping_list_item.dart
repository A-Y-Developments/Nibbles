import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';

part 'shopping_list_item.freezed.dart';

@freezed
class ShoppingListItem with _$ShoppingListItem {
  const factory ShoppingListItem({
    required String id,
    required String babyId,
    required String name,
    required bool isChecked,
    required ShoppingListSource source,
    required DateTime createdAt,
  }) = _ShoppingListItem;
}
