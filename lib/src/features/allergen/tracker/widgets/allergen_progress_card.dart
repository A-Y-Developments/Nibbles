import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Card for an allergen the user is currently introducing or has finished.
///
/// Variants:
///  - [AllergenStatus.inProgress] — coral linear bar (N/3).
///  - [AllergenStatus.safe]       — green linear bar (3/3) + Safe chip.
///  - [AllergenStatus.flagged]    — coral bar filled, plus a Flagged chip.
class AllergenProgressCard extends StatelessWidget {
  const AllergenProgressCard({
    required this.allergen,
    required this.status,
    required this.cleanLogCount,
    required this.totalLogCount,
    required this.onTap,
    super.key,
  });

  final Allergen allergen;
  final AllergenStatus status;

  /// Logs without `hadReaction == true`. Drives the 0/3 bar fill.
  final int cleanLogCount;

  /// All logs for this allergen (used for "Log N total" caption).
  final int totalLogCount;

  final VoidCallback onTap;

  AppLinearProgressVariant get _variant {
    switch (status) {
      case AllergenStatus.safe:
        return AppLinearProgressVariant.green;
      case AllergenStatus.flagged:
      case AllergenStatus.inProgress:
      case AllergenStatus.notStarted:
        return AppLinearProgressVariant.coral;
    }
  }

  /// 0..1 — clamps clean logs at 3 (the "introduced" target).
  double get _progress => (cleanLogCount.clamp(0, 3)) / 3;

  Widget? get _trailingChip {
    switch (status) {
      case AllergenStatus.safe:
        return const AppChip(label: 'Safe', tone: AppChipTone.safe);
      case AllergenStatus.flagged:
        return const AppChip(label: 'Flagged', tone: AppChipTone.flag);
      case AllergenStatus.inProgress:
      case AllergenStatus.notStarted:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trailingChip = _trailingChip;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: const BoxDecoration(
              color: AppColors.coralSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              allergen.emoji,
              style: const TextStyle(fontSize: 24, height: 1),
            ),
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        allergen.name,
                        style: textTheme.labelLarge,
                      ),
                    ),
                    if (trailingChip != null) trailingChip,
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${cleanLogCount.clamp(0, 3)}/3 times',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSizes.sm),
                AppLinearProgress(value: _progress, variant: _variant),
                if (totalLogCount > cleanLogCount) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '$totalLogCount log${totalLogCount == 1 ? '' : 's'} total',
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
