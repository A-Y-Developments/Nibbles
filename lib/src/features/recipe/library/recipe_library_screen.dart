import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:nibbles/src/features/recipe/library/widgets/library_header.dart';
import 'package:nibbles/src/features/recipe/library/widgets/read_guide_banner.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_category_row.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_search_empty.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_search_results.dart';

/// Recipe Library screen (RC-01, NIB-53 reskin + NIB-58 search rewire).
///
/// Reskins the previous SliverGrid layout to a butter-wash [LibraryHeader] +
/// vertical stack of horizontal [RecipeCategoryRow]s, driven by
/// `RecipeService.getRecipesByCategory`. A first-launch [ReadGuideBanner]
/// appears above the first row when `LocalFlagService.isStartingGuideSeen()`
/// is `false`. Section order:
///   1. (optional) 'Recommendation for {ongoing allergen}' — recipes from
///      any category whose `allergenTags` contain the in-progress allergen.
///   2. One row per category in the order returned by the service.
///
/// Search (NIB-58): the header's search input dispatches the query to
/// [RecipeLibraryController.setSearchQuery]. A non-empty
/// `state.searchQuery` collapses the body into [RecipeSearchResults]; an
/// empty result inside that branch renders [RecipeSearchEmpty]. Clearing
/// the field reverts to the category-rows layout.
///
/// Allergen-level recipe flagging is preserved via the
/// `flaggedAllergenKeys` prop on every card-rendering widget.
class RecipeLibraryScreen extends ConsumerWidget {
  const RecipeLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            backgroundColor: AppColors.cream,
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _RecipeLibraryBody(babyId: babyId);
      },
    );
  }
}

class _RecipeLibraryBody extends ConsumerStatefulWidget {
  const _RecipeLibraryBody({required this.babyId});

  final String babyId;

  @override
  ConsumerState<_RecipeLibraryBody> createState() => _RecipeLibraryBodyState();
}

class _RecipeLibraryBodyState extends ConsumerState<_RecipeLibraryBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStartingGuide() {
    // TODO(NIB-94): replace SnackBar with `context.pushNamed(
    //   AppRoute.startingGuide.name)` once the Starting Guide route lands.
    // Route is not registered yet so we cannot reference it here without
    // breaking analyze.
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Starting Guide coming soon'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _onBookmarkTap() {
    // Per NIB-53 spec point 7: the bookmark just navigates (or shows the
    // SnackBar). Only the 'Read Guide' CTA inside the banner marks the
    // starting_guide_seen flag.
    _openStartingGuide();
  }

  void _onReadGuideTap() {
    unawaited(
      ref
          .read(recipeLibraryControllerProvider(widget.babyId).notifier)
          .markStartingGuideSeen(),
    );
    _openStartingGuide();
  }

  void _onSearchChanged(String query) {
    ref
        .read(recipeLibraryControllerProvider(widget.babyId).notifier)
        .setSearchQuery(query);
  }

  Future<void> _refresh() => ref
      .read(recipeLibraryControllerProvider(widget.babyId).notifier)
      .refresh();

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(
      recipeLibraryControllerProvider(widget.babyId),
    );

    final searchValue = libraryAsync.valueOrNull?.searchQuery ?? '';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          LibraryHeader(
            searchController: _searchController,
            searchValue: searchValue,
            onSearchChanged: _onSearchChanged,
            onBookmarkTap: _onBookmarkTap,
          ),
          Expanded(
            child: libraryAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => _ErrorView(onRetry: _refresh),
              data: (state) => _RecipeContent(
                state: state,
                onReadGuideTap: _onReadGuideTap,
                onRefresh: _refresh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeContent extends StatelessWidget {
  const _RecipeContent({
    required this.state,
    required this.onReadGuideTap,
    required this.onRefresh,
  });

  final RecipeLibraryState state;
  final VoidCallback onReadGuideTap;
  final Future<void> Function() onRefresh;

  List<Recipe> get _allRecipes => state.recipesByCategory.values
      .expand((rs) => rs)
      .toSet()
      .toList();

  List<Recipe> get _recommendations {
    final key = state.ongoingAllergenKey;
    if (key == null) return const [];
    return _allRecipes.where((r) => r.allergenTags.contains(key)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (state.searchQuery.isNotEmpty) {
      final results = state.filteredRecipes;
      if (results.isEmpty) {
        return const RecipeSearchEmpty();
      }
      return RecipeSearchResults(
        recipes: results,
        flaggedAllergenKeys: state.flaggedAllergenKeys,
      );
    }

    if (state.recipesByCategory.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: _EmptyView(
          isStartingGuideSeen: state.isStartingGuideSeen,
          onReadGuideTap: onReadGuideTap,
        ),
      );
    }

    final ongoingKey = state.ongoingAllergenKey;
    final recommendations = _recommendations;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          if (!state.isStartingGuideSeen)
            ReadGuideBanner(onTap: onReadGuideTap),
          if (ongoingKey != null && recommendations.isNotEmpty)
            RecipeCategoryRow(
              title: 'Recommendation for ${_displayName(ongoingKey)} '
                  '${AllergenEmoji.get(ongoingKey)}',
              recipes: recommendations,
              flaggedAllergenKeys: state.flaggedAllergenKeys,
            ),
          for (final entry in state.recipesByCategory.entries)
            if (entry.value.isNotEmpty)
              RecipeCategoryRow(
                title: entry.key,
                recipes: entry.value,
                flaggedAllergenKeys: state.flaggedAllergenKeys,
              ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  static const _allergenNames = {
    'peanut': 'Peanut',
    'egg': 'Egg',
    'dairy': 'Dairy',
    'tree_nuts': 'Tree Nuts',
    'sesame': 'Sesame',
    'soy': 'Soy',
    'wheat': 'Wheat',
    'fish': 'Fish',
    'shellfish': 'Shellfish',
  };

  static String _displayName(String key) => _allergenNames[key] ?? key;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Text(
                  "Couldn't load recipes. Pull down to retry.",
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.fgFaint,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.isStartingGuideSeen,
    required this.onReadGuideTap,
  });

  final bool isStartingGuideSeen;
  final VoidCallback onReadGuideTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (!isStartingGuideSeen) ReadGuideBanner(onTap: onReadGuideTap),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No recipes yet',
                    style: AppTypography.emptyStateTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Check back after completing more allergen steps.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.fgFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
