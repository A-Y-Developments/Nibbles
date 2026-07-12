import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Three discrete introduction segments (one per logged give, max 3).
///
/// One segment per exposure (oldest-first, capped at 3): a clean exposure
/// fills lime/green, an exposure that had a reaction fills coral, and remaining
/// slots stay on the track colour. [onDark] swaps the palette for the burgundy
/// cards (fills on a translucent-white track).
class DetailSegmentBar extends StatelessWidget {
  const DetailSegmentBar({
    required this.reactionFlags,
    this.onDark = false,
    super.key,
  });

  /// Per-exposure reaction flags, oldest-first. `true` = that exposure had a
  /// reaction. Only the first 3 are shown.
  final List<bool> reactionFlags;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final flags = reactionFlags.take(3).toList(growable: false);
    final safeFill = onDark ? AppColors.lime : AppColors.green;
    const reactionFill = AppColors.coral;
    final track = onDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.borderMuted;
    return Row(
      children: List<Widget>.generate(3, (i) {
        final Color color;
        if (i < flags.length) {
          color = flags[i] ? reactionFill : safeFill;
        } else {
          color = track;
        }
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : AppSizes.xs),
            child: AnimatedContainer(
              duration: AppDurations.base,
              curve: AppCurves.standard,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}
