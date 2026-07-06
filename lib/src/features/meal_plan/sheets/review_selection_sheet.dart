import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
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
                itemBuilder: (context, index) => _ReviewRow(
                  recipe: recipes[index],
                ),
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

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          _Thumbnail(url: recipe.thumbnailUrl),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  recipe.title,
                  style: AppTypography.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.xs),
                _MetaRow(recipe: recipe),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Iron-Rich / nutrition chips + age range under the recipe title.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final tags = recipe.nutritionTags.take(2).toList();
    final extra = recipe.nutritionTags.length - tags.length;
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tag in tags) AppChip(label: tag),
        if (extra > 0) AppChip(label: '+$extra', tone: AppChipTone.mute),
        Text(
          recipe.ageRange,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.fgMuted),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.xxl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: (url == null || url!.isEmpty)
          ? Container(
              width: size,
              height: size,
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.restaurant_outlined,
                color: AppColors.hint,
                size: AppSizes.iconMd,
              ),
            )
          : CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: size,
                height: size,
                color: AppColors.surfaceVariant,
              ),
              errorWidget: (_, __, ___) => Container(
                width: size,
                height: size,
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.restaurant_outlined,
                  color: AppColors.hint,
                  size: AppSizes.iconMd,
                ),
              ),
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
