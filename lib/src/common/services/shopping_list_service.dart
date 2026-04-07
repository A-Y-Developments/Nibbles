import 'package:nibbles/src/common/data/repositories/shopping_list_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_service.g.dart';

class ShoppingListService {
  const ShoppingListService(this._repo);

  final ShoppingListRepository _repo;

  Future<Result<List<ShoppingListItem>>> getItems(String babyId) =>
      _repo.getItems(babyId);

  /// Adds selected ingredient names from a recipe. Names only — no quantities.
  Future<Result<void>> addFromRecipe(
    String babyId,
    String recipeId,
    List<String> selectedIngredientNames,
  ) {
    final now = DateTime.now();
    final items = selectedIngredientNames
        .map(
          (name) => ShoppingListItem(
            id: '',
            babyId: babyId,
            name: name,
            isChecked: false,
            source: ShoppingListSource.recipe,
            createdAt: now,
          ),
        )
        .toList();
    return _repo.addItems(items);
  }

  /// Adds a single manually-entered item.
  Future<Result<void>> addManualItem(String babyId, String name) =>
      _repo.addItems([
        ShoppingListItem(
          id: '',
          babyId: babyId,
          name: name,
          isChecked: false,
          source: ShoppingListSource.manual,
          createdAt: DateTime.now(),
        ),
      ]);

  Future<Result<void>> checkItem(String itemId) =>
      _repo.setChecked(itemId, isChecked: true);

  Future<Result<void>> uncheckItem(String itemId) =>
      _repo.setChecked(itemId, isChecked: false);

  Future<Result<void>> deleteItem(String itemId) => _repo.deleteItem(itemId);

  Future<Result<void>> clearAll(String babyId) => _repo.clearAll(babyId);

  /// Returns a plain-text list of unchecked item names.
  /// The caller is responsible for writing to the clipboard.
  String copyToClipboard(List<ShoppingListItem> uncheckedItems) =>
      uncheckedItems.map((i) => '• ${i.name}').join('\n');
}

@Riverpod(keepAlive: true)
ShoppingListService shoppingListService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  ShoppingListServiceRef ref,
) => ShoppingListService(ref.watch(shoppingListRepositoryProvider));
