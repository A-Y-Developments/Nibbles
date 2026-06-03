import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Static premium teaser card — Figma node 1200:10685.
///
/// Layout: vertical column. Top row holds the scaled-down `nibbles` wordmark
/// (~79x19) and the Nibble crown badge (26x26) at gap 12; below sits the
/// upsell body copy.
/// Surface = Nibble-primary-cream (#fffcd5 / `butterSoft`), 1px
/// Nibble-primary-Lime (#eaec8c / `butter`) border, radius 10, padding 12.
/// Static for MVP (NIB-73 wires the paywall push).
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
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.butter),
      ),
      padding: const EdgeInsets.all(AppSizes.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('nibbles', style: wordmark),
              const SizedBox(width: AppSizes.sp12),
              ExcludeSemantics(
                child: Container(
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
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sp12),
          // Body/Regular — Figtree 400 15/22.
          Text(
            'Unlock premium personalized guidance and exclusive recipes.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
