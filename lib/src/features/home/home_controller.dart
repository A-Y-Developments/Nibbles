import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
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
    final currentFut = ref
        .read(allergenServiceProvider)
        .getCurrentAllergen(babyId);
    final mealsFut = ref.read(mealPlanServiceProvider).getAllEntries(babyId);

    final baby = await babyFut;
    final logsResult = await logsFut;
    final stateResult = await stateFut;
    final currentResult = await currentFut;
    final mealsResult = await mealsFut;

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

    final currentKey = currentResult.dataOrNull?.key;
    final currentStatus = currentKey == null
        ? AllergenStatus.notStarted
        : statuses[currentKey] ?? AllergenStatus.notStarted;
    final currentClean = currentKey == null ? 0 : logCounts[currentKey] ?? 0;

    final plannedDates = _plannedDates(allMeals);
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
      currentAllergenCleanCount: currentClean,
    );
  }

  /// Sorted, unique date-only days that carry at least one meal.
  List<DateTime> _plannedDates(List<MealPlanEntry> entries) {
    final days = <DateTime>{
      for (final e in entries)
        DateTime(e.planDate.year, e.planDate.month, e.planDate.day),
    };
    return days.toList()..sort();
  }

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
