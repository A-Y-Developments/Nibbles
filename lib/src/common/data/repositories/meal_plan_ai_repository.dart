import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meal_plan_ai_repository.g.dart';

/// Client for the `generate-meal-plan` Supabase Edge Function. The function
/// owns the OpenAI call, allergen/age validation, and recipe-pool checks
/// server-side; this repo only invokes it and parses the response into
/// [RecipeAssignment]s ready for the existing meal-plan write path.
// ignore: one_member_abstracts
abstract interface class MealPlanAiRepository {
  Future<Result<List<RecipeAssignment>>> generatePlan({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> preferences,
    required String notes,
  });
}

class MealPlanAiRepositoryImpl implements MealPlanAiRepository {
  MealPlanAiRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<Result<List<RecipeAssignment>>> generatePlan({
    required String babyId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> preferences,
    required String notes,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-meal-plan',
        body: <String, dynamic>{
          'babyId': babyId,
          'startDate': _formatDate(startDate),
          'endDate': _formatDate(endDate),
          'preferences': preferences,
          'notes': notes,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return _invalid();

      final rawAssignments = data['assignments'];
      if (rawAssignments is! List) return _invalid();

      final assignments = <RecipeAssignment>[];
      for (final item in rawAssignments) {
        if (item is! Map) return _invalid();
        final recipeId = item['recipeId'];
        final dayOffset = item['dayOffset'];
        if (recipeId is! String || dayOffset is! int) return _invalid();
        assignments.add(
          RecipeAssignment(recipeId: recipeId, dayOffset: dayOffset),
        );
      }

      return Result.success(assignments);
    } on FunctionException catch (e) {
      return Result.failure(ServerException(_functionMessage(e)));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  Result<List<RecipeAssignment>> _invalid() =>
      const Result.failure(UnknownException());

  String _functionMessage(FunctionException e) {
    final details = e.details;
    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }
    return e.reasonPhrase ?? 'Failed to generate meal plan.';
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

@Riverpod(keepAlive: true)
MealPlanAiRepository mealPlanAiRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  MealPlanAiRepositoryRef ref,
) => MealPlanAiRepositoryImpl();
