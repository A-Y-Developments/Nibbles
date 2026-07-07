import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/controls/app_checkbox.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';

/// Shows the Add-to-Shoplist bottom sheet (NIB-75).
///
/// Layout mirrors the meal-plan day modal (`AddToShoppingListModal`):
///   * draggable sheet, grab handle, title + "Select all" toggle, divider
///   * plain checkbox rows (leading checkbox + name) with a trailing burgundy
///     X that drops the row from this sheet's candidate list
///   * single full-width "Add (N) items" pill at the bottom
///
/// Recipe-specific behaviour retained: ingredients are pre-loaded (no async
/// fetch), and the per-row X removes the row with an Undo snackbar.
///
/// All rows are pre-selected on open. Resolves to the picked ingredient names
/// on confirm, or `null` on dismiss.
Future<List<String>?> showAddToShoppingListSheet(
  BuildContext context,
  List<Ingredient> ingredients,
) {
  return showModalBottomSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
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

  /// Indices removed via the per-row `X`. Cannot be re-added except via Undo.
  final Set<int> _removed = <int>{};

  /// Guard against double-tap on confirm.
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _selected = <int>{for (var i = 0; i < widget.ingredients.length; i++) i};
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
    final name = widget.ingredients[index].name;
    setState(() {
      _removed.add(index);
      _selected.remove(index);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed $name'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _removed.remove(index);
                _selected.add(index);
              });
            },
          ),
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
    if (_dismissing) return;
    _dismissing = true;
    final picked = <String>[
      for (var i = 0; i < widget.ingredients.length; i++)
        if (_selected.contains(i)) widget.ingredients[i].name,
    ];
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedCount = _selected.length;
    final visibleIndices = <int>[
      for (var i = 0; i < widget.ingredients.length; i++)
        if (!_removed.contains(i)) i,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppSizes.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Add to Shoplist', style: textTheme.titleSmall),
                  ),
                  if (_remainingCount > 0)
                    TextButton(
                      onPressed: _toggleSelectAll,
                      child: Text(_allSelected ? 'Deselect all' : 'Select all'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Divider(height: 1),
            Expanded(
              child: visibleIndices.isEmpty
                  ? _EmptyState(textTheme: textTheme)
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: visibleIndices.length,
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                  vertical: AppSizes.md,
                ),
                child: AppPillButton(
                  label: 'Add ($selectedCount) items',
                  onPressed: selectedCount == 0 ? null : _confirm,
                ),
              ),
            ),
          ],
        );
      },
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
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: name,
      checked: selected,
      onTap: onToggle,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.xs,
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: AppCheckbox(
                  value: selected,
                  onChanged: (_) => onToggle(),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(name, style: textTheme.bodyMedium),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _RemoveButton(name: name, onPressed: onRemove),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove $name',
      child: InkResponse(
        onTap: onPressed,
        radius: AppSizes.lg,
        child: const SizedBox(
          width: AppSizes.xxl,
          height: AppSizes.xxl,
          child: Center(
            child: Icon(
              Icons.close,
              size: AppSizes.iconSm,
              color: AppColors.burgundy,
              semanticLabel: '',
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePaddingH),
        child: Text(
          'No ingredients left.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
