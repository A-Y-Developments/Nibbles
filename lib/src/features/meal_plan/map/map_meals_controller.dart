import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_meals_controller.g.dart';

/// Drives the NIB-95 Map Meals Plan screen.
///
/// Holds the picked recipes + date range (handed in via [MapMealsArgs]),
/// the currently selected day chip, and the in-progress recipe→day
/// assignments. Bulk-commits via [MealPlanService.appendMealsToRange]
/// (APPEND only — no replace semantics per NIB-120).
@riverpod
class MapMealsController extends _$MapMealsController {
  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  MapMealsState build(MapMealsArgs args) {
    final start = _dateOnly(args.startDate);
    final end = _dateOnly(args.endDate);
    return MapMealsState(
      pickedRecipes: args.pickedRecipes,
      startDate: start,
      endDate: end,
      selectedDay: start,
    );
  }

  /// Switches the active day chip.
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: _dateOnly(day));
  }

  /// Adds (or overwrites) the assignment for [recipeId] to the currently
  /// selected day on the state.
  void assignToSelectedDay(String recipeId) {
    final next = Map<String, DateTime>.from(state.assignments);
    next[recipeId] = state.selectedDay;
    state = state.copyWith(assignments: next, errorMessage: null);
  }

  /// Removes [recipeId] from the assignments map.
  void unassign(String recipeId) {
    final next = Map<String, DateTime>.from(state.assignments)
      ..remove(recipeId);
    state = state.copyWith(assignments: next, errorMessage: null);
  }

  /// Bulk-commits the assignments via [MealPlanService.appendMealsToRange].
  ///
  /// Returns true on success (caller pops with `true`). On failure leaves
  /// `errorMessage` set so the screen can show the P1 retry dialog.
  Future<bool> commit() async {
    if (state.assignments.isEmpty) return false;

    state = state.copyWith(isCommitting: true, errorMessage: null);

    final babyId = await ref.read(currentBabyIdProvider.future);
    if (babyId == null) {
      state = state.copyWith(
        isCommitting: false,
        errorMessage: 'No baby profile found.',
      );
      return false;
    }

    final start = state.startDate;
    final assignments = state.assignments.entries.map((entry) {
      final day = _dateOnly(entry.value);
      final offset = day.difference(start).inDays;
      return RecipeAssignment(recipeId: entry.key, dayOffset: offset);
    }).toList();

    final result = await ref
        .read(mealPlanServiceProvider)
        .appendMealsToRange(
          babyId: babyId,
          startDate: state.startDate,
          endDate: state.endDate,
          assignments: assignments,
        );

    if (result.isFailure) {
      state = state.copyWith(
        isCommitting: false,
        errorMessage: result.errorOrNull?.message ?? 'Failed to save plan.',
      );
      return false;
    }

    state = state.copyWith(isCommitting: false);
    return true;
  }
}
