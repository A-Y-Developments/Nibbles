import 'package:flutter/material.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/recipe/detail/recipe_detail_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_detail_controller.g.dart';

@riverpod
class RecipeDetailController extends _$RecipeDetailController {
  @override
  Future<RecipeDetailState> build(String babyId, String recipeId) async {
    final allergenSvc = ref.read(allergenServiceProvider);

    final (recipeResult, programResult, logsResult) = await (
      ref.read(recipeServiceProvider).getRecipeById(recipeId),
      allergenSvc.getProgramState(babyId),
      allergenSvc.getLogs(babyId),
    ).wait;

    if (recipeResult.isFailure) throw recipeResult.errorOrNull!;
    if (programResult.isFailure) throw programResult.errorOrNull!;
    if (logsResult.isFailure) throw logsResult.errorOrNull!;

    final recipe = recipeResult.dataOrNull!;
    final currentKey = programResult.dataOrNull!.currentAllergenKey;
    final allLogs = logsResult.dataOrNull!;

    // Derive status per allergen tag on this recipe.
    final statuses = <String, AllergenStatus>{};
    for (final tag in recipe.allergenTags) {
      final tagLogs = allLogs
          .where((AllergenLog l) => l.allergenKey == tag)
          .toList();
      statuses[tag] = allergenSvc.deriveStatus(tagLogs);
    }

    return RecipeDetailState(
      recipe: recipe,
      currentAllergenKey: currentKey,
      allergenStatuses: statuses,
    );
  }

  /// Assigns this recipe to a meal plan date, with optional meal time.
  /// Fires analytics on success.
  Future<Result<void>> assignToMealPlan(
    DateTime date, {
    TimeOfDay? time,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return const Result.failure(UnknownException());

    state = AsyncData(current.copyWith(isAddingToMealPlan: true));

    final result = await ref
        .read(mealPlanServiceProvider)
        .assignRecipe(babyId, recipeId, date, mealTime: time);

    state = AsyncData(current.copyWith(isAddingToMealPlan: false));

    if (result.isSuccess) {
      await Analytics.instance.logRecipeAddedToMealPlan(recipeId: recipeId);
    }

    return result;
  }

  /// Adds selected ingredient names to the shopping list.
  Future<Result<void>> addToShoppingList(List<String> selectedNames) async {
    final current = state.valueOrNull;
    if (current == null) return const Result.failure(UnknownException());

    state = AsyncData(current.copyWith(isAddingToShoppingList: true));

    final result = await ref
        .read(shoppingListServiceProvider)
        .addFromRecipe(babyId, recipeId, selectedNames);

    state = AsyncData(current.copyWith(isAddingToShoppingList: false));
    return result;
  }
}
