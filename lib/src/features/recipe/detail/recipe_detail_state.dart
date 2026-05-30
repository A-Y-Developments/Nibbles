import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'recipe_detail_state.freezed.dart';

@freezed
class RecipeDetailState with _$RecipeDetailState {
  const factory RecipeDetailState({
    required Recipe recipe,
    required String currentAllergenKey,
    @Default(<String, AllergenStatus>{})
    Map<String, AllergenStatus> allergenStatuses,
    @Default(false) bool isAddingToMealPlan,
    @Default(false) bool isAddingToShoppingList,
  }) = _RecipeDetailState;

  const RecipeDetailState._();

  /// Optional list of utensils for this recipe. Returns null until the
  /// `Recipe` entity surfaces a utensils field (NIB-129 only added
  /// `nutritionTags` + `category`; the rest is pending). Routed through a
  /// getter so callers stay compile-clean and the UI conditionally hides
  /// the section.
  List<String>? get utensils => null;

  /// Optional fridge storage note. Null until backed by the entity.
  String? get storageNote => null;

  /// Optional freezer storage note. Null until backed by the entity.
  String? get freezerNote => null;

  /// Optional "Texture Tip" body copy. Null until backed by the entity.
  String? get textureTip => null;

  /// Optional "Why this meal" body copy. Null until backed by the entity.
  String? get whyThisMeal => null;
}
