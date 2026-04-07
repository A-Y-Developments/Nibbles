import 'package:flutter/material.dart';
import 'package:nibbles/src/common/data/repositories/meal_plan_repository.dart';
import 'package:nibbles/src/common/data/repositories/recipe_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_service.g.dart';

class MealPlanService {
  const MealPlanService(this._repo, this._recipeRepo);

  final MealPlanRepository _repo;
  final RecipeRepository _recipeRepo;

  /// Returns all meal plan entries for the 7-day week starting on [weekStart].
  Future<Result<List<MealPlanEntry>>> getWeekMeals(
    String babyId,
    DateTime weekStart,
  ) => _repo.getWeekMeals(babyId, weekStart, _weekEnd(weekStart));

  /// Inserts a new recipe assignment for [planDate].
  /// Multiple meals per day are allowed.
  Future<Result<MealPlanEntry>> assignRecipe(
    String babyId,
    String recipeId,
    DateTime planDate, {
    TimeOfDay? mealTime,
  }) => _repo.assignRecipe(babyId, recipeId, planDate, mealTime);

  /// Deletes all meal plan entries for the 7-day week starting on [weekStart].
  Future<Result<void>> clearWeek(String babyId, DateTime weekStart) =>
      _repo.clearWeek(babyId, weekStart, _weekEnd(weekStart));

  /// Returns deduplicated ingredient names across all recipes planned for the
  /// 7-day week starting on [weekStart].
  ///
  /// Individual recipe fetch failures are skipped (best-effort); only a
  /// failure to fetch the week's meal plan propagates as [Result.failure].
  Future<Result<List<String>>> getWeekIngredientNames(
    String babyId,
    DateTime weekStart,
  ) async {
    final mealsResult = await _repo.getWeekMeals(
      babyId,
      weekStart,
      _weekEnd(weekStart),
    );
    if (mealsResult.isFailure) {
      return Result.failure(mealsResult.errorOrNull!);
    }

    final names = <String>{};
    for (final entry in mealsResult.dataOrNull!) {
      final recipeResult = await _recipeRepo.getRecipeById(entry.recipeId);
      if (recipeResult.isFailure) continue;
      names.addAll(recipeResult.dataOrNull!.ingredients.map((i) => i.name));
    }

    return Result.success(names.toList());
  }

  /// Returns deduplicated ingredient names across all recipes planned
  /// for [date].
  ///
  /// Individual recipe fetch failures are skipped (best-effort); only a
  /// failure to fetch the day's meal plan propagates as [Result.failure].
  Future<Result<List<String>>> getDayIngredientNames(
    String babyId,
    DateTime date,
  ) async {
    final mealsResult = await _repo.getWeekMeals(babyId, date, date);
    if (mealsResult.isFailure) {
      return Result.failure(mealsResult.errorOrNull!);
    }

    final names = <String>{};
    for (final entry in mealsResult.dataOrNull!) {
      final recipeResult = await _recipeRepo.getRecipeById(entry.recipeId);
      if (recipeResult.isFailure) continue;
      names.addAll(recipeResult.dataOrNull!.ingredients.map((i) => i.name));
    }

    return Result.success(names.toList());
  }

  /// Deletes a single meal plan entry by ID.
  Future<Result<void>> removeEntry(String entryId) =>
      _repo.removeEntry(entryId);

  /// Deletes all meal plan entries for [babyId] on [date].
  Future<Result<void>> clearDay(String babyId, DateTime date) =>
      _repo.clearDay(babyId, date);

  static DateTime _weekEnd(DateTime weekStart) =>
      weekStart.add(const Duration(days: 6));
}

@Riverpod(keepAlive: true)
MealPlanService mealPlanService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  MealPlanServiceRef ref,
) => MealPlanService(
  ref.watch(mealPlanRepositoryProvider),
  ref.watch(recipeRepositoryProvider),
);
