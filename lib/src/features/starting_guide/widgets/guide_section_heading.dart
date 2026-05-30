import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Bold section title rendered between blocks inside an article. Maps to the
/// Figma Title 2/Bold (Parkinsans 20/700 h28) — uses [TextTheme.titleMedium]
/// which the app theme defines as 20/700.
class GuideSectionHeading extends StatelessWidget {
  const GuideSectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.titleMedium?.copyWith(
        color: AppColors.fgStrong,
      ),
    );
  }
}
