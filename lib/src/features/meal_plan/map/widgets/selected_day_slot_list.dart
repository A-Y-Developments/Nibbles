import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';

/// "Meals for {Day}" panel for the Map Meals Plan screen (NIB-95).
///
/// Shows the recipes currently assigned to the selected day. If empty,
/// renders the dashed "No Meals Mapped Yet" placeholder. Each assigned
/// row exposes a remove button that unassigns the recipe.
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

    return Column(
      children: [
        for (var i = 0; i < recipes.length; i++) ...[
          if (i != 0) const SizedBox(height: AppSizes.sm),
          _AssignedRow(
            recipe: recipes[i],
            onRemove: () => onRemove(recipes[i].id),
          ),
        ],
      ],
    );
  }
}

class _AssignedRow extends StatelessWidget {
  const _AssignedRow({required this.recipe, required this.onRemove});

  final Recipe recipe;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sp12,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.green),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.greenDeep,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              recipe.title,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.greenDeep,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close,
              color: AppColors.greenDeep,
              size: AppSizes.iconSm,
            ),
            visualDensity: VisualDensity.compact,
            splashRadius: AppSizes.iconMd,
          ),
        ],
      ),
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
        alignment: Alignment.center,
        child: Text(
          'No Meals Mapped Yet',
          style: AppTypography.bodyBold.copyWith(color: AppColors.fgMuted),
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
