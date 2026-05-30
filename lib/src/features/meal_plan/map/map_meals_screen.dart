import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart'
    show MealPlanService;
import 'package:nibbles/src/features/meal_plan/map/map_meals_controller.dart';
import 'package:nibbles/src/features/meal_plan/map/map_meals_state.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/day_chip_row.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/picked_recipe_row.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/selected_day_slot_list.dart';

/// Map Meals Plan full-screen (NIB-95).
///
/// Takes a list of picked recipes + a date range (handed in via
/// [MapMealsArgs] through `GoRouterState.extra` from NIB-87's Browse Meal
/// sheet) and lets the user assign each picked recipe to a day in the
/// range. On commit, calls [MealPlanService.appendMealsToRange] (APPEND
/// only — no replace per NIB-120). On success pops with `true`. On
/// failure shows a blocking P1 retry dialog.
class MapMealsScreen extends ConsumerWidget {
  const MapMealsScreen({required this.args, super.key});

  final MapMealsArgs args;

  static const _weekdayName = <int, String>{
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

  static const _weekdayShort = <int, String>{
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapMealsControllerProvider(args));
    final notifier = ref.read(mapMealsControllerProvider(args).notifier);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _MapMealsAppBar(state: state),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.md),
            DayChipRow(
              startDate: state.startDate,
              endDate: state.endDate,
              selectedDay: state.selectedDay,
              onSelect: notifier.selectDay,
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                children: [
                  _SelectedDayHeader(state: state, weekdayNames: _weekdayName),
                  const SizedBox(height: AppSizes.sm),
                  SelectedDaySlotList(
                    recipes: state.recipesForSelectedDay(),
                    onRemove: notifier.unassign,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Meals Picked — ${state.totalCount} selected',
                    style: AppTypography.sectionTitle,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  for (var i = 0; i < state.pickedRecipes.length; i++) ...[
                    if (i != 0) const SizedBox(height: AppSizes.sm),
                    PickedRecipeRow(
                      recipe: state.pickedRecipes[i],
                      onTap: () => notifier.assignToSelectedDay(
                        state.pickedRecipes[i].id,
                      ),
                      assignedLabel: _assignedLabelFor(
                        state.pickedRecipes[i],
                        state,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
            _CommitBar(state: state, onCommit: () => _onCommit(context, ref)),
          ],
        ),
      ),
    );
  }

  String? _assignedLabelFor(Recipe recipe, MapMealsState state) {
    final assignedDay = state.assignments[recipe.id];
    if (assignedDay == null) return null;
    final abbrev = _weekdayShort[assignedDay.weekday] ?? '';
    return '$abbrev ${assignedDay.day}';
  }

  Future<void> _onCommit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(mapMealsControllerProvider(args).notifier);
    final success = await notifier.commit();
    if (!context.mounted) return;
    if (success) {
      context.pop(true);
      return;
    }
    await _showRetryDialog(context, ref);
  }

  Future<void> _showRetryDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: const Text(
            "Couldn't save your plan",
            style: AppTypography.sectionTitle,
          ),
          content: Text(
            'Please try again',
            style: AppTypography.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.button.copyWith(color: AppColors.fgMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.greenDeep,
                foregroundColor: AppColors.onGreen,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _onCommit(context, ref);
              },
              child: Text('Retry', style: AppTypography.button),
            ),
          ],
        );
      },
    );
  }
}

class _MapMealsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MapMealsAppBar({required this.state});

  final MapMealsState state;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cream,
      surfaceTintColor: AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fgDefault),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text('Map Meals Plan', style: AppTypography.textTheme.titleLarge),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.pagePaddingH),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sp12,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.greenTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                '${state.filledCount} of ${state.totalCount} slots filled',
                style: AppTypography.caption.copyWith(
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({required this.state, required this.weekdayNames});

  final MapMealsState state;
  final Map<int, String> weekdayNames;

  @override
  Widget build(BuildContext context) {
    final dayName = weekdayNames[state.selectedDay.weekday] ?? '';
    final n = state.recipesForSelectedDay().length;
    final m = state.totalCount;
    return Text(
      'Meals for $dayName ($n/$m)',
      style: AppTypography.sectionTitle,
    );
  }
}

class _CommitBar extends StatelessWidget {
  const _CommitBar({required this.state, required this.onCommit});

  final MapMealsState state;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final hasAssignments = state.assignments.isNotEmpty;
    final disabled = !hasAssignments || state.isCommitting;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePaddingH,
          AppSizes.sm,
          AppSizes.pagePaddingH,
          AppSizes.sp12,
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: disabled
                  ? AppColors.borderMuted
                  : AppColors.greenDeep,
              foregroundColor: AppColors.onGreen,
              disabledBackgroundColor: AppColors.borderMuted,
              disabledForegroundColor: AppColors.fgFaint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            onPressed: disabled ? null : onCommit,
            child: state.isCommitting
                ? const SizedBox(
                    width: AppSizes.iconSm,
                    height: AppSizes.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onGreen,
                    ),
                  )
                : Text('Mapp Meal Plan', style: AppTypography.button),
          ),
        ),
      ),
    );
  }
}
