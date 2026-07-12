import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_mock.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:nibbles/src/features/recipe/library/widgets/library_header.dart';
import 'package:nibbles/src/features/recipe/library/widgets/read_guide_banner.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_category_row.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_search_empty.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_search_results.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Recipe Library screen (RC-01, NIB-53 redesign + NIB-58 search rewire).
///
/// Reskins the Recipe Library tab to the butter-gradient hero + vertical
/// stack of horizontal [RecipeCategoryRow]s per Figma 971:8644 / 971:8760.
/// Driven by `RecipeService.getRecipesByCategory`. A forest
/// 'New to Starting Solids?' [ReadGuideBanner] always sits above the first
/// row. Section order:
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
    if (kRecipeLibraryUseMock) {
      return const _RecipeLibraryMockBody();
    }

    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => GradientScaffold(
        body: Center(
          child: Semantics(
            label: 'Loading recipes',
            child: const BrandFlowerLoader.small(),
          ),
        ),
      ),
      error: (_, __) => GradientScaffold(
        body: Semantics(
          liveRegion: true,
          container: true,
          child: const Center(child: Text('Could not load baby profile.')),
        ),
      ),
      data: (babyId) {
        if (babyId == null) {
          return GradientScaffold(
            body: Semantics(
              liveRegion: true,
              container: true,
              child: const Center(child: Text('No baby profile found.')),
            ),
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
    context.pushNamed(AppRoute.startingGuide.name);
  }

  void _onBookmarkTap() {
    _openStartingGuide();
  }

  void _onReadGuideTap() {
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

    return GradientScaffold(
      body: Column(
        children: [
          LibraryHeader(
            searchController: _searchController,
            searchValue: searchValue,
            onSearchChanged: _onSearchChanged,
            onBookmarkTap: _onBookmarkTap,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppDurations.fade,
              switchInCurve: AppCurves.standard,
              switchOutCurve: AppCurves.standard,
              child: libraryAsync.when(
                loading: () => Center(
                  key: const ValueKey('recipe-library-loading'),
                  child: Semantics(
                    label: 'Loading recipes',
                    child: const BrandFlowerLoader.small(),
                  ),
                ),
                error: (_, __) => _ErrorView(
                  key: const ValueKey('recipe-library-error'),
                  onRetry: _refresh,
                ),
                data: (state) => _RecipeContent(
                  key: const ValueKey('recipe-library-data'),
                  state: state,
                  onReadGuideTap: _onReadGuideTap,
                  onRefresh: _refresh,
                ),
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
    super.key,
  });

  final RecipeLibraryState state;
  final VoidCallback onReadGuideTap;
  final Future<void> Function() onRefresh;

  List<Recipe> get _allRecipes =>
      state.recipesByCategory.values.expand((rs) => rs).toSet().toList();

  List<Recipe> get _recommendations {
    final key = state.ongoingAllergenKey;
    if (key == null) return const [];
    return _allRecipes.where((r) => r.allergenTags.contains(key)).toList();
  }

  // A recipe can surface in more than one category row (and again in the
  // recommendation strip). Hero tags must be unique per screen, so only ids
  // that appear exactly once across the category rows are hero-eligible; the
  // recommendation strip never carries a hero (its cards duplicate a category
  // row). Non-eligible cards fall back to a plain push.
  Set<String> get _categoryHeroIds {
    final counts = <String, int>{};
    for (final recipes in state.recipesByCategory.values) {
      for (final r in recipes) {
        counts[r.id] = (counts[r.id] ?? 0) + 1;
      }
    }
    return {
      for (final entry in counts.entries)
        if (entry.value == 1) entry.key,
    };
  }

  Set<String> _uniqueIds(List<Recipe> recipes) {
    final counts = <String, int>{};
    for (final r in recipes) {
      counts[r.id] = (counts[r.id] ?? 0) + 1;
    }
    return {
      for (final entry in counts.entries)
        if (entry.value == 1) entry.key,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.fade,
      switchInCurve: AppCurves.standard,
      switchOutCurve: AppCurves.standard,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (state.searchQuery.isNotEmpty) {
      final results = state.filteredRecipes;
      if (results.isEmpty) {
        return const RecipeSearchEmpty(key: ValueKey('recipe-search-empty'));
      }
      return RecipeSearchResults(
        key: const ValueKey('recipe-search-results'),
        recipes: results,
        flaggedAllergenKeys: state.flaggedAllergenKeys,
        heroEligibleIds: _uniqueIds(results),
      );
    }

    if (state.recipesByCategory.isEmpty) {
      return BrandRefreshIndicator(
        key: const ValueKey('recipe-empty'),
        onRefresh: onRefresh,
        child: _EmptyView(onReadGuideTap: onReadGuideTap),
      );
    }

    final ongoingKey = state.ongoingAllergenKey;
    final recommendations = _recommendations;
    final heroIds = _categoryHeroIds;

    final sections = <Widget>[
      ReadGuideBanner(onTap: onReadGuideTap),
      if (ongoingKey != null && recommendations.isNotEmpty)
        RecipeCategoryRow(
          title:
              'Recommendation for '
              '${AllergenEmoji.displayName(ongoingKey)} '
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
            heroEligibleIds: heroIds,
          ),
    ];

    return BrandRefreshIndicator(
      key: const ValueKey('recipe-categories'),
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: sections.length + 1,
        itemBuilder: (context, index) {
          if (index == sections.length) {
            return const SizedBox(height: AppSizes.xl);
          }
          return sections[index]
              .animate()
              .fadeIn(
                delay: _sectionStagger * index,
                duration: AppDurations.fade,
              )
              .slideY(
                begin: 0.04,
                end: 0,
                delay: _sectionStagger * index,
                duration: AppDurations.slide,
                curve: AppCurves.emphasized,
              );
        },
      ),
    );
  }
}

const Duration _sectionStagger = Duration(milliseconds: 60);

/// Visual-only mock body used while [kRecipeLibraryUseMock] is on. Owns a
/// local search controller and renders [_RecipeContent] from
/// [buildMockRecipeLibraryState] — no baby profile or controller needed.
class _RecipeLibraryMockBody extends StatefulWidget {
  const _RecipeLibraryMockBody();

  @override
  State<_RecipeLibraryMockBody> createState() => _RecipeLibraryMockBodyState();
}

class _RecipeLibraryMockBodyState extends State<_RecipeLibraryMockBody> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStartingGuide() => context.pushNamed(AppRoute.startingGuide.name);

  @override
  Widget build(BuildContext context) {
    final state = buildMockRecipeLibraryState().copyWith(searchQuery: _search);

    return GradientScaffold(
      body: Column(
        children: [
          LibraryHeader(
            searchController: _searchController,
            searchValue: _search,
            onSearchChanged: (q) => setState(() => _search = q.trim()),
            onBookmarkTap: _openStartingGuide,
          ),
          Expanded(
            child: _RecipeContent(
              state: state,
              onReadGuideTap: _openStartingGuide,
              onRefresh: () async {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return BrandRefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Couldn't load recipes.",
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.fgFaint,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ElevatedButton(
                        onPressed: () => unawaited(onRetry()),
                        child: const Text('Retry'),
                      ),
                    ],
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
  const _EmptyView({required this.onReadGuideTap});

  final VoidCallback onReadGuideTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ReadGuideBanner(onTap: onReadGuideTap),
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
