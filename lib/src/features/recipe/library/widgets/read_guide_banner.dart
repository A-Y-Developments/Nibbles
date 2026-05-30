import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// First-launch 'Read Guide' banner for the Recipe Library (Figma 971:8644
/// outer, 1015:6821 inner). Butter-soft tip card with a green-deep glyph,
/// title, supporting copy, and a green-deep 'Read Guide' CTA.
///
/// Visibility is gated upstream by `LocalFlagService.isStartingGuideSeen()`;
/// the banner itself is a pure presentation widget — tapping the CTA fires
/// [onTap] and the caller is responsible for marking the flag and routing
/// to the Starting Guide.
class ReadGuideBanner extends StatelessWidget {
  const ReadGuideBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.md,
        AppSizes.pagePaddingH,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.md - 2),
      decoration: BoxDecoration(
        color: AppColors.bgCardTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Glyph(),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New to solids?',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.fgStrong,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Start here — our Starting Guide walks you through '
                  'first foods, portions, and what to watch out for.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
                const SizedBox(height: AppSizes.sm + 2),
                _ReadGuideCta(onTap: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.tipGlyph,
      height: AppSizes.tipGlyph,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book_outlined,
        color: AppColors.butter,
        size: AppSizes.iconSm,
      ),
    );
  }
}

class _ReadGuideCta extends StatelessWidget {
  const _ReadGuideCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenDeep,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Read Guide',
                style: AppTypography.button.copyWith(
                  color: AppColors.cream,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: AppSizes.xs),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.cream,
                size: AppSizes.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
