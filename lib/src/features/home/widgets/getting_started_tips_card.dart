import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';

/// NIB-96: single "Getting Started Tips" cream card under a "Helpful
/// Guidance" section title.
///
/// Used by all three Home empty variants (ready-to-start empty,
/// ready-to-start with ongoing, no-meals-mapped). The populated variant
/// renders the richer `HelpfulGuidanceCard` instead. Copy is verbatim from
/// the Figma frame.
class GettingStartedTipsCard extends StatelessWidget {
  const GettingStartedTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Helpful Guidance', style: AppTypography.sectionTitle),
        SizedBox(height: AppSizes.sp12),
        TipCard(
          title: 'Getting Started Tips',
          body:
              'Start with single-ingredient purees and introduce one new '
              'food every 3-5 days to monitor for reactions.',
        ),
      ],
    );
  }
}
