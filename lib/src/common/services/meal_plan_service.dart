import 'package:flutter/material.dart';
import 'package:nibbles/src/common/data/repositories/meal_plan_repository.dart';
import 'package:nibbles/src/common/data/repositories/recipe_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_service.g.dart';

/// One slot in a bulk-append payload: which recipe and which day inside the
/// `[startDate, endDate]` window it should land on. `dayOffset` 0 == startDate.
class RecipeAssignment {
  const RecipeAssignment({
    required this.recipeId,
    required this.dayOffset,
    this.mealTime,
  });

  final String recipeId;
  final int dayOffset;
  final TimeOfDay? mealTime;
}

class MealPlanService {
  const MealPlanService(this._repo, this._recipeRepo);

  final MealPlanRepository _repo;
  final RecipeRepository _recipeRepo;

  /// Returns all meal plan entries for the 7-day week starting on [weekStart].
  Future<Result<List<MealPlanEntry>>> getWeekMeals(
    String babyId,
    DateTime weekStart,
  ) => _repo.getWeekMeals(babyId, weekStart, _weekEnd(weekStart));

  /// NIB-59 / NIB-120: rolling-7 today-anchored window.
  /// Returns entries for `[today, today + 6]` inclusive.
  /// [today] defaults to `DateTime.now()` but is overridable for testing.
  Future<Result<List<MealPlanEntry>>> getRolling7(
    String babyId, {
    DateTime? today,
  }) {
    final start = _dateOnly(today ?? DateTime.now());
    final end = start.add(const Duration(days: 6));
    return _repo.getEntriesInRange(babyId, start, end);
  }

  /// Returns every meal plan entry for [babyId], ordered by plan_date.
  /// Backs the Home redesign (mealPrepSetUp discriminator + date strip range).
  Future<Result<List<MealPlanEntry>>> getAllEntries(String babyId) =>
      _repo.getAllEntries(babyId);

  /// Returns all meal plan entries for the inclusive `[startDate, endDate]`
  /// window. Used by the persisted-plan controller to load a plan of arbitrary
  /// length (unlike [getRolling7], which is fixed at 7 days).
  Future<Result<List<MealPlanEntry>>> getEntriesInRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) =>
      _repo.getEntriesInRange(babyId, _dateOnly(startDate), _dateOnly(endDate));

  /// Returns every entry owned by [planId] regardless of date, so meals added
  /// on a "+ Add Date" day past the plan's end still load.
  Future<Result<List<MealPlanEntry>>> getEntriesForPlan(String planId) =>
      _repo.getEntriesForPlan(planId);

  /// Inserts a new recipe assignment for [planDate].
  /// Multiple meals per day are allowed.
  Future<Result<MealPlanEntry>> assignRecipe(
    String babyId,
    String recipeId,
    DateTime planDate, {
    TimeOfDay? mealTime,
  }) => _repo.assignRecipe(babyId, recipeId, planDate, mealTime);

  /// NIB-59 / NIB-120: APPEND-bulk add (NOT replace).
  ///
  /// Each [assignments] entry specifies (recipeId, dayOffset) where
  /// `dayOffset` is relative to [startDate]. Out-of-range offsets
  /// (negative or beyond `endDate`) are rejected as a [Result.failure].
  Future<Result<List<MealPlanEntry>>> appendMealsToRange({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
    required List<RecipeAssignment> assignments,
    String? mealPlanId,
  }) {
    if (assignments.isEmpty) {
      return Future.value(const Result.success([]));
    }

    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);
    final windowLengthDays = end.difference(start).inDays;

    final inserts = <MealPlanEntryInsert>[];
    for (final a in assignments) {
      if (a.dayOffset < 0 || a.dayOffset > windowLengthDays) {
        return Future.value(
          Result.failure(
            ServerException(
              'RecipeAssignment.dayOffset ${a.dayOffset} is outside '
              '[0..$windowLengthDays].',
            ),
          ),
        );
      }
      inserts.add(
        MealPlanEntryInsert(
          babyId: babyId,
          recipeId: a.recipeId,
          planDate: start.add(Duration(days: a.dayOffset)),
          mealTime: a.mealTime,
          mealPlanId: mealPlanId,
        ),
      );
    }

    return _repo.appendBulk(inserts);
  }

  /// Deletes all meal plan entries for the 7-day week starting on [weekStart].
  Future<Result<void>> clearWeek(String babyId, DateTime weekStart) =>
      _repo.clearWeek(babyId, weekStart, _weekEnd(weekStart));

  /// NIB-59: explicit clear of an arbitrary date range — wired by NIB-103 UI.
  Future<Result<void>> clearRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) => _repo.deleteRange(babyId, _dateOnly(startDate), _dateOnly(endDate));

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

  /// NIB-136: range-scoped ingredient aggregation for the
  /// "Add to Shoplist" sheet launched from the screen-level overflow menu.
  ///
  /// Walks every meal-plan entry whose `planDate` falls inside
  /// `[startDate, endDate]`, expands them into recipe ingredients, and
  /// returns a list of unique ingredient names. Dedup is case-insensitive
  /// (e.g. "olive oil" and "Olive Oil" collapse to one) but the display
  /// casing of the first occurrence is preserved.
  ///
  /// Individual recipe fetch failures are skipped (best-effort); only a
  /// failure to fetch the range's meal plan propagates as [Result.failure].
  Future<Result<List<String>>> getRangeIngredientNames(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final mealsResult = await _repo.getEntriesInRange(
      babyId,
      _dateOnly(startDate),
      _dateOnly(endDate),
    );
    if (mealsResult.isFailure) {
      return Result.failure(mealsResult.errorOrNull!);
    }

    final seenKeys = <String>{};
    final names = <String>[];
    for (final entry in mealsResult.dataOrNull!) {
      final recipeResult = await _recipeRepo.getRecipeById(entry.recipeId);
      if (recipeResult.isFailure) continue;
      for (final ingredient in recipeResult.dataOrNull!.ingredients) {
        final key = ingredient.name.toLowerCase();
        if (seenKeys.add(key)) names.add(ingredient.name);
      }
    }

    return Result.success(names);
  }

  /// Deletes a single meal plan entry by ID.
  Future<Result<void>> removeEntry(String entryId) =>
      _repo.removeEntry(entryId);

  /// Deletes all meal plan entries for [babyId] on [date].
  Future<Result<void>> clearDay(String babyId, DateTime date) =>
      _repo.clearDay(babyId, date);

  /// Returns the baby's current persisted plan, or `null` if none.
  Future<Result<MealPlan?>> getActivePlan(String babyId) =>
      _repo.getActivePlan(babyId);

  /// Creates a plan for `[start, end]`, replacing any existing plan.
  Future<Result<MealPlan>> createPlan(
    String babyId,
    DateTime start,
    DateTime end,
  ) => _repo.createPlan(babyId, _dateOnly(start), _dateOnly(end));

  /// Deletes a plan by ID — cascades its entries.
  Future<Result<void>> deletePlan(String planId) => _repo.deletePlan(planId);

  static DateTime _weekEnd(DateTime weekStart) =>
      weekStart.add(const Duration(days: 6));

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
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
