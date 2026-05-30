import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_library_controller.g.dart';

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

    final recipesByCategory = categoriesResult.dataOrNull!;
    final statuses = statusesResult.dataOrNull!;
    final flagged = flaggedResult.dataOrNull!;

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
    state = AsyncData(current.copyWith(searchQuery: trimmed));
  }
}
