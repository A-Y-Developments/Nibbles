import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Three discrete introduction segments (one per logged give, max 3).
///
/// Filled = times the allergen was introduced; remainder = not yet introduced.
/// Count is the total log count, capped at 3. [onDark] swaps the palette for
/// the burgundy detail header (lime fill on a translucent-white track).
class DetailSegmentBar extends StatelessWidget {
  const DetailSegmentBar({
    required this.introducedCount,
    this.onDark = false,
    super.key,
  });

  final int introducedCount;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final filledCount = introducedCount.clamp(0, 3);
    final fill = onDark ? AppColors.lime : AppColors.green;
    final track = onDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.borderMuted;
    return Row(
      children: List<Widget>.generate(3, (i) {
        final isFilled = i < filledCount;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : AppSizes.xs),
            child: Container(
              height: 8,
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
