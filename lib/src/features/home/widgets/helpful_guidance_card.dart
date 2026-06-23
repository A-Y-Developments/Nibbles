import 'package:flutter/material.dart';
import 'package:nibbles/gen/assets.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';

/// Home — Helpful Guidance section (NIB-77, Figma 1242:10648).
///
/// Renders a 'Helpful Guidance' title3 + three white tip cards (butter glyph
/// circle, display 14/700 title, callout body) + a final 'Important Health
/// Disclaimer' [TipCard] (butter-soft surface). Static content for MVP.
///
/// Copy is verbatim from the home-populated audit (node 1242:10567). The
/// trailing space on "No fruit yet today " and the truncated body
/// "Dinner is a good chance for ..." mirror the Figma frame exactly per
/// AC — do not paraphrase.
class HelpfulGuidanceCard extends StatelessWidget {
  const HelpfulGuidanceCard({super.key});

  static const List<_TipContent> _tips = [
    _TipContent(
      title: 'No fruit yet today ',
      body: 'Dinner is a good chance for ...',
    ),
    _TipContent(
      title: 'Offer water with each meal',
      body: 'Small sips in an open cup from 6 months',
    ),
    _TipContent(
      title: 'Milk feeds still the priority',
      body: 'Breastmilk or formula remains the main nutrition at 8 months',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Helpful Guidance', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSizes.sm + 2),
        ...List<Widget>.generate(_tips.length, (i) {
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.sm + 2),
            child: _GuidanceTipCard(content: _tips[i]),
          );
        }),
        const SizedBox(height: AppSizes.sm + 2),
        TipCard(
          title: 'Important Health Disclaimer',
          body:
              'Our recommendations are intended for educational purposes '
              'only and should not be considered medical advice.',
          leading: Assets.images.home.tipBulb.svg(width: 38, height: 37),
        ),
      ],
    );
  }
}

class _TipContent {
  const _TipContent({required this.title, required this.body});

  final String title;
  final String body;
}

class _GuidanceTipCard extends StatelessWidget {
  const _GuidanceTipCard({required this.content});

  final _TipContent content;

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
                  content.title,
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
                  content.body,
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
