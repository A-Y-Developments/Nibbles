import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
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

    return Opacity(
      opacity: unsafe ? 0.5 : 1,
      child: GestureDetector(
        onTap: unsafe ? null : onTap,
        child: Container(
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
      return Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
        child: const Icon(
          Icons.restaurant_outlined,
          color: AppColors.hint,
          size: AppSizes.iconLg,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
        child: const Icon(
          Icons.restaurant_outlined,
          color: AppColors.hint,
          size: AppSizes.iconLg,
        ),
      ),
    );
  }
}

class _SelectIndicator extends StatelessWidget {
  const _SelectIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderMuted,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
          : null,
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

    return Opacity(
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
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
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

  @override
  Widget build(BuildContext context) {
    const size = 56.0;

    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: AppColors.surfaceVariant,
        child: const Icon(
          Icons.restaurant_outlined,
          color: AppColors.hint,
          size: AppSizes.iconMd,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, __) =>
          Container(width: size, height: size, color: AppColors.surfaceVariant),
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
    );
  }
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
    return Container(
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: border),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
          : null,
    );
  }
}
