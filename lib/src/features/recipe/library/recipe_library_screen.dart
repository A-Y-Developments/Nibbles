import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_controller.dart';
import 'package:nibbles/src/features/recipe/library/recipe_library_state.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_card.dart';
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

class _RecipeLibraryBody extends ConsumerWidget {
  const _RecipeLibraryBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeLibraryControllerProvider(babyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Recipes', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => RefreshIndicator(
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
                      "Couldn't load recipes. Pull down to retry.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (state) => _RecipeContent(babyId: babyId, state: state),
      ),
    );
  }
}

class _RecipeContent extends ConsumerWidget {
  const _RecipeContent({required this.babyId, required this.state});

  final String babyId;
  final RecipeLibraryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = section.recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () => context.pushNamed(
                    AppRoute.recipeDetail.name,
                    pathParameters: {'recipeId': recipe.id},
                  ),
                );
              }, childCount: section.recipes.length),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
        ],
      ),
    );
  }
}
