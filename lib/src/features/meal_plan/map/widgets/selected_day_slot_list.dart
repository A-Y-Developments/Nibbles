import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/meal_recipe_card.dart';

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
    final targetBorder = isHovering ? AppColors.green : AppColors.borderMuted;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetBorder),
      duration: AppDurations.base,
      curve: AppCurves.standard,
      builder: (context, color, _) {
        final borderColor = color ?? targetBorder;
        return AnimatedSize(
          duration: AppDurations.base,
          curve: AppCurves.standard,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: AppDurations.fade,
            switchInCurve: AppCurves.standard,
            child: recipes.isEmpty
                ? _EmptyDayPlaceholder(
                    key: const ValueKey<bool>(true),
                    borderColor: borderColor,
                  )
                : _PopulatedDayContainer(
                    key: const ValueKey<bool>(false),
                    recipes: recipes,
                    onRemoveAt: onRemoveAt,
                    borderColor: borderColor,
                  ),
          ),
        );
      },
    );
  }
}

/// Cream-tinted dashed container holding the assigned recipe cards.
class _PopulatedDayContainer extends StatelessWidget {
  const _PopulatedDayContainer({
    required this.recipes,
    required this.onRemoveAt,
    required this.borderColor,
    super.key,
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
              MealRecipeCard(
                recipe: recipes[i],
                trailing: IconButton(
                  onPressed: () => onRemoveAt(i),
                  tooltip: 'Remove ${recipes[i].title} from day',
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.fgMuted,
                    size: 18,
                  ),
                  visualDensity: VisualDensity.compact,
                  splashRadius: AppSizes.iconMd,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder({required this.borderColor, super.key});

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
