import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
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
        SizedBox(
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
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}

/// Search text field used at the top of the master list section.
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
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search recipes',
          prefixIcon: const Icon(Icons.search, color: AppColors.hint),
          filled: true,
          fillColor: AppColors.bgInput,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
        ),
      ),
    );
  }
}

/// Counter chip showing the selected and unselected counts.
class SelectionCounters extends StatelessWidget {
  const SelectionCounters({
    required this.selectedCount,
    required this.unselectedCount,
    super.key,
  });

  final int selectedCount;
  final int unselectedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Row(
        children: [
          _Counter(
            label: '$selectedCount selected',
            background: AppColors.greenTint,
            foreground: AppColors.greenDeep,
          ),
          const SizedBox(width: AppSizes.sm),
          _Counter(
            label: '$unselectedCount unselected',
            background: AppColors.surfaceVariant,
            foreground: AppColors.fgMuted,
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sp12,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
