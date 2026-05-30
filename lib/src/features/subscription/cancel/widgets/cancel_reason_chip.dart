import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Single-select reason chip for the cancel-subscription overlay (NIB-82,
/// Figma 1216:12019 / component button-choice).
///
/// Default state (Figma): cream (#fffcd5) fill, no border, 12px padding,
/// radius 10, Parkinsans SemiBold 15/22 Black (#2c2c2c) label.
///
/// Selected state (engineering-defined per NIB-82 AC — Figma canvas only
/// shows the default state): sage `greenTint` fill + `green` 1.5px border +
/// `greenDeep` label. Distinct from the delete-account chip (NIB-78) which
/// deepens to butter — this ticket explicitly calls for sage tint/border.
class CancelReasonChip extends StatelessWidget {
  const CancelReasonChip({
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
    final fill = selected ? AppColors.greenTint : AppColors.butterSoft;
    final fg = selected ? AppColors.greenDeep : AppColors.text;
    final border = selected
        ? const BorderSide(color: AppColors.green, width: 1.5)
        : BorderSide.none;

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        side: border,
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
              style: AppTypography.button.copyWith(
                fontFamily: FontFamily.parkinsans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fg,
                height: 22 / 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
