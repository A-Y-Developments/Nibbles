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
}
