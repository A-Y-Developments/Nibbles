import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

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
        opacity: isUnsafe ? 0.7 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: isUnsafe
                ? Border.all(
                    color: AppColors.allergenFlagged.withValues(alpha: 0.4),
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _GridThumbnail(url: recipe.thumbnailUrl),
                  if (isUnsafe)
                    Positioned(
                      top: AppSizes.xs,
                      left: AppSizes.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.allergenFlagged,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Not safe',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.sm,
                    AppSizes.sm,
                    AppSizes.sm,
                    AppSizes.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      _AgeTag(ageRange: recipe.ageRange),
                      if (recipe.allergenTags.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.xs),
                        _AllergenChips(
                          tags: recipe.allergenTags,
                          flaggedKeys: flaggedAllergenKeys,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridThumbnail extends StatelessWidget {
  const _GridThumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(AppSizes.radiusMd),
      topRight: Radius.circular(AppSizes.radiusMd),
    );

    if (url == null || url!.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: borderRadius,
          ),
          child: const Icon(
            Icons.restaurant_outlined,
            color: AppColors.hint,
            size: AppSizes.iconLg,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const ColoredBox(color: AppColors.surfaceVariant),
          errorWidget: (_, __, ___) => const ColoredBox(
            color: AppColors.surfaceVariant,
            child: Icon(
              Icons.restaurant_outlined,
              color: AppColors.hint,
              size: AppSizes.iconLg,
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeTag extends StatelessWidget {
  const _AgeTag({required this.ageRange});

  final String ageRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        'Fit for: $ageRange',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class _AllergenChips extends StatelessWidget {
  const _AllergenChips({required this.tags, this.flaggedKeys = const {}});

  final List<String> tags;
  final Set<String> flaggedKeys;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.xs,
      children: tags
          .map(
            (tag) => Text(
              AllergenEmoji.get(tag),
              style: TextStyle(
                fontSize: 12,
                color: flaggedKeys.contains(tag)
                    ? AppColors.allergenFlagged
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
