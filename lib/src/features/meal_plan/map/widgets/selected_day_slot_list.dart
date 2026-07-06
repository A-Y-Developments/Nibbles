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

/// The `DragTarget` drop-zone body for the Map Meals Plan screen (NIB-95).
///
/// * Empty: dashed placeholder card containing "No Meals Mapped Yet" + a
///   drag-&-drop helper line (frame 971:8375).
/// * Populated: cream-tinted dashed container holding one card per assigned
///   recipe instance (thumbnail + title + allergen tags + x to unassign) —
///   frames 971:8476 / 971:8511. Removal is positional (duplicates allowed).
/// * While a drag hovers ([isHovering]) the dashed border turns green
///   (frame 971:8511).
class SelectedDaySlotList extends StatelessWidget {
  const SelectedDaySlotList({
    required this.recipes,
    required this.onRemoveAt,
    this.isHovering = false,
    super.key,
  });

  /// Ordered recipes for the selected day (duplicates preserved). Index is the
  /// removal key passed back through [onRemoveAt].
  final List<Recipe> recipes;
  final ValueChanged<int> onRemoveAt;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    final borderColor = isHovering ? AppColors.green : AppColors.borderMuted;
    if (recipes.isEmpty) {
      return _EmptyDayPlaceholder(borderColor: borderColor);
    }
    return _PopulatedDayContainer(
      recipes: recipes,
      onRemoveAt: onRemoveAt,
      borderColor: borderColor,
    );
  }
}

/// Cream-tinted dashed container holding the assigned recipe cards.
class _PopulatedDayContainer extends StatelessWidget {
  const _PopulatedDayContainer({
    required this.recipes,
    required this.onRemoveAt,
    required this.borderColor,
  });

  final List<Recipe> recipes;
  final ValueChanged<int> onRemoveAt;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: borderColor),
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
                onRemove: () => onRemoveAt(i),
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
/// allergen tag chips, and a trailing `close` icon that unassigns this
/// instance.
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
            tooltip: 'Remove ${recipe.title} from day',
            icon: const Icon(
              Icons.close,
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
              label: AllergenEmoji.displayName(t),
              emoji: AllergenEmoji.get(t),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder({required this.borderColor});

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: borderColor),
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
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
