import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/widgets/baby_face_glyph.dart';

/// Hero card on top of an article — butter-soft tinted card with a baby-face
/// glyph, title, and subtitle. Modelled on `components-cards.html` tip card
/// (radius20, butter-soft tint, fgDefault title, fgMuted body).
class GuideHeroCard extends StatelessWidget {
  const GuideHeroCard({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCardTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BabyFaceGlyph(),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
            ),
          ),
        ],
      ),
    );
  }
}
