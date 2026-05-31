import 'package:flutter/material.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// Verbatim helper line under "Meals for {Day} (X/Y)" — see Figma frames
/// 971:8375 (inside the empty placeholder) and 971:8476 (above the
/// populated container).
const _kHelperText = 'Drag & drop or click meals below to add them';

/// "Meals for {Day}" panel for the Map Meals Plan screen (NIB-95).
///
/// * Empty: dashed-border placeholder card containing
///   "No Meals Mapped Yet" + a Drag-&-drop helper line (frame 971:8375).
/// * Populated: cream-tinted dashed container holding one row per
///   assigned recipe (thumbnail + title + allergen tags + delete_outline
///   to unassign) — see frames 971:8476 / 971:8511.
class SelectedDaySlotList extends StatelessWidget {
  const SelectedDaySlotList({
    required this.recipes,
    required this.onRemove,
    super.key,
  });

  final List<Recipe> recipes;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const _EmptyDayPlaceholder();
    }
    return _PopulatedDayContainer(recipes: recipes, onRemove: onRemove);
  }
}

/// Cream-tinted dashed container holding the assigned recipe rows.
class _PopulatedDayContainer extends StatelessWidget {
  const _PopulatedDayContainer({
    required this.recipes,
    required this.onRemove,
  });

  final List<Recipe> recipes;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.butterSoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        padding: const EdgeInsets.all(AppSizes.sp12),
        child: Column(
          children: [
            for (var i = 0; i < recipes.length; i++) ...[
              if (i != 0) const SizedBox(height: AppSizes.sm),
              _AssignedRecipeCard(
                recipe: recipes[i],
                onRemove: () => onRemove(recipes[i].id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Recipe card displayed inside a filled day slot.
///
/// Mirrors the Figma frame 971:8476 layout — thumbnail, two-line title,
/// allergen tag chips, and a trailing `delete_outline` icon that
/// unassigns the recipe.
class _AssignedRecipeCard extends StatelessWidget {
  const _AssignedRecipeCard({required this.recipe, required this.onRemove});

  final Recipe recipe;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sp12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recipe.allergenTags.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  _TagsRow(tags: recipe.allergenTags),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.fgMuted,
              size: AppSizes.iconMd,
            ),
            visualDensity: VisualDensity.compact,
            splashRadius: AppSizes.iconMd,
          ),
        ],
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

class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.lg,
        ),
        child: Column(
          children: [
            Text(
              'No Meals Mapped Yet',
              style: AppTypography.bodyBold.copyWith(color: AppColors.fgMuted),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              _kHelperText,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.fgMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.dividerThickness;

    const dashWidth = 6.0;
    const dashGap = 4.0;
    const radius = AppSizes.radiusLg;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
