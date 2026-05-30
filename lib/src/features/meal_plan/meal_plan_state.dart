import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'meal_plan_state.freezed.dart';

/// Rolling-7 meal plan state (NIB-120):
/// - [windowStart] is today (date-only).
/// - [windowEnd] is today + 6 days.
/// - [entries] is every meal_plan_entry in that inclusive window.
/// - [expanded] tracks per-day accordion state, keyed by UTC date-only.
@freezed
class MealPlanState with _$MealPlanState {
  const factory MealPlanState({
    required DateTime windowStart,
    required DateTime windowEnd,
    required List<MealPlanEntry> entries,
    Baby? baby,
    @Default(<DateTime, bool>{}) Map<DateTime, bool> expanded,
    @Default(<String, Recipe>{}) Map<String, Recipe> recipes,
    @Default(<String>{}) Set<String> flaggedAllergenKeys,
    AllergenBoardItem? currentAllergenBoardItem,
    AllergenProgramState? programState,
  }) = _MealPlanState;
}
