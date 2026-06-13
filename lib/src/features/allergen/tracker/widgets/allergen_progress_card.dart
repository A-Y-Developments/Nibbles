import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Card for an allergen the user is currently introducing or has finished.
///
/// Visual spec — Figma frames 1089:17373 / 1116:18287 (board) +
/// AllergenProgres instances 1525:20068 (Safe) / 1525:19423 (Ongoing):
///  - Allergen icon (coralSoft circle) · name · status pill
///  - "N/3 times " subhead (Figma copy — trailing space preserved)
///  - 3-segment progress bar (filled segments = clean log count)
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

  /// Logs without `hadReaction == true`. Drives the segmented bar fill.
  final int cleanLogCount;

  /// All logs for this allergen (used for the "N total logs" caption).
  final int totalLogCount;

  final VoidCallback onTap;

  AppSegmentedProgressTone get _barTone {
    switch (status) {
      case AllergenStatus.safe:
        return AppSegmentedProgressTone.green;
      case AllergenStatus.flagged:
        return AppSegmentedProgressTone.flag;
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
        // Salmon-ghost pill: AppChipTone.neutral is the salmon-ghost token.
        return const AppChip(label: 'Ongoing');
      case AllergenStatus.notStarted:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trailingChip = _trailingChip();
    final clamped = cleanLogCount.clamp(0, 3);

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
                      Text(allergen.name, style: textTheme.titleSmall),
                      const SizedBox(height: AppSizes.sp2),
                      Text(
                        // Figma verbatim: keeps the trailing space on "N/3 times ".
                        '$clamped/3 times ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingChip != null) trailingChip,
              ],
            ),
            const SizedBox(height: AppSizes.sp12),
            AppSegmentedProgressBar(filledCount: clamped, tone: _barTone),
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
    );
  }
}
