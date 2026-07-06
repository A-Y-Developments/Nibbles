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

  /// COPIES [recipeId] onto the currently selected day (appended to that
  /// day's list). The picked palette is reusable, so the same recipe can be
  /// added to many days and to one day multiple times — this never removes
  /// anything from the palette.
  void assignToSelectedDay(String recipeId) {
    final day = _dateOnly(state.selectedDay);
    final next = <DateTime, List<String>>{
      for (final entry in state.assignments.entries)
        entry.key: List<String>.from(entry.value),
    };
    (next[day] ??= <String>[]).add(recipeId);
    state = state.copyWith(assignments: next, errorMessage: null);
    unawaited(
      ref
          .read(analyticsProvider)
          .logMealPrepMappingAssigned(
            recipeId: recipeId,
            dayOffsetIso: _isoDate(day),
          ),
    );
  }

  /// Removes a single mapped instance from the selected day by its position
  /// [index] in that day's list (mapped cards can hold duplicates, so removal
  /// is positional, not id-based).
  void unassignFromSelectedDayAt(int index) {
    final day = _dateOnly(state.selectedDay);
    final current = state.assignments[day];
    if (current == null || index < 0 || index >= current.length) return;
    final updated = List<String>.from(current)..removeAt(index);
    final next = <DateTime, List<String>>{
      for (final entry in state.assignments.entries)
        entry.key: List<String>.from(entry.value),
    };
    if (updated.isEmpty) {
      next.remove(day);
    } else {
      next[day] = updated;
    }
    state = state.copyWith(assignments: next, errorMessage: null);
  }

  /// Creates/replaces the plan for the window, then bulk-appends every mapped
  /// meal instance into it via [MealPlanService.appendMealsToRange].
  ///
  /// Partial (or empty) mappings are allowed — Finish is enabled at any time.
  /// Returns true on success (caller pops with `true`). On failure leaves
  /// `errorMessage` set so the screen can show the P1 retry dialog.
  Future<bool> commit() async {
    state = state.copyWith(isCommitting: true, errorMessage: null);

    final babyId = await ref.read(currentBabyIdProvider.future);
    if (babyId == null) {
      state = state.copyWith(
        isCommitting: false,
        errorMessage: 'No baby profile found.',
      );
      return false;
    }

    final start = _dateOnly(state.startDate);
    final assignments = <RecipeAssignment>[];
    for (final entry in state.assignments.entries) {
      final offset = _dateOnly(entry.key).difference(start).inDays;
      for (final recipeId in entry.value) {
        assignments.add(
          RecipeAssignment(recipeId: recipeId, dayOffset: offset),
        );
      }
    }

    final service = ref.read(mealPlanServiceProvider);

    final planResult = await service.createPlan(
      babyId,
      state.startDate,
      state.endDate,
    );
    if (planResult.isFailure) {
      return _recordAndFail(
        planResult.errorOrNull?.message,
        assignments.length,
      );
    }

    final result = await service.appendMealsToRange(
      babyId: babyId,
      startDate: state.startDate,
      endDate: state.endDate,
      mealPlanId: planResult.dataOrNull!.id,
      assignments: assignments,
    );

    if (result.isFailure) {
      return _recordAndFail(result.errorOrNull?.message, assignments.length);
    }

    state = state.copyWith(isCommitting: false);
    unawaited(
      ref
          .read(analyticsProvider)
          .logMealPrepCommitted(
            recipeCount: assignments.length,
            dayCount: state.dayCount,
          ),
    );
    return true;
  }

  /// Records the non-fatal crash payload, sets the P1 `errorMessage`, and
  /// returns false so [commit] can bail out.
  Future<bool> _recordAndFail(String? message, int recipeCount) async {
    await ref.read(mealPrepCrashRecorderProvider)(
      'meal_prep_commit_failure: $message',
      StackTrace.current,
      reason: 'meal_prep_commit_failure',
      information: <String>[
        'recipe_count=$recipeCount',
        'day_count=${state.dayCount}',
      ],
    );
    state = state.copyWith(
      isCommitting: false,
      errorMessage: message ?? 'Failed to save plan.',
    );
    return false;
  }

  /// `yyyy-MM-dd` for analytics. Locale-stable, no PII.
  static String _isoDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }
}
