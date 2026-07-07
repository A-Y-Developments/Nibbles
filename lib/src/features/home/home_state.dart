import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';

part 'home_state.freezed.dart';

/// Home redesign state contract.
///
/// The controller fetches the FULL dataset once (all meals + all hydrated
/// recipes + allergen statuses/counts). Per-selected-day slices are pure
/// client-side derivations (see `HomeDayView`) so the date strip is instant.
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    Baby? baby,
    @Default(<MealPlanEntry>[]) List<MealPlanEntry> allMeals,
    @Default(<String, Recipe>{}) Map<String, Recipe> allRecipes,
    @Default(<DateTime>[]) List<DateTime> plannedDates,
    @Default(<String, AllergenStatus>{})
    Map<String, AllergenStatus> allergenStatuses,
    @Default(<String, int>{}) Map<String, int> allergenLogCounts,
    String? currentAllergenKey,
    @Default(AllergenStatus.notStarted) AllergenStatus currentAllergenStatus,
    @Default(<bool>[]) List<bool> currentAllergenReactionFlags,
  }) = _HomeState;

  const HomeState._();

  /// True once the baby has a picked meal-prep range (or legacy meals) — drives
  /// the date strip vs. the "Create First Meal" CTA. Based on [plannedDates]
  /// (the picked range) so a set-but-unfilled plan still shows the strip.
  bool get mealPrepSetUp => plannedDates.isNotEmpty;

  /// Count of allergens in [AllergenStatus.safe].
  int get safeCount =>
      allergenStatuses.values.where((s) => s == AllergenStatus.safe).length;

  /// Count of allergens in [AllergenStatus.flagged].
  int get flaggedCount =>
      allergenStatuses.values.where((s) => s == AllergenStatus.flagged).length;

  /// Count of allergens currently being introduced.
  int get inProgressCount => allergenStatuses.values
      .where((s) => s == AllergenStatus.inProgress)
      .length;

  /// Count of allergens not yet started.
  int get notStartedCount => allergenStatuses.values
      .where((s) => s == AllergenStatus.notStarted)
      .length;

  /// Number of allergens the baby has finished introducing (safe or flagged).
  /// Drives the hero allergen ring (`introducedCount`/11).
  int get introducedCount => safeCount + flaggedCount;

  /// True once every allergen has been introduced.
  bool get allAllergensDone => introducedCount >= kAllergenKeys.length;

  /// Drives the "Active Program Allergens" checklist chip.
  bool get hasActiveProgramAllergen =>
      introducedCount > 0 || inProgressCount > 0;

  /// Sub-state for the hero allergen widget.
  ///
  /// `advanceToNextAllergen` is explicit-only (never auto-fires on completion
  /// and `saveAllergenLog` never advances), so a just-finished allergen keeps
  /// `currentAllergenKey` pointing at it until the user starts the next one —
  /// that is what surfaces `finishedStartNext`.
  HomeAllergenHeroState get allergenHeroState {
    if (allAllergensDone) return HomeAllergenHeroState.allDone;
    if (currentAllergenStatus == AllergenStatus.inProgress) {
      return HomeAllergenHeroState.ongoing;
    }
    if (currentAllergenStatus == AllergenStatus.safe ||
        currentAllergenStatus == AllergenStatus.flagged) {
      return HomeAllergenHeroState.finishedStartNext;
    }
    return HomeAllergenHeroState.start;
  }
}

/// Hero allergen widget sub-states.
enum HomeAllergenHeroState {
  /// No allergen active yet — prompt to start the first introduction.
  start,

  /// The current allergen is mid-introduction (1-2 clean logs / selected).
  ongoing,

  /// The current allergen finished (safe/flagged); prompt to start the next.
  finishedStartNext,

  /// All 11 allergens introduced.
  allDone,
}
