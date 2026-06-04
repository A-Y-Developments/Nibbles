import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Circular ghost back button matching the kit `.rbtn` spec
/// (kit.css line 62-71 + PlanAndRecipes.jsx line 18): 32x32 circle,
/// transparent background, green-deep icon.
class GuideBackButton extends StatelessWidget {
  const GuideBackButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: AppSizes.roundButtonSm,
            height: AppSizes.roundButtonSm,
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.greenDeep,
              size: AppSizes.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
