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
/// mapper flow (NIB-87, Figma 971:8264 + 971:8334).
///
/// Surfaces:
///   * Header — "Browse Meal" title, weekday date range
///     ("Mon, 20 - Thu 23 April"), and a top-right close (X) icon.
///   * "Recomendation for {ongoing allergen}" carousel — only when an
///     `AllergenStatus.inProgress` allergen exists per
///     [AllergenService.getAllergenStatuses]. The verbatim Figma copy
///     intentionally retains the typo "Recomendation" until the PO
///     clarifies (acceptance criteria).
///   * Category-derived carousels — driven by [Recipe.category]; falls
///     back to allergen-tag groups when no recipes carry a category.
///   * Searchable master list with tappable selected / unselected counter
///     pills that filter the list into a review mode.
///   * Sticky CTA — "Add (N)" in browse mode, "Mapp Meal Plan" in review
///     mode (verbatim Figma copy; "Map Meal Plan" PO-correction noted).
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
    // NIB-161: default useSafeArea:false wraps the sheet in
    // MediaQuery.removePadding(removeTop), zeroing padding.top, so the header
    // rendered under the status bar / Dynamic Island.
    useSafeArea: true,
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
  final Set<String> _deselectedRecipeIds = {};

  List<Recipe>? _recipes;
  Set<String> _flaggedKeys = {};
  String? _ongoingAllergenKey;
  String _query = '';
  bool _loading = true;
  String? _error;
  BrowseMealSelectionFilter _filter = BrowseMealSelectionFilter.none;

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
        _deselectedRecipeIds.add(r.id);
        unawaited(analytics.logMealPrepBrowseDeselected(recipeId: r.id));
      } else {
        _selectedRecipeIds.add(r.id);
        _deselectedRecipeIds.remove(r.id);
        unawaited(analytics.logMealPrepBrowseSelected(recipeId: r.id));
      }
    });
  }

  void _onSelectedCounterTap() {
    setState(() {
      _filter = _filter == BrowseMealSelectionFilter.selected
          ? BrowseMealSelectionFilter.none
          : BrowseMealSelectionFilter.selected;
    });
  }

  void _onUnselectedCounterTap() {
    setState(() {
      _filter = _filter == BrowseMealSelectionFilter.unselected
          ? BrowseMealSelectionFilter.none
          : BrowseMealSelectionFilter.unselected;
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
    Iterable<Recipe> filtered = all;
    switch (_filter) {
      case BrowseMealSelectionFilter.none:
        break;
      case BrowseMealSelectionFilter.selected:
        filtered = all.where((r) => _selectedRecipeIds.contains(r.id));
      case BrowseMealSelectionFilter.unselected:
        filtered = all.where((r) => _deselectedRecipeIds.contains(r.id));
    }
    if (_query.isEmpty) return filtered.toList();
    final q = _query.toLowerCase();
    return filtered
        .where((r) => r.title.toLowerCase().contains(q))
        .toList();
  }

  List<Recipe> _recommendationsFor(String allergenKey) {
    final all = _recipes ?? const <Recipe>[];
    return all
        .where((r) => r.allergenTags.contains(allergenKey))
        .toList(growable: false);
  }

  /// Category-derived groups: one carousel per non-null `Recipe.category`
  /// present in the loaded recipes. Flagged-allergen recipes are excluded so
  /// they only surface in the master list (where their disabled state is
  /// communicated explicitly).
  ///
  /// If no recipes carry a category we fall back to allergen-tag groups so
  /// the sheet still has visual structure when the seed data is sparse
  /// (open question NIB-87 — final category set TBC by PO).
  List<MapEntry<String, List<Recipe>>> _categoryGroups() {
    final all = _recipes ?? const <Recipe>[];
    if (all.isEmpty) return const [];
    final byCategory = <String, List<Recipe>>{};
    for (final r in all) {
      if (_isUnsafe(r)) continue;
      final cat = r.category;
      if (cat == null || cat.isEmpty) continue;
      byCategory.putIfAbsent(cat, () => <Recipe>[]).add(r);
    }
    if (byCategory.isNotEmpty) {
      return byCategory.entries.toList(growable: false);
    }
    // Fallback: derived from allergen tags.
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

  Future<void> _maybeClose() async {
    if (_selectedRecipeIds.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text('Discard your selections?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard ?? false) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;

    return PopScope(
      canPop: _selectedRecipeIds.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _maybeClose();
      },
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSizes.sm),
                _GrabHandle(),
                const SizedBox(height: AppSizes.md),
                _Header(
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                  onClose: _maybeClose,
                ),
                const SizedBox(height: AppSizes.md),
                Expanded(child: _body()),
                if (!_loading && _error == null) _StickyAddBar(
                  count: _selectedRecipeIds.length,
                  inReviewMode: _filter != BrowseMealSelectionFilter.none,
                  onPressed: _selectedRecipeIds.isEmpty ? null : _confirm,
                ),
              ],
            ),
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
    final selectedCount = _selectedRecipeIds.length;
    final searchResults = _searchResults;
    final ongoingKey = _ongoingAllergenKey;
    final ongoingRecipes = ongoingKey == null
        ? const <Recipe>[]
        : _recommendationsFor(ongoingKey);
    final categoryGroups = _categoryGroups();
    final inReviewMode = _filter != BrowseMealSelectionFilter.none;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (!inReviewMode) ...[
                BrowseMealSearchField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSizes.md),
                if (ongoingKey != null && ongoingRecipes.isNotEmpty)
                  RecommendationCarouselSection(
                    title: 'Recomendation for '
                        '${AllergenEmoji.get(ongoingKey)} '
                        '${_displayName(ongoingKey)}',
                    recipes: ongoingRecipes,
                    selectedIds: _selectedRecipeIds,
                    isUnsafe: _isUnsafe,
                    onToggle: _toggleRecipe,
                  ),
                for (final group in categoryGroups)
                  RecommendationCarouselSection(
                    title: _categoryDisplayTitle(group.key),
                    recipes: group.value,
                    selectedIds: _selectedRecipeIds,
                    isUnsafe: _isUnsafe,
                    onToggle: _toggleRecipe,
                  ),
              ],
              SelectionCounters(
                selectedCount: selectedCount,
                unselectedCount: _deselectedRecipeIds.length,
                activeFilter: _filter,
                onSelectedTap: _onSelectedCounterTap,
                onUnselectedTap: _onUnselectedCounterTap,
                showUnselected: _deselectedRecipeIds.isNotEmpty,
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

  /// Renders a carousel section title from a [Recipe.category] value or an
  /// allergen-key fallback. When the category is already a display string
  /// (e.g. "Iron-rich Purées") we use it verbatim; allergen-key fallbacks
  /// get an emoji prefix.
  String _categoryDisplayTitle(String raw) {
    if (kAllergenKeys.contains(raw)) {
      return '${AllergenEmoji.get(raw)} ${_displayName(raw)} recipes';
    }
    return raw;
  }
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
  const _Header({
    required this.startDate,
    required this.endDate,
    required this.onClose,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onClose;

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Figma spec format example: "Mon, 20 - Thu 23 April".
  /// Weekday short + day of month at both ends, full month name at the tail.
  String _formatRange() {
    final sameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;
    final start = startDate;
    final end = endDate;
    final startW = _weekdays[start.weekday - 1];
    final endW = _weekdays[end.weekday - 1];
    final endM = _months[end.month - 1];
    if (sameDay) {
      return '$startW, ${start.day} $endM';
    }
    return '$startW, ${start.day} - $endW ${end.day} $endM';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Browse Meal', style: textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  _formatRange(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgDefault,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.greenDeep),
            tooltip: 'Close',
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
  const _StickyAddBar({
    required this.count,
    required this.inReviewMode,
    required this.onPressed,
  });

  final int count;
  final bool inReviewMode;
  final VoidCallback? onPressed;

  /// Floating CTA label per ticket NIB-87:
  ///   * Browse phase  → "Add (N)"
  ///   * Review phase  → "Mapp Meal Plan" (verbatim Figma copy; PO has the
  ///     "Map" correction noted as an open question but the bracketed
  ///     verbatim spelling is required until clarified).
  String get _label =>
      inReviewMode ? 'Mapp Meal Plan' : 'Add ($count)';

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
            _label,
            style: AppTypography.button.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
