import 'package:flutter/material.dart';
import 'package:nibbles/gen/fonts.gen.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Full-width green-deep pill CTA used at the bottom of every article.
///
/// Matches the kit `.pillbtn` spec — green-deep fill, cream label in
/// Parkinsans 700, full radius, trailing forward arrow.
class GuideCtaPill extends StatelessWidget {
  const GuideCtaPill({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenDeep,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        onTap: onTap,
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: FontFamily.parkinsans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.cream,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.cream,
                size: AppSizes.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
