import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/recipe_plan_row.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Review-selection sheet (Figma 971:8354). Lists every recipe the user
/// picked in the Browse Meal sheet so they can confirm before mapping.
///
/// Terminal actions:
///   * "Back" → pops with `null` (caller returns to the browse sheet).
///   * "Map Meals" → pops with the confirmed `List<Recipe>` (the caller
///     navigates to the map route — this sheet never navigates itself).
Future<List<Recipe>?> showReviewSelectionSheet(
  BuildContext context, {
  required List<Recipe> recipes,
}) {
  return showModalBottomSheet<List<Recipe>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _ReviewSelectionSheet(recipes: recipes),
  );
}

class _ReviewSelectionSheet extends StatelessWidget {
  const _ReviewSelectionSheet({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            _GrabHandle(),
            const SizedBox(height: AppSizes.md),
            _Header(count: recipes.length),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                  vertical: AppSizes.sm,
                ),
                itemCount: recipes.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.sm),
                itemBuilder: (context, index) =>
                    RecipePlanRow(recipe: recipes[index]),
              ),
            ),
            _FooterBar(
              onBack: () => Navigator.of(context).pop(),
              onMap: () => Navigator.of(context).pop(recipes),
            ),
          ],
        ),
      ),
    );
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
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Selection', style: textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            '$count selected',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
          ),
        ],
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({required this.onBack, required this.onMap});

  final VoidCallback onBack;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        AppSizes.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppPillButton(
              label: 'Back',
              variant: AppPillButtonVariant.secondary,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: AppPillButton(label: 'Map Meals', onPressed: onMap),
          ),
        ],
      ),
    );
  }
}
