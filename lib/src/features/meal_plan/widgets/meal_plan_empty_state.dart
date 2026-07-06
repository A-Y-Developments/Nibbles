import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/brand/brand_flower.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_date_range_form.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_header.dart';

/// Meal Plan empty-state route (Figma 2839:16295 / 2839:15923).
///
/// Layout (top → bottom):
/// 1. Butter-gradient [MealPlanHeader] (title + age subtitle). The overflow
///    `⋯` is HIDDEN in the empty state — creation happens via the card CTAs.
/// 2. White rounded form card hosting [MealPlanDateRangeForm] (two date fields
///    + the coral "N weeks · M days" info chip once both dates are set) plus
///    the CTA pair: primary "Set a Meal Prep" (sparkle → AI flow) and ghost
///    "Fill in myself" (→ manual flow). Both stay disabled until a valid range
///    is chosen.
/// 3. Brand [BrandFlower] + caption "Let's create meal plan for {babyName}!".
class MealPlanEmptyState extends StatefulWidget {
  const MealPlanEmptyState({
    required this.babyName,
    required this.ageMonths,
    required this.onSetMealPrep,
    required this.onFillInMyself,
    super.key,
  });

  final String babyName;
  final int ageMonths;

  /// AI path — fires with the chosen range when "Set a Meal Prep" is tapped.
  final ValueChanged<DateTimeRange> onSetMealPrep;

  /// Manual path — fires with the chosen range when "Fill in myself" is tapped.
  final ValueChanged<DateTimeRange> onFillInMyself;

  @override
  State<MealPlanEmptyState> createState() => _MealPlanEmptyStateState();
}

class _MealPlanEmptyStateState extends State<MealPlanEmptyState> {
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final range = _range;
    return Column(
      children: [
        MealPlanHeader(
          babyName: widget.babyName,
          ageMonths: widget.ageMonths,
          overflowButton: const SizedBox.shrink(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MealPlanDateRangeForm(
                        onRangeChanged: (r) => setState(() => _range = r),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppPillButton(
                        label: 'Set a Meal Prep',
                        leading: const Icon(Icons.auto_awesome),
                        onPressed: range == null
                            ? null
                            : () => widget.onSetMealPrep(range),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      AppPillButton(
                        label: 'Fill in myself',
                        variant: AppPillButtonVariant.ghost,
                        onPressed: range == null
                            ? null
                            : () => widget.onFillInMyself(range),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                const Center(child: BrandFlower()),
                const SizedBox(height: AppSizes.md),
                Center(
                  child: Text(
                    "Let's create meal plan for ${widget.babyName}!",
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

/// White rounded card with soft shadow that wraps the date-range form + CTAs.
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
