import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';

/// Bulk add-to-shopping-list modal for all ingredients on the selected day.
class AddToShoppingListModal extends ConsumerStatefulWidget {
  const AddToShoppingListModal({
    required this.babyId,
    required this.date,
    super.key,
  });

  final String babyId;
  final DateTime date;

  @override
  ConsumerState<AddToShoppingListModal> createState() =>
      _AddToShoppingListModalState();
}

class _AddToShoppingListModalState
    extends ConsumerState<AddToShoppingListModal> {
  List<String>? _ingredients;
  late Set<String> _selected;
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
        .getDayIngredientNames(widget.babyId, widget.date);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = 'Could not load ingredients.';
        _loading = false;
      });
      return;
    }
    final items = result.dataOrNull ?? [];
    setState(() {
      _ingredients = items;
      _selected = items.toSet();
      _loading = false;
    });
  }

  Future<void> _confirm() async {
    final selected = _selected.toList();
    if (selected.isEmpty) return;

    setState(() => _submitting = true);
    // recipeId is required by the signature but not stored in
    // ShoppingListItem — empty string is intentional for bulk meal-plan adds.
    final result = await ref
        .read(shoppingListServiceProvider)
        .addFromRecipe(widget.babyId, '', selected);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't add items. Try again.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selected.length} items added to shopping list'),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    child: Text(
                      'Add to Shopping List',
                      style: textTheme.titleLarge,
                    ),
                  ),
                  if (!_loading &&
                      _ingredients != null &&
                      _ingredients!.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(
                        () =>
                            _selected = _selected.length == _ingredients!.length
                            ? {}
                            : _ingredients!.toSet(),
                      ),
                      child: Text(
                        _selected.length == _ingredients!.length
                            ? 'Deselect all'
                            : 'Select all',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Divider(height: 1),
            Expanded(child: _buildContent(scrollController, textTheme)),
            // Bottom action
            if (!_loading && _error == null)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePaddingH,
                    vertical: AppSizes.md,
                  ),
                  child: FilledButton(
                    onPressed: _selected.isEmpty || _submitting
                        ? null
                        : _confirm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                      backgroundColor: AppColors.primary,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Text('Add ${_selected.length} items'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController, TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
        ),
      );
    }
    final items = _ingredients!;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePaddingH),
          child: Text(
            'No ingredients found for this day.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final name = items[index];
        return CheckboxListTile(
          title: Text(name, style: textTheme.bodyMedium),
          value: _selected.contains(name),
          activeColor: AppColors.primary,
          onChanged: (checked) => setState(() {
            if (checked ?? false) {
              _selected = {..._selected, name};
            } else {
              _selected = _selected.where((s) => s != name).toSet();
            }
          }),
        );
      },
    );
  }
}
