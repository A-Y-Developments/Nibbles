import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_meals_controller.g.dart';

/// Injectable Crashlytics recorder so unit tests can assert the non-fatal
/// payload without touching real Firebase. Mirrors the
/// `AllergenCrashRecorderFn` pattern from NIB-125.
typedef MealPrepCrashRecorderFn =
    Future<void> Function(
      Object error,
      StackTrace stack, {
      String? reason,
      List<String>? information,
    });

Future<void> _defaultMealPrepCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
  List<String>? information,
}) {
  return FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: reason,
    information: information ?? const <Object>[],
    // Non-fatal: meal-prep commit failures still surface a P1 retry dialog.
    // ignore: avoid_redundant_argument_values
    fatal: false,
  );
}

/// Provider for the [MealPrepCrashRecorderFn]. Tests override this to capture
/// the recorded payload without hitting Crashlytics.
@Riverpod(keepAlive: true)
MealPrepCrashRecorderFn mealPrepCrashRecorder(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  MealPrepCrashRecorderRef ref,
) => _defaultMealPrepCrashRecorder;

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
    unawaited(
      ref
          .read(analyticsProvider)
          .logMealPrepMappingAssigned(
            recipeId: recipeId,
            dayOffsetIso: _isoDate(state.selectedDay),
          ),
    );
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
      final dayCount = state.endDate.difference(state.startDate).inDays + 1;
      await ref.read(mealPrepCrashRecorderProvider)(
        'meal_prep_commit_failure: ${result.errorOrNull?.message}',
        StackTrace.current,
        reason: 'meal_prep_commit_failure',
        information: <String>[
          'recipe_count=${assignments.length}',
          'day_count=$dayCount',
        ],
      );
      state = state.copyWith(
        isCommitting: false,
        errorMessage: result.errorOrNull?.message ?? 'Failed to save plan.',
      );
      return false;
    }

    state = state.copyWith(isCommitting: false);
    unawaited(
      ref
          .read(analyticsProvider)
          .logMealPrepCommitted(
            recipeCount: assignments.length,
            dayCount: state.endDate.difference(state.startDate).inDays + 1,
          ),
    );
    return true;
  }

  /// `yyyy-MM-dd` for analytics. Locale-stable, no PII.
  static String _isoDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }
}
