import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_date_range_form.dart';

/// Which path the user chose out of the Select Period Date sheet.
enum MealPrepMode {
  /// Generate the plan with AI.
  ai,

  /// Fill the plan in manually (browse → review → map).
  manual,
}

/// Result of the Select Period Date sheet: the chosen [mode] plus the
/// selected [range]. Returned via [showSelectPeriodDateSheet].
class SelectPeriodResult {
  const SelectPeriodResult({required this.mode, required this.range});

  final MealPrepMode mode;
  final DateTimeRange range;
}

/// Bottom sheet "Select Period Date" (Figma 971:8053). Hosts the shared
/// [MealPlanDateRangeForm] (two date fields + "N weeks · M days" chip) and a
/// button pair: primary "Generate with AI" (sparkle) and ghost
/// "Fill in myself". Launched from the meal-plan overflow →
/// "Create new meal prep". Pops with a [SelectPeriodResult], or `null` on
/// dismiss.
class SelectPeriodDateSheet extends StatefulWidget {
  const SelectPeriodDateSheet({this.initialStart, this.initialEnd, super.key});

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<SelectPeriodDateSheet> createState() => _SelectPeriodDateSheetState();
}

class _SelectPeriodDateSheetState extends State<SelectPeriodDateSheet> {
  DateTimeRange? _range;

  void _submit(MealPrepMode mode) {
    final range = _range;
    if (range == null) return;
    Navigator.of(context).pop(SelectPeriodResult(mode: mode, range: range));
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = _range != null;

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
                initialStart: widget.initialStart,
                initialEnd: widget.initialEnd,
                onRangeChanged: (range) => setState(() => _range = range),
              ),
              const SizedBox(height: AppSizes.lg),
              AppPillButton(
                label: 'Generate with AI',
                leading: const Icon(Icons.auto_awesome),
                onPressed: hasRange ? () => _submit(MealPrepMode.ai) : null,
              ),
              const SizedBox(height: AppSizes.sm),
              AppPillButton(
                label: 'Fill in myself',
                variant: AppPillButtonVariant.ghost,
                onPressed: hasRange ? () => _submit(MealPrepMode.manual) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows [SelectPeriodDateSheet] as a modal bottom sheet. Returns the chosen
/// [SelectPeriodResult] (mode + range), or `null` on dismiss.
Future<SelectPeriodResult?> showSelectPeriodDateSheet(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
}) {
  return showModalBottomSheet<SelectPeriodResult>(
    context: context,
    useRootNavigator: true,
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
