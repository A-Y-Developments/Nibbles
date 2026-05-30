import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/widgets/baby_face_glyph.dart';

/// Article card rendered on the Starting Guide hub list.
///
/// White surface, rounded-2xl, soft card shadow, with a green-deep glyph
/// (kit `.tip__ico`), title, subtitle, and a trailing chevron — mirrors the
/// kit's interactive list card pattern.
class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.article,
    required this.onTap,
    super.key,
  });

  final GuideArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            boxShadow: AppSizes.shadowCard,
          ),
          child: Row(
            children: [
              const BabyFaceGlyph(size: BabyFaceGlyph.smallSize),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.fgStrong,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      article.subtitle,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.fgMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greenDeep,
                size: AppSizes.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
