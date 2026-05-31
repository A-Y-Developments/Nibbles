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
/// `assignments` is `recipeId -> DateTime` (one slot per recipe). The user
/// taps a picked recipe row to assign it to [selectedDay]; tapping again
/// after picking a different chip re-assigns it.
@freezed
class MapMealsState with _$MapMealsState {
  const factory MapMealsState({
    required List<Recipe> pickedRecipes,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime selectedDay,
    @Default(<String, DateTime>{}) Map<String, DateTime> assignments,
    @Default(false) bool isCommitting,
    String? errorMessage,
  }) = _MapMealsState;

  const MapMealsState._();

  /// Number of slots filled (length of [assignments]) — for the AppBar chip.
  int get filledCount => assignments.length;

  /// Total picked recipes — for the AppBar chip's denominator.
  int get totalCount => pickedRecipes.length;

  /// Recipes assigned to [selectedDay].
  List<Recipe> recipesForSelectedDay() {
    final key = _dateKey(selectedDay);
    final ids = assignments.entries
        .where((e) => _dateKey(e.value) == key)
        .map((e) => e.key)
        .toSet();
    return pickedRecipes.where((r) => ids.contains(r.id)).toList();
  }

  /// Set of days (date-only) that have at least one assignment — drives
  /// the day-chip "Filled" variant (frame 971:8441).
  Set<DateTime> filledDays() {
    return assignments.values
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  static String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
