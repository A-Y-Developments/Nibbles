import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Rounded-square green-deep back button matching the kit header treatment
/// (see `components-header.html` — green-deep on cream, 32x32, radius8).
class GuideBackButton extends StatelessWidget {
  const GuideBackButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenDeep,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        onTap: onTap,
        child: const SizedBox(
          width: AppSizes.roundButtonSm,
          height: AppSizes.roundButtonSm,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onGreen,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}
