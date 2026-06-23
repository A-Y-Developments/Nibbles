import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/widgets/baby_face_glyph.dart';

/// Hero card on top of an article — butter-soft tinted card with a baby-face
/// glyph, title, and subtitle. Modelled on the kit `.tip` card
/// (kit.css line 102-117): `bg-card-tint`, `r-xl` radius, 14px 16px padding,
/// `.tip__ttl` title (700 14px/1.2 Parkinsans, fg-strong).
class GuideHeroCard extends StatelessWidget {
  const GuideHeroCard({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Kit `.tip` padding is 14px 16px — literal because there are no exact
      // tokens for 14px vertical / 16px horizontal pair.
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCardTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BabyFaceGlyph(),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: const TextStyle(
              fontFamily: FontFamily.parkinsans,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
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
