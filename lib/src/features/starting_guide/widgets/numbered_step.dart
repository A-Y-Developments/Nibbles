import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// One numbered step row inside an article — green-deep pill containing the
/// step number, sitting next to a heading + body block.
///
/// Renders without the number pill when [stepNumber] is null (used for
/// plain heading/body sections).
class NumberedStep extends StatelessWidget {
  const NumberedStep({
    required this.heading,
    required this.body,
    this.stepNumber,
    super.key,
  });

  final int? stepNumber;
  final String heading;
  final String body;

  static const _pillSize = AppSizes.tipGlyph;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stepNumber != null) ...[
          _StepPill(stepNumber: stepNumber!),
          const SizedBox(width: AppSizes.sp12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: stepNumber != null
                    ? const EdgeInsets.only(top: AppSizes.xs)
                    : EdgeInsets.zero,
                child: Text(
                  heading,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  body,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.stepNumber});

  final int stepNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NumberedStep._pillSize,
      height: NumberedStep._pillSize,
      decoration: const BoxDecoration(
        color: AppColors.greenDeep,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$stepNumber',
        style: const TextStyle(
          fontFamily: FontFamily.parkinsans,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1,
          color: AppColors.butter,
        ),
      ),
    );
  }
}
