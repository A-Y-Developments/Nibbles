import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Recipe library card (NIB-53 redesign).
///
/// Visual target is a 158x220 tile per Figma 971:8661 — image-top (117 high,
/// white surface) + 12px-padded content column. The content column fills the
/// remaining card height and uses space-between to pin the 2-line title to
/// the top and the salmon-ghost chip row (bolt 'Iron Rich' chip + a `+N`
/// overflow chip) to the bottom. Flagged-allergen recipes show a
/// [AppChipTone.flag] 'Not safe' chip overlaid on the image and dim the card.
///
/// Library-only: rendered by `RecipeCategoryRow` (horizontal 158x220 row)
/// and `RecipeSearchResults` (2-column 158x220 grid). Both pin the box.
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

  // Figma 760:7436 title block: 2 lines x 20 = 40h. Slack between the title
  // and the bottom-pinned chip row is absorbed by space-between, not a gap.
  static const double _titleBlockHeight = 40;

  @override
  Widget build(BuildContext context) {
    final isUnsafe = _hasUnsafeAllergen;

    return Semantics(
      button: true,
      label: isUnsafe ? '${recipe.title}, not safe' : recipe.title,
      identifier: 'recipe_card_${recipe.id}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: isUnsafe ? 0.85 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: ColoredBox(
              color: AppColors.cream,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardThumbnail(url: recipe.thumbnailUrl, isUnsafe: isUnsafe),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.sp12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          _NutritionChipRow(tags: recipe.nutritionTags),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
              memCacheWidth: (158 * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              memCacheHeight: (117 * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              placeholder: (_, __) => const ColoredBox(color: AppColors.tan20),
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

/// First nutrition tag as a salmon-ghost chip (Figma 'Iron Rich' bolt label)
/// + a `+N` overflow chip for the rest. The label chip is [Flexible] and
/// ellipsizes so a long tag never overflows the ~134px content width; the
/// `+N` chip is non-shrinking. When there are no tags, renders a fixed-
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
        Flexible(child: _NutritionChip(label: tags.first)),
        if (extra > 0) ...[
          const SizedBox(width: AppSizes.xs),
          _NutritionChip.overflow(count: extra),
        ],
      ],
    );
  }
}

/// Card-local salmon-ghost nutrition chip (Figma 'LabelContain', node
/// 1082:7250). bg coralSoft / fg coralDeep, Figtree Regular 10/16, h24,
/// radius 30. Deliberately NOT the shared [AppChip] (Parkinsans 11/700):
/// this chip needs the Figtree caption token and a flexible, ellipsizing
/// label so the row stays overflow-safe on the narrow card.
class _NutritionChip extends StatelessWidget {
  const _NutritionChip({required this.label})
    : count = null,
      isOverflow = false;

  const _NutritionChip.overflow({required this.count})
    : label = '',
      isOverflow = true;

  final String label;
  final int? count;
  final bool isOverflow;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.figtree(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 16 / 10,
      color: AppColors.coralDeep,
    );

    return Container(
      height: AppSizes.chipHeightSm,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppSizes.radius3xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverflow ? Icons.add : Icons.bolt,
            size: AppSizes.iconSm,
            color: AppColors.coralDeep,
          ),
          SizedBox(width: isOverflow ? AppSizes.xs : AppSizes.sm),
          if (isOverflow)
            Text('${count ?? 0}', style: textStyle)
          else
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
        ],
      ),
    );
  }
}
