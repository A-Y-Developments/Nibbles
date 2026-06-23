import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_library_controller.g.dart';

/// Canonical display order for the RC-01 category sections, matching the
/// "Baby's First Nibbles" e-book sequence. Categories not listed here render
/// after these, in the order Supabase returned them.
const List<String> kRecipeCategoryOrder = [
  'Iron-Rich Purées',
  'Whipped Bone Marrow',
  'Iron-Rich Finger Foods',
  'Stool-Softening Meals',
  '10-Minute Meals (Minimal Prep)',
  'High-Energy Meals for Small Appetites',
];

/// Controller for the Recipe Library screen (RC-01, NIB-53 reskin).
///
/// Drives off [RecipeService.getRecipesByCategory] (NIB-129) for the main
/// category grouping, [AllergenService.getAllergenStatuses] for the
/// ongoing-allergen recommendation header, and
/// [RecipeService.getFlaggedAllergenKeys] for the 'Not safe' card treatment.
/// The first-launch 'Read Guide' banner state is read synchronously from
/// [LocalFlagService.isStartingGuideSeen].
@riverpod
class RecipeLibraryController extends _$RecipeLibraryController {
  @override
  Future<RecipeLibraryState> build(String babyId) async {
    final recipeService = ref.read(recipeServiceProvider);
    final allergenService = ref.read(allergenServiceProvider);
    final flags = ref.read(localFlagServiceProvider);

    final (categoriesResult, statusesResult, flaggedResult) = await (
      recipeService.getRecipesByCategory(babyId),
      allergenService.getAllergenStatuses(babyId),
      recipeService.getFlaggedAllergenKeys(babyId),
    ).wait;

    if (categoriesResult.isFailure) throw categoriesResult.errorOrNull!;
    if (statusesResult.isFailure) throw statusesResult.errorOrNull!;
    if (flaggedResult.isFailure) throw flaggedResult.errorOrNull!;

    final statuses = statusesResult.dataOrNull!;
    final flagged = flaggedResult.dataOrNull!;
    final recipesByCategory = _orderByCanonical(categoriesResult.dataOrNull!);

    // First allergen in canonical order with status == inProgress (or null).
    String? ongoingAllergenKey;
    for (final key in kAllergenKeys) {
      if (statuses[key] == AllergenStatus.inProgress) {
        ongoingAllergenKey = key;
        break;
      }
    }

    return RecipeLibraryState(
      recipesByCategory: recipesByCategory,
      ongoingAllergenKey: ongoingAllergenKey,
      flaggedAllergenKeys: flagged,
      isStartingGuideSeen: flags.isStartingGuideSeen(),
    );
  }

  Map<String, List<Recipe>> _orderByCanonical(
    Map<String, List<Recipe>> byCategory,
  ) {
    final ordered = <String, List<Recipe>>{};
    for (final key in kRecipeCategoryOrder) {
      final recipes = byCategory[key];
      if (recipes != null && recipes.isNotEmpty) ordered[key] = recipes;
    }
    for (final entry in byCategory.entries) {
      ordered.putIfAbsent(entry.key, () => entry.value);
    }
    return ordered;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Persists the Starting Guide seen flag and updates state so the banner
  /// disappears immediately. Fire-and-forget — Hive write is non-blocking.
  Future<void> markStartingGuideSeen() async {
    final current = state.valueOrNull;
    if (current == null || current.isStartingGuideSeen) return;
    state = AsyncData(current.copyWith(isStartingGuideSeen: true));
    await ref.read(localFlagServiceProvider).markStartingGuideSeen();
  }

  /// Updates the active search query. The query is trimmed; a non-empty
  /// query collapses the screen into the search-results view, an empty one
  /// restores the category-rows layout. Filtering itself lives on
  /// [RecipeLibraryState.filteredRecipes].
  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    final trimmed = query.trim();
    if (trimmed == current.searchQuery) return;
    final wasEmpty = current.searchQuery.isEmpty;
    state = AsyncData(current.copyWith(searchQuery: trimmed));
    if (wasEmpty && trimmed.isNotEmpty) {
      unawaited(
        Analytics.instance.logRecipeSearch(queryLength: trimmed.length),
      );
    }
  }
}
