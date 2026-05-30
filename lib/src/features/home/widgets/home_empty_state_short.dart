import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-96: short "Ready to start?" empty state.
///
/// Used when the ongoing-introduced card and day chips need hiding (program
/// not started). Renders only the butter-wash "Ready to start?" card and its
/// primary CTA — no Getting Started Tips section below. Reuses
/// [ReadyToStartCard] from [HomeEmptyStateFull].
class HomeEmptyStateShort extends StatelessWidget {
  const HomeEmptyStateShort({
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePaddingH,
        vertical: AppSizes.sm,
      ),
      child: ReadyToStartCard(onPressed: () => _onPressed(context)),
    );
  }
}
