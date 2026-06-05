import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';

/// Card for an allergen that hasn't been logged yet (status `notStarted`).
///
/// Visual spec — Figma 1116:18287 / "Not Tried" row:
///  - Grey card bg (borderSoft / #EAEAEA)
///  - Allergen icon in neutral circle
///  - Name + "Not Tried" subhead
///  - Lime pill "Start Introduce" CTA (butter bg, greenDeep text)
///
/// Tap opens the existing log capture sheet for that allergen (the saved
/// log flips the derived status to `inProgress` on next read).
class StartIntroduceCard extends StatelessWidget {
  const StartIntroduceCard({
    required this.allergen,
    required this.onStartIntroduce,
    super.key,
  });

  final Allergen allergen;
  final VoidCallback onStartIntroduce;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: AppColors.borderSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: const BoxDecoration(
              color: AppColors.borderMuted,
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
                  'Not Tried',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          AppPillButton(
            label: 'Start Introduce',
            onPressed: onStartIntroduce,
            variant: AppPillButtonVariant.ghost,
            size: AppPillButtonSize.small,
            expand: false,
          ),
        ],
      ),
    );
  }
}
