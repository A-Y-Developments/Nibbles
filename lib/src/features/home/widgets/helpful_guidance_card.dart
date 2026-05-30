import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';

/// Home — Helpful Guidance section (NIB-77, Figma 1242:10648).
///
/// Renders a 'Helpful Guidance' title3 + three white tip cards (butter glyph
/// circle, display 14/700 title, callout body) + a final 'Important Health
/// Disclaimer' [TipCard] (butter-soft surface). Static content for MVP.
class HelpfulGuidanceCard extends StatelessWidget {
  const HelpfulGuidanceCard({super.key});

  static const List<_TipContent> _tips = [
    _TipContent(
      emoji: '🥄',
      title: 'Try one new food at a time',
      body: 'Wait 3-5 days between new foods so reactions are easy to trace.',
    ),
    _TipContent(
      emoji: '⏱️',
      title: 'Watch for reactions for 24 hours',
      body: 'Most reactions surface within the first day after a new food.',
    ),
    _TipContent(
      emoji: '👩‍⚕️',
      title: 'Consult your pediatrician for concerns',
      body: 'Reach out before introducing high-risk foods or for any reaction.',
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
        const TipCard(
          title: 'Important Health Disclaimer',
          body: 'Our recommendations are intended for educational purposes '
              'only and should not be considered medical advice.',
        ),
      ],
    );
  }
}

class _TipContent {
  const _TipContent({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
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
        boxShadow: AppSizes.shadowCard,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md - 2,
        vertical: AppSizes.sp12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.butter,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              content.emoji,
              style: const TextStyle(fontSize: 16, height: 1),
            ),
          ),
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
