import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Single-select button-choice row used in the Delete Account overlay
/// (Figma 1216:11954 / component 1207:11246).
///
/// Default: butter-soft (#fffcd5) fill, no border, 12px padding, radius 10,
/// Parkinsans SemiBold 15/22 Black (#2c2c2c) label.
///
/// Selected (engineering-derived affordance; Figma canvas only shows the
/// default state): deepens fill to butter and shifts the label to
/// green-deep — fill-only, no trailing glyph (Figma doesn't show one).
class ReasonChoiceRow extends StatelessWidget {
  const ReasonChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? AppColors.butter : AppColors.butterSoft;
    final fg = selected ? AppColors.greenDeep : AppColors.text;

    // Single-select choice: expose selected + button role so a screen reader
    // announces which reason is picked (mirrors SettingsRow / RadioPill).
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                // Figma: padding 12 on all sides.
                padding: const EdgeInsets.all(AppSizes.sp12),
                child: Text(
                  label,
                  style: AppTypography.headline.copyWith(color: fg),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
