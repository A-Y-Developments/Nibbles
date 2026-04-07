import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_controller.g.dart';

@riverpod
class MealPlanController extends _$MealPlanController {
  var _weekStart = _mondayOf(DateTime.now());
  var _selectedDate = _dateOnly(DateTime.now());
  var _calendarExpanded = false;
  late String _babyId;

  static DateTime _mondayOf(DateTime date) {
    final d = _dateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

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
        final r = await recipeService.getRecipeById(entry.recipeId);
        if (r.isSuccess) recipeMap[entry.recipeId] = r.dataOrNull!;
      }
    }

    final flaggedResult = await recipeService.getFlaggedAllergenKeys(babyId);
    final flaggedKeys = flaggedResult.dataOrNull ?? <String>{};

    AllergenBoardItem? currentBoardItem;
    AllergenProgramState? programState;
    final programResult = await ref
        .read(allergenServiceProvider)
        .getProgramState(babyId);
    if (programResult.isSuccess) {
      final ps = programResult.dataOrNull;
      programState = ps;
      if (ps != null && ps.status != AllergenProgramStatus.completed) {
        final boardResult = await ref
            .read(allergenServiceProvider)
            .getAllergenBoardSummary(babyId);
        if (boardResult.isSuccess) {
          currentBoardItem = boardResult.dataOrNull!
              .where(
                (AllergenBoardItem item) =>
                    item.allergen.key == ps.currentAllergenKey,
              )
              .firstOrNull;
        }
      }
    }

    return MealPlanState(
      meals: meals,
      weekStart: _weekStart,
      selectedDate: _selectedDate,
      calendarExpanded: _calendarExpanded,
      recipes: recipeMap,
      flaggedAllergenKeys: flaggedKeys,
      currentAllergenBoardItem: currentBoardItem,
      programState: programState,
    );
  }

  void selectDate(DateTime date) {
    final d = _dateOnly(date);
    _selectedDate = d;

    final current = state.valueOrNull;
    if (current == null) return;

    final weekEnd = current.weekStart.add(const Duration(days: 6));
    if (d.isBefore(current.weekStart) || d.isAfter(weekEnd)) {
      // Day is outside current week — shift week and reload meals.
      _weekStart = _mondayOf(d);
      ref.invalidateSelf();
    } else {
      // Same week — pure UI update, no reload.
      state = AsyncData(current.copyWith(selectedDate: d));
    }
  }

  void toggleCalendar() {
    _calendarExpanded = !_calendarExpanded;
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(calendarExpanded: _calendarExpanded));
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
  Future<bool> clearDay(DateTime date) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .clearDay(_babyId, date);
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
