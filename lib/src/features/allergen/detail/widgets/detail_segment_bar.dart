import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Three discrete introduction segments (one per logged give, max 3).
///
/// Filled (green) = times the allergen was introduced; remainder (grey) =
/// not yet introduced. Count is the total log count, capped at 3.
class DetailSegmentBar extends StatelessWidget {
  const DetailSegmentBar({required this.introducedCount, super.key});

  final int introducedCount;

  @override
  Widget build(BuildContext context) {
    final filledCount = introducedCount.clamp(0, 3);
    return Row(
      children: List<Widget>.generate(3, (i) {
        final isFilled = i < filledCount;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : AppSizes.xs),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: isFilled ? AppColors.green : AppColors.borderMuted,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
        );
      }),
    );
  }
}
