import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_date_range_form.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_header.dart';

/// Meal Plan empty-state route (Figma 971:8199 / 971:8547).
///
/// Layout (top → bottom):
/// 1. Butter-gradient [MealPlanHeader] (title + age subtitle + overflow).
/// 2. White rounded form card hosting [MealPlanDateRangeForm] with the
///    'Create meal plan' CTA.
/// 3. Brand [BrandFlower] flower illustration.
/// 4. Caption "Let's create a meal plan for {babyName}!" — the baby name
///    interpolates the runtime value.
///
/// Tapping a date field opens an inline calendar directly below it — never
/// the OS picker. Hitting the CTA emits a [DateTimeRange] via
/// [onCreateMealPlan].
class MealPlanEmptyState extends StatelessWidget {
  const MealPlanEmptyState({
    required this.babyName,
    required this.ageMonths,
    required this.onCreateMealPlan,
    this.overflowButton,
    super.key,
  });

  final String babyName;
  final int ageMonths;
  final ValueChanged<DateTimeRange> onCreateMealPlan;

  /// Optional overflow button slot — empty state still renders the header,
  /// so pass a [MealPlanOverflowButton] to enable the screen-level menu.
  final Widget? overflowButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MealPlanHeader(
          babyName: babyName,
          ageMonths: ageMonths,
          overflowButton: overflowButton ?? const SizedBox.shrink(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePaddingH,
              AppSizes.md,
              AppSizes.pagePaddingH,
              AppSizes.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormCard(
                  child: MealPlanDateRangeForm(
                    ctaLabel: 'Create meal plan',
                    onSubmit: onCreateMealPlan,
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                const Center(child: BrandFlower()),
                const SizedBox(height: AppSizes.md),
                Center(
                  child: Text(
                    "Let's create a meal plan for $babyName!",
                    textAlign: TextAlign.center,
                    style: AppTypography.emptyStateTitle,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// White rounded card with soft shadow that wraps the date-range form
/// — matches the Figma 971:8199 card around the Start/End/CTA stack.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppSizes.shadowCard,
      ),
      child: child,
    );
  }
}
