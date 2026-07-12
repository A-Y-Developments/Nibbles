import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/feedback/press_scale.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';

/// Article card rendered on the Starting Guide hub list.
///
/// Cream fill, title on the left, butter quatrefoil 'next' blob on the right.
/// The blob overflows the right padding and is clipped flush by the card's
/// rounded corners — per Figma 971-8692.
class ArticleCard extends StatelessWidget {
  const ArticleCard({required this.article, required this.onTap, super.key});

  static const double _blobWidth = 66;
  static const double _blobHeight = 59;
  static const double _blobBleed = 12;

  final GuideArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: MergeSemantics(
        child: PressableScale(
          enabled: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Material(
              color: AppColors.butterSoft,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSizes.sp12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            color: AppColors.fgStrong,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ExcludeSemantics(
                        child: Transform.translate(
                          offset: const Offset(_blobBleed, 0),
                          child: Assets.icons.guideNextArrow.svg(
                            width: _blobWidth,
                            height: _blobHeight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
