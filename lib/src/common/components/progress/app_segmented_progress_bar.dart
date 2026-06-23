import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Fill tone for [AppSegmentedProgressBar].
enum AppSegmentedProgressTone { green, coral, flag }

/// Three discrete progress segments (Figma allergen-tracker pattern).
///
/// Each segment is a pill; filled segments use the variant fill, empty
/// segments use the variant track. Mirrors the segmented bar on the
/// allergen progress card (1525:20068 / 1525:19423) and the per-allergen
/// detail header (DetailSegmentBar).
class AppSegmentedProgressBar extends StatelessWidget {
  const AppSegmentedProgressBar({
    required this.filledCount,
    this.totalSegments = 3,
    this.tone = AppSegmentedProgressTone.green,
    this.height = 8,
    super.key,
  }) : assert(filledCount >= 0, 'filledCount must be >= 0'),
       assert(totalSegments > 0, 'totalSegments must be > 0');

  /// Number of filled segments (clamped to [totalSegments]).
  final int filledCount;
  final int totalSegments;
  final AppSegmentedProgressTone tone;
  final double height;

  Color get _fill {
    switch (tone) {
      case AppSegmentedProgressTone.green:
        return AppColors.green;
      case AppSegmentedProgressTone.coral:
        return AppColors.coralDeep;
      case AppSegmentedProgressTone.flag:
        return AppColors.destructiveSoft;
    }
  }

  Color get _track {
    switch (tone) {
      case AppSegmentedProgressTone.green:
        return AppColors.borderSoft;
      case AppSegmentedProgressTone.coral:
        return AppColors.coralSoft;
      case AppSegmentedProgressTone.flag:
        return AppColors.destructiveSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = filledCount.clamp(0, totalSegments);
    final fill = _fill;
    final track = _track;
    return Row(
      children: List<Widget>.generate(totalSegments, (i) {
        final isFilled = i < clamped;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i == totalSegments - 1 ? 0 : AppSizes.xs,
            ),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: isFilled ? fill : track,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}
