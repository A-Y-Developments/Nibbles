import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_controller.dart';
import 'package:nibbles/src/features/meal_plan/meal_plan_state.dart';
import 'package:nibbles/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_day_cell.dart';
import 'package:nibbles/src/features/meal_plan/widgets/recipe_select_modal.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _MealPlanBody(babyId: babyId);
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _MealPlanBody extends ConsumerWidget {
  const _MealPlanBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync = ref.watch(mealPlanControllerProvider(babyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Meal Plan', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          PopupMenuButton<_AppBarAction>(
            icon: const Icon(Icons.more_vert, color: AppColors.subtext),
            onSelected: (action) async {
              switch (action) {
                case _AppBarAction.addToShoppingList:
                  await _openShoppingListModal(context, ref);
                case _AppBarAction.clearWeek:
                  await _confirmClearWeek(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _AppBarAction.addToShoppingList,
                child: Text('Add to Shopping List'),
              ),
              PopupMenuItem(
                value: _AppBarAction.clearWeek,
                child: Text('Clear current week'),
              ),
            ],
          ),
        ],
      ),
      body: controllerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(mealPlanControllerProvider(babyId)),
        ),
        data: (state) => _WeekView(
          state: state,
          babyId: babyId,
          onPreviousWeek: () => ref
              .read(mealPlanControllerProvider(babyId).notifier)
              .previousWeek(),
          onNextWeek: () =>
              ref.read(mealPlanControllerProvider(babyId).notifier).nextWeek(),
          onAssignRecipe: (date) async =>
              _openRecipeSelect(context, ref, babyId, date),
          onEditEntry: (entry) async =>
              _openRecipeSelect(context, ref, babyId, entry.planDate),
          onRemoveEntry: (entry) async =>
              _removeEntry(context, ref, babyId, entry),
        ),
      ),
    );
  }

  Future<void> _openShoppingListModal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final state = ref.read(mealPlanControllerProvider(babyId)).valueOrNull;
    if (state == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) =>
          AddToShoppingListModal(babyId: babyId, weekStart: state.weekStart),
    );
  }

  Future<void> _confirmClearWeek(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear week'),
        content: const Text(
          'This will remove all meals from this week. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final ok = await ref
        .read(mealPlanControllerProvider(babyId).notifier)
        .clearWeek();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't clear week. Try again.")),
      );
    }
  }

  Future<void> _openRecipeSelect(
    BuildContext context,
    WidgetRef ref,
    String babyId,
    DateTime date,
  ) async {
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) => RecipeSelectModal(babyId: babyId),
    );

    if (recipe == null) return;
    if (!context.mounted) return;

    final ok = await ref
        .read(mealPlanControllerProvider(babyId).notifier)
        .assignRecipe(date, recipe.id);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add to meal plan. Try again.")),
      );
    }
  }

  Future<void> _removeEntry(
    BuildContext context,
    WidgetRef ref,
    String babyId,
    MealPlanEntry entry,
  ) async {
    final ok = await ref
        .read(mealPlanControllerProvider(babyId).notifier)
        .removeEntry(entry.id);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't remove meal. Try again.")),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Week view
// ---------------------------------------------------------------------------

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.state,
    required this.babyId,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onAssignRecipe,
    required this.onEditEntry,
    required this.onRemoveEntry,
  });

  final MealPlanState state;
  final String babyId;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final Future<void> Function(DateTime date) onAssignRecipe;
  final Future<void> Function(MealPlanEntry entry) onEditEntry;
  final Future<void> Function(MealPlanEntry entry) onRemoveEntry;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        _WeekHeader(
          weekStart: state.weekStart,
          onPrevious: onPreviousWeek,
          onNext: onNextWeek,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSizes.lg),
            itemCount: 7,
            itemBuilder: (context, i) {
              final date = state.weekStart.add(Duration(days: i));
              final dateOnly = DateTime(date.year, date.month, date.day);
              final isToday = dateOnly == todayDate;

              final entry = state.meals
                  .where(
                    (e) =>
                        e.planDate.year == date.year &&
                        e.planDate.month == date.month &&
                        e.planDate.day == date.day,
                  )
                  .firstOrNull;

              final recipe = entry != null
                  ? state.recipes[entry.recipeId]
                  : null;

              return MealDayCell(
                date: date,
                isToday: isToday,
                entry: entry,
                recipe: recipe,
                onTap: () => onAssignRecipe(date),
                onEdit: () => onEditEntry(entry!),
                onRemove: () => onRemoveEntry(entry!),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Week header
// ---------------------------------------------------------------------------

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.weekStart,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _label() {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final startDay = weekStart.day;
    final endDay = weekEnd.day;
    final endMonth = _months[weekEnd.month - 1];

    if (weekStart.month == weekEnd.month) {
      return 'Mon $startDay – Sun $endDay $endMonth';
    }
    final startMonth = _months[weekStart.month - 1];
    return 'Mon $startDay $startMonth – Sun $endDay $endMonth';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.text,
            onPressed: onPrevious,
            tooltip: 'Previous week',
          ),
          Text(_label(), style: Theme.of(context).textTheme.titleSmall),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.text,
            onPressed: onNext,
            tooltip: 'Next week',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load meal plan.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.sm),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

enum _AppBarAction { addToShoppingList, clearWeek }
