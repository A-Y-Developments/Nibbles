import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_controller.g.dart';

@riverpod
class MealPlanController extends _$MealPlanController {
  late String _babyId;

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// NIB-143: most-recent Monday on or before [dt] (local-date floor).
  /// `DateTime.weekday` is 1 (Mon) through 7 (Sun), so subtracting
  /// `weekday - 1` lands on Monday.
  static DateTime _mondayOnOrBefore(DateTime dt) {
    final dateOnly = _dateOnly(dt);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }

  /// Normalize an expand-map key to a UTC date-only [DateTime] so keys match
  /// regardless of the input's local TZ or sub-day precision.
  static DateTime _expandedKey(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day);

  @override
  Future<MealPlanState> build(String babyId) async {
    _babyId = babyId;

    // NIB-143: anchor the 7-day window on the most-recent Monday
    // on/before today so the planner always renders a Mon-Sun week.
    final windowStart = _mondayOnOrBefore(DateTime.now());
    final windowEnd = windowStart.add(const Duration(days: 6));

    final mealPlanService = ref.read(mealPlanServiceProvider);
    final recipeService = ref.read(recipeServiceProvider);
    final babyService = ref.read(babyProfileServiceProvider);
    final allergenService = ref.read(allergenServiceProvider);

    // Parallel fetch: baby + rolling-7 entries + flagged keys + program state.
    final results = await Future.wait<Object?>([
      babyService.getBaby(),
      mealPlanService.getRolling7(babyId, today: windowStart),
      recipeService.getFlaggedAllergenKeys(babyId),
      allergenService.getProgramState(babyId),
    ]);

    final baby = results[0] as Baby?;

    final entriesResult = results[1]! as Result<List<MealPlanEntry>>;
    if (entriesResult.isFailure) {
      throw StateError(entriesResult.errorOrNull!.message);
    }
    final entries = entriesResult.dataOrNull!;

    final flaggedResult = results[2]! as Result<Set<String>>;
    final flaggedKeys = flaggedResult.dataOrNull ?? <String>{};

    final programResult = results[3]! as Result<AllergenProgramState>;
    AllergenProgramState? programState;
    AllergenBoardItem? currentBoardItem;
    if (programResult.isSuccess) {
      final ps = programResult.dataOrNull;
      programState = ps;
      if (ps != null && ps.status != AllergenProgramStatus.completed) {
        final boardResult = await allergenService.getAllergenBoardSummary(
          babyId,
        );
        if (boardResult.isSuccess) {
          currentBoardItem = boardResult.dataOrNull!
              .where(
                (AllergenBoardItem item) =>
                    item.allergen.key == ps.currentAllergenKey,
              )
              .firstOrNull;
        }
      }
    }

    // Hydrate recipe lookup for every entry (best-effort, deduplicated).
    final recipeMap = <String, Recipe>{};
    for (final entry in entries) {
      if (recipeMap.containsKey(entry.recipeId)) continue;
      final r = await recipeService.getRecipeById(entry.recipeId);
      if (r.isSuccess) recipeMap[entry.recipeId] = r.dataOrNull!;
    }

    return MealPlanState(
      windowStart: windowStart,
      windowEnd: windowEnd,
      entries: entries,
      baby: baby,
      recipes: recipeMap,
      flaggedAllergenKeys: flaggedKeys,
      currentAllergenBoardItem: currentBoardItem,
      programState: programState,
    );
  }

  /// Flip the accordion expand state for [day]. Key is normalized to UTC
  /// date-only so lookups are stable.
  void toggleExpanded(DateTime day) {
    final current = state.valueOrNull;
    if (current == null) return;
    final key = _expandedKey(day);
    final next = Map<DateTime, bool>.from(current.expanded);
    next[key] = !(next[key] ?? false);
    state = AsyncData(current.copyWith(expanded: next));
  }

  /// NIB-59: APPEND-bulk add for [startDate]..[endDate]. Calls
  /// [MealPlanService.appendMealsToRange] then invalidates self to refetch.
  /// Returns false on failure — caller should surface a P2 toast.
  Future<bool> appendBulkPrep({
    required DateTime startDate,
    required DateTime endDate,
    required List<RecipeAssignment> assignments,
  }) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .appendMealsToRange(
          babyId: _babyId,
          startDate: startDate,
          endDate: endDate,
          assignments: assignments,
        );
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// NIB-59: explicit clear for an arbitrary date range. Returns false on
  /// failure — caller should surface a P2 toast.
  Future<bool> clearRange(DateTime startDate, DateTime endDate) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .clearRange(_babyId, startDate, endDate);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Returns false on failure — caller should show P2 toast.
  Future<bool> assignRecipe(DateTime date, String recipeId) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .assignRecipe(_babyId, recipeId, date);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Returns false on failure — caller should show P2 toast.
  Future<bool> removeEntry(String entryId) async {
    final result = await ref.read(mealPlanServiceProvider).removeEntry(entryId);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Returns false on failure — caller should show P2 toast.
  Future<bool> clearDay(DateTime date) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .clearDay(_babyId, date);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }
}
