import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

/// NIB-86: Redesigned Home dashboard controller (extended for NIB-77).
///
/// Parallel-fetches:
///  1. The current baby profile (NIB-65 header + greeting).
///  2. Per-allergen logs (NIB-126 status derivation + NIB-77 log counts
///     for the ongoing card "X/3 times" subhead and segment fill).
///  3. Rolling-7 meal plan entries (NIB-59), filtered to today.
///
/// After the meal-plan entries resolve, the controller hydrates each unique
/// `recipeId` into a [Recipe] map so the today's-meals card can render
/// recipe titles + allergen/nutrition chips. Recipe fetch failures are P3 —
/// the controller falls back to a partial map without throwing.
///
/// A missing baby is NOT an error — the screen renders the full empty-state
/// placeholder. Allergen or meal-plan fetch failures throw via the existing
/// pattern and surface as `AsyncValue.error`.
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeState> build(String babyId) async {
    final babyFut = ref.read(babyProfileServiceProvider).getBaby();
    final logsFut = ref.read(allergenServiceProvider).getLogs(babyId);
    final mealsFut = ref.read(mealPlanServiceProvider).getRolling7(babyId);

    final baby = await babyFut;
    final logsResult = await logsFut;
    final mealsResult = await mealsFut;

    if (baby == null) {
      // Empty-state path: no baby yet — surface a successful, empty state so
      // the screen can render the empty-state placeholder rather than an error.
      return const HomeState();
    }

    if (logsResult.isFailure) throw logsResult.errorOrNull!;
    if (mealsResult.isFailure) throw mealsResult.errorOrNull!;

    final allLogs = logsResult.dataOrNull ?? const <AllergenLog>[];
    final rolling = mealsResult.dataOrNull ?? const <MealPlanEntry>[];

    final logsByKey = <String, List<AllergenLog>>{};
    for (final log in allLogs) {
      (logsByKey[log.allergenKey] ??= <AllergenLog>[]).add(log);
    }

    final statuses = {
      for (final key in kAllergenKeys)
        key: deriveStatusForLogs(logsByKey[key] ?? const <AllergenLog>[]),
    };

    // Clean-log counts feed the ongoing card "X/3 times" + segment fill.
    // Reactions never advance the count — they flip the allergen to flagged
    // which suppresses the ongoing card entirely.
    final logCounts = {
      for (final key in kAllergenKeys)
        key: (logsByKey[key] ?? const <AllergenLog>[])
            .where((l) => !l.hadReaction)
            .length,
    };

    final today = DateTime.now();
    final todaysMeals = rolling
        .where((e) => _isSameDay(e.planDate, today))
        .toList(growable: false);

    final recipes = await _hydrateRecipes(todaysMeals);

    return HomeState(
      baby: baby,
      allergenStatuses: statuses,
      allergenLogCounts: logCounts,
      todaysMeals: todaysMeals,
      todaysRecipes: recipes,
    );
  }

  /// Resolve each unique `recipeId` referenced by [entries] to its [Recipe].
  /// Failed lookups are silently skipped (P3 — the meal row falls back to
  /// the meal-time label) so a single bad id doesn't kill the dashboard.
  Future<Map<String, Recipe>> _hydrateRecipes(
    List<MealPlanEntry> entries,
  ) async {
    if (entries.isEmpty) return const <String, Recipe>{};

    final uniqueIds = <String>{for (final e in entries) e.recipeId};
    final service = ref.read(recipeServiceProvider);

    final fetched = await Future.wait(
      uniqueIds.map(service.getRecipeById),
    );

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

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
