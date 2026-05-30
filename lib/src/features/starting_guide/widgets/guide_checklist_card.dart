import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';

/// Lime-fill card — title + score chip on the top row, then a vertical list
/// of check-mark rows. Matches "Readiness Signs 3/5" on 5 Sign Readiness
/// (Figma 1474:50031).
class GuideChecklistCard extends StatelessWidget {
  const GuideChecklistCard({
    required this.title,
    required this.score,
    required this.items,
    super.key,
  });

  final String title;
  final String score;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
              ),
              AppChip(label: score),
            ],
          ),
          const SizedBox(height: AppSizes.sp12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSizes.sp12),
            _ChecklistRow(text: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: AppColors.greenDeep,
          ),
        ),
        const SizedBox(width: AppSizes.sp12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgDefault,
            ),
          ),
        ),
      ],
    );
  }
}
