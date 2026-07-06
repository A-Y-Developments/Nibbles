import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/constants/guidance_tips.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';
import 'package:nibbles/src/common/domain/entities/guidance_tip.dart';

/// Home — Helpful Guidance section.
///
/// Renders a "Helpful Guidance" title, one white tip card per [tips] entry
/// (baby glyph + bold title + body) and a fixed "Important Health Disclaimer"
/// [TipCard]. [tips] is driven by `homeDayViewProvider(babyId).guidance`.
class HelpfulGuidanceCard extends StatelessWidget {
  const HelpfulGuidanceCard({required this.tips, super.key});

  final List<GuidanceTip> tips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Helpful Guidance', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSizes.sm + 2),
        ...List<Widget>.generate(tips.length, (i) {
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.sm + 2),
            child: _GuidanceTipCard(tip: tips[i]),
          );
        }),
        if (tips.isNotEmpty) const SizedBox(height: AppSizes.sm + 2),
        TipCard(
          title: 'Important Health Disclaimer',
          body: GuidanceTips.healthDisclaimerBody,
          leading: Assets.images.home.tipBulb.svg(width: 38, height: 37),
        ),
      ],
    );
  }
}

class _GuidanceTipCard extends StatelessWidget {
  const _GuidanceTipCard({required this.tip});

  final GuidanceTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: const [BoxShadow(color: Color(0x33EAEC8C), blurRadius: 5)],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md - 2,
        vertical: AppSizes.sp12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.images.home.guidanceBaby.svg(width: 38, height: 37),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppTypography.sectionTitle.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.fgStrong,
                  ),
                ),
                const SizedBox(height: AppSizes.sp2),
                Text(
                  tip.body,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
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
