import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';

/// Header block above the segmented control on the Allergen Tracker.
///
/// Renders the coral progress ring (safeCount / 9) on the left and a vertical
/// stack of stat columns on the right. The visible columns are decided by
/// the caller via [showNotTried] — `Not Tried` is rendered on the Big 11 tab
/// only (per spec rule 8).
class TrackerHeader extends StatelessWidget {
  const TrackerHeader({
    required this.safeCount,
    required this.flaggedCount,
    required this.notTriedCount,
    required this.showNotTried,
    super.key,
  });

  final int safeCount;
  final int flaggedCount;
  final int notTriedCount;
  final bool showNotTried;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppProgressRing(value: safeCount, max: 9),
        const SizedBox(width: AppSizes.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatRow(
                label: 'Safe',
                value: safeCount,
                color: AppColors.safeFg,
              ),
              const SizedBox(height: AppSizes.sm),
              _StatRow(
                label: 'Not Safe',
                value: flaggedCount,
                color: AppColors.flagFg,
              ),
              if (showNotTried) ...[
                const SizedBox(height: AppSizes.sm),
                _StatRow(
                  label: 'Not Tried',
                  value: notTriedCount,
                  color: AppColors.fgMuted,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: AppSizes.sm,
          height: AppSizes.sm,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
          ),
        ),
        Text(
          '$value',
          style: textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
