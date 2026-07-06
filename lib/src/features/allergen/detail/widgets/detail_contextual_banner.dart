import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';

/// Banner shown beneath the 3-segment bar — copy depends on derived status.
///
/// Per spec 8 — copy is verbatim from the Figma frames. The banner does NOT
/// render for [AllergenStatus.notStarted] (no logs → no contextual guidance).
class DetailContextualBanner extends StatelessWidget {
  const DetailContextualBanner({
    required this.status,
    required this.allergenName,
    super.key,
  });

  final AllergenStatus status;
  final String allergenName;

  ({String text, Color bg, Color fg})? _content() {
    switch (status) {
      case AllergenStatus.notStarted:
        return null;
      case AllergenStatus.inProgress:
        return (
          text:
              'This allergen introduction is in progress. Complete the plan '
              'before introducing another allergen.',
          bg: AppColors.coralSoft,
          fg: AppColors.coralDeep,
        );
      case AllergenStatus.safe:
        return (
          text:
              'This allergen has already been introduced. Continue offering '
              'it regularly to help maintain exposure.',
          bg: AppColors.cardCream,
          fg: AppColors.greenDeep,
        );
      case AllergenStatus.flagged:
        return (
          text:
              'You already tried this allergen, but it appears to be '
              'unsafe. Please consult a medical professional for further '
              'guidance.',
          bg: AppColors.destructiveSoft,
          fg: AppColors.burgundy,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _content();
    if (c == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sp12,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Text(
        c.text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: c.fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
