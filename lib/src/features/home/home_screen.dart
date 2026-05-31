import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/day_chip_row.dart';
import 'package:nibbles/src/features/home/widgets/getting_started_tips_card.dart';
import 'package:nibbles/src/features/home/widgets/greeting_card.dart';
import 'package:nibbles/src/features/home/widgets/helpful_guidance_card.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/features/home/widgets/home_header.dart';
import 'package:nibbles/src/features/home/widgets/home_no_meals_state.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_introduced_card.dart';
import 'package:nibbles/src/features/home/widgets/stat_ring_card.dart';
import 'package:nibbles/src/features/home/widgets/today_date_label.dart';
import 'package:nibbles/src/features/home/widgets/todays_meals_card.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-86 scaffold + NIB-77 populated dashboard + NIB-96 empty-state variant
/// routing.
///
/// The screen is intentionally thin: it watches the controller and routes
/// the resulting [HomeState] into one of four variants — Figma frames
/// 1266:12135 (ready-to-start empty), 1242:10152 (ready-to-start with
/// ongoing), 1266:12400 (no meals mapped) and 1242:10567 (populated). The
/// header/greeting/stats chrome is present in ALL four; the middle and
/// tips sections swap based on [HomeState.variant].
///
/// The populated branch carries NIB-77's data flow — `allergenLogCounts`
/// drives the ongoing card "X/3 times" subhead and `todaysRecipes` hydrates
/// the today's-meals card chips. Non-populated variants that still render
/// the ongoing card pass `logCounts` too (zeros are tolerated).
///
/// The `baby == null` edge case keeps the standalone [HomeEmptyStateFull]
/// (no header — there is no baby to greet).
///
/// Converted to [ConsumerStatefulWidget] in NIB-106 so `initState` can fire
/// `logScreenView('home')` once on mount via a post-frame callback.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Emit screen_view('home') once on the first frame. Guarded + unawaited
    // so an uninitialised Firebase / analytics hiccup never throws into the
    // frame callback (mirrors splash_screen.dart).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await Analytics.instance.logScreenView(screenName: 'home');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  void _onCreateFirstMeal() {
    unawaited(Analytics.instance.logHomeCreateFirstMealTapped());
    context.goNamed(AppRoute.mealPlan.name);
  }

  @override
  Widget build(BuildContext context) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const _HomeLoadingScaffold(),
      error: (_, __) =>
          const _HomeErrorScaffold(message: 'Could not load baby profile.'),
      data: (babyId) {
        if (babyId == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: HomeEmptyStateFull(onCreateMealPlan: _onCreateFirstMeal),
            ),
          );
        }
        return _HomeBody(babyId: babyId, onCreateFirstMeal: _onCreateFirstMeal);
      },
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.babyId, required this.onCreateFirstMeal});

  final String babyId;
  final VoidCallback onCreateFirstMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(homeControllerProvider(babyId));

    return asyncState.when(
      loading: () => const _HomeLoadingScaffold(),
      error: (err, _) => _HomeErrorScaffold(
        message: err is AppException ? err.message : 'Something went wrong.',
        onRetry: () => ref.invalidate(homeControllerProvider(babyId)),
      ),
      data: (state) =>
          _HomeContent(state: state, onCreateFirstMeal: onCreateFirstMeal),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.onCreateFirstMeal});

  final HomeState state;
  final VoidCallback onCreateFirstMeal;

  @override
  Widget build(BuildContext context) {
    final baby = state.baby;

    // `baby == null` is the only branch that drops the dashboard chrome —
    // there is no baby to greet. All three Figma variants below render the
    // header + greeting + stats.
    if (baby == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: HomeEmptyStateFull(onCreateMealPlan: onCreateFirstMeal),
        ),
      );
    }

    final ageMonths = _monthsBetween(baby.dateOfBirth, DateTime.now());
    final variant = state.variant;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePaddingH,
            vertical: AppSizes.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(babyName: baby.name, ageMonths: ageMonths),
              const SizedBox(height: AppSizes.md),
              GreetingCard(
                babyName: baby.name,
                ageMonths: ageMonths,
                dateOfBirth: baby.dateOfBirth,
              ),
              const SizedBox(height: AppSizes.md),
              StatRingCard(
                safeCount: state.safeCount,
                flaggedCount: state.flaggedCount,
                notStartedCount: state.notStartedCount,
                inProgressCount: state.inProgressCount,
                todayMealCount: state.todayMealCount,
                todayMealTarget: 2,
              ),
              const SizedBox(height: AppSizes.md),
              ..._middleSection(
                state: state,
                babyName: baby.name,
                variant: variant,
                onCreateFirstMeal: onCreateFirstMeal,
              ),
              const SizedBox(height: AppSizes.md),
              _tipsSection(variant),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Middle section composition per variant.
  ///
  /// - [HomeVariant.readyToStartEmpty]: only the date label + the
  ///   ReadyToStart card. No ongoing, no day chips, no today's meals.
  /// - [HomeVariant.readyToStartWithOngoing]: ongoing + day chips + date
  ///   label + ReadyToStart card.
  /// - [HomeVariant.noMealsToday]: ongoing + day chips + date label +
  ///   `HomeNoMealsState` dashed body.
  /// - [HomeVariant.populated]: ongoing + day chips + `TodaysMealsCard`
  ///   (which renders its own date label).
  List<Widget> _middleSection({
    required HomeState state,
    required String babyName,
    required HomeVariant variant,
    required VoidCallback onCreateFirstMeal,
  }) {
    switch (variant) {
      case HomeVariant.readyToStartEmpty:
        return [
          const TodayDateLabel(),
          const SizedBox(height: AppSizes.sm),
          ReadyToStartCard(babyName: babyName, onPressed: onCreateFirstMeal),
        ];
      case HomeVariant.readyToStartWithOngoing:
        return [
          OngoingIntroducedCard(
            allergenStatuses: state.allergenStatuses,
            logCounts: state.allergenLogCounts,
          ),
          const SizedBox(height: AppSizes.md),
          const DayChipRow(),
          const SizedBox(height: AppSizes.md),
          const TodayDateLabel(),
          const SizedBox(height: AppSizes.sm),
          ReadyToStartCard(babyName: babyName, onPressed: onCreateFirstMeal),
        ];
      case HomeVariant.noMealsToday:
        return [
          OngoingIntroducedCard(
            allergenStatuses: state.allergenStatuses,
            logCounts: state.allergenLogCounts,
          ),
          const SizedBox(height: AppSizes.md),
          const DayChipRow(),
          const SizedBox(height: AppSizes.md),
          const TodayDateLabel(),
          const SizedBox(height: AppSizes.sm),
          HomeNoMealsState(babyName: babyName, onAddMeal: onCreateFirstMeal),
        ];
      case HomeVariant.populated:
        return [
          OngoingIntroducedCard(
            allergenStatuses: state.allergenStatuses,
            logCounts: state.allergenLogCounts,
          ),
          const SizedBox(height: AppSizes.md),
          const DayChipRow(),
          const SizedBox(height: AppSizes.md),
          TodaysMealsCard(
            todaysMeals: state.todaysMeals,
            recipes: state.todaysRecipes,
          ),
        ];
    }
  }

  /// Populated keeps the rich [HelpfulGuidanceCard]; every other variant
  /// renders the single "Getting Started Tips" cream card.
  Widget _tipsSection(HomeVariant variant) {
    if (variant == HomeVariant.populated) {
      return const HelpfulGuidanceCard();
    }
    return const GettingStartedTipsCard();
  }

  int _monthsBetween(DateTime from, DateTime to) {
    final raw = (to.year - from.year) * 12 + (to.month - from.month);
    final adjusted = to.day < from.day ? raw - 1 : raw;
    return adjusted < 0 ? 0 : adjusted;
  }
}

class _HomeLoadingScaffold extends StatelessWidget {
  const _HomeLoadingScaffold();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: CircularProgressIndicator()),
  );
}

class _HomeErrorScaffold extends StatelessWidget {
  const _HomeErrorScaffold({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
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
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.subtext,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSizes.lg),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
