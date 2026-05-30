import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Single-select button-choice row used in the Delete Account overlay
/// (Figma 1216:11954). Mirrors kit `.pillbtn--ghost` semantics — butter-soft
/// fill, Parkinsans 600 label, full-width pill — but pre-selected the fill
/// deepens to `butter` and the label/border darkens for affordance.
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
    final fg = selected ? AppColors.greenDeep : AppColors.fgDefault;
    final borderColor = selected
        ? AppColors.greenDeep
        : AppColors.borderSoft;

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: borderColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sp12 + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.button.copyWith(
                      fontFamily: FontFamily.parkinsans,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      height: 1.294,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle,
                    size: AppSizes.iconSm + 2,
                    color: AppColors.greenDeep,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
