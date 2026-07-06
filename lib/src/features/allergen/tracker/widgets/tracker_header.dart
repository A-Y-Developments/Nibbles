import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';

/// Header block above the segmented control on the Allergen Tracker.
///
/// Figma frames 1089:17373 (Ongoing) / 1116:18287 (Big 11):
///  - Centred coral progress ring (introduced / 9) above
///  - Horizontal row of stat columns (big black number + grey label)
///
/// Visible columns:
///  - Ongoing tab → "Safe foods" + "Unsafe"
///  - Big 11 tab → adds "Not Tried"
class TrackerHeader extends StatelessWidget {
  const TrackerHeader({
    required this.introducedCount,
    required this.safeCount,
    required this.flaggedCount,
    required this.notTriedCount,
    required this.showNotTried,
    super.key,
  });

  /// Number of allergens with any logged exposure. Drives the ring fill —
  /// matches the Figma `1/9` numerator (Allergen Tracker open question
  /// resolved per ticket: "introduced count").
  final int introducedCount;
  final int safeCount;
  final int flaggedCount;
  final int notTriedCount;
  final bool showNotTried;

  static const int _totalAllergens = 11;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppProgressRing(value: introducedCount, max: _totalAllergens),
        const SizedBox(height: AppSizes.md),
        _StatRow(
          showNotTried: showNotTried,
          safeCount: safeCount,
          flaggedCount: flaggedCount,
          notTriedCount: notTriedCount,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.showNotTried,
    required this.safeCount,
    required this.flaggedCount,
    required this.notTriedCount,
  });

  final bool showNotTried;
  final int safeCount;
  final int flaggedCount;
  final int notTriedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatColumn(value: safeCount, label: 'Safe foods'),
        ),
        Expanded(
          child: _StatColumn(value: flaggedCount, label: 'Unsafe'),
        ),
        if (showNotTried)
          Expanded(
            child: _StatColumn(value: notTriedCount, label: 'Not Tried'),
          ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: textTheme.displaySmall?.copyWith(color: AppColors.fgStrong),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppColors.fgFaint),
        ),
      ],
    );
  }
}
