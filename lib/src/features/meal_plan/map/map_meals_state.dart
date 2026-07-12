import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

part 'map_meals_state.freezed.dart';

/// Route payload for the Map Meals Plan screen (NIB-95).
///
/// Handed in via `GoRouterState.extra` from NIB-87's Browse Meal sheet.
/// Carried as a freezed value so the controller family key has stable
/// equality (lists/dates are deep-compared rather than identity-compared).
@freezed
class MapMealsArgs with _$MapMealsArgs {
  const factory MapMealsArgs({
    required List<Recipe> pickedRecipes,
    required DateTime startDate,
    required DateTime endDate,
  }) = _MapMealsArgs;
}

/// NIB-95 Map Meals Plan screen state.
///
/// `assignments` is a MULTIMAP `day(date-only) -> ordered [recipeId]`. The
/// picked-recipe palette is REUSABLE: dragging or tapping a picked recipe
/// COPIES it onto [selectedDay] (appended to that day's list), so the same
/// recipe can live on many days and a day can hold multiple copies. Removing
/// a mapped card removes a single instance by its position in the day's list.
@freezed
class MapMealsState with _$MapMealsState {
  const factory MapMealsState({
    required List<Recipe> pickedRecipes,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime selectedDay,
    @Default(<DateTime, List<String>>{})
    Map<DateTime, List<String>> assignments,
    @Default(false) bool isCommitting,
    String? errorMessage,
  }) = _MapMealsState;

  const MapMealsState._();

  /// Total number of assigned meal instances across every day — the "X" in
  /// "X of M slots filled".
  int get filledCount =>
      assignments.values.fold(0, (sum, ids) => sum + ids.length);

  /// Inclusive day count of the `[startDate, endDate]` window.
  int get dayCount =>
      _dateOnly(endDate).difference(_dateOnly(startDate)).inDays + 1;

  /// Total slot target across the whole window — the "M" in
  /// "X of M slots filled" — i.e. `dayCount * mealsPerDay`.
  int totalSlots(int mealsPerDay) => dayCount * mealsPerDay;

  /// Recipe ids assigned to [selectedDay], in insertion order (duplicates
  /// preserved). Positional — index is the removal key.
  List<String> recipeIdsForSelectedDay() => List<String>.from(
    assignments[_dateOnly(selectedDay)] ?? const <String>[],
  );

  /// Recipes assigned to [selectedDay], expanded from
  /// [recipeIdsForSelectedDay] preserving order and duplicates.
  List<Recipe> recipesForSelectedDay() {
    final byId = {for (final r in pickedRecipes) r.id: r};
    return [
      for (final id in recipeIdsForSelectedDay())
        if (byId[id] != null) byId[id]!,
    ];
  }

  /// Number of meals assigned to an arbitrary [day].
  int assignedCountForDay(DateTime day) =>
      assignments[_dateOnly(day)]?.length ?? 0;

  /// Number of meals assigned to [selectedDay] — the "k" in "Meals for
  /// {Weekday} (k/N)".
  int assignedCountForSelectedDay() => assignedCountForDay(selectedDay);

  /// Days whose assigned count meets or exceeds the per-day target — drives
  /// the day-chip ✓ / "full" variant (frame 971:8441). A [mealsPerDay] of 0
  /// never marks a day full.
  Set<DateTime> fullDays(int mealsPerDay) {
    if (mealsPerDay <= 0) return const <DateTime>{};
    return {
      for (final entry in assignments.entries)
        if (entry.value.length >= mealsPerDay) entry.key,
    };
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
