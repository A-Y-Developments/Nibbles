import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';

/// NIB-136: range-scoped "Add to Shoplist" bottom sheet (Figma 971:7850 /
/// 971:7924). Aggregates de-duplicated ingredient names across every recipe
/// planned inside `[startDate, endDate]` and lets the user toggle which ones
/// land in the shopping list with `source=mealPlan`.
///
/// Launched from the meal-planner screen-level overflow menu. The per-day
/// overflow continues to use the day-scoped `AddToShoppingListModal`.
class RangeAddToShoplistSheet extends ConsumerStatefulWidget {
  const RangeAddToShoplistSheet({
    required this.babyId,
    required this.startDate,
    required this.endDate,
    super.key,
  });

  final String babyId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  ConsumerState<RangeAddToShoplistSheet> createState() =>
      _RangeAddToShoplistSheetState();
}

class _RangeAddToShoplistSheetState
    extends ConsumerState<RangeAddToShoplistSheet> {
  static const _weekdayShort = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _monthLong = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<String>? _ingredients;
  Set<String> _selected = <String>{};
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final result = await ref
        .read(mealPlanServiceProvider)
        .getRangeIngredientNames(
          widget.babyId,
          widget.startDate,
          widget.endDate,
        );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = 'Could not load ingredients.';
        _loading = false;
      });
      return;
    }
    final items = result.dataOrNull ?? <String>[];
    setState(() {
      _ingredients = items;
      _selected = items.toSet();
      _loading = false;
    });
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected = {..._selected}..remove(name);
      } else {
        _selected = {..._selected, name};
      }
    });
  }

  void _toggleAll() {
    final items = _ingredients;
    if (items == null || items.isEmpty) return;
    setState(() {
      _selected = _selected.isEmpty ? items.toSet() : <String>{};
    });
  }

  Future<void> _submit() async {
    final selected = _ingredients
        ?.where(_selected.contains)
        .toList(growable: false);
    if (selected == null || selected.isEmpty) return;

    setState(() => _submitting = true);
    final result = await ref
        .read(shoppingListServiceProvider)
        .addFromMealPlan(widget.babyId, selected);
    if (!mounted) return;
    setState(() => _submitting = false);

    final messenger = ScaffoldMessenger.of(context);
    if (result.isFailure) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't add items. Try again.")),
      );
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Added to shopping list.')),
    );
    Navigator.of(context).pop(true);
  }

  /// Spec format: `Mon, 20 - Thu 23 April` (Figma 971:7908). Comma only
  /// after the start weekday; month name appears once at the end.
  String _dateRangeLabel() {
    final start = widget.startDate;
    final end = widget.endDate;
    final startDow = _weekdayShort[start.weekday - 1];
    final endDow = _weekdayShort[end.weekday - 1];
    final endMonth = _monthLong[end.month - 1];
    return '$startDow, ${start.day} - $endDow ${end.day} $endMonth';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.19, 0.50],
              colors: [AppColors.butterSoft, Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.xl - 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.sp12,
                AppSizes.lg + MediaQuery.of(context).padding.top,
                AppSizes.sp12,
                AppSizes.md,
              ),
              child: Column(
                children: [
                  _Header(
                    title: 'Add to Shoplist',
                    subtitle: _dateRangeLabel(),
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: AppSizes.sp12),
                  Expanded(child: _buildList(scrollController)),
                  if (!_loading && _error == null)
                    _BottomActions(
                      anySelected: _selected.isNotEmpty,
                      selectedCount: _selected.length,
                      submitting: _submitting,
                      onToggleAll: _toggleAll,
                      onSubmit: _submit,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(ScrollController controller) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text(
            _error!,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final items = _ingredients!;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text(
            'No ingredients yet.',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sp12),
      itemBuilder: (context, index) {
        final name = items[index];
        return _IngredientRow(
          name: name,
          selected: _selected.contains(name),
          onTap: () => _toggle(name),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header — title + subtitle (date range) + close button
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: const Padding(
            padding: EdgeInsets.all(AppSizes.sm),
            child: Icon(
              Icons.close,
              size: AppSizes.iconSm + 8,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ingredient row — full-width tappable card with checkbox + name + close X
// ---------------------------------------------------------------------------

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.sp12),
          decoration: BoxDecoration(
            color: selected ? AppColors.butter : AppColors.cream,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              _CheckboxIcon(checked: selected),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: AppSizes.sm),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.burgundy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckboxIcon extends StatelessWidget {
  const _CheckboxIcon({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Icon(
      checked ? Icons.check_box : Icons.check_box_outline_blank,
      size: 18,
      color: AppColors.greenDeep,
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom actions — outlined toggle on left, filled Add on right
// ---------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.anySelected,
    required this.selectedCount,
    required this.submitting,
    required this.onToggleAll,
    required this.onSubmit,
  });

  final bool anySelected;
  final int selectedCount;
  final bool submitting;
  final VoidCallback onToggleAll;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final toggleLabel = anySelected ? 'Unselect All' : 'Select All';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sm,
        AppSizes.md,
        AppSizes.sm,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: submitting ? null : onToggleAll,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.xxl),
                side: const BorderSide(color: AppColors.greenDeep),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius2xl),
                ),
                foregroundColor: AppColors.greenDeep,
              ),
              child: Text(
                toggleLabel,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sp12),
          Expanded(
            child: FilledButton(
              onPressed: anySelected && !submitting ? onSubmit : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.xxl),
                backgroundColor: AppColors.greenDeep,
                disabledBackgroundColor: AppColors.greenDeep.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius2xl),
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onGreen,
                      ),
                    )
                  : Text(
                      'Add ($selectedCount)',
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper that opens [RangeAddToShoplistSheet] as a modal bottom sheet.
/// Returns `true` if the user confirmed an add; `null` on dismiss.
Future<bool?> showRangeAddToShoplistSheet(
  BuildContext context, {
  required String babyId,
  required DateTime startDate,
  required DateTime endDate,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => RangeAddToShoplistSheet(
      babyId: babyId,
      startDate: startDate,
      endDate: endDate,
    ),
  );
}
