import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Sticky bottom CTA used on the recipe detail screen — a single full-width
/// green pill button that opens the multi-day Add-to-Meal-Plan sheet.
///
/// Wrapped in a white surface with a subtle top divider so it floats above
/// the scrollable content. Bottom inset is added so the button clears the
/// home indicator.
class AddToMealPlanCta extends StatelessWidget {
  const AddToMealPlanCta({
    required this.isAdding,
    required this.onPressed,
    super.key,
  });

  final bool isAdding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppSizes.shadowCard,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sp12,
        AppSizes.pagePaddingH,
        AppSizes.sp12 + MediaQuery.of(context).padding.bottom,
      ),
      child: AppPillButton(
        label: isAdding ? 'Adding…' : 'Add to Meal Plan',
        onPressed: isAdding ? null : onPressed,
        leading: const Icon(Icons.add),
      ),
    );
  }
}

/// Lime success toast shown over the top of the hero on the recipe detail
/// screen after the user adds the recipe to their meal plan.
///
/// Mirrors Figma node 971:9727 — butter (lime) fill + forest-dark text, no
/// dismiss control. Caller owns auto-dismiss state via a timer.
class AddToMealPlanSuccessBanner extends StatelessWidget {
  const AddToMealPlanSuccessBanner({
    required this.message,
    super.key,
  });

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
