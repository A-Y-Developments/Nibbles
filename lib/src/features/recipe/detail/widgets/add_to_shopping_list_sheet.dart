import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';

/// Shows a bottom sheet for selecting ingredients to add to the shopping list.
/// Ingredient names only — no quantities. All pre-checked by default.
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
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(Iterable.generate(widget.ingredients.length));
  }

  @override
  Widget build(BuildContext context) {
    final count = _selected.length;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: AppSizes.sm),
            Container(
              width: 40,
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
              child: Text(
                'Add to Shopping List',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  final name = widget.ingredients[index].name;
                  return CheckboxListTile(
                    value: _selected.contains(index),
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _selected.add(index);
                        } else {
                          _selected.remove(index);
                        }
                      });
                    },
                    title: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePaddingH,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: FilledButton(
                  onPressed: count == 0
                      ? null
                      : () {
                          final names = _selected
                              .map((i) => widget.ingredients[i].name)
                              .toList();
                          Navigator.of(context).pop(names);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    count == 0
                        ? 'Select items'
                        : 'Add $count ${count == 1 ? 'item' : 'items'}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
