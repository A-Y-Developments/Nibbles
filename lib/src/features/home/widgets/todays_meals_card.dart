import 'package:flutter/material.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';

/// Placeholder for NIB-77 (today's meals card). Wave 2 will replace.
class TodaysMealsCard extends StatelessWidget {
  const TodaysMealsCard({
    required this.todaysMeals,
    super.key,
  });

  final List<MealPlanEntry> todaysMeals;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-77): implement today's meals card per redesign.
    return const SizedBox.shrink();
  }
}
