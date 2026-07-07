import 'package:flutter/foundation.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
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

  /// Injectable clock so the window derivation is deterministic under test.
  @visibleForTesting
  static DateTime Function() nowBuilder = DateTime.now;

  /// Normalize an expand-map key to a UTC date-only [DateTime] so keys match
  /// regardless of the input's local TZ or sub-day precision.
  static DateTime _expandedKey(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day);

  @override
  Future<MealPlanState> build(String babyId) async {
    _babyId = babyId;

    final mealPlanService = ref.read(mealPlanServiceProvider);
    final recipeService = ref.read(recipeServiceProvider);
    final babyService = ref.read(babyProfileServiceProvider);
    final allergenService = ref.read(allergenServiceProvider);

    // Parallel fetch: baby + active plan + flagged keys + program state.
    final results = await Future.wait<Object?>([
      babyService.getBaby(),
      mealPlanService.getActivePlan(babyId),
      recipeService.getFlaggedAllergenKeys(babyId),
      allergenService.getProgramState(babyId),
    ]);

    final baby = results[0] as Baby?;

    final planResult = results[1]! as Result<MealPlan?>;
    if (planResult.isFailure) {
      throw StateError(planResult.errorOrNull!.message);
    }
    final plan = planResult.dataOrNull;

    final flaggedResult = results[2]! as Result<Set<String>>;
    final flaggedKeys = flaggedResult.dataOrNull ?? <String>{};

    final programResult = results[3]! as Result<AllergenProgramState>;
    final (programState, currentBoardItem) = await _resolveProgram(
      babyId,
      programResult,
      allergenService,
    );

    // No active plan → empty state. windowStart/windowEnd are placeholders
    // (today) and unused by the empty-state render path.
    if (plan == null) {
      final today = _dateOnly(nowBuilder());
      return MealPlanState(
        windowStart: today,
        windowEnd: today,
        entries: const [],
        baby: baby,
        flaggedAllergenKeys: flaggedKeys,
        currentAllergenBoardItem: currentBoardItem,
        programState: programState,
      );
    }

    final windowStart = _dateOnly(plan.startDate);
    final planEnd = _dateOnly(plan.endDate);

    // Fetch by plan id (not date range) so meals added on a "+ Add Date" day
    // beyond the plan's end still load.
    final entriesResult = await mealPlanService.getEntriesForPlan(plan.id);
    if (entriesResult.isFailure) {
      throw StateError(entriesResult.errorOrNull!.message);
    }
    final entries = entriesResult.dataOrNull!;

    // Window end is the plan's end, extended to cover any entry that lands
    // past it (defensive: entries are normally inside the plan range).
    var windowEnd = planEnd;
    for (final entry in entries) {
      final p = _dateOnly(entry.planDate);
      if (p.isAfter(windowEnd)) windowEnd = p;
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
      plan: plan,
      baby: baby,
      recipes: recipeMap,
      flaggedAllergenKeys: flaggedKeys,
      currentAllergenBoardItem: currentBoardItem,
      programState: programState,
    );
  }

  Future<(AllergenProgramState?, AllergenBoardItem?)> _resolveProgram(
    String babyId,
    Result<AllergenProgramState> programResult,
    AllergenService allergenService,
  ) async {
    if (!programResult.isSuccess) return (null, null);
    final ps = programResult.dataOrNull;
    if (ps == null || ps.status == AllergenProgramStatus.completed) {
      return (ps, null);
    }
    final boardResult = await allergenService.getAllergenBoardSummary(babyId);
    if (!boardResult.isSuccess) return (ps, null);
    final item = boardResult.dataOrNull!
        .where((AllergenBoardItem i) => i.allergen.key == ps.currentAllergenKey)
        .firstOrNull;
    return (ps, item);
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

  /// APPEND-bulk add for [startDate]..[endDate]. Calls
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
          mealPlanId: state.valueOrNull?.plan?.id,
        );
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Explicit clear for an arbitrary date range. Returns false on failure —
  /// caller should surface a P2 toast.
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

  /// Creates a plan for `[start, end]`, replacing any existing plan.
  /// Returns false on failure — caller should show P2 toast.
  Future<bool> createPlan(DateTime start, DateTime end) async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .createPlan(_babyId, start, end);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }

  /// Deletes the active plan (cascades its entries), returning the planner to
  /// the empty state. Returns false on failure — caller shows a P2 toast.
  Future<bool> deleteActivePlan() async {
    final plan = state.valueOrNull?.plan;
    if (plan == null) return false;
    final result = await ref.read(mealPlanServiceProvider).deletePlan(plan.id);
    if (result.isFailure) return false;
    ref.invalidateSelf();
    return true;
  }
}
