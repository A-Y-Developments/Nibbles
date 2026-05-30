import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'recipe_library_state.freezed.dart';

/// State for the Recipe Library screen (RC-01).
///
/// [recipesByCategory] is the category-grouped output of
/// `RecipeService.getRecipesByCategory` (NIB-129). Iteration order over the
/// map drives section order on screen — controllers should pass an insertion
/// ordered map (the default `LinkedHashMap`) so that order is preserved.
///
/// [ongoingAllergenKey] is the first allergen in canonical key order whose
/// derived status is `AllergenStatus.inProgress`, or `null` when no allergen
/// is currently in progress.
///
/// [flaggedAllergenKeys] drives the 'Not safe' visual treatment on cards
/// whose `allergenTags` intersect with a baby's flagged-allergen set.
///
/// [isStartingGuideSeen] gates the first-launch 'Read Guide' banner.
@freezed
class RecipeLibraryState with _$RecipeLibraryState {
  const factory RecipeLibraryState({
    required Map<String, List<Recipe>> recipesByCategory,
    String? ongoingAllergenKey,
    @Default(<String>{}) Set<String> flaggedAllergenKeys,
    @Default(false) bool isStartingGuideSeen,
  }) = _RecipeLibraryState;
}
