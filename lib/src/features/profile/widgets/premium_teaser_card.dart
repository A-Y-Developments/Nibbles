import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Premium card — Figma nodes 1200:10685 (upsell) / 1211:11469 (trial).
///
/// Surface = Nibble-primary-cream (#fffcd5 / `butterSoft`), 1px
/// Nibble-primary-Lime (#eaec8c / `butter`) border, radius 10, padding 12.
///
/// Two variants, selected by [trialDaysLeft]:
///  - null  → upsell: `nibbles` wordmark + crown badge, then upsell copy.
///  - value → trial: "Free Trial" + crown on the left, "N Days left" pill
///    on the right (no body copy).
///
/// Static for MVP — subscription state is M2-deferred (NIB-73). The trial
/// variant is rendered by passing [trialDaysLeft] once subscriptions ship.
class PremiumTeaserCard extends StatelessWidget {
  const PremiumTeaserCard({this.trialDaysLeft, super.key});

  final int? trialDaysLeft;

  static const double _crownSize = 26;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.butter),
      ),
      padding: const EdgeInsets.all(AppSizes.sp12),
      child: trialDaysLeft == null ? _buildUpsell(context) : _buildTrial(),
    );
  }

  Widget _buildUpsell(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              label: 'Nibbles',
              image: true,
              child: ExcludeSemantics(
                child: Assets.images.nibblesLogoBlack.image(height: 22),
              ),
            ),
            const SizedBox(width: AppSizes.sp12),
            _crown(),
          ],
        ),
        const SizedBox(height: AppSizes.sp12),
        // Body/Regular — Figtree 400 15/22.
        Text(
          'Unlock premium personalized guidance and exclusive recipes.',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildTrial() {
    final days = trialDaysLeft ?? 0;
    final dayLabel = days == 1 ? 'Day' : 'Days';

    return Row(
      children: [
        Text(
          'Free Trial',
          style: AppTypography.headline.copyWith(color: AppColors.text),
        ),
        const SizedBox(width: AppSizes.sp12),
        _crown(),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sp12,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.coralSoft,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Text(
            '$days $dayLabel left',
            style: AppTypography.headline.copyWith(
              fontSize: 13,
              color: AppColors.coralDeep,
            ),
          ),
        ),
      ],
    );
  }

  Widget _crown() {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        Assets.images.profile.premiumCrown.path,
        width: _crownSize,
        height: _crownSize,
      ),
    );
  }
}
