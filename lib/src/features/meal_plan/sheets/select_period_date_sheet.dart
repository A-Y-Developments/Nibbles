import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_date_range_form.dart';

/// Bottom-sheet variant of the Meal Plan date range form (Figma 971:8000).
///
/// Title: 'Select Period Date'. Hosts the same [MealPlanDateRangeForm] used
/// by the empty state, but with the 'Custom meal plan' CTA per the Figma
/// frame. Launched from the meal-plan overflow → 'Create new meal prep'
/// action. Pops with the chosen [DateTimeRange] on submit, or `null` on
/// dismiss.
class SelectPeriodDateSheet extends StatelessWidget {
  const SelectPeriodDateSheet({this.initialStart, this.initialEnd, super.key});

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.md,
            AppSizes.pagePaddingH,
            AppSizes.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMuted,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Select Period Date',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.fgStrong,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              MealPlanDateRangeForm(
                ctaLabel: 'Custom meal plan',
                initialStart: initialStart,
                initialEnd: initialEnd,
                onSubmit: (range) => Navigator.of(context).pop(range),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper that shows [SelectPeriodDateSheet] as a modal bottom sheet.
/// Returns the chosen [DateTimeRange], or `null` on dismiss.
Future<DateTimeRange?> showSelectPeriodDateSheet(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
}) {
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => SelectPeriodDateSheet(
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}
