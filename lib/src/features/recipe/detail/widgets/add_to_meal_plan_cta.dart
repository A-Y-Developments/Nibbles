import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';

/// Sticky bottom CTA used on the recipe detail screen — a single full-width
/// green pill button that opens the existing `AddToMealPlanSheet`.
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

/// Inline success banner — DS-styled, top-anchored inside the scroll view.
/// Mirrors Figma node 1474:53362. The screen owns dismiss state.
class AddToMealPlanSuccessBanner extends StatelessWidget {
  const AddToMealPlanSuccessBanner({
    required this.message,
    required this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sp12,
        ),
        decoration: BoxDecoration(
          color: AppColors.greenTint,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.green, width: 1.5),
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
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close,
                size: AppSizes.iconSm,
                color: AppColors.greenDeep,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minHeight: AppSizes.iconLg,
                minWidth: AppSizes.iconLg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
