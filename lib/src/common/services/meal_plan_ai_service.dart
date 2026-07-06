import 'package:nibbles/src/common/data/repositories/meal_plan_ai_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_ai_service.g.dart';

/// Orchestrates AI meal-plan generation: asks the edge function for recipe
/// assignments, then persists them through the existing plan write path
/// ([MealPlanService.createPlan] + [MealPlanService.appendMealsToRange]).
class MealPlanAiService {
  const MealPlanAiService(this._aiRepo, this._mealPlanService);

  final MealPlanAiRepository _aiRepo;
  final MealPlanService _mealPlanService;

  /// Generates assignments for `[startDate, endDate]` and persists them as a
  /// new active plan (replacing any existing one). Returns the created plan.
  Future<Result<MealPlan>> generateAndPersist({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> preferences,
    required String notes,
  }) async {
    final generated = await _aiRepo.generatePlan(
      babyId: babyId,
      startDate: startDate,
      endDate: endDate,
      preferences: preferences,
      notes: notes,
    );
    if (generated.isFailure) {
      return Result.failure(generated.errorOrNull!);
    }

    final planResult = await _mealPlanService.createPlan(
      babyId,
      startDate,
      endDate,
    );
    if (planResult.isFailure) {
      return Result.failure(planResult.errorOrNull!);
    }
    final plan = planResult.dataOrNull!;

    final appendResult = await _mealPlanService.appendMealsToRange(
      babyId: babyId,
      startDate: startDate,
      endDate: endDate,
      assignments: generated.dataOrNull!,
      mealPlanId: plan.id,
    );
    if (appendResult.isFailure) {
      return Result.failure(appendResult.errorOrNull!);
    }

    return Result.success(plan);
  }
}

@Riverpod(keepAlive: true)
MealPlanAiService mealPlanAiService(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  MealPlanAiServiceRef ref,
) => MealPlanAiService(
  ref.watch(mealPlanAiRepositoryProvider),
  ref.watch(mealPlanServiceProvider),
);
