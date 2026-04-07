import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_plan_entry.freezed.dart';

@freezed
class MealPlanEntry with _$MealPlanEntry {
  const factory MealPlanEntry({
    required String id,
    required String babyId,
    required String recipeId,
    required DateTime planDate,

    /// Optional meal time stored as "HH:mm".
    String? mealTime,
  }) = _MealPlanEntry;
}
