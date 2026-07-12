import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/components/icons/allergen_icon.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Shared recipe card for the Map Meals Plan screen (NIB-95).
///
/// Used by both the "Meals Picked" palette rows and the assigned-slot cards.
/// The thumbnail is FULL-BLEED — flush to the card's left edge, no inner
/// padding/margin — and the card carries no border (only an optional lift
/// shadow while dragging). Differences between call sites are expressed via
/// [trailing] (drag handle vs. remove button) and [titleMaxLines].
class MealRecipeCard extends StatelessWidget {
  const MealRecipeCard({
    required this.recipe,
    required this.trailing,
    this.titleMaxLines = 1,
    this.elevated = false,
    super.key,
  });

  final Recipe recipe;
  final Widget trailing;
  final int titleMaxLines;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final cardHeight = titleMaxLines >= 2 ? 96.0 : 76.0;
    return SizedBox(
      height: cardHeight,
      child: AnimatedContainer(
        duration: AppDurations.base,
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: elevated
                  ? const Color(0x33000000)
                  : const Color(0x00000000),
              blurRadius: elevated ? 16 : 0,
              offset: elevated ? const Offset(0, 8) : Offset.zero,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: cardHeight,
                child: _Thumbnail(url: recipe.thumbnailUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.sp12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.title,
                        style: AppTypography.bodyBold,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.allergenTags.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.xs),
                        AllergenTagsRow(tags: recipe.allergenTags),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.sm),
                child: Center(child: trailing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed square thumbnail. Fills the tight constraints handed down by
/// [MealRecipeCard] (no fixed size of its own). Handles null/empty, bundled
/// `assets/` images, and remote URLs with a mock-recipe placeholder fallback.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  Widget _placeholder() =>
      Assets.images.recipe.mockRecipe.image(fit: BoxFit.cover);

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _placeholder();
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }
}

/// Allergen tag chips for a recipe card: the first allergen as a labelled
/// chip, remaining allergens collapsed into a `+N` chip.
class AllergenTagsRow extends StatelessWidget {
  const AllergenTagsRow({required this.tags, super.key});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final first = tags.first;
    final overflow = tags.length - 1;
    return Row(
      children: [
        Flexible(
          child: AppChip(
            label: AllergenEmoji.displayName(first),
            icon: AllergenIcon(allergenKey: first, size: 14),
            flexibleLabel: true,
          ),
        ),
        if (overflow > 0) ...[
          const SizedBox(width: AppSizes.xs),
          AppChip(label: '$overflow', icon: const Icon(Icons.add, size: 12)),
        ],
      ],
    );
  }
}
