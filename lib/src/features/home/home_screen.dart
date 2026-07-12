import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/home/home_controller.dart';
import 'package:nibbles/src/features/home/home_day_view.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/helpful_guidance_card.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/features/home/widgets/home_header.dart';
import 'package:nibbles/src/features/home/widgets/home_hero_card.dart';
import 'package:nibbles/src/features/home/widgets/home_no_meals_state.dart';
import 'package:nibbles/src/features/home/widgets/todays_meals_card.dart';
import 'package:nibbles/src/features/meal_plan/add_meals_for_day.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// Home redesign dashboard.
///
/// Watches [homeControllerProvider] (hero + allergen + date strip) and
/// [homeDayViewProvider] (per-day meals + guidance). Composition is a plain
/// scroll column: header, optional date strip, lime hero card, meals section
/// and helpful guidance. The `baby == null` edge case keeps the standalone
/// [HomeEmptyStateFull].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
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

    return _CrossFade(
      child: babyIdAsync.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const _HomeLoadingScaffold(),
        error: (_, __) => _HomeErrorScaffold(
          message: 'Could not load baby profile.',
          onRetry: () => ref.invalidate(currentBabyIdProvider),
        ),
        data: (babyId) {
          if (babyId == null) {
            return GradientScaffold(
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
      ),
    );
  }
}

/// Fade-through between Home's async phases (loading ↔ error ↔ content).
/// Each phase supplies a distinct key so the switcher cross-fades on change
/// while `skipLoadingOn*` keeps refreshes from flashing the loader.
class _CrossFade extends StatelessWidget {
  const _CrossFade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: AppDurations.fade,
    switchInCurve: AppCurves.standard,
    switchOutCurve: AppCurves.standard,
    child: child,
  );
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.babyId, required this.onCreateFirstMeal});

  final String babyId;
  final VoidCallback onCreateFirstMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(homeControllerProvider(babyId));

    return _CrossFade(
      child: asyncState.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const _HomeLoadingScaffold(),
        error: (err, _) => _HomeErrorScaffold(
          message: err is AppException ? err.message : 'Something went wrong.',
          onRetry: () => ref.invalidate(homeControllerProvider(babyId)),
        ),
        data: (state) => _HomeContent(
          babyId: babyId,
          state: state,
          onCreateFirstMeal: onCreateFirstMeal,
          onRefresh: () async {
            ref.invalidate(homeControllerProvider(babyId));
            await ref.read(homeControllerProvider(babyId).future);
          },
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.babyId,
    required this.state,
    required this.onCreateFirstMeal,
    required this.onRefresh,
  });

  final String babyId;
  final HomeState state;
  final VoidCallback onCreateFirstMeal;
  final Future<void> Function() onRefresh;

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Direct-add a meal to the day the date strip currently has selected. The
  /// Browse Meal sheet is single-date, so it commits without a map/confirm
  /// step. Home reads meals via its own controller, so refresh it on success.
  Future<void> _onAddMeal(BuildContext context, WidgetRef ref) async {
    final day = ref.read(selectedHomeDateProvider);
    final added = await addMealsForDay(context, ref, babyId: babyId, day: day);
    if (added > 0) ref.invalidate(homeControllerProvider(babyId));
  }

  Future<void> _openTracker(BuildContext context, WidgetRef ref) async {
    await context.pushNamed(AppRoute.allergenTracker.name);
    ref.invalidate(homeControllerProvider(babyId));
  }

  void _openAllergenDetail(BuildContext context) {
    final key = state.currentAllergenKey;
    if (key == null) return;
    context.pushNamed(
      AppRoute.allergenDetail.name,
      pathParameters: {'allergenKey': key},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = state.baby;
    if (baby == null) {
      return GradientScaffold(
        body: SafeArea(
          child: HomeEmptyStateFull(onCreateMealPlan: onCreateFirstMeal),
        ),
      );
    }

    final ageMonths = _monthsBetween(baby.dateOfBirth, DateTime.now());
    final selected = ref.watch(selectedHomeDateProvider);
    final dayView = ref.watch(homeDayViewProvider(babyId));
    final topInset = MediaQuery.of(context).padding.top;
    final key = state.currentAllergenKey;

    return GradientScaffold(
      body: SafeArea(
        top: false,
        child: BrandRefreshIndicator(
          topOffset: topInset,
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: AppSizes.pagePaddingV + topInset,
              bottom: AppSizes.pagePaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _entrance(
                  0,
                  _hPad(
                    HomeHeader(
                      babyName: baby.name,
                      ageMonths: ageMonths,
                      onAvatarTap: () =>
                          context.pushNamed(AppRoute.profile.name),
                      onTodayTap: () =>
                          ref.read(selectedHomeDateProvider.notifier).state =
                              homeDateOnly(DateTime.now()),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                _entrance(
                  1,
                  _hPad(
                    HomeHeroCard(
                      babyName: baby.name,
                      ageMonths: ageMonths,
                      dateOfBirth: baby.dateOfBirth,
                      mealCount: dayView.mealCount,
                      mealTarget: dayView.mealTarget,
                      introducedCount: state.introducedCount,
                      ironRich: dayView.ironRich,
                      hasActiveProgramAllergen: state.hasActiveProgramAllergen,
                      heroState: state.allergenHeroState,
                      allergenKey: key,
                      allergenDisplayName: key == null
                          ? ''
                          : AllergenEmoji.displayName(key),
                      allergenReactionFlags: state.currentAllergenReactionFlags,
                      onStartTracker: () => _openTracker(context, ref),
                      onOpenDetail: () => _openAllergenDetail(context),
                    ),
                  ),
                ),
                if (state.mealPrepSetUp) ...[
                  const SizedBox(height: AppSizes.md),
                  _entrance(
                    2,
                    WeekStrip(
                      days: _buildWeekDays(state.plannedDates, selected),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePaddingH,
                      ),
                      onDaySelected: (i) =>
                          ref.read(selectedHomeDateProvider.notifier).state =
                              state.plannedDates[i],
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.md),
                _entrance(3, _hPad(_mealsSection(context, ref, dayView))),
                const SizedBox(height: AppSizes.md),
                _entrance(
                  4,
                  _hPad(HelpfulGuidanceCard(tips: dayView.guidance)),
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hPad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePaddingH),
    child: child,
  );

  Widget _entrance(int order, Widget child) => child
      .animate(delay: AppDurations.fast * order)
      .fadeIn(duration: AppDurations.fade)
      .slideY(
        begin: 0.06,
        end: 0,
        duration: AppDurations.slide,
        curve: AppCurves.emphasized,
      );

  Widget _mealsSection(
    BuildContext context,
    WidgetRef ref,
    HomeDayView dayView,
  ) {
    final Widget section;
    if (!state.mealPrepSetUp) {
      section = ReadyToStartCard(
        key: const ValueKey('home_meals_ready'),
        babyName: state.baby?.name,
        onPressed: onCreateFirstMeal,
      );
    } else if (dayView.meals.isEmpty) {
      section = HomeNoMealsState(
        key: const ValueKey('home_meals_empty'),
        babyName: state.baby?.name,
        onAddMeal: () => _onAddMeal(context, ref),
      );
    } else {
      section = TodaysMealsCard(
        key: const ValueKey('home_meals_populated'),
        meals: dayView.meals,
        recipes: dayView.recipes,
        mealCount: dayView.mealCount,
        mealTarget: dayView.mealTarget,
        onAdd: () => _onAddMeal(context, ref),
      );
    }

    return AnimatedSwitcher(
      duration: AppDurations.base,
      switchInCurve: AppCurves.standard,
      switchOutCurve: AppCurves.standard,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        ),
      ),
      child: section,
    );
  }

  List<WeekDay> _buildWeekDays(List<DateTime> dates, DateTime selected) {
    return [
      for (final date in dates)
        WeekDay(
          dayOfWeek: _weekdays[date.weekday - 1],
          date: '${date.day} ${_months[date.month - 1]}',
          state: _isSameDay(date, selected)
              ? DayChipState.selected
              : DayChipState.idle,
        ),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _monthsBetween(DateTime from, DateTime to) {
    final raw = (to.year - from.year) * 12 + (to.month - from.month);
    final adjusted = to.day < from.day ? raw - 1 : raw;
    return adjusted < 0 ? 0 : adjusted;
  }
}

class _HomeLoadingScaffold extends StatelessWidget {
  const _HomeLoadingScaffold();

  @override
  Widget build(BuildContext context) => GradientScaffold(
    body: Center(
      child: Semantics(
        label: 'Loading home dashboard',
        child: const BrandFlowerLoader.small(),
      ),
    ),
  );
}

class _HomeErrorScaffold extends StatelessWidget {
  const _HomeErrorScaffold({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GradientScaffold(
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
