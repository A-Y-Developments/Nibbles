import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';

/// Article card rendered on the Starting Guide hub list.
///
/// Cream fill, no shadow, title-only. Trailing Quatrefoil with forward arrow
/// per Figma design spec.
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
    return Semantics(
      button: true,
      label: article.title,
      child: MergeSemantics(
        child: Material(
          color: AppColors.butterSoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sp12,
                vertical: AppSizes.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.fgStrong,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  const ExcludeSemantics(
                    child: SizedBox(
                      width: AppSizes.roundButton,
                      height: AppSizes.roundButton,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Quatrefoil(
                            size: AppSizes.roundButton,
                            coreColor: AppColors.greenDeep,
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.surface,
                            size: AppSizes.iconMd,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
