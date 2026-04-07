import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class RecipeLibraryScreen extends ConsumerWidget {
  const RecipeLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _RecipeLibraryBody(babyId: babyId);
      },
    );
  }
}

class _RecipeLibraryBody extends ConsumerStatefulWidget {
  const _RecipeLibraryBody({required this.babyId});

  final String babyId;

  @override
  ConsumerState<_RecipeLibraryBody> createState() => _RecipeLibraryBodyState();
}

class _RecipeLibraryBodyState extends ConsumerState<_RecipeLibraryBody> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(
      recipeLibraryControllerProvider(widget.babyId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Recipes', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (q) => setState(() => _searchQuery = q.trim()),
          ),
          Expanded(
            child: recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => RefreshIndicator(
                onRefresh: () => ref
                    .read(
                      recipeLibraryControllerProvider(widget.babyId).notifier,
                    )
                    .refresh(),
                child: ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.lg),
                          child: Text(
                            "Couldn't load recipes. Pull down to retry.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              data: (state) => _RecipeContent(
                babyId: widget.babyId,
                state: state,
                searchQuery: _searchQuery,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.xs,
        AppSizes.pagePaddingH,
        AppSizes.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          prefixIcon: const Icon(Icons.search, size: AppSizes.iconMd),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: AppSizes.iconSm),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _RecipeContent extends ConsumerWidget {
  const _RecipeContent({
    required this.babyId,
    required this.state,
    required this.searchQuery,
  });

  final String babyId;
  final RecipeLibraryState state;
  final String searchQuery;

  List<Recipe> _filteredRecipes() {
    final q = searchQuery.toLowerCase();
    final all = state.sections.expand((s) => s.recipes).toSet().toList();
    return all
        .where(
          (r) =>
              r.title.toLowerCase().contains(q) ||
              r.allergenTags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchQuery.isNotEmpty) {
      return _SearchResults(
        recipes: _filteredRecipes(),
        query: searchQuery,
        flaggedAllergenKeys: state.flaggedAllergenKeys,
      );
    }

    if (state.sections.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(recipeLibraryControllerProvider(babyId).notifier)
            .refresh(),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Text(
                    'No recipes available right now. '
                    'Check back after completing more allergen steps.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(recipeLibraryControllerProvider(babyId).notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          for (final section in state.sections) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePaddingH,
                  AppSizes.lg,
                  AppSizes.pagePaddingH,
                  AppSizes.sm,
                ),
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final recipe = section.recipes[index];
                  return RecipeGridCard(
                    recipe: recipe,
                    flaggedAllergenKeys: state.flaggedAllergenKeys,
                    onTap: () => context.pushNamed(
                      AppRoute.recipeDetail.name,
                      pathParameters: {'recipeId': recipe.id},
                    ),
                  );
                }, childCount: section.recipes.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.sm,
                  mainAxisSpacing: AppSizes.sm,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.recipes,
    required this.query,
    this.flaggedAllergenKeys = const {},
  });

  final List<Recipe> recipes;
  final String query;
  final Set<String> flaggedAllergenKeys;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Text(
            'No recipes found for "$query".',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePaddingH,
        AppSizes.sm,
        AppSizes.pagePaddingH,
        AppSizes.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.sm,
        mainAxisSpacing: AppSizes.sm,
        childAspectRatio: 0.78,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeGridCard(
          recipe: recipe,
          flaggedAllergenKeys: flaggedAllergenKeys,
          onTap: () => context.pushNamed(
            AppRoute.recipeDetail.name,
            pathParameters: {'recipeId': recipe.id},
          ),
        );
      },
    );
  }
}
