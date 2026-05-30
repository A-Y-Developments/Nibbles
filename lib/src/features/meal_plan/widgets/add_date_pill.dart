import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Ghost "+ Add Date" pill rendered below the day list. Grows the visible
/// window by one day (Figma 971:7826).
class AddDatePill extends StatelessWidget {
  const AddDatePill({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.sm,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.greenDeep, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: AppSizes.buttonHeightSm,
            child: Center(
              child: Text(
                '+ Add Date',
                style: AppTypography.button.copyWith(
                  color: AppColors.greenDeep,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
