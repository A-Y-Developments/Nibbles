import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Status label pill rendered on the header card.
///
/// Per spec 5 — Ongoing salmon-ghost / Safe sage-tint / Unsafe coral.
/// `safe` is the canonical 'completed' status — never use `completed`.
class DetailStatusPill extends StatelessWidget {
  const DetailStatusPill({required this.status, super.key});

  final AllergenStatus status;

  ({String label, Color bg, Color fg}) _styling() {
    switch (status) {
      case AllergenStatus.notStarted:
        return (
          label: 'Not started',
          bg: AppColors.surfaceVariant,
          fg: AppColors.fgMuted,
        );
      case AllergenStatus.inProgress:
        return (
          label: 'Ongoing',
          bg: AppColors.coralSoft,
          fg: AppColors.coralDeep,
        );
      case AllergenStatus.safe:
        return (
          label: 'Safe',
          bg: AppColors.greenTint,
          fg: AppColors.greenDeep,
        );
      case AllergenStatus.flagged:
        return (label: 'Unsafe', bg: AppColors.coral, fg: AppColors.cream);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _styling();
    return Container(
      height: AppSizes.chipHeightSm,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      alignment: Alignment.center,
      child: Text(
        s.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: s.fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}
