import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Shared recipe row for meal-plan contexts (Figma 2765:16144 "mp-card") —
/// used by the day accordion list and the Add-to-Meal-Plan sheet, which
/// rendered byte-identical rows independently before this was factored out.
///
/// Thumbnail + title + a single primary attribute chip (first nutrition tag,
/// falling back to age range) plus a `+N` chip for the rest — both chips
/// share the same tone, never a muted/grey one.
class RecipePlanRow extends StatelessWidget {
  const RecipePlanRow({
    required this.recipe,
    this.onTap,
    this.flaggedAllergenNames = const [],
    super.key,
  });

  final Recipe? recipe;
  final VoidCallback? onTap;

  /// Display names of allergens on this recipe that are currently flagged —
  /// surfaced only in the semantics label, not visually.
  final List<String> flaggedAllergenNames;

  static const double _thumbnailWidth = 90;
  static const double _thumbnailHeight = 76;

  @override
  Widget build(BuildContext context) {
    final title = recipe?.title ?? '…';
    final attributes = <String>[
      ...(recipe?.nutritionTags ?? const <String>[]),
      if (recipe?.ageRange != null) recipe!.ageRange,
    ];
    final semanticsLabel = flaggedAllergenNames.isEmpty
        ? title
        : '$title, flagged: ${flaggedAllergenNames.join(', ')}';

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sp12,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          _Thumbnail(url: recipe?.thumbnailUrl),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.fgStrong,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      Flexible(child: AppChip(label: attributes.first)),
                      if (attributes.length > 1) ...[
                        const SizedBox(width: AppSizes.xs),
                        AppChip(
                          label: '${attributes.length - 1}',
                          icon: const Icon(Icons.add, size: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: onTap == null
          ? content
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: content,
            ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const width = RecipePlanRow._thumbnailWidth;
    const height = RecipePlanRow._thumbnailHeight;
    Widget child;
    if (url == null || url!.isEmpty) {
      child = const _ThumbnailPlaceholder();
    } else if (url!.startsWith('assets/')) {
      child = Image.asset(
        url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ThumbnailPlaceholder(),
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => const _ThumbnailPlaceholder(),
        errorWidget: (_, __, ___) => const _ThumbnailPlaceholder(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: child,
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Assets.images.recipe.mockRecipe.image(
      width: RecipePlanRow._thumbnailWidth,
      height: RecipePlanRow._thumbnailHeight,
      fit: BoxFit.cover,
    );
  }
}
