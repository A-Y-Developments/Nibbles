import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';

/// Header for the Meal Plan screen (Figma 971:7804). No own background — it
/// inherits the page `moreWhite` wash from the surrounding `GradientScaffold`
/// so it reads as a continuation of the page, not a distinct band.
///
/// Title row: 'Meal Planner for {babyName}' (titleMedium) and a green-deep
/// rounded-square overflow button on the right. The [overflowButton] slot is
/// owned by the caller so it can host its own `PopupMenuButton`/`showMenu` flow.
class MealPlanHeader extends StatelessWidget {
  const MealPlanHeader({
    required this.babyName,
    required this.overflowButton,
    super.key,
  });

  final String babyName;
  final Widget overflowButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    style: AppTypography.textTheme.titleMedium,
                  ),
                ),
                overflowButton,
              ],
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
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: AppSizes.roundButtonMd,
          height: AppSizes.roundButtonMd,
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
