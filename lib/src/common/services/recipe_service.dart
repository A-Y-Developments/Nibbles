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

  /// Fetches all recipes, filtering out any tagged with the baby's flagged
  /// allergens (i.e. allergens where a reaction was recorded).
  Future<Result<List<Recipe>>> getFilteredRecipes(String babyId) async {
    final flaggedResult = await _getFlaggedAllergenKeys(babyId);
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

    return Result.success(
      recipes
          .where((r) => !r.allergenTags.any(flagged.contains))
          .toList(),
    );
  }

  /// Returns recipes tagged with [allergenKey] that are not flagged for
  /// [babyId]. Used for the Home recommendations strip.
  Future<Result<List<Recipe>>> getRecommendationsForAllergen(
    String allergenKey,
    String babyId,
  ) async {
    final flaggedResult = await _getFlaggedAllergenKeys(babyId);
    if (flaggedResult.isFailure) {
      return Result.failure(flaggedResult.errorOrNull!);
    }

    final flagged = flaggedResult.dataOrNull!;

    // If the target allergen itself is flagged, no recommendations.
    if (flagged.contains(allergenKey)) return const Result.success([]);

    final recipesResult = await _recipeRepo.getRecipesByAllergen(allergenKey);
    if (recipesResult.isFailure) {
      return Result.failure(recipesResult.errorOrNull!);
    }

    final recipes = recipesResult.dataOrNull!;

    // Also exclude recipes that have other flagged allergen tags.
    return Result.success(
      recipes
          .where((r) => !r.allergenTags.any(flagged.contains))
          .toList(),
    );
  }

  /// Fetches a single recipe by ID.
  Future<Result<Recipe>> getRecipeById(String recipeId) =>
      _recipeRepo.getRecipeById(recipeId);

  // --- Private helpers ---

  /// Returns the set of allergen keys for which [babyId] has had a reaction.
  Future<Result<Set<String>>> _getFlaggedAllergenKeys(String babyId) async {
    final logsResult = await _allergenRepo.getLogs(babyId);
    if (logsResult.isFailure) {
      return Result.failure(logsResult.errorOrNull!);
    }

    final flaggedKeys = logsResult
        .dataOrNull!
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
) =>
    RecipeService(
      ref.watch(recipeRepositoryProvider),
      ref.watch(allergenRepositoryProvider),
    );
