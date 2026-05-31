import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-96: short "Ready to Start?" empty state.
///
/// Renders only the butter-wash [ReadyToStartCard] (no Getting Started Tips
/// below). Used when the host already renders its own tips block. Reuses
/// [ReadyToStartCard] from [HomeEmptyStateFull].
class HomeEmptyStateShort extends StatelessWidget {
  const HomeEmptyStateShort({
    this.babyName,
    this.onCreateMealPlan,
    super.key,
  });

  /// Optional baby name. Interpolated into the spec copy when provided.
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
      child: ReadyToStartCard(
        babyName: babyName,
        onPressed: () => _onPressed(context),
      ),
    );
  }
}
