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

  /// Optional list of utensils for this recipe, sourced from the entity.
  /// Returns null when the recipe has no utensils (null or empty) so the UI
  /// conditionally hides the section.
  List<String>? get utensils =>
      (recipe.utensils?.isEmpty ?? true) ? null : recipe.utensils;

  /// Optional fridge storage note, sourced from the entity.
  String? get storageNote => recipe.storageNote;

  /// Optional freezer storage note, sourced from the entity.
  String? get freezerNote => recipe.freezerNote;

  /// Optional "Texture Tip" body copy, sourced from the entity.
  String? get textureTip => recipe.textureTip;

  /// Optional "Why this meal" body copy, sourced from the entity.
  String? get whyThisMeal => recipe.whyThisMeal;
}
