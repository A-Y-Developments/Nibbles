import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'meal_plan_state.freezed.dart';

@freezed
class MealPlanState with _$MealPlanState {
  const factory MealPlanState({
    required List<MealPlanEntry> meals,
    required DateTime weekStart,
    @Default(<String, Recipe>{}) Map<String, Recipe> recipes,
  }) = _MealPlanState;
}
