// freezed copies @JsonKey field annotations into generated parts, triggering a
// false-positive from very_good_analysis on the generated getter declarations.
// ignore_for_file: invalid_annotation_target
import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/sources/local/hive_service.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'recipe_repository.g.dart';

abstract interface class RecipeRepository {
  /// RECIPE-01: Fetch all recipes from Supabase, ordered by title.
  /// Serves from Hive cache if available; refreshes in background.
  Future<Result<List<Recipe>>> getAllRecipes();

  /// RECIPE-02: Fetch recipes where allergen_tags contains [allergenKey].
  Future<Result<List<Recipe>>> getRecipesByAllergen(String allergenKey);

  /// RECIPE-03: Fetch single recipe by ID.
  Future<Result<Recipe>> getRecipeById(String recipeId);
}

class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl({
    SupabaseClient? supabaseClient,
    HiveService? hiveService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _hive = hiveService ?? HiveService();

  final SupabaseClient _supabase;
  final HiveService _hive;

  static const _cacheKey = 'recipes_all';

  @override
  Future<Result<List<Recipe>>> getAllRecipes() async {
    final cached = _hive.recipesBox.get(_cacheKey);
    if (cached != null) {
      try {
        final list = (jsonDecode(cached) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Recipe.fromJson)
            .toList();
        // Background refresh — do not await.
        unawaited(_refreshCache());
        return Result.success(list);
      } on Object catch (e, st) {
        // Cache corrupt — log and fall through to remote fetch.
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            st,
            reason: 'Recipe Hive cache corruption',
          ),
        );
      }
    }

    return _fetchFromSupabaseAndCache();
  }

  @override
  Future<Result<List<Recipe>>> getRecipesByAllergen(String allergenKey) async {
    // Use cached all-recipes and filter client-side to avoid extra RPC.
    final allResult = await getAllRecipes();
    if (allResult.isFailure) {
      return Result.failure(allResult.errorOrNull!);
    }
    final filtered = allResult.dataOrNull!
        .where((r) => r.allergenTags.contains(allergenKey))
        .toList();
    return Result.success(filtered);
  }

  @override
  Future<Result<Recipe>> getRecipeById(String recipeId) async {
    // Check cache first.
    final cached = _hive.recipesBox.get(_cacheKey);
    if (cached != null) {
      try {
        final list = (jsonDecode(cached) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Recipe.fromJson)
            .toList();
        final match = list.where((r) => r.id == recipeId).firstOrNull;
        if (match != null) return Result.success(match);
      } on Object {
        // Cache unusable — fall through to remote.
      }
    }

    try {
      final data = await _supabase
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();

      return Result.success(_recipeFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  // --- Private helpers ---

  Future<Result<List<Recipe>>> _fetchFromSupabaseAndCache() async {
    try {
      final data = await _supabase.from('recipes').select().order('title');

      final recipes = (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_recipeFromRow)
          .toList();

      await _hive.recipesBox.put(
        _cacheKey,
        jsonEncode(recipes.map((r) => r.toJson()).toList()),
      );

      return Result.success(recipes);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  Future<void> _refreshCache() async {
    try {
      final data = await _supabase.from('recipes').select().order('title');

      final recipes = (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_recipeFromRow)
          .toList();

      await _hive.recipesBox.put(
        _cacheKey,
        jsonEncode(recipes.map((r) => r.toJson()).toList()),
      );
    } on Object {
      // Silent background refresh — errors are not surfaced to UI.
    }
  }

  Recipe _recipeFromRow(Map<String, dynamic> row) {
    final rawIngredients = (row['ingredients'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return Recipe(
      id: row['id'] as String,
      title: row['title'] as String,
      ageRange: row['age_range'] as String,
      allergenTags: (row['allergen_tags'] as List<dynamic>).cast<String>(),
      ingredients: rawIngredients.map(Ingredient.fromJson).toList(),
      steps: (row['steps'] as List<dynamic>).cast<String>(),
      howToServe: row['serving_guidance'] as String,
      notes: row['notes'] as String?,
      thumbnailUrl: row['thumbnail_url'] as String?,
    );
  }
}

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  RecipeRepositoryRef ref,
) => RecipeRepositoryImpl();
