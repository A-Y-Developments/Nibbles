import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Colour variant for [AppLinearProgress] — components-progress preview.
enum AppLinearProgressVariant { coral, green, butter }

/// Thin pill progress bar. Mirrors components-progress preview `.bar`:
/// 8px track, fill + matching track tint per variant.
class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    required this.value,
    this.variant = AppLinearProgressVariant.coral,
    this.height = 8,
    super.key,
  }) : assert(value >= 0 && value <= 1, 'value must be 0..1');

  /// Progress 0..1.
  final double value;
  final AppLinearProgressVariant variant;
  final double height;

  Color get _fill {
    switch (variant) {
      case AppLinearProgressVariant.coral:
        return AppColors.coralDeep;
      case AppLinearProgressVariant.green:
        return AppColors.green;
      case AppLinearProgressVariant.butter:
        return AppColors.progressButterFill;
    }
  }

  Color get _track {
    switch (variant) {
      case AppLinearProgressVariant.coral:
        return AppColors.coralSoft;
      case AppLinearProgressVariant.green:
        return AppColors.green.withValues(alpha: 0.18);
      case AppLinearProgressVariant.butter:
        return AppColors.butter.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Stack(
        children: [
          Container(height: height, width: double.infinity, color: _track),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: _fill,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
