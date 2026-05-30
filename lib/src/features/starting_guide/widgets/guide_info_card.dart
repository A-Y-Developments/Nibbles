import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/widgets/baby_face_glyph.dart';

/// White info card — small baby-face glyph, bold heading, body. Matches the
/// "SIMPLE AND PRACTICAL / EVIDENCE INFORMED / No Fluf" tiles on Baby's First
/// Nibbles (Figma 971:8730).
class GuideInfoCard extends StatelessWidget {
  const GuideInfoCard({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BabyFaceGlyph(size: BabyFaceGlyph.smallSize),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            body,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
            ),
          ),
        ],
      ),
    );
  }
}
