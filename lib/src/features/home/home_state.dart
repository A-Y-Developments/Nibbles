import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'home_state.freezed.dart';

/// Reshaped per NIB-86 (NIB-120 Home redesign), extended by NIB-77 remediation:
///
/// - `baby`: nullable so empty-state can render without throwing.
/// - `allergenStatuses`: derived per-allergen statuses (NIB-126). Always
///   contains all 9 canonical keys.
/// - `allergenLogCounts`: clean (no-reaction) log counts per allergen key.
///   Drives the "X/3 times" subhead + segment fill on the ongoing card.
/// - `todaysMeals`: rolling-7 entries (NIB-59) filtered to today.
/// - `todaysRecipes`: recipe-id → [Recipe] hydration for today's meals so
///   the meal rows can render the recipe title + allergen/nutrition chips.
///
/// Legacy fields (`programState`, `recommendations`, `todayRecipes`,
/// `currentAllergenBoardItem`, `isGeneralRecommendations`,
/// `generalRecommendations`, `flaggedAllergenKeys`) are dropped — no remaining
/// consumers exist after the `home_screen` rewrite.
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    Baby? baby,
    @Default(<String, AllergenStatus>{})
    Map<String, AllergenStatus> allergenStatuses,
    @Default(<String, int>{}) Map<String, int> allergenLogCounts,
    @Default(<MealPlanEntry>[]) List<MealPlanEntry> todaysMeals,
    @Default(<String, Recipe>{}) Map<String, Recipe> todaysRecipes,
  }) = _HomeState;

  const HomeState._();

  /// Count of allergens in [AllergenStatus.safe].
  int get safeCount =>
      allergenStatuses.values.where((s) => s == AllergenStatus.safe).length;

  /// Count of allergens in [AllergenStatus.flagged].
  int get flaggedCount =>
      allergenStatuses.values.where((s) => s == AllergenStatus.flagged).length;

  /// Count of allergens in [AllergenStatus.notStarted].
  int get notStartedCount => allergenStatuses.values
      .where((s) => s == AllergenStatus.notStarted)
      .length;

  /// Count of allergens currently being introduced.
  int get inProgressCount => allergenStatuses.values
      .where((s) => s == AllergenStatus.inProgress)
      .length;

  /// Today's meal count.
  int get todayMealCount => todaysMeals.length;

  /// True when the baby exists but has zero allergen logs (everything still
  /// [AllergenStatus.notStarted]) and no meals planned. Drives the full
  /// empty-state placeholder.
  bool get hasNoActivity =>
      todayMealCount == 0 &&
      safeCount == 0 &&
      flaggedCount == 0 &&
      inProgressCount == 0;
}
