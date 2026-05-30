import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/widgets/numbered_step.dart';

/// Butter-soft card containing a title, optional lead paragraph, and a
/// numbered list of [NumberedStep] rows. Used by Nibbles Goals (First
/// Nibbles), Feeding is Skill-Building (Introduction), Items to Avoid
/// (Feeding Principles).
class GuideNumberedListCard extends StatelessWidget {
  const GuideNumberedListCard({
    required this.title,
    required this.items,
    this.body,
    super.key,
  });

  final String title;
  final String? body;
  final List<NumberedItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              body!,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.sp12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSizes.sp12),
            NumberedStep(
              stepNumber: i + 1,
              heading: items[i].heading,
              body: items[i].body,
            ),
          ],
        ],
      ),
    );
  }
}
