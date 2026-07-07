import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/meal_plan/sheets/browse_meal_sheet.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// `yyyy-MM-dd` for analytics. Locale-stable, no PII.
String _isoDate(DateTime dt) {
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '${dt.year}-$m-$d';
}

/// Opens the Browse Meal sheet scoped to a single [day] and appends the picks
/// straight onto that day — no map / confirmation step, because the target
/// date is already fixed. Shared by the Meal Plan per-day "Add" pill and the
/// Home today's-meals card. Surfaces a P2 toast on failure. Returns the number
/// of recipes added (0 if cancelled or on failure).
Future<int> addMealsForDay(
  BuildContext context,
  WidgetRef ref, {
  required String babyId,
  required DateTime day,
}) async {
  final picked = await showBrowseMealSheet(
    context,
    babyId: babyId,
    startDate: day,
    endDate: day,
  );
  if (picked == null || picked.isEmpty) return 0;
  if (!context.mounted) return 0;

  final notifier = ref.read(mealPlanControllerProvider(babyId).notifier);
  // Home never watches the meal-plan controller, so ensure it has resolved —
  // otherwise the active plan id won't be attached to the new entries and they
  // would go missing from the plan-scoped Meal Plan screen.
  await ref.read(mealPlanControllerProvider(babyId).future);

  final assignments = [
    for (final r in picked) RecipeAssignment(recipeId: r.id, dayOffset: 0),
  ];
  final ok = await notifier.appendBulkPrep(
    startDate: day,
    endDate: day,
    assignments: assignments,
  );
  if (!ok) {
    if (context.mounted) {
      AppToast.error(context, "Couldn't add to meal plan. Try again.");
    }
    return 0;
  }

  final analytics = ref.read(analyticsProvider);
  final iso = _isoDate(day);
  for (final r in picked) {
    unawaited(
      analytics.logMealPlanRecipeAssigned(recipeId: r.id, dayOffsetIso: iso),
    );
  }
  return picked.length;
}
