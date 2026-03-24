import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_library_controller.g.dart';

/// Allergen key → display name map (sequence order preserved for sections).
const _allergenNames = {
  'peanut': 'Peanut',
  'egg': 'Egg',
  'dairy': 'Dairy',
  'tree_nuts': 'Tree Nuts',
  'sesame': 'Sesame',
  'soy': 'Soy',
  'wheat': 'Wheat',
  'fish': 'Fish',
  'shellfish': 'Shellfish',
};

const _allergenSequence = [
  'peanut',
  'egg',
  'dairy',
  'tree_nuts',
  'sesame',
  'soy',
  'wheat',
  'fish',
  'shellfish',
];

@riverpod
class RecipeLibraryController extends _$RecipeLibraryController {
  @override
  Future<RecipeLibraryState> build(String babyId) async {
    final (recipesResult, programResult) = await (
      ref.read(recipeServiceProvider).getFilteredRecipes(babyId),
      ref.read(allergenServiceProvider).getProgramState(babyId),
    ).wait;

    if (recipesResult.isFailure) throw recipesResult.errorOrNull!;
    if (programResult.isFailure) throw programResult.errorOrNull!;

    final recipes = recipesResult.dataOrNull!;
    final currentKey = programResult.dataOrNull!.currentAllergenKey;

    final sections = <RecipeSection>[];

    // 1. Recommendations — recipes tagged with current allergen.
    final recommendations = recipes
        .where((Recipe r) => r.allergenTags.contains(currentKey))
        .toList();
    if (recommendations.isNotEmpty) {
      final name = _allergenNames[currentKey] ?? currentKey;
      final emoji = AllergenEmoji.get(currentKey);
      sections.add(
        RecipeSection(
          title: 'Recommendation for $name $emoji',
          recipes: recommendations,
        ),
      );
    }

    // 2. One section per allergen in sequence order (skip current).
    for (final key in _allergenSequence) {
      if (key == currentKey) continue;
      final tagged = recipes
          .where((Recipe r) => r.allergenTags.contains(key))
          .toList();
      if (tagged.isEmpty) continue;
      final name = _allergenNames[key] ?? key;
      final emoji = AllergenEmoji.get(key);
      sections.add(RecipeSection(title: '$name $emoji', recipes: tagged));
    }

    // 3. Untagged recipes — "All Recipes".
    final untagged = recipes
        .where((Recipe r) => r.allergenTags.isEmpty)
        .toList();
    if (untagged.isNotEmpty) {
      sections.add(RecipeSection(title: 'All Recipes', recipes: untagged));
    }

    return RecipeLibraryState(sections: sections);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
