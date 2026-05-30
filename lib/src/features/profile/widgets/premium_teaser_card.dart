import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Static premium teaser card — butter-soft surface, scaled-down `nibbles`
/// wordmark, butter crown badge, body copy.
///
/// Static for MVP (NIB-73 wires the paywall push). Mirrors
/// `design/ui_kits/nibbles_mobile/ProfileScreen.jsx` premium card.
class PremiumTeaserCard extends StatelessWidget {
  const PremiumTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Scale the brand wordmark from kit 42 → 22 to fit the inline lockup.
    final wordmark = AppTypography.brandWordmark.copyWith(
      fontSize: 22,
      letterSpacing: 22 * -0.02,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md - 2,
      ),
      child: Row(
        children: [
          Text('nibbles', style: wordmark),
          const SizedBox(width: AppSizes.sm - 2),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: BorderRadius.circular(AppSizes.sm),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 18,
              color: AppColors.greenDeep,
            ),
          ),
          const SizedBox(width: AppSizes.sp12 + 2),
          Expanded(
            child: Text(
              'Unlock premium personalized guidance and exclusive recipes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
