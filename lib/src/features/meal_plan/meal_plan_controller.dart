import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_controller.g.dart';

@riverpod
class MealPlanController extends _$MealPlanController {
  var _weekStart = _currentWeekMonday();
  late String _babyId;

  static DateTime _currentWeekMonday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  @override
  Future<MealPlanState> build(String babyId) async {
    _babyId = babyId;

    final service = ref.read(mealPlanServiceProvider);
    final mealsResult = await service.getWeekMeals(babyId, _weekStart);
    if (mealsResult.isFailure) throw mealsResult.errorOrNull!;
    final meals = mealsResult.dataOrNull!;

    final recipeService = ref.read(recipeServiceProvider);
    final recipeMap = <String, Recipe>{};
    for (final entry in meals) {
      if (!recipeMap.containsKey(entry.recipeId)) {
        final result = await recipeService.getRecipeById(entry.recipeId);
        if (result.isSuccess) recipeMap[entry.recipeId] = result.dataOrNull!;
      }
    }

    return MealPlanState(
      meals: meals,
      weekStart: _weekStart,
      recipes: recipeMap,
    );
  }

  void previousWeek() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    ref.invalidateSelf();
  }

  void nextWeek() {
    _weekStart = _weekStart.add(const Duration(days: 7));
    ref.invalidateSelf();
  }

  /// Returns false on failure — caller should show P2 toast.
  Future<bool> assignRecipe(DateTime date, String recipeId) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .assignRecipe(_babyId, recipeId, date);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Returns false on failure — caller should show P2 toast.
  Future<bool> removeEntry(String entryId) async {
    final result = await ref.read(mealPlanServiceProvider).removeEntry(entryId);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Returns false on failure — caller should show P2 toast.
  Future<bool> clearWeek() async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .clearWeek(_babyId, _weekStart);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }
}
