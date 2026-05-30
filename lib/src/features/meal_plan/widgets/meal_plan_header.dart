import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Butter-gradient header for the Meal Plan screen (Figma 971:7804).
///
/// Title row: 'Meal Planner for {babyName}' (titleLarge), age subtitle
/// ('{ageMonths} Month'), days label, and a green-deep rounded-square
/// overflow button on the right. The [overflowButton] slot is owned by
/// the caller so it can host its own `PopupMenuButton`/`showMenu` flow.
class MealPlanHeader extends StatelessWidget {
  const MealPlanHeader({
    required this.babyName,
    required this.ageMonths,
    required this.dayCount,
    required this.overflowButton,
    super.key,
  });

  final String babyName;
  final int ageMonths;
  final int dayCount;
  final Widget overflowButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.butter, AppColors.butterSoft],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        AppSizes.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meal Planner for $babyName',
                    style: AppTypography.textTheme.titleLarge,
                  ),
                ),
                overflowButton,
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              '$ageMonths Month',
              style: AppTypography.caption.copyWith(color: AppColors.fgFaint),
            ),
            const SizedBox(height: AppSizes.sp12),
            Text(
              'Meal plan for $dayCount days',
              style: AppTypography.sectionTitle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Green-deep rounded-square overflow button used in the header's right slot.
/// Wrap with a `PopupMenuButton.child` or a tap-to-`showMenu` builder to
/// surface the screen-level overflow menu.
class MealPlanOverflowButton extends StatelessWidget {
  const MealPlanOverflowButton({required this.onTap, super.key});

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
            Icons.more_horiz,
            color: AppColors.onGreen,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}
