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
///
/// [searchQuery] is the trimmed search input from the header pill. When
/// non-empty the screen collapses category rows into a flat
/// `RecipeSearchResults` list driven by [filteredRecipes]; when empty
/// the category-rows layout is restored.
@freezed
class RecipeLibraryState with _$RecipeLibraryState {
  const factory RecipeLibraryState({
    required Map<String, List<Recipe>> recipesByCategory,
    String? ongoingAllergenKey,
    @Default(<String>{}) Set<String> flaggedAllergenKeys,
    @Default(false) bool isStartingGuideSeen,
    @Default('') String searchQuery,
  }) = _RecipeLibraryState;

  const RecipeLibraryState._();

  /// Flat, deduped list of recipes across every category. Iteration order
  /// follows the insertion order of [recipesByCategory].
  List<Recipe> get _allRecipes =>
      recipesByCategory.values.expand((rs) => rs).toSet().toList();

  /// Recipes matching [searchQuery] against the recipe title or any
  /// `nutritionTags` entry. Returns an empty list when [searchQuery] is empty.
  ///
  /// NIB-196: matches on a word boundary (`\b`) rather than a raw substring, so
  /// "egg" matches "Egg Yolk Puree" / "Scrambled Eggs" but not the "egg" inside
  /// "Veggie" — a false positive that mattered on a safety-relevant query.
  List<Recipe> get filteredRecipes {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final pattern = RegExp(r'\b' + RegExp.escape(q));
    return _allRecipes
        .where(
          (r) =>
              pattern.hasMatch(r.title.toLowerCase()) ||
              r.nutritionTags.any((t) => pattern.hasMatch(t.toLowerCase())),
        )
        .toList();
  }
}
