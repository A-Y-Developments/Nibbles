import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
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

    // Only the recipe is essential — without it there is nothing to render.
    // The allergen program/logs are SECONDARY (they only tint the
    // "Contains allergens" chips); a failure there must NOT collapse the whole
    // screen, so they degrade to safe defaults (P3) instead of throwing.
    if (recipeResult.isFailure) throw recipeResult.errorOrNull!;

    final recipe = recipeResult.dataOrNull!;
    final currentKey = programResult.dataOrNull?.currentAllergenKey ?? '';
    final allLogs = logsResult.dataOrNull ?? const <AllergenLog>[];

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

  /// Bulk-assigns this recipe to every date in [dates] via a single
  /// `appendMealsToRange` call.
  ///
  /// Builds a list of [RecipeAssignment] with `dayOffset` relative to the
  /// earliest date in [dates] (the window's `startDate`). Fires analytics
  /// once on success regardless of day count.
  Future<Result<List<MealPlanEntry>>> assignToMealPlan(
    Set<DateTime> dates,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return const Result.failure(UnknownException());
    if (dates.isEmpty) return const Result.success(<MealPlanEntry>[]);

    state = AsyncData(current.copyWith(isAddingToMealPlan: true));

    final normalized = dates.map(_dateOnly).toList()..sort();
    final start = normalized.first;
    final end = normalized.last;
    final assignments = normalized
        .map(
          (d) => RecipeAssignment(
            recipeId: recipeId,
            dayOffset: d.difference(start).inDays,
          ),
        )
        .toList();

    final result = await ref
        .read(mealPlanServiceProvider)
        .appendMealsToRange(
          babyId: babyId,
          startDate: start,
          endDate: end,
          assignments: assignments,
        );

    state = AsyncData(current.copyWith(isAddingToMealPlan: false));

    if (result.isSuccess) {
      unawaited(
        Analytics.instance.logRecipeAddedToMealPlan(
          recipeId: recipeId,
          dayCount: normalized.length,
        ),
      );
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

    if (result.isSuccess) {
      unawaited(
        Analytics.instance.logRecipeAddedToShoppingList(
          recipeId: recipeId,
          itemCount: selectedNames.length,
        ),
      );
    }

    return result;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
