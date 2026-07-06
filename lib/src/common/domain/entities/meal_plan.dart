import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_plan.freezed.dart';

@freezed
class MealPlan with _$MealPlan {
  const factory MealPlan({
    required String id,
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime createdAt,
  }) = _MealPlan;
}
