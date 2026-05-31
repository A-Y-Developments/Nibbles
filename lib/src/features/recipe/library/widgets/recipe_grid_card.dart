import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Recipe library / home recommendation card (NIB-53 redesign).
///
/// Visual target is a 158x220 tile per Figma 971:8661 — image-top (117 high,
/// white surface) + 12px-padded content column containing a 2-line title and
/// a row of salmon-ghost chips ('Iron Rich' bolt chip + a `+N` overflow
/// chip). Flagged-allergen recipes show a [AppChipTone.flag] 'Not safe'
/// chip overlaid on the image and dim the card slightly.
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

  // Figma 760:7436 paragraph block (158x117 thumb + 12 padding + 40px
  // title block + 24px chip row + 12 padding = 220 total).
  static const double _titleBlockHeight = 40;

  @override
  Widget build(BuildContext context) {
    final isUnsafe = _hasUnsafeAllergen;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isUnsafe ? 0.85 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: ColoredBox(
            color: AppColors.cream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardThumbnail(
                  url: recipe.thumbnailUrl,
                  isUnsafe: isUnsafe,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.sp12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: _titleBlockHeight,
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontFamily: FontFamily.parkinsans,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 20 / 13,
                            color: AppColors.fgStrong,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _NutritionChipRow(tags: recipe.nutritionTags),
                    ],
                  ),
                ),
              ],
            ),
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

  // Figma 760:7432 thumbnail container: 158w x 117h, white bg.
  static const double _thumbHeight = 117;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thumbHeight,
      width: double.infinity,
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
              memCacheWidth:
                  (158 * MediaQuery.devicePixelRatioOf(context)).round(),
              memCacheHeight:
                  (117 * MediaQuery.devicePixelRatioOf(context)).round(),
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
    );
  }
}

/// First nutrition tag as a salmon-ghost chip (Figma 'Iron Rich' label) +
/// `+N` overflow chip for the rest. Both use [AppChipTone.neutral] so the
/// chip background and text colour follow the Figma 'LabelContain' token
/// (salmon-ghost / salmon-dark). When there are no tags, renders a fixed-
/// height spacer so the card height stays stable across recipes.
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
          child: AppChip(
            label: tags.first,
            icon: const Icon(Icons.bolt),
          ),
        ),
        if (extra > 0) ...[
          const SizedBox(width: AppSizes.xs),
          AppChip(label: '+$extra'),
        ],
      ],
    );
  }
}
