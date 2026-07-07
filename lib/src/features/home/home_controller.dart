import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

/// Home redesign controller. Fetches the FULL dataset once so per-day slices
/// (see `homeDayViewProvider`) are pure client-side derivations.
///
/// Parallel-fetches:
///  1. Baby profile (greeting + age for guidance).
///  2. Allergen logs (status derivation + clean counts).
///  3. Program state (the "Start Introduce" selection overlay).
///  4. The current/active allergen (hero allergen widget).
///  5. ALL meal plan entries (mealPrepSetUp, plannedDates, day slices).
///
/// After entries resolve, every unique `recipeId` is hydrated into a [Recipe]
/// map. Recipe fetch failures are P3 (skipped). A missing baby is NOT an error
/// — an empty [HomeState] is returned. Allergen-log and meal-plan fetch
/// failures throw and surface as `AsyncValue.error`. A failed current-allergen
/// or program-state read degrades gracefully (no hero key / no overlay).
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeState> build(String babyId) async {
    final babyFut = ref.read(babyProfileServiceProvider).getBaby();
    final logsFut = ref.read(allergenServiceProvider).getLogs(babyId);
    final stateFut = ref.read(allergenServiceProvider).getProgramState(babyId);
    final mealsFut = ref.read(mealPlanServiceProvider).getAllEntries(babyId);
    final planFut = ref.read(mealPlanServiceProvider).getActivePlan(babyId);

    final baby = await babyFut;
    final logsResult = await logsFut;
    final stateResult = await stateFut;
    final mealsResult = await mealsFut;
    final planResult = await planFut;

    if (baby == null) return const HomeState();

    if (logsResult.isFailure) throw logsResult.errorOrNull!;
    if (mealsResult.isFailure) throw mealsResult.errorOrNull!;

    final allLogs = logsResult.dataOrNull ?? const <AllergenLog>[];
    final allMeals = mealsResult.dataOrNull ?? const <MealPlanEntry>[];

    final logsByKey = <String, List<AllergenLog>>{};
    for (final log in allLogs) {
      (logsByKey[log.allergenKey] ??= <AllergenLog>[]).add(log);
    }

    final statuses = deriveStatusesWithSelection(
      logsByKey: logsByKey,
      selectedAllergenKey: stateResult.dataOrNull?.selectedAllergenKey,
    );

    final logCounts = {
      for (final key in kAllergenKeys)
        key: (logsByKey[key] ?? const <AllergenLog>[])
            .where((l) => !l.hadReaction)
            .length,
    };

    final inProgressKey = kAllergenKeys.firstWhere(
      (key) => statuses[key] == AllergenStatus.inProgress,
      orElse: () => '',
    );
    final selectedKey = stateResult.dataOrNull?.selectedAllergenKey;
    final mostRecentLoggedKey = allLogs.isEmpty
        ? null
        : ([...allLogs]..sort((a, b) {
                final byDate = a.logDate.compareTo(b.logDate);
                return byDate != 0
                    ? byDate
                    : a.createdAt.compareTo(b.createdAt);
              }))
              .last
              .allergenKey;
    // Same priority as the tracker's _displayAllergen (selected → inProgress →
    // most-recent-log). The legacy program current_allergen_key is deliberately
    // excluded — "Start Introduce" never advances it, so it surfaces a stale
    // allergen and makes Home disagree with the tracker.
    final currentKey = (selectedKey != null && selectedKey.isNotEmpty)
        ? selectedKey
        : inProgressKey.isNotEmpty
        ? inProgressKey
        : mostRecentLoggedKey;
    final currentStatus = currentKey == null
        ? AllergenStatus.notStarted
        : statuses[currentKey] ?? AllergenStatus.notStarted;
    final currentReactionFlags = currentKey == null
        ? const <bool>[]
        : (() {
            final logs = [...?logsByKey[currentKey]]
              ..sort((a, b) {
                final byDate = a.logDate.compareTo(b.logDate);
                return byDate != 0
                    ? byDate
                    : a.createdAt.compareTo(b.createdAt);
              });
            return logs.map((l) => l.hadReaction).toList(growable: false);
          })();

    final plannedDates = _plannedDates(planResult.dataOrNull, allMeals);
    final recipes = await _hydrateRecipes(allMeals);

    return HomeState(
      baby: baby,
      allMeals: allMeals,
      allRecipes: recipes,
      plannedDates: plannedDates,
      allergenStatuses: statuses,
      allergenLogCounts: logCounts,
      currentAllergenKey: currentKey,
      currentAllergenStatus: currentStatus,
      currentAllergenReactionFlags: currentReactionFlags,
    );
  }

  /// The date strip's day list — the full contiguous range the user *picked*
  /// in meal prep, not just the days that carry a meal. When an active [plan]
  /// exists the range is `plan.startDate..plan.endDate` (a picked 8–15 range
  /// shows all 8 days even if only 8–11 are filled); the end is extended to
  /// cover any stray entry landing past it. With no plan (legacy entries), it
  /// falls back to the min..max of days that have meals. Empty ⇔ meal prep is
  /// not set up.
  List<DateTime> _plannedDates(MealPlan? plan, List<MealPlanEntry> entries) {
    final mealDays = [for (final e in entries) _dateOnly(e.planDate)];

    final DateTime start;
    var end = DateTime(0);
    if (plan != null) {
      start = _dateOnly(plan.startDate);
      end = _dateOnly(plan.endDate);
      for (final d in mealDays) {
        if (d.isAfter(end)) end = d;
      }
    } else {
      if (mealDays.isEmpty) return const <DateTime>[];
      start = mealDays.reduce((a, b) => a.isBefore(b) ? a : b);
      end = mealDays.reduce((a, b) => a.isAfter(b) ? a : b);
    }

    final out = <DateTime>[];
    var day = start;
    while (!day.isAfter(end)) {
      out.add(day);
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return out;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Resolve each unique `recipeId` referenced by [entries] to its [Recipe].
  /// Failed lookups are silently skipped (P3).
  Future<Map<String, Recipe>> _hydrateRecipes(
    List<MealPlanEntry> entries,
  ) async {
    if (entries.isEmpty) return const <String, Recipe>{};

    final uniqueIds = <String>{for (final e in entries) e.recipeId};
    final service = ref.read(recipeServiceProvider);

    final fetched = await Future.wait(uniqueIds.map(service.getRecipeById));

    final out = <String, Recipe>{};
    var i = 0;
    for (final id in uniqueIds) {
      final result = fetched[i++];
      if (result.isSuccess) {
        final recipe = result.dataOrNull;
        if (recipe != null) out[id] = recipe;
      }
    }
    return out;
  }
}
