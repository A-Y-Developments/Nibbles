import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';

/// Card for an allergen that hasn't been logged yet (status `notStarted`).
///
/// Renders the allergen icon + name and a small Start Introduce CTA that
/// opens the existing log capture sheet for that allergen (the saved log
/// flips the derived status to `inProgress` on next read — there is no
/// server-side "mark started" write).
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

    return AppCard(
      variant: AppCardVariant.dashed,
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
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
                Text(allergen.name, style: textTheme.labelLarge),
                const SizedBox(height: 2),
                Text('Not tried yet', style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          AppPillButton(
            label: 'Start Introduce',
            onPressed: onStartIntroduce,
            size: AppPillButtonSize.small,
            expand: false,
          ),
        ],
      ),
    );
  }
}
