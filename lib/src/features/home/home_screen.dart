import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// NIB-86 scaffold.
///
/// The screen is intentionally thin: it watches the controller and routes the
/// resulting [HomeState] into placeholder widgets under `widgets/`. The leaf
/// implementations land in NIB-65 (header + greeting + stat ring), NIB-77
/// (ongoing card + day chips + today's meals + guidance) and NIB-96
/// (empty-state variants).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyIdAsync = ref.watch(currentBabyIdProvider);

    return babyIdAsync.when(
      loading: () => const _HomeLoadingScaffold(),
      error: (_, __) => const _HomeErrorScaffold(
        message: 'Could not load baby profile.',
      ),
      data: (babyId) {
        if (babyId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: HomeEmptyStateFull()),
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
      loading: () => const _HomeLoadingScaffold(),
      error: (err, _) => _HomeErrorScaffold(
        message: err is AppException ? err.message : 'Something went wrong.',
        onRetry: () => ref.invalidate(homeControllerProvider(babyId)),
      ),
      data: (state) => _HomeContent(state: state),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final baby = state.baby;

    // Full empty-state — no baby OR no logged activity yet.
    if (baby == null || state.hasNoActivity) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: HomeEmptyStateFull(babyName: baby?.name),
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
