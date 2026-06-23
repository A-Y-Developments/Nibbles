import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';

/// Lime success toast shown over the top of the hero on the recipe detail
/// screen after the user adds the recipe to their meal plan.
///
/// Mirrors Figma node 971:9727 — butter (lime) fill + forest-dark text, no
/// dismiss control. Caller owns auto-dismiss state via a timer.
class AddToMealPlanSuccessBanner extends StatelessWidget {
  const AddToMealPlanSuccessBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sp12,
          ),
          decoration: BoxDecoration(
            color: AppColors.butter,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: AppSizes.iconMd,
                color: AppColors.greenDeep,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.greenDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
