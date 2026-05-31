import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// A single picked-recipe row for the Map Meals Plan screen (NIB-95).
///
/// Renders thumbnail + title + allergen tag chips. Tap-to-assign drives
/// the controller's `assignToSelectedDay`. If [assignedLabel] is non-null
/// the row shows a trailing day badge (e.g. "Tue 3") so the user can see
/// at a glance which day a picked recipe already lives on.
class PickedRecipeRow extends StatelessWidget {
  const PickedRecipeRow({
    required this.recipe,
    required this.onTap,
    this.assignedLabel,
    super.key,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final String? assignedLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
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
                  if (recipe.allergenTags.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    _TagsRow(tags: recipe.allergenTags),
                  ],
                ],
              ),
            ),
            if (assignedLabel != null) ...[
              const SizedBox(width: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenTint,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  assignedLabel!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.greenDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        width: AppSizes.iconXl,
        height: AppSizes.iconXl,
        color: AppColors.surfaceVariant,
        child: url == null
            ? const Icon(
                Icons.restaurant,
                color: AppColors.fgFaint,
                size: AppSizes.iconMd,
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.restaurant,
                  color: AppColors.fgFaint,
                  size: AppSizes.iconMd,
                ),
              ),
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      children: tags
          .take(3)
          .map(
            (t) => AppChip(
              label: t.replaceAll('_', ' '),
              emoji: AllergenEmoji.get(t),
            ),
          )
          .toList(),
    );
  }
}
