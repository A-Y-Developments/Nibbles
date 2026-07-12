import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Vertical recipe card used inside the recommendation carousels of the
/// Browse Meal sheet. Displays thumbnail, title, age range and a selection
/// indicator. When [unsafe] is true the card is visually disabled and
/// non-interactive.
class BrowseMealRecipeCard extends StatelessWidget {
  const BrowseMealRecipeCard({
    required this.recipe,
    required this.selected,
    required this.unsafe,
    required this.onTap,
    super.key,
  });

  final Recipe recipe;
  final bool selected;
  final bool unsafe;
  final VoidCallback onTap;

  static const double _cardWidth = 160;
  static const double _imageHeight = 100;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = selected ? AppColors.primary : AppColors.borderSoft;

    // NIB-165 — expose the whole card as a single selectable node so VoiceOver
    // users can find/pick a recipe and golden flows can target it by id.
    return Semantics(
      identifier: 'browse_meal_recipe_card_${recipe.id}',
      button: true,
      selected: selected,
      enabled: !unsafe,
      label: unsafe
          ? '${recipe.title}, ${recipe.ageRange}, flagged allergen'
          : '${recipe.title}, ${recipe.ageRange}',
      onTap: unsafe ? null : onTap,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: AppDurations.base,
        curve: AppCurves.standard,
        opacity: unsafe ? 0.5 : 1,
        child: GestureDetector(
          onTap: unsafe ? null : onTap,
          child: AnimatedContainer(
            duration: AppDurations.base,
            curve: AppCurves.standard,
            width: _cardWidth,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
              boxShadow: AppSizes.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusMd),
                        topRight: Radius.circular(AppSizes.radiusMd),
                      ),
                      child: _Thumbnail(url: recipe.thumbnailUrl),
                    ),
                    if (unsafe)
                      Positioned(
                        top: AppSizes.xs,
                        right: AppSizes.xs,
                        child: _UnsafeBadge(),
                      )
                    else
                      Positioned(
                        top: AppSizes.xs,
                        right: AppSizes.xs,
                        child: _SelectIndicator(selected: selected),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: textTheme.labelMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      if (recipe.nutritionTags.isNotEmpty) ...[
                        _NutritionChips(tags: recipe.nutritionTags),
                        const SizedBox(height: AppSizes.xs),
                      ],
                      Text(
                        recipe.ageRange,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.fgMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

/// First nutrition tag (e.g. "Iron-Rich") as a coral chip, plus a "+N" mute
/// chip when the recipe carries more. Single row — the 160px card can't fit
/// a wrap without pushing the age line off.
class _NutritionChips extends StatelessWidget {
  const _NutritionChips({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final extra = tags.length - 1;
    return Row(
      children: [
        Flexible(child: AppChip(label: tags.first, flexibleLabel: true)),
        if (extra > 0) ...[
          const SizedBox(width: AppSizes.xs),
          AppChip(label: '$extra', icon: const Icon(Icons.add, size: 12)),
        ],
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const height = BrowseMealRecipeCard._imageHeight;
    const width = BrowseMealRecipeCard._cardWidth;

    if (url == null || url!.isEmpty) {
      return _fallback(width, height);
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(url!, width: width, height: height, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) =>
          Container(width: width, height: height, color: AppColors.tan20),
      errorWidget: (_, __, ___) => _fallback(width, height),
    );
  }

  Widget _fallback(double width, double height) => Assets
      .images
      .recipe
      .mockRecipe
      .image(width: width, height: height, fit: BoxFit.cover);
}

class _SelectIndicator extends StatelessWidget {
  const _SelectIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.base,
      curve: AppCurves.standard,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderMuted,
        ),
      ),
      child: AnimatedSwitcher(
        duration: AppDurations.quick,
        switchInCurve: AppCurves.emphasized,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: selected
            ? const Icon(
                Icons.check,
                key: ValueKey<bool>(true),
                size: 16,
                color: AppColors.onPrimary,
              )
            : const SizedBox.shrink(key: ValueKey<bool>(false)),
      ),
    );
  }
}

class _UnsafeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: AppColors.flagFg,
          ),
          const SizedBox(width: 2),
          Text(
            'Flagged',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.flagFg,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// List row used inside the searchable master list of the Browse Meal sheet.
class BrowseMealRecipeRow extends StatelessWidget {
  const BrowseMealRecipeRow({
    required this.recipe,
    required this.selected,
    required this.unsafe,
    required this.flaggedTags,
    required this.onTap,
    super.key,
  });

  final Recipe recipe;
  final bool selected;
  final bool unsafe;
  final List<String> flaggedTags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: AppDurations.base,
      curve: AppCurves.standard,
      opacity: unsafe ? 0.5 : 1,
      child: InkWell(
        onTap: unsafe ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.sm + AppSizes.xs,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: _RowThumbnail(url: recipe.thumbnailUrl),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (unsafe)
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 13,
                            color: AppColors.flagFg,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              'Not safe: ${_formatFlaggedTags(flaggedTags)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.flagFg,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        recipe.ageRange,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _RowSelectIndicator(selected: selected, disabled: unsafe),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowThumbnail extends StatelessWidget {
  const _RowThumbnail({required this.url});

  final String? url;

  static const double _w = 90;
  static const double _h = 76;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallback();
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(url!, width: _w, height: _h, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: _w,
      height: _h,
      fit: BoxFit.cover,
      placeholder: (_, __) =>
          Container(width: _w, height: _h, color: AppColors.tan20),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Assets.images.recipe.mockRecipe.image(
    width: _w,
    height: _h,
    fit: BoxFit.cover,
  );
}

String _formatFlaggedTags(List<String> tags) => tags
    .map((t) => '${AllergenEmoji.get(t)} ${AllergenEmoji.displayName(t)}')
    .join(', ');

class _RowSelectIndicator extends StatelessWidget {
  const _RowSelectIndicator({required this.selected, required this.disabled});

  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? AppColors.primary : AppColors.surface;
    final border = selected
        ? AppColors.primary
        : (disabled ? AppColors.borderSoft : AppColors.borderMuted);
    return AnimatedContainer(
      duration: AppDurations.base,
      curve: AppCurves.standard,
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: border),
      ),
      child: AnimatedSwitcher(
        duration: AppDurations.quick,
        switchInCurve: AppCurves.emphasized,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: selected
            ? const Icon(
                Icons.check,
                key: ValueKey<bool>(true),
                size: 16,
                color: AppColors.onPrimary,
              )
            : const SizedBox.shrink(key: ValueKey<bool>(false)),
      ),
    );
  }
}
