import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

part 'home_state.freezed.dart';

/// Reshaped per NIB-86 (NIB-120 Home redesign), extended by NIB-77 remediation
/// and NIB-96 empty-state variant routing:
///
/// - `baby`: nullable so empty-state can render without throwing.
/// - `allergenStatuses`: derived per-allergen statuses (NIB-126). Always
///   contains all 9 canonical keys.
/// - `allergenLogCounts`: clean (no-reaction) log counts per allergen key
///   (NIB-77). Drives the "X/3 times" subhead + segment fill on the ongoing
///   card.
/// - `todaysMeals`: rolling-7 entries (NIB-59) filtered to today.
/// - `todaysRecipes`: recipe-id → [Recipe] hydration for today's meals so
///   the meal rows can render the recipe title + allergen/nutrition chips
///   (NIB-77).
/// - `hasAnyPlannedMeal`: NIB-96 discriminator — true when the rolling-7
///   window contains at least one entry (anywhere in the next 7 days).
///   Used to distinguish "ready to start" (no meals planned at all) from
///   "no meals mapped today" (slots scheduled but today is empty).
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
    @Default(false) bool hasAnyPlannedMeal,
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

  /// NIB-96 Home dashboard variant selector. Maps the user's progression
  /// state to one of four Figma frames: ready-to-start empty, ready-to-start
  /// with ongoing, no-meals-mapped, and populated.
  HomeVariant get variant {
    if (todayMealCount > 0) return HomeVariant.populated;
    if (hasAnyPlannedMeal) return HomeVariant.noMealsToday;
    if (inProgressCount > 0) return HomeVariant.readyToStartWithOngoing;
    return HomeVariant.readyToStartEmpty;
  }
}

/// NIB-96 — the four Figma-canonical Home variants.
enum HomeVariant {
  /// Pristine post-onboarding: no allergens started, no meals planned.
  /// Figma 1266:12135.
  readyToStartEmpty,

  /// Allergen program kicked off but no meals planned yet.
  /// Figma 1242:10152.
  readyToStartWithOngoing,

  /// Meal slots scheduled in the rolling-7 window but today's slot empty.
  /// Figma 1266:12400.
  noMealsToday,

  /// Today has at least one mapped meal.
  /// Figma 1242:10567.
  populated,
}
