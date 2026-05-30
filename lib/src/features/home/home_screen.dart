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
import 'package:nibbles/src/features/home/widgets/greeting_card.dart';
import 'package:nibbles/src/features/home/widgets/helpful_guidance_card.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/features/home/widgets/home_header.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_introduced_card.dart';
import 'package:nibbles/src/features/home/widgets/stat_ring_card.dart';
import 'package:nibbles/src/features/home/widgets/todays_meals_card.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-86 scaffold.
///
/// The screen is intentionally thin: it watches the controller and routes the
/// resulting [HomeState] into placeholder widgets under `widgets/`. The leaf
/// implementations land in NIB-65 (header + greeting + stat ring), NIB-77
/// (ongoing card + day chips + today's meals + guidance) and NIB-96
/// (empty-state variants).
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
      error: (_, __) => const _HomeErrorScaffold(
        message: 'Could not load baby profile.',
      ),
      data: (babyId) {
        if (babyId == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: HomeEmptyStateFull(onCreateMealPlan: _onCreateFirstMeal),
            ),
          );
        }
        return _HomeBody(
          babyId: babyId,
          onCreateFirstMeal: _onCreateFirstMeal,
        );
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
      data: (state) => _HomeContent(
        state: state,
        onCreateFirstMeal: onCreateFirstMeal,
      ),
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

    // Full empty-state — no baby OR no logged activity yet.
    if (baby == null || state.hasNoActivity) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: HomeEmptyStateFull(
            babyName: baby?.name,
            onCreateMealPlan: onCreateFirstMeal,
          ),
        ),
      );
    }

    final ageMonths = _monthsBetween(baby.dateOfBirth, DateTime.now());

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
              HomeHeader(
                babyName: baby.name,
                ageMonths: ageMonths,
              ),
              const SizedBox(height: AppSizes.md),
              GreetingCard(
                babyName: baby.name,
                ageMonths: ageMonths,
              ),
              const SizedBox(height: AppSizes.md),
              StatRingCard(
                safeCount: state.safeCount,
                flaggedCount: state.flaggedCount,
                notStartedCount: state.notStartedCount,
                inProgressCount: state.inProgressCount,
              ),
              const SizedBox(height: AppSizes.md),
              OngoingIntroducedCard(
                allergenStatuses: state.allergenStatuses,
              ),
              const SizedBox(height: AppSizes.md),
              const DayChipRow(),
              const SizedBox(height: AppSizes.md),
              TodaysMealsCard(todaysMeals: state.todaysMeals),
              const SizedBox(height: AppSizes.md),
              const HelpfulGuidanceCard(),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
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
