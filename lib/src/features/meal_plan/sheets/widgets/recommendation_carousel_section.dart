import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/inputs/app_search_field.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/meal_plan/sheets/widgets/browse_meal_recipe_card.dart';

/// Horizontal carousel of recipe cards under a labeled section header.
class RecommendationCarouselSection extends StatelessWidget {
  const RecommendationCarouselSection({
    required this.title,
    required this.recipes,
    required this.selectedIds,
    required this.isUnsafe,
    required this.onToggle,
    super.key,
  });

  final String title;
  final List<Recipe> recipes;
  final Set<String> selectedIds;
  final bool Function(Recipe recipe) isUnsafe;
  final void Function(Recipe recipe) onToggle;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: Text(title, style: textTheme.titleMedium),
        ),
        const SizedBox(height: AppSizes.sm),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: AppDurations.slide,
          curve: AppCurves.emphasized,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 8),
              child: child,
            ),
          ),
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.xs,
              ),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final unsafe = isUnsafe(recipe);
                return BrowseMealRecipeCard(
                  recipe: recipe,
                  selected: selectedIds.contains(recipe.id),
                  unsafe: unsafe,
                  onTap: () => onToggle(recipe),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}

/// Search text field used at the top of the master list section.
///
/// Delegates to [AppSearchField] for consistent look + behaviour.
class BrowseMealSearchField extends StatelessWidget {
  const BrowseMealSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: AppSearchField(
        controller: controller,
        hintText: 'Search recipe',
        onChanged: onChanged,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

/// Selection filter chips for the Browse Meal sheet.
///
/// Per Figma 971:8334, the "{N} selected" / "{N} unselected" pills are
/// tap-targets that filter the master list to selected / unselected recipes
/// respectively. The "unselected" chip only renders when the user has begun
/// reviewing their picks (i.e. [showUnselected] is true).
class SelectionCounters extends StatelessWidget {
  const SelectionCounters({
    required this.selectedCount,
    required this.unselectedCount,
    required this.activeFilter,
    required this.onSelectedTap,
    required this.onUnselectedTap,
    this.showUnselected = false,
    super.key,
  });

  final int selectedCount;
  final int unselectedCount;
  final BrowseMealSelectionFilter activeFilter;
  final VoidCallback onSelectedTap;
  final VoidCallback onUnselectedTap;
  final bool showUnselected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Row(
        children: [
          _Counter(
            label: '$selectedCount selected',
            background: AppColors.butterSoft,
            foreground: AppColors.greenDeep,
            active: activeFilter == BrowseMealSelectionFilter.selected,
            onTap: onSelectedTap,
          ),
          if (showUnselected) ...[
            const SizedBox(width: AppSizes.sm),
            _Counter(
              label: '$unselectedCount unselected',
              background: AppColors.coralSoft,
              foreground: AppColors.coralDeep,
              active: activeFilter == BrowseMealSelectionFilter.unselected,
              onTap: onUnselectedTap,
            ),
          ],
        ],
      ),
    );
  }
}

/// Filter modes for the selection counter chips.
enum BrowseMealSelectionFilter { none, selected, unselected }

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.background,
    required this.foreground,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.base,
        curve: AppCurves.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: active ? foreground : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.fade,
          switchInCurve: AppCurves.standard,
          child: Text(
            label,
            key: ValueKey<String>(label),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
