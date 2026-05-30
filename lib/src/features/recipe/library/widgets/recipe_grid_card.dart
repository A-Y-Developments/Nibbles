import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Recipe library / home recommendation card (NIB-53 reskin).
///
/// Visual target is a 158x220 tile per Figma 971:8760 — image-top + headline
/// + a leading nutrition chip with a `+N` overflow chip when the recipe has
/// more than one nutrition tag. Flagged-allergen recipes show a
/// [AppChipTone.flag] 'Not safe' chip overlaid on the image.
///
/// The card is width-flexible (parent provides the box) so the same widget
/// continues to render in the Home carousel (140-wide `SizedBox`) and the
/// Home recommendations grid (aspect-ratio driven) — only the Library row
/// pins the box to 158x220.
class RecipeGridCard extends StatelessWidget {
  const RecipeGridCard({
    required this.recipe,
    required this.onTap,
    this.flaggedAllergenKeys = const {},
    super.key,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final Set<String> flaggedAllergenKeys;

  bool get _hasUnsafeAllergen =>
      recipe.allergenTags.any(flaggedAllergenKeys.contains);

  @override
  Widget build(BuildContext context) {
    final isUnsafe = _hasUnsafeAllergen;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isUnsafe ? 0.85 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: AppSizes.shadowCard,
          ),
          padding: const EdgeInsets.all(AppSizes.sp12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardThumbnail(
                url: recipe.thumbnailUrl,
                isUnsafe: isUnsafe,
              ),
              const SizedBox(height: AppSizes.sm + 2),
              Text(
                recipe.title,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.sm - 2),
              _NutritionChipRow(tags: recipe.nutritionTags),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({required this.url, required this.isUnsafe});

  final String? url;
  final bool isUnsafe;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 134 / 110,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null || url!.isEmpty)
              const ColoredBox(
                color: AppColors.tan20,
                child: Icon(
                  Icons.restaurant_outlined,
                  color: AppColors.tan60,
                  size: AppSizes.iconLg,
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: AppColors.tan20),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: AppColors.tan20,
                  child: Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.tan60,
                    size: AppSizes.iconLg,
                  ),
                ),
              ),
            if (isUnsafe)
              const Positioned(
                top: AppSizes.xs + 2,
                left: AppSizes.xs + 2,
                child: AppChip(
                  label: 'Not safe',
                  tone: AppChipTone.flag,
                  icon: Icon(Icons.warning_amber_rounded),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// First nutrition tag as a salmon-ghost chip + `+N` mute chip for the rest.
/// When there are no tags, renders a fixed-height spacer so the card height
/// stays stable across recipes.
class _NutritionChipRow extends StatelessWidget {
  const _NutritionChipRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox(height: AppSizes.chipHeightSm);
    }
    final extra = tags.length - 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: AppChip(label: tags.first),
        ),
        if (extra > 0) ...[
          const SizedBox(width: AppSizes.xs),
          AppChip(label: '+$extra', tone: AppChipTone.mute),
        ],
      ],
    );
  }
}
