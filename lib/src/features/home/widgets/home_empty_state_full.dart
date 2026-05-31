import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/home/widgets/getting_started_tips_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-96: Header-less full "Ready to Start?" empty state.
///
/// Renders only the [ReadyToStartCard] + the single [GettingStartedTipsCard].
/// Used by the `home_screen` only on the `baby == null` edge case — every
/// other Home variant keeps the header/greeting/stats chrome and composes
/// [ReadyToStartCard] / [GettingStartedTipsCard] inline.
class HomeEmptyStateFull extends StatelessWidget {
  const HomeEmptyStateFull({
    this.babyName,
    this.onCreateMealPlan,
    super.key,
  });

  /// Optional baby name. When null the CTA body falls back to a neutral
  /// "your baby's food journey" phrasing.
  final String? babyName;

  /// Invoked when the user taps "Create First Meal". Defaults to navigating
  /// to the meal plan tab via `context.goNamed(AppRoute.mealPlan.name)`.
  final VoidCallback? onCreateMealPlan;

  void _onPressed(BuildContext context) {
    final cb = onCreateMealPlan;
    if (cb != null) {
      cb();
      return;
    }
    context.goNamed(AppRoute.mealPlan.name);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.pagePaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReadyToStartCard(
            babyName: babyName,
            onPressed: () => _onPressed(context),
          ),
          const SizedBox(height: AppSizes.lg),
          const GettingStartedTipsCard(),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

/// Butter-wash "Ready to Start?" card. Shared between [HomeEmptyStateFull]
/// and the inline empty-content composition inside `home_screen`. Renders
/// the headline + spec body copy (interpolating [babyName] when provided)
/// and a primary "Create First Meal" pill driven by [onPressed].
class ReadyToStartCard extends StatelessWidget {
  const ReadyToStartCard({
    required this.onPressed,
    this.babyName,
    super.key,
  });

  final VoidCallback onPressed;
  final String? babyName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final possessive = (babyName == null || babyName!.isEmpty)
        ? "your baby's"
        : "$babyName's";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.butter, AppColors.butterSoft],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppSizes.shadowCard,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ready to Start?',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Begin $possessive food journey by creating your first meal '
            'prep and introducing allergens safely.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.fgFaint,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppPillButton(
            label: 'Create First Meal',
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
