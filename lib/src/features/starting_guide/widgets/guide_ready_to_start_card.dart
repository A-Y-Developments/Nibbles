import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// White closing card — centered title + body + a single primary pill CTA.
/// Matches the "Ready to Start?" cards at the end of Introduction (Figma
/// 971:8744) and Feeding Principles (Figma 1474:50514).
class GuideReadyToStartCard extends StatelessWidget {
  const GuideReadyToStartCard({
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    super.key,
  });

  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          AppPillButton(label: ctaLabel, onPressed: onCta),
        ],
      ),
    );
  }
}
