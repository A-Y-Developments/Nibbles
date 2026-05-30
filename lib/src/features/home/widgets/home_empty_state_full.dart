import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-96: full "Ready to start?" empty state.
///
/// Butter-wash card with title + body copy and a primary "Create First Meal"
/// pill, followed by a static "Getting Started Tips" section with 3 tip
/// cards. The CTA invokes [onCreateMealPlan]; when null, falls back to
/// routing to the meal plan tab (NIB-86 wires no callback through
/// `home_screen`).
class HomeEmptyStateFull extends StatelessWidget {
  const HomeEmptyStateFull({
    this.babyName,
    this.onCreateMealPlan,
    super.key,
  });

  /// Optional baby name. Preserved from the NIB-86 placeholder signature;
  /// the spec copy is name-agnostic, so this is currently unused for
  /// rendering.
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
          ReadyToStartCard(onPressed: () => _onPressed(context)),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'Getting Started Tips',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppSizes.sm),
          const TipCard(
            title: 'Start with single-ingredient foods',
            body: 'Offer one new food at a time so reactions are easy to spot.',
          ),
          const SizedBox(height: AppSizes.sm),
          const TipCard(
            title: 'Introduce allergens early',
            body: 'Peanut, egg and dairy work best from around 6 months.',
          ),
          const SizedBox(height: AppSizes.sm),
          const TipCard(
            title: 'Watch, wait, repeat',
            body: 'Offer each new food 2-3 days apart before adding the next.',
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

/// Butter-wash "Ready to start?" card. Shared between [HomeEmptyStateFull]
/// and `HomeEmptyStateShort`. Renders the headline + body copy and a primary
/// "Create First Meal" pill driven by [onPressed].
class ReadyToStartCard extends StatelessWidget {
  const ReadyToStartCard({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            'Ready to start?',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.fgStrong,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            "Track allergen introductions and plan baby's meals.",
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
