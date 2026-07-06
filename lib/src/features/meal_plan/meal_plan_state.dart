import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'meal_plan_state.freezed.dart';

/// Persisted-plan meal plan state.
/// - [plan] is the baby's active [MealPlan] or `null` (→ empty state).
/// - [windowStart] is `plan.startDate` (or today when [plan] is null).
/// - [windowEnd] is `max(plan.endDate, latest entry planDate)`.
/// - [entries] is every meal_plan_entry inside `[windowStart, windowEnd]`.
/// - [expanded] tracks per-day accordion state, keyed by UTC date-only.
@freezed
class MealPlanState with _$MealPlanState {
  const factory MealPlanState({
    required DateTime windowStart,
    required DateTime windowEnd,
    required List<MealPlanEntry> entries,
    MealPlan? plan,
    Baby? baby,
    @Default(<DateTime, bool>{}) Map<DateTime, bool> expanded,
    @Default(<String, Recipe>{}) Map<String, Recipe> recipes,
    @Default(<String>{}) Set<String> flaggedAllergenKeys,
    AllergenBoardItem? currentAllergenBoardItem,
    AllergenProgramState? programState,
  }) = _MealPlanState;
}
