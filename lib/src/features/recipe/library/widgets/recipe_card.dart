import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({required this.recipe, required this.onTap, super.key});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.pagePaddingH,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _Thumbnail(url: recipe.thumbnailUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm + AppSizes.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                      _AllergenChips(tags: recipe.allergenTags),
                    ],
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.hint,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSizes.sm),
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
    const size = 72.0;
    const radius = BorderRadius.only(
      topLeft: Radius.circular(AppSizes.radiusMd),
      bottomLeft: Radius.circular(AppSizes.radiusMd),
    );

    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: radius,
        ),
        child: const Icon(
          Icons.restaurant_outlined,
          color: AppColors.hint,
          size: AppSizes.iconLg,
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
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
            size: AppSizes.iconLg,
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
        ageRange,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AllergenChips extends StatelessWidget {
  const _AllergenChips({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.xs,
      children: tags
          .map(
            (tag) => Text(
              AllergenEmoji.get(tag),
              style: const TextStyle(fontSize: 14),
            ),
          )
          .toList(),
    );
  }
}
