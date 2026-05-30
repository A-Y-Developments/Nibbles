import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/controls/app_checkbox.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';

/// Shows the Add-to-Shopping-List bottom sheet.
///
/// Per Figma node 971:9042 — each row has a leading [AppCheckbox] and a
/// trailing `X` that permanently removes the ingredient from this add's
/// candidate list. A bottom toggle flips between Select All / Unselect All
/// over the remaining (non-removed) rows. The `Add (N)` CTA returns the
/// selected ingredient names, or `null` on dismiss / cancel.
///
/// Names-only contract — reuses the existing
/// `ShoppingListService.addFromRecipe` path. No data layer changes.
Future<List<String>?> showAddToShoppingListSheet(
  BuildContext context,
  List<Ingredient> ingredients,
) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXl),
      ),
    ),
    builder: (context) => _ShoppingListSheet(ingredients: ingredients),
  );
}

class _ShoppingListSheet extends StatefulWidget {
  const _ShoppingListSheet({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  State<_ShoppingListSheet> createState() => _ShoppingListSheetState();
}

class _ShoppingListSheetState extends State<_ShoppingListSheet> {
  /// Indices (in the original ingredients order) currently selected.
  late Set<int> _selected;

  /// Indices removed via the per-row `X`. Cannot be re-added in this session.
  final Set<int> _removed = <int>{};

  @override
  void initState() {
    super.initState();
    // Default: every row pre-selected.
    _selected = <int>{
      for (var i = 0; i < widget.ingredients.length; i++) i,
    };
  }

  int get _remainingCount => widget.ingredients.length - _removed.length;

  bool get _allSelected =>
      _remainingCount > 0 && _selected.length == _remainingCount;

  void _toggleRow(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  void _removeRow(int index) {
    setState(() {
      _removed.add(index);
      _selected.remove(index);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Removed.'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selected.clear();
      } else {
        _selected = <int>{
          for (var i = 0; i < widget.ingredients.length; i++)
            if (!_removed.contains(i)) i,
        };
      }
    });
  }

  void _confirm() {
    final picked = <String>[
      for (var i = 0; i < widget.ingredients.length; i++)
        if (_selected.contains(i)) widget.ingredients[i].name,
    ];
    Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selected.length;
    final visibleIndices = <int>[
      for (var i = 0; i < widget.ingredients.length; i++)
        if (!_removed.contains(i)) i,
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            // Grab handle.
            Container(
              width: AppSizes.sp40,
              height: AppSizes.xs,
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add to Shopping List',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.fgStrong,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(
              height: AppSizes.dividerThickness,
              thickness: AppSizes.dividerThickness,
              color: AppColors.borderSoft,
            ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: visibleIndices.isEmpty
                    ? _EmptyState(theme: theme)
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.pagePaddingH,
                          vertical: AppSizes.sp12,
                        ),
                        itemCount: visibleIndices.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, i) {
                          final index = visibleIndices[i];
                          return _IngredientRow(
                            name: widget.ingredients[index].name,
                            selected: _selected.contains(index),
                            onToggle: () => _toggleRow(index),
                            onRemove: () => _removeRow(index),
                          );
                        },
                      ),
              ),
            ),
            const Divider(
              height: AppSizes.dividerThickness,
              thickness: AppSizes.dividerThickness,
              color: AppColors.borderSoft,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.pagePaddingH,
                AppSizes.sp12,
                AppSizes.pagePaddingH,
                AppSizes.sp12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _SelectAllToggle(
                      label: _allSelected ? 'Unselect All' : 'Select All',
                      onPressed: _remainingCount == 0 ? null : _toggleSelectAll,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  AppPillButton(
                    label: 'Add ($selectedCount)',
                    onPressed: selectedCount == 0 ? null : _confirm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.selected,
    required this.onToggle,
    required this.onRemove,
  });

  final String name;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sp12,
            vertical: AppSizes.sp12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              AppCheckbox(
                value: selected,
                onChanged: (_) => onToggle(),
              ),
              const SizedBox(width: AppSizes.sp12),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgDefault,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _RemoveButton(onPressed: onRemove),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove',
      child: InkResponse(
        onTap: onPressed,
        radius: AppSizes.checkbox,
        child: Container(
          width: AppSizes.checkbox,
          height: AppSizes.checkbox,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.destructiveSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: AppSizes.iconSm,
            color: AppColors.destructive,
          ),
        ),
      ),
    );
  }
}

class _SelectAllToggle extends StatelessWidget {
  const _SelectAllToggle({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null;
    final color = disabled ? AppColors.fgFaint : AppColors.greenDeep;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xs,
          vertical: AppSizes.xs,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.xl,
      ),
      child: Center(
        child: Text(
          'No ingredients left.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.fgFaint,
          ),
        ),
      ),
    );
  }
}
