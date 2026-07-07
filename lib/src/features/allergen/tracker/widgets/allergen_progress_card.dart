import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_icon_tile.dart';

/// Card for an allergen the user has tried or is currently introducing.
///
/// Figma 2780:13178 (Big 11 "Already Tried" / "Ongoing"):
///  - Quatrefoil allergen tile · name · "N/3 times" · status pill · chevron
///  - 3-segment progress bar (filled segments = total exposures, capped at 3)
class AllergenProgressCard extends StatelessWidget {
  const AllergenProgressCard({
    required this.allergen,
    required this.status,
    required this.totalLogCount,
    required this.onTap,
    super.key,
  });

  final Allergen allergen;
  final AllergenStatus status;

  /// All logs (safe + reaction) for this allergen — drives "N/3 times" and the
  /// segmented bar fill. A reaction turns the whole bar red via [_barTone].
  final int totalLogCount;

  final VoidCallback onTap;

  AppSegmentedProgressTone get _barTone {
    switch (status) {
      case AllergenStatus.flagged:
        return AppSegmentedProgressTone.flag;
      case AllergenStatus.safe:
      case AllergenStatus.inProgress:
      case AllergenStatus.notStarted:
        return AppSegmentedProgressTone.green;
    }
  }

  Widget? _trailingChip() {
    switch (status) {
      case AllergenStatus.safe:
        return const AppChip(label: 'Safe', tone: AppChipTone.safe);
      case AllergenStatus.flagged:
        return const AppChip(label: 'Unsafe', tone: AppChipTone.flag);
      case AllergenStatus.inProgress:
        return const AppChip(label: 'Ongoing');
      case AllergenStatus.notStarted:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trailingChip = _trailingChip();
    final clamped = totalLogCount.clamp(0, 3);

    return Semantics(
      identifier: 'allergen_card_${allergen.key}',
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const AllergenIconTile(size: 52),
                const SizedBox(width: AppSizes.sp12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(allergen.name, style: textTheme.titleSmall),
                      const SizedBox(height: AppSizes.sp2),
                      Text(
                        '$clamped/3 times',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingChip != null) ...[
                  trailingChip,
                  const SizedBox(width: AppSizes.sm),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  size: AppSizes.iconMd,
                  color: AppColors.fgFaint,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sp12),
            AppSegmentedProgressBar(filledCount: clamped, tone: _barTone),
          ],
        ),
      ),
    );
  }
}
