import 'package:flutter/material.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meal_plan_repository.g.dart';

/// Insert payload for [MealPlanRepository.appendBulk] — one row per recipe
/// assignment. Pure INSERT (no upsert / no onConflict) so duplicates are
/// allowed; this is what makes bulk-add APPEND-semantic per NIB-120.
class MealPlanEntryInsert {
  const MealPlanEntryInsert({
    required this.babyId,
    required this.recipeId,
    required this.planDate,
    this.mealTime,
    this.mealPlanId,
  });

  final String babyId;
  final String recipeId;
  final DateTime planDate;
  final TimeOfDay? mealTime;

  /// Optional FK to the persisted `meal_plans` row this entry belongs to.
  /// Null for legacy rolling-7 entries with no owning plan.
  final String? mealPlanId;
}

abstract interface class MealPlanRepository {
  /// MEAL-01: Fetch all meal_plan_entries for baby within
  /// [weekStart]..[weekEnd].
  Future<Result<List<MealPlanEntry>>> getWeekMeals(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  );

  /// NIB-59: Range query — fetch entries for baby within
  /// [startDate]..[endDate] inclusive. Used by `getRolling7` in the service.
  Future<Result<List<MealPlanEntry>>> getEntriesInRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Fetch every meal_plan_entry for [babyId], ordered by plan_date.
  /// Backs the Home redesign's full dataset (mealPrepSetUp, plannedDates).
  Future<Result<List<MealPlanEntry>>> getAllEntries(String babyId);

  /// Fetch every entry linked to [planId] regardless of `plan_date`, ordered by
  /// date — so meals added on a "+ Add Date" day past the plan's end still
  /// render after a refetch.
  Future<Result<List<MealPlanEntry>>> getEntriesForPlan(String planId);

  /// MEAL-02: Insert a new meal entry for [planDate].
  /// Multiple entries per day are allowed.
  Future<Result<MealPlanEntry>> assignRecipe(
    String babyId,
    String recipeId,
    DateTime planDate,
    TimeOfDay? mealTime,
  );

  /// NIB-59: Bulk INSERT (APPEND, not upsert) — duplicates allowed.
  Future<Result<List<MealPlanEntry>>> appendBulk(
    List<MealPlanEntryInsert> entries,
  );

  /// MEAL-03: Delete all entries for baby within [weekStart]..[weekEnd].
  Future<Result<void>> clearWeek(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  );

  /// NIB-59: Delete all entries for baby within [startDate]..[endDate].
  Future<Result<void>> deleteRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  );

  /// MEAL-04: Delete a single meal plan entry by ID.
  Future<Result<void>> removeEntry(String entryId);

  /// MEAL-05: Delete all entries for baby on [date].
  Future<Result<void>> clearDay(String babyId, DateTime date);

  /// Returns the baby's current persisted plan (most recent by `created_at`),
  /// or `null` if the baby has no plan.
  Future<Result<MealPlan?>> getActivePlan(String babyId);

  /// Creates a plan for `[start, end]`, enforcing a single active plan per
  /// baby: any existing plans (and their cascaded entries) are deleted first.
  Future<Result<MealPlan>> createPlan(
    String babyId,
    DateTime start,
    DateTime end,
  );

  /// Persists a new `end_date` for [planId] — backs "+ Add Date" so the widened
  /// window survives a refetch and reaches Home's date strip.
  Future<Result<MealPlan>> updatePlanEndDate(String planId, DateTime endDate);

  /// Deletes a plan by ID — cascades its `meal_plan_entries`.
  Future<Result<void>> deletePlan(String planId);
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
  ) => getEntriesInRange(babyId, weekStart, weekEnd);

  @override
  Future<Result<List<MealPlanEntry>>> getEntriesInRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final data = await _supabase
          .from('meal_plan_entries')
          .select()
          .eq('baby_id', babyId)
          .gte('plan_date', _formatDate(startDate))
          .lte('plan_date', _formatDate(endDate))
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
  Future<Result<List<MealPlanEntry>>> getAllEntries(String babyId) async {
    try {
      final data = await _supabase
          .from('meal_plan_entries')
          .select()
          .eq('baby_id', babyId)
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
  Future<Result<List<MealPlanEntry>>> getEntriesForPlan(String planId) async {
    try {
      final data = await _supabase
          .from('meal_plan_entries')
          .select()
          .eq('meal_plan_id', planId)
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
  Future<Result<List<MealPlanEntry>>> appendBulk(
    List<MealPlanEntryInsert> entries,
  ) async {
    if (entries.isEmpty) return const Result.success([]);
    try {
      final payload = entries
          .map(
            (e) => <String, dynamic>{
              'baby_id': e.babyId,
              'recipe_id': e.recipeId,
              'plan_date': _formatDate(e.planDate),
              if (e.mealTime != null) 'meal_time': _formatTime(e.mealTime!),
              if (e.mealPlanId != null) 'meal_plan_id': e.mealPlanId,
            },
          )
          .toList();

      final data = await _supabase
          .from('meal_plan_entries')
          .insert(payload)
          .select();

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
  Future<Result<void>> clearWeek(
    String babyId,
    DateTime weekStart,
    DateTime weekEnd,
  ) => deleteRange(babyId, weekStart, weekEnd);

  @override
  Future<Result<void>> deleteRange(
    String babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      await _supabase
          .from('meal_plan_entries')
          .delete()
          .eq('baby_id', babyId)
          .gte('plan_date', _formatDate(startDate))
          .lte('plan_date', _formatDate(endDate));

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

  @override
  Future<Result<MealPlan?>> getActivePlan(String babyId) async {
    try {
      final data = await _supabase
          .from('meal_plans')
          .select()
          .eq('baby_id', babyId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return const Result.success(null);
      return Result.success(_planFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<MealPlan>> createPlan(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Enforce a single active plan per baby — cascade removes old entries.
      await _supabase.from('meal_plans').delete().eq('baby_id', babyId);

      final data = await _supabase
          .from('meal_plans')
          .insert(<String, dynamic>{
            'baby_id': babyId,
            'start_date': _formatDate(start),
            'end_date': _formatDate(end),
          })
          .select()
          .single();

      return Result.success(_planFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<MealPlan>> updatePlanEndDate(
    String planId,
    DateTime endDate,
  ) async {
    try {
      final data = await _supabase
          .from('meal_plans')
          .update(<String, dynamic>{'end_date': _formatDate(endDate)})
          .eq('id', planId)
          .select()
          .single();

      return Result.success(_planFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> deletePlan(String planId) async {
    try {
      await _supabase.from('meal_plans').delete().eq('id', planId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  // ---------------------------------------------------------------------------
  // Row mappers
  // ---------------------------------------------------------------------------

  MealPlan _planFromRow(Map<String, dynamic> row) => MealPlan(
    id: row['id'] as String,
    babyId: row['baby_id'] as String,
    startDate: DateTime.parse(row['start_date'] as String),
    endDate: DateTime.parse(row['end_date'] as String),
    createdAt: DateTime.parse(row['created_at'] as String),
  );

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
