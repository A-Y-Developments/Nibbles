import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-96: dashed "No Meals Mapped Yet" empty state.
///
/// Decorative-only (no drag-and-drop). Renders a dashed-border card with the
/// title + body copy and a primary "+ Add" pill that invokes [onAddMeal];
/// when null, falls back to routing to the meal plan tab (NIB-86 wires no
/// callback through `home_screen`).
class HomeNoMealsState extends StatelessWidget {
  const HomeNoMealsState({
    this.babyName,
    this.onAddMeal,
    super.key,
  });

  /// Optional baby name. Preserved from the NIB-86 placeholder signature;
  /// the spec copy is name-agnostic, so this is currently unused for
  /// rendering.
  final String? babyName;

  /// Invoked when the user taps "+ Add". Defaults to navigating to the meal
  /// plan tab via `context.goNamed(AppRoute.mealPlan.name)`.
  final VoidCallback? onAddMeal;

  void _onPressed(BuildContext context) {
    final cb = onAddMeal;
    if (cb != null) {
      cb();
      return;
    }
    context.goNamed(AppRoute.mealPlan.name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      variant: AppCardVariant.dashed,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No Meals Mapped Yet',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            "Tap below to add today's first meal.",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.fgMuted,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Align(
            child: AppPillButton(
              label: '+ Add',
              size: AppPillButtonSize.small,
              expand: false,
              onPressed: () => _onPressed(context),
            ),
          ),
        ],
      ),
    );
  }
}
