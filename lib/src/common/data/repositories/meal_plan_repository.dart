import 'package:flutter/material.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meal_plan_repository.g.dart';

abstract interface class MealPlanRepository {
  /// MEAL-01: Fetch all meal_plan_entries for baby within
  /// [weekStart]..[weekEnd].
  Future<Result<List<MealPlanEntry>>> getWeekMeals(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  );

  /// MEAL-02: Insert a new meal entry for [planDate].
  /// Multiple entries per day are allowed.
  Future<Result<MealPlanEntry>> assignRecipe(
    String babyId,
    String recipeId,
    DateTime planDate,
    TimeOfDay? mealTime,
  );

  /// MEAL-03: Delete all entries for baby within [weekStart]..[weekEnd].
  Future<Result<void>> clearWeek(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  );

  /// MEAL-04: Delete a single meal plan entry by ID.
  Future<Result<void>> removeEntry(String entryId);

  /// MEAL-05: Delete all entries for baby on [date].
  Future<Result<void>> clearDay(String babyId, DateTime date);
}

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<Result<List<MealPlanEntry>>> getWeekMeals(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    try {
      final data = await _supabase
          .from('meal_plan_entries')
          .select()
          .eq('baby_id', babyId)
          .gte('plan_date', _formatDate(weekStart))
          .lte('plan_date', _formatDate(weekEnd))
          .order('plan_date');

      return Result.success(
        (data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(_entryFromRow)
            .toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<MealPlanEntry>> assignRecipe(
    String babyId,
    String recipeId,
    DateTime planDate,
    TimeOfDay? mealTime,
  ) async {
    try {
      final payload = <String, dynamic>{
        'baby_id': babyId,
        'recipe_id': recipeId,
        'plan_date': _formatDate(planDate),
        if (mealTime != null) 'meal_time': _formatTime(mealTime),
      };

      final data = await _supabase
          .from('meal_plan_entries')
          .insert(payload)
          .select()
          .single();

      return Result.success(_entryFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> clearWeek(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    try {
      await _supabase
          .from('meal_plan_entries')
          .delete()
          .eq('baby_id', babyId)
          .gte('plan_date', _formatDate(weekStart))
          .lte('plan_date', _formatDate(weekEnd));

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> removeEntry(String entryId) async {
    try {
      await _supabase.from('meal_plan_entries').delete().eq('id', entryId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> clearDay(String babyId, DateTime date) async {
    try {
      await _supabase
          .from('meal_plan_entries')
          .delete()
          .eq('baby_id', babyId)
          .eq('plan_date', _formatDate(date));
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  // ---------------------------------------------------------------------------
  // Row mapper
  // ---------------------------------------------------------------------------

  MealPlanEntry _entryFromRow(Map<String, dynamic> row) {
    final rawTime = row['meal_time'] as String?;
    // Supabase returns time as "HH:mm:ss" — keep only "HH:mm".
    final mealTime = (rawTime != null && rawTime.length >= 5)
        ? rawTime.substring(0, 5)
        : rawTime;

    return MealPlanEntry(
      id: row['id'] as String,
      babyId: row['baby_id'] as String,
      recipeId: row['recipe_id'] as String,
      planDate: DateTime.parse(row['plan_date'] as String),
      mealTime: mealTime,
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
MealPlanRepository mealPlanRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  MealPlanRepositoryRef ref,
) => MealPlanRepositoryImpl();
