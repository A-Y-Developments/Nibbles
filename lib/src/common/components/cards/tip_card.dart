import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Hint / tip card. Mirrors kit `.tip`: butterSoft fill, radiusXl,
/// 28px greenDeep glyph circle with butter glyph, 14/700 title + callout body.
class TipCard extends StatelessWidget {
  const TipCard({
    required this.title,
    required this.body,
    this.glyph = 'i',
    super.key,
  });

  final String title;
  final String body;

  /// Glyph rendered inside the greenDeep circle (kit default "i").
  final String glyph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sp12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.tipGlyph,
            height: AppSizes.tipGlyph,
            decoration: const BoxDecoration(
              color: AppColors.greenDeep,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              glyph,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.butter,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.fgStrong,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgDefault,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
