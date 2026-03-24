import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_sheet.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Could not load baby profile.')),
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            body: Center(child: Text('No baby profile found.')),
          );
        }
        return _HomeBody(babyId: babyId);
      },
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.babyId});

  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(homeControllerProvider(babyId));

    return asyncState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  err is AppException ? err.message : 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.subtext),
                ),
                const SizedBox(height: AppSizes.lg),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(homeControllerProvider(babyId)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (state) => _HomeContent(babyId: babyId, state: state),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.babyId, required this.state});

  final String babyId;
  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pagePaddingH,
                  AppSizes.pagePaddingV,
                  AppSizes.pagePaddingH,
                  0,
                ),
                child: _Header(baby: state.baby),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: _AllergenWidget(
                  babyId: babyId,
                  state: state,
                  onLogFood: () => _openLogSheet(context, ref, state),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: _TodayMealCard(babyId: babyId, state: state),
              ),
            ),
            if (_showRecommendations(state)) ...[
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
              SliverToBoxAdapter(
                child: _RecommendationsStrip(state: state),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
          ],
        ),
      ),
    );
  }

  bool _showRecommendations(HomeState state) {
    return state.programState.status != AllergenProgramStatus.completed &&
        state.recommendations.isNotEmpty;
  }

  Future<void> _openLogSheet(
    BuildContext context,
    WidgetRef ref,
    HomeState state,
  ) async {
    final boardItem = state.currentAllergenBoardItem;
    if (boardItem == null) return;

    final logged = await showAllergenLogSheet(
      context,
      babyId: babyId,
      babyName: state.baby.name,
      allergenKey: boardItem.allergen.key,
      allergenName: boardItem.allergen.name,
      allergenEmoji: boardItem.allergen.emoji,
    );

    if (logged ?? false) {
      ref.invalidate(homeControllerProvider(babyId));
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Left: logo / app name
        Text(
          'Nibbles',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        // Center: greeting
        Column(
          children: [
            Text(
              "Hi, ${baby.name}'s Parents 👋",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _ageStageLabel(baby.dateOfBirth),
              style: textTheme.bodySmall?.copyWith(color: AppColors.subtext),
            ),
          ],
        ),
        const Spacer(),
        // Right: profile avatar
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => context.pushNamed(AppRoute.profile.name),
            child: Container(
              width: AppSizes.avatarSm,
              height: AppSizes.avatarSm,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _ageStageLabel(DateTime dob) {
    final months =
        (DateTime.now().year - dob.year) * 12 +
        DateTime.now().month -
        dob.month;
    if (months < 6) return 'Under 6 months';
    if (months < 9) return '6–9 months';
    if (months < 12) return '9–12 months';
    if (months < 18) return '12–18 months';
    if (months < 24) return '18–24 months';
    return '2+ years';
  }
}

// ---------------------------------------------------------------------------
// Allergen Widget — 3 states
// ---------------------------------------------------------------------------

class _AllergenWidget extends StatelessWidget {
  const _AllergenWidget({
    required this.babyId,
    required this.state,
    required this.onLogFood,
  });

  final String babyId;
  final HomeState state;
  final VoidCallback onLogFood;

  @override
  Widget build(BuildContext context) {
    // State C — program complete
    if (state.programState.status == AllergenProgramStatus.completed) {
      return _CompletionBanner(babyName: state.baby.name);
    }

    final boardItem = state.currentAllergenBoardItem;
    if (boardItem == null) return const SizedBox.shrink();

    return _ActiveAllergenCard(
      boardItem: boardItem,
      hasLoggedToday: state.hasLoggedToday,
      onLogFood: onLogFood,
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.babyName});

  final String babyName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.profile.name),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 28)),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                '$babyName has completed the allergen program! '
                'All discovered safe allergens are in your Profile.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveAllergenCard extends StatelessWidget {
  const _ActiveAllergenCard({
    required this.boardItem,
    required this.hasLoggedToday,
    required this.onLogFood,
  });

  final AllergenBoardItem boardItem;
  final bool hasLoggedToday;
  final VoidCallback onLogFood;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logs = boardItem.logs;
    final allergen = boardItem.allergen;
    final dayCount = min(logs.length, 3);
    final weeklyDots = _buildWeeklyDots(logs);
    final lastLog = logs.isEmpty
        ? null
        : (List<AllergenLog>.from(logs)
              ..sort((a, b) => b.logDate.compareTo(a.logDate)))
            .first;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Allergen header
          Row(
            children: [
              Text(allergen.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allergen.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Day $dayCount/3',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Weekly dots (Sun–Sat)
          _WeeklyDots(dots: weeklyDots),
          const SizedBox(height: AppSizes.sm),
          // Last log summary
          if (lastLog != null) ...[
            Text(
              lastLog.hadReaction
                  ? 'Last log: Had Reaction ⚠️'
                  : 'Last log: No Reaction ✅',
              style: textTheme.bodySmall?.copyWith(color: AppColors.subtext),
            ),
            const SizedBox(height: AppSizes.md),
          ],
          // CTA — State A vs State B
          if (hasLoggedToday)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Logged today',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('log_food_button'),
                onPressed: onLogFood,
                child: const Text('Log Food'),
              ),
            ),
        ],
      ),
    );
  }

  List<bool> _buildWeeklyDots(List<AllergenLog> logs) {
    final today = DateTime.now();
    final sundayStart = today.subtract(Duration(days: today.weekday % 7));
    return List.generate(7, (i) {
      final day = sundayStart.add(Duration(days: i));
      return logs.any(
        (log) =>
            log.logDate.year == day.year &&
            log.logDate.month == day.month &&
            log.logDate.day == day.day,
      );
    });
  }
}

class _WeeklyDots extends StatelessWidget {
  const _WeeklyDots({required this.dots});

  final List<bool> dots;

  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final filled = i < dots.length && dots[i];
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.primary : AppColors.surfaceVariant,
                border: Border.all(
                  color: filled ? AppColors.primary : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: filled
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              _labels[i],
              style: textTheme.labelSmall?.copyWith(color: AppColors.subtext),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Today's Meal Card
// ---------------------------------------------------------------------------

class _TodayMealCard extends StatelessWidget {
  const _TodayMealCard({required this.babyId, required this.state});

  final String babyId;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Meal",
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.subtext,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          if (state.todayRecipe != null)
            _FilledMealCard(recipe: state.todayRecipe!)
          else
            _EmptyMealCard(),
        ],
      ),
    );
  }
}

class _FilledMealCard extends StatelessWidget {
  const _FilledMealCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (recipe.allergenTags.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xs),
                Wrap(
                  spacing: AppSizes.xs,
                  children: recipe.allergenTags.map((tag) {
                    final emoji = AllergenEmoji.get(tag);
                    return Chip(
                      label: Text('$emoji $tag'),
                      labelStyle: textTheme.labelSmall,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: AppColors.surfaceVariant,
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.add_shopping_cart_outlined,
            size: AppSizes.iconMd,
          ),
          color: AppColors.primary,
          tooltip: 'Add to shopping list',
          onPressed: () => context.pushNamed(AppRoute.shoppingList.name),
        ),
      ],
    );
  }
}

class _EmptyMealCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No meal planned for today. Add one from the recipe library.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
        ),
        const SizedBox(height: AppSizes.sm),
        TextButton(
          onPressed: () => context.goNamed(AppRoute.recipeLibrary.name),
          child: const Text('Browse Recipe Library'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recommendations Strip
// ---------------------------------------------------------------------------

class _RecommendationsStrip extends StatelessWidget {
  const _RecommendationsStrip({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allergenKey = state.programState.currentAllergenKey;
    final allergenEmoji = AllergenEmoji.get(allergenKey);
    final allergenName = state.currentAllergenBoardItem?.allergen.name ??
        allergenKey.replaceAll('_', ' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: Text(
            'Recommended for $allergenName $allergenEmoji',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
            ),
            itemCount: state.recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
            itemBuilder: (context, index) {
              final recipe = state.recommendations[index];
              return _RecommendationCard(recipe: recipe);
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.recipeDetail.name,
        pathParameters: {'recipeId': recipe.id},
      ),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Center(
                child: recipe.allergenTags.isNotEmpty
                    ? Text(
                        AllergenEmoji.get(recipe.allergenTags.first),
                        style: const TextStyle(fontSize: 36),
                      )
                    : const Icon(
                        Icons.restaurant,
                        color: AppColors.hint,
                        size: AppSizes.iconLg,
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              recipe.title,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (recipe.allergenTags.isNotEmpty) ...[
              const SizedBox(height: AppSizes.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                ),
                child: Text(
                  '${AllergenEmoji.get(recipe.allergenTags.first)}'
                  ' ${recipe.allergenTags.first}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
