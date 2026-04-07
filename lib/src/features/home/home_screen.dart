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
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_sheet.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.subtext),
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
                  onProceedToNext: () => _proceedToNext(context, ref),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                child: _TodayMealCard(
                  babyId: babyId,
                  state: state,
                  flaggedAllergenKeys: state.flaggedAllergenKeys,
                ),
              ),
            ),
            if (_showRecommendations(state)) ...[
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
              SliverToBoxAdapter(
                child: _RecommendationsStrip(
                  state: state,
                  flaggedAllergenKeys: state.flaggedAllergenKeys,
                ),
              ),
            ],
            if (_showGeneralGrid(state)) ...[
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePaddingH,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.isGeneralRecommendations
                            ? 'Recipes for You 🍽️'
                            : 'General Recommendations 🍽️',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.goNamed(AppRoute.recipeLibrary.name),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.sm,
                    mainAxisSpacing: AppSizes.sm,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final recipe = state.generalRecommendations[index];
                    return RecipeGridCard(
                      recipe: recipe,
                      flaggedAllergenKeys: state.flaggedAllergenKeys,
                      onTap: () => context.pushNamed(
                        AppRoute.recipeDetail.name,
                        pathParameters: {'recipeId': recipe.id},
                      ),
                    );
                  }, childCount: state.generalRecommendations.length),
                ),
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
        !state.isGeneralRecommendations &&
        state.recommendations.isNotEmpty;
  }

  bool _showGeneralGrid(HomeState state) {
    return state.programState.status != AllergenProgramStatus.completed &&
        state.generalRecommendations.isNotEmpty;
  }

  Future<void> _proceedToNext(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(allergenServiceProvider)
        .advanceToNextAllergen(babyId);
    result.when(
      success: (_) => ref.invalidate(homeControllerProvider(babyId)),
      failure: (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Couldn't advance. Please try again."),
            ),
          );
        }
      },
    );
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
      allergenKey: boardItem.allergen.key,
      allergenName: boardItem.allergen.name,
      allergenEmoji: boardItem.allergen.emoji,
    );

    if (logged ?? false) {
      ref.invalidate(homeControllerProvider(babyId));

      // If a reaction was logged, show GP referral dialog.
      final logState = ref.read(allergenLogControllerProvider);
      if (logState.hadReaction == true && context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => const _GpReferralDialog(),
        );
      }
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
        // Left: greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    required this.onProceedToNext,
  });

  final String babyId;
  final HomeState state;
  final VoidCallback onLogFood;
  final VoidCallback onProceedToNext;

  @override
  Widget build(BuildContext context) {
    // State C — program complete
    if (state.programState.status == AllergenProgramStatus.completed) {
      return _CompletionBanner(babyName: state.baby.name);
    }

    final boardItem = state.currentAllergenBoardItem;
    if (boardItem == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.allergenTracker.name),
      child: _ActiveAllergenCard(
        boardItem: boardItem,
        onLogFood: onLogFood,
        onProceedToNext: onProceedToNext,
      ),
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
    required this.onLogFood,
    required this.onProceedToNext,
  });

  final AllergenBoardItem boardItem;
  final VoidCallback onLogFood;
  final VoidCallback onProceedToNext;

  String _progressCopy(int logCount, bool isSafe, bool isFlagged) {
    if (isSafe) return 'All 3 exposures done — no reaction! 🎉';
    if (isFlagged) return 'Reaction detected — you can skip to the next one.';
    if (logCount == 0) return 'Feed 3 times over a few days to confirm safe.';
    if (logCount == 1) return '2 more exposures needed — keep going!';
    return '1 more exposure to go — almost there!';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logs = boardItem.logs;
    final allergen = boardItem.allergen;
    final logCount = min(logs.length, 3);
    final isSafe = boardItem.status == AllergenStatus.safe;
    final isFlagged = boardItem.status == AllergenStatus.flagged;
    final lastLog = logs.isEmpty
        ? null
        : (List<AllergenLog>.from(
            logs,
          )..sort((a, b) => b.logDate.compareTo(a.logDate))).first;

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
          // Eyebrow label
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: isFlagged
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : isSafe
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              isFlagged
                  ? '⚠️ Reaction flagged'
                  : isSafe
                  ? '✅ Allergen safe'
                  : '🧪 Now introducing',
              style: textTheme.labelSmall?.copyWith(
                color: isFlagged
                    ? AppColors.warning
                    : isSafe
                    ? AppColors.success
                    : AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          // Allergen header
          Row(
            children: [
              Text(allergen.emoji, style: const TextStyle(fontSize: 32)),
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
                      '$logCount of 3 exposures logged',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              // Tap hint
              const Icon(
                Icons.chevron_right,
                color: AppColors.subtext,
                size: AppSizes.iconSm,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Introduction dots (3 required logs)
          _IntroductionDots(logs: logs),
          const SizedBox(height: AppSizes.sm),
          // Progress copy
          Text(
            _progressCopy(logCount, isSafe, isFlagged),
            style: textTheme.bodySmall?.copyWith(color: AppColors.subtext),
          ),
          // Last log summary
          if (lastLog != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              lastLog.hadReaction
                  ? 'Last log: Had Reaction ⚠️'
                  : 'Last log: No Reaction ✅',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.subtext,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: isSafe
                ? FilledButton(
                    key: const Key('proceed_next_button'),
                    onPressed: onProceedToNext,
                    child: const Text('Proceed to Next Allergen'),
                  )
                : isFlagged
                ? FilledButton(
                    key: const Key('skip_next_button'),
                    onPressed: onProceedToNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warning,
                    ),
                    child: const Text('Skip to Next Allergen'),
                  )
                : FilledButton(
                    key: const Key('log_food_button'),
                    onPressed: onLogFood,
                    child: const Text('Log Food Today'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _IntroductionDots extends StatelessWidget {
  const _IntroductionDots({required this.logs});

  final List<AllergenLog> logs;

  String _tasteEmoji(EmojiTaste taste) => switch (taste) {
    EmojiTaste.love => '😍',
    EmojiTaste.neutral => '😐',
    EmojiTaste.dislike => '😣',
  };

  @override
  Widget build(BuildContext context) {
    final sorted = List<AllergenLog>.from(logs)
      ..sort((a, b) => a.logDate.compareTo(b.logDate));
    final capped = sorted.length > 3 ? sorted.sublist(0, 3) : sorted;
    return Row(
      children: List.generate(3, (i) {
        final log = i < capped.length ? capped[i] : null;
        final filled = log != null;
        final isReaction = log?.hadReaction ?? false;
        final dotColor = !filled
            ? AppColors.surfaceVariant
            : isReaction
            ? AppColors.allergenFlagged
            : AppColors.allergenSafe;
        final borderColor = !filled ? AppColors.divider : dotColor;

        return Padding(
          padding: const EdgeInsets.only(right: AppSizes.sm),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: filled
                ? Center(
                    child: Text(
                      isReaction ? '⚠️' : _tasteEmoji(log.emojiTaste),
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// GP Referral Dialog — shown after a reaction is logged
// ---------------------------------------------------------------------------

class _GpReferralDialog extends StatelessWidget {
  const _GpReferralDialog();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      icon: const Icon(
        Icons.local_hospital_outlined,
        color: AppColors.warning,
        size: AppSizes.iconXl,
      ),
      title: Text(
        'Reaction Recorded',
        style: textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Text(
        'A reaction has been logged for this allergen. '
        'We recommend consulting your GP or paediatrician '
        'before continuing exposure.',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
        textAlign: TextAlign.center,
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Today's Meal Card
// ---------------------------------------------------------------------------

class _TodayMealCard extends StatelessWidget {
  const _TodayMealCard({
    required this.babyId,
    required this.state,
    this.flaggedAllergenKeys = const {},
  });

  final String babyId;
  final HomeState state;
  final Set<String> flaggedAllergenKeys;

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
          if (state.todayRecipes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  state.todayRecipes
                      .expand(
                        (r) => [
                          _FilledMealCard(
                            recipe: r,
                            flaggedAllergenKeys: flaggedAllergenKeys,
                          ),
                          const SizedBox(height: AppSizes.sm),
                        ],
                      )
                      .toList()
                    ..removeLast(),
            )
          else
            _EmptyMealCard(),
        ],
      ),
    );
  }
}

class _FilledMealCard extends StatelessWidget {
  const _FilledMealCard({
    required this.recipe,
    this.flaggedAllergenKeys = const {},
  });

  final Recipe recipe;
  final Set<String> flaggedAllergenKeys;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final flaggedTags = recipe.allergenTags
        .where(flaggedAllergenKeys.contains)
        .toList();
    final isUnsafe = flaggedTags.isNotEmpty;

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.recipeDetail.name,
        pathParameters: {'recipeId': recipe.id},
      ),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (recipe.allergenTags.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Wrap(
              spacing: AppSizes.xs,
              children: recipe.allergenTags.map((tag) {
                final emoji = AllergenEmoji.get(tag);
                final isFlagged = flaggedAllergenKeys.contains(tag);
                return Chip(
                  label: Text('$emoji $tag'),
                  labelStyle: textTheme.labelSmall?.copyWith(
                    color: isFlagged ? AppColors.allergenFlagged : null,
                    fontWeight: isFlagged ? FontWeight.w700 : null,
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isFlagged
                      ? AppColors.allergenFlagged.withValues(alpha: 0.1)
                      : AppColors.surfaceVariant,
                  side: isFlagged
                      ? BorderSide(
                          color: AppColors.allergenFlagged.withValues(
                            alpha: 0.4,
                          ),
                        )
                      : BorderSide.none,
                );
              }).toList(),
            ),
          ],
          if (isUnsafe) ...[
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.allergenFlagged,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Contains flagged allergen',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.allergenFlagged,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
          'No meal planned for today. Add one to get started.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.subtext),
        ),
        const SizedBox(height: AppSizes.sm),
        TextButton(
          onPressed: () => context.goNamed(AppRoute.mealPlan.name),
          child: const Text('Plan a Meal'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recommendations Strip
// ---------------------------------------------------------------------------

class _RecommendationsStrip extends StatelessWidget {
  const _RecommendationsStrip({
    required this.state,
    this.flaggedAllergenKeys = const {},
  });

  final HomeState state;
  final Set<String> flaggedAllergenKeys;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allergenKey = state.programState.currentAllergenKey;
    final allergenEmoji = AllergenEmoji.get(allergenKey);
    final allergenName =
        state.currentAllergenBoardItem?.allergen.name ??
        allergenKey.replaceAll('_', ' ');
    final title = state.isGeneralRecommendations
        ? 'Recipes for You 🍽️'
        : 'Recommended for $allergenName $allergenEmoji';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
          ),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        SizedBox(
          height: 226,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.xs,
            ),
            itemCount: state.recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
            itemBuilder: (context, index) {
              final recipe = state.recommendations[index];
              return SizedBox(
                width: 140,
                child: RecipeGridCard(
                  recipe: recipe,
                  flaggedAllergenKeys: flaggedAllergenKeys,
                  onTap: () => context.pushNamed(
                    AppRoute.recipeDetail.name,
                    pathParameters: {'recipeId': recipe.id},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
