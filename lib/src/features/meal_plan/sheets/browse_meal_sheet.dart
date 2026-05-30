import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/sheets/widgets/browse_meal_recipe_card.dart';
import 'package:nibbles/src/features/meal_plan/sheets/widgets/recommendation_carousel_section.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Bottom sheet shown via [showModalBottomSheet]. Returns the picked recipes
/// or null on cancel. Multi-select Browse Meal sheet for the meal-plan
/// mapper flow (NIB-87).
///
/// Surfaces:
///   * "Recommendation for {ongoing allergen}" carousel — only when an
///     `AllergenStatus.inProgress` allergen exists per
///     [AllergenService.getAllergenStatuses].
///   * Tag-derived carousels — grouped by allergen tag on the loaded recipes.
///   * Searchable master list with selected / unselected counters.
///   * Sticky "Add (N)" CTA returning the picked [Recipe] list.
///
/// Flagged-allergen recipes (those tagged with any key returned by
/// [RecipeService.getFlaggedAllergenKeys]) are rendered visually disabled
/// and are non-interactive in every surface.
Future<List<Recipe>?> showBrowseMealSheet(
  BuildContext context, {
  required String babyId,
  required DateTime startDate,
  required DateTime endDate,
}) {
  return showModalBottomSheet<List<Recipe>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _BrowseMealSheet(
      babyId: babyId,
      startDate: startDate,
      endDate: endDate,
    ),
  );
}

class _BrowseMealSheet extends ConsumerStatefulWidget {
  const _BrowseMealSheet({
    required this.babyId,
    required this.startDate,
    required this.endDate,
  });

  final String babyId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  ConsumerState<_BrowseMealSheet> createState() => _BrowseMealSheetState();
}

class _BrowseMealSheetState extends ConsumerState<_BrowseMealSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedRecipeIds = {};

  List<Recipe>? _recipes;
  Set<String> _flaggedKeys = {};
  String? _ongoingAllergenKey;
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final recipeService = ref.read(recipeServiceProvider);
    final allergenService = ref.read(allergenServiceProvider);

    final recipesResult = await recipeService.getAllRecipes(widget.babyId);
    final flaggedResult = await recipeService.getFlaggedAllergenKeys(
      widget.babyId,
    );
    final statusesResult = await allergenService.getAllergenStatuses(
      widget.babyId,
    );

    if (!mounted) return;

    if (recipesResult.isFailure ||
        flaggedResult.isFailure ||
        statusesResult.isFailure) {
      setState(() {
        _error = "Couldn't load recipes.";
        _loading = false;
      });
      return;
    }

    final statuses = statusesResult.dataOrNull ?? const {};
    // First kAllergenKeys-order key whose status is inProgress.
    String? ongoing;
    for (final key in kAllergenKeys) {
      if (statuses[key] == AllergenStatus.inProgress) {
        ongoing = key;
        break;
      }
    }

    setState(() {
      _recipes = recipesResult.dataOrNull;
      _flaggedKeys = flaggedResult.dataOrNull ?? {};
      _ongoingAllergenKey = ongoing;
      _loading = false;
    });
  }

  bool _isUnsafe(Recipe r) => r.allergenTags.any(_flaggedKeys.contains);

  List<String> _flaggedTagsFor(Recipe r) =>
      r.allergenTags.where(_flaggedKeys.contains).toList();

  void _toggleRecipe(Recipe r) {
    if (_isUnsafe(r)) return;
    final analytics = ref.read(analyticsProvider);
    setState(() {
      if (_selectedRecipeIds.contains(r.id)) {
        _selectedRecipeIds.remove(r.id);
        unawaited(analytics.logMealPrepBrowseDeselected(recipeId: r.id));
      } else {
        _selectedRecipeIds.add(r.id);
        unawaited(analytics.logMealPrepBrowseSelected(recipeId: r.id));
      }
    });
  }

  void _confirm() {
    final all = _recipes ?? const <Recipe>[];
    final byId = {for (final r in all) r.id: r};
    final picked = _selectedRecipeIds
        .map((id) => byId[id])
        .whereType<Recipe>()
        .toList();
    Navigator.of(context).pop(picked);
  }

  List<Recipe> get _searchResults {
    final all = _recipes ?? const <Recipe>[];
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((r) => r.title.toLowerCase().contains(q)).toList();
  }

  List<Recipe> _recommendationsFor(String allergenKey) {
    final all = _recipes ?? const <Recipe>[];
    return all
        .where((r) => r.allergenTags.contains(allergenKey))
        .toList(growable: false);
  }

  /// Tag-derived groups: one carousel per allergen key present in the loaded
  /// recipes, ordered by [kAllergenKeys], excluding the ongoing-allergen key
  /// (already surfaced) and any flagged keys.
  List<MapEntry<String, List<Recipe>>> _tagGroups() {
    final all = _recipes ?? const <Recipe>[];
    if (all.isEmpty) return const [];
    final groups = <String, List<Recipe>>{};
    for (final key in kAllergenKeys) {
      if (key == _ongoingAllergenKey) continue;
      if (_flaggedKeys.contains(key)) continue;
      final list = all
          .where((r) => r.allergenTags.contains(key))
          .toList(growable: false);
      if (list.isEmpty) continue;
      groups[key] = list;
    }
    return groups.entries.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.sm),
              _GrabHandle(),
              const SizedBox(height: AppSizes.md),
              _Header(
                startDate: widget.startDate,
                endDate: widget.endDate,
              ),
              const SizedBox(height: AppSizes.md),
              Expanded(child: _body()),
              if (!_loading && _error == null) _StickyAddBar(
                count: _selectedRecipeIds.length,
                onPressed: _selectedRecipeIds.isEmpty ? null : _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorPlaceholder(message: _error!, onRetry: _load);
    }
    final recipes = _recipes ?? const <Recipe>[];
    if (recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePaddingH),
          child: Text(
            'No recipes available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
            ),
          ),
        ),
      );
    }
    return _content();
  }

  Widget _content() {
    final totalCount = (_recipes ?? const <Recipe>[]).length;
    final selectedCount = _selectedRecipeIds.length;
    final unselectedCount = (totalCount - selectedCount).clamp(0, totalCount);
    final searchResults = _searchResults;
    final ongoingKey = _ongoingAllergenKey;
    final ongoingRecipes = ongoingKey == null
        ? const <Recipe>[]
        : _recommendationsFor(ongoingKey);
    final tagGroups = _tagGroups();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (ongoingKey != null && ongoingRecipes.isNotEmpty)
                RecommendationCarouselSection(
                  title: 'Recommendation for '
                      '${AllergenEmoji.get(ongoingKey)} '
                      '${_displayName(ongoingKey)}',
                  recipes: ongoingRecipes,
                  selectedIds: _selectedRecipeIds,
                  isUnsafe: _isUnsafe,
                  onToggle: _toggleRecipe,
                ),
              for (final group in tagGroups)
                RecommendationCarouselSection(
                  title: '${AllergenEmoji.get(group.key)} '
                      '${_displayName(group.key)} recipes',
                  recipes: group.value,
                  selectedIds: _selectedRecipeIds,
                  isUnsafe: _isUnsafe,
                  onToggle: _toggleRecipe,
                ),
              const SizedBox(height: AppSizes.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All recipes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              BrowseMealSearchField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: AppSizes.sm),
              SelectionCounters(
                selectedCount: selectedCount,
                unselectedCount: unselectedCount,
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
        if (searchResults.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.pagePaddingH),
              child: Text(
                _query.isEmpty
                    ? 'No recipes available.'
                    : 'No results for "$_query".',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.fgMuted,
                ),
              ),
            ),
          )
        else
          SliverList.separated(
            itemCount: searchResults.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: AppSizes.dividerThickness,
              color: AppColors.borderSoft,
            ),
            itemBuilder: (context, index) {
              final recipe = searchResults[index];
              return BrowseMealRecipeRow(
                recipe: recipe,
                selected: _selectedRecipeIds.contains(recipe.id),
                unsafe: _isUnsafe(recipe),
                flaggedTags: _flaggedTagsFor(recipe),
                onTap: () => _toggleRecipe(recipe),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
      ],
    );
  }

  String _displayName(String key) => key.replaceAll('_', ' ');
}

class _GrabHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  String _format(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;
    final range = sameDay
        ? _format(startDate)
        : '${_format(startDate)} – ${_format(endDate)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Browse Meals', style: textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            range,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconLg,
              color: AppColors.destructive,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
            ),
            const SizedBox(height: AppSizes.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyAddBar extends StatelessWidget {
  const _StickyAddBar({required this.count, required this.onPressed});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderSoft),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.md,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          ),
          child: Text(
            'Add ($count)',
            style: AppTypography.button.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
