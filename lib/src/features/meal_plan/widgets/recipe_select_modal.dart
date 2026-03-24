import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';

/// Shows a filterable list of recipes and returns the selected [Recipe]
/// via [Navigator.pop].
class RecipeSelectModal extends ConsumerStatefulWidget {
  const RecipeSelectModal({required this.babyId, super.key});

  final String babyId;

  @override
  ConsumerState<RecipeSelectModal> createState() => _RecipeSelectModalState();
}

class _RecipeSelectModalState extends ConsumerState<RecipeSelectModal> {
  List<Recipe>? _recipes;
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final result = await ref
        .read(recipeServiceProvider)
        .getFilteredRecipes(widget.babyId);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = 'Could not load recipes.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _recipes = result.dataOrNull;
      _loading = false;
    });
  }

  List<Recipe> get _filtered {
    final all = _recipes ?? [];
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((r) => r.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
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
              child: Text('Select a Recipe', style: textTheme.titleLarge),
            ),
            const SizedBox(height: AppSizes.md),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search recipes…',
                  prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(height: 1),
            // Content
            Expanded(child: _buildContent(scrollController, textTheme)),
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
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty
              ? 'No recipes available.'
              : 'No results for "$_query".',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.sm,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final recipe = items[index];
        return ListTile(
          title: Text(recipe.title, style: textTheme.labelLarge),
          subtitle: recipe.allergenTags.isEmpty
              ? null
              : Text(
                  recipe.allergenTags.join(' · '),
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
          onTap: () => Navigator.of(context).pop(recipe),
        );
      },
    );
  }
}
