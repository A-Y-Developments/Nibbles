import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Surface variant for [AppCard] — maps to kit `.card`, `.card--soft`,
/// `.card--dashed`.
enum AppCardVariant { plain, soft, dashed }

/// Base container surface. radiusXl (20), kit padding 14x16 snapped to grid.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.plain,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.md,
      vertical: AppSizes.sp12,
    ),
    this.onTap,
    this.borderColor = AppColors.borderMuted,
    this.borderWidth = 1.5,
    this.cornerRadius = AppSizes.radiusXl,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Dashed-border stroke color (only used by [AppCardVariant.dashed]).
  final Color borderColor;

  /// Dashed-border stroke width (only used by [AppCardVariant.dashed]).
  final double borderWidth;

  /// Corner radius for the surface and dashed border.
  final double cornerRadius;

  Color get _background {
    switch (variant) {
      case AppCardVariant.plain:
        return AppColors.surface;
      case AppCardVariant.soft:
        return AppColors.butterSoft;
      case AppCardVariant.dashed:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);

    Widget content = Container(
      decoration: BoxDecoration(color: _background, borderRadius: radius),
      padding: padding,
      child: child,
    );

    if (variant == AppCardVariant.dashed) {
      content = CustomPaint(
        painter: _DashedBorderPainter(
          color: borderColor,
          radius: cornerRadius,
          strokeWidth: borderWidth,
        ),
        child: content,
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: content),
      );
    }
    return content;
  }
}

/// Paints a 1.5px dashed rounded-rect border (kit `.card--dashed`).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}
