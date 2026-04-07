import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/repositories/recipe_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_service.g.dart';

class RecipeService {
  const RecipeService(this._recipeRepo, this._allergenRepo);

  final RecipeRepository _recipeRepo;
  final AllergenRepository _allergenRepo;

  /// Fetches all recipes (no filtering). Safe recipes appear first, recipes
  /// containing flagged allergens are sorted to the end.
  Future<Result<List<Recipe>>> getAllRecipes(String babyId) async {
    final flaggedResult = await getFlaggedAllergenKeys(babyId);
    if (flaggedResult.isFailure) {
      return Result.failure(flaggedResult.errorOrNull!);
    }

    final recipesResult = await _recipeRepo.getAllRecipes();
    if (recipesResult.isFailure) {
      return Result.failure(recipesResult.errorOrNull!);
    }

    final flagged = flaggedResult.dataOrNull!;
    final recipes = recipesResult.dataOrNull!;

    if (flagged.isEmpty) return Result.success(recipes);

    // Sort: safe recipes first, flagged-allergen recipes last.
    final safe = <Recipe>[];
    final unsafe = <Recipe>[];
    for (final r in recipes) {
      if (r.allergenTags.any(flagged.contains)) {
        unsafe.add(r);
      } else {
        safe.add(r);
      }
    }
    return Result.success([...safe, ...unsafe]);
  }

  /// Returns recipes tagged with [allergenKey]. Recipes containing other
  /// flagged allergens are sorted to the end (not removed).
  Future<Result<List<Recipe>>> getRecommendationsForAllergen(
    String allergenKey,
    String babyId,
  ) async {
    final flaggedResult = await getFlaggedAllergenKeys(babyId);
    if (flaggedResult.isFailure) {
      return Result.failure(flaggedResult.errorOrNull!);
    }

    final recipesResult = await _recipeRepo.getRecipesByAllergen(allergenKey);
    if (recipesResult.isFailure) {
      return Result.failure(recipesResult.errorOrNull!);
    }

    final flagged = flaggedResult.dataOrNull!;
    final recipes = recipesResult.dataOrNull!;

    // Sort: safe first, recipes with flagged allergens last.
    final safe = <Recipe>[];
    final unsafe = <Recipe>[];
    for (final r in recipes) {
      if (r.allergenTags.any(flagged.contains)) {
        unsafe.add(r);
      } else {
        safe.add(r);
      }
    }
    return Result.success([...safe, ...unsafe]);
  }

  /// Returns a general set of recipes (not tied to any allergen) for
  /// use when the current allergen is already safe or flagged.
  /// Safe recipes appear first, flagged-allergen recipes last.
  Future<Result<List<Recipe>>> getGeneralRecommendations(String babyId) async {
    final result = await getAllRecipes(babyId);
    if (result.isFailure) return result;
    final recipes = result.dataOrNull!;
    return Result.success(recipes.take(10).toList());
  }

  /// Fetches a single recipe by ID.
  Future<Result<Recipe>> getRecipeById(String recipeId) =>
      _recipeRepo.getRecipeById(recipeId);

  /// Returns the set of allergen keys for which [babyId] has had a reaction.
  Future<Result<Set<String>>> getFlaggedAllergenKeys(String babyId) async {
    final logsResult = await _allergenRepo.getLogs(babyId);
    if (logsResult.isFailure) {
      return Result.failure(logsResult.errorOrNull!);
    }

    final flaggedKeys = logsResult.dataOrNull!
        .where((l) => l.hadReaction)
        .map((l) => l.allergenKey)
        .toSet();

    return Result.success(flaggedKeys);
  }
}

@Riverpod(keepAlive: true)
RecipeService recipeService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  RecipeServiceRef ref,
) => RecipeService(
  ref.watch(recipeRepositoryProvider),
  ref.watch(allergenRepositoryProvider),
);
