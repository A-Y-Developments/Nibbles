import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/cards/app_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-96: dashed "No Meals Mapped Yet" empty state.
///
/// Renders a "TODAY'S MEALS" overline + n/2 counter, then a dashed-border
/// inner card with the title + body copy and a primary "+ Add" pill. The
/// CTA invokes [onAddMeal]; when null, falls back to routing to the meal
/// plan tab. Decorative-only — no drag-and-drop wiring.
class HomeNoMealsState extends StatelessWidget {
  const HomeNoMealsState({
    this.babyName,
    this.onAddMeal,
    this.scheduledSlots = 2,
    this.filledSlots = 0,
    super.key,
  });

  /// Optional baby name. Preserved for parity with the other empty-state
  /// widgets; not currently surfaced in this card's copy.
  final String? babyName;

  /// Invoked when the user taps "+ Add". Defaults to navigating to the meal
  /// plan tab via `context.goNamed(AppRoute.mealPlan.name)`.
  final VoidCallback? onAddMeal;

  /// Total scheduled meal slots for today (right-side denominator).
  final int scheduledSlots;

  /// Filled slots so far today (left-side numerator). Always 0 for the
  /// dashed empty body to render.
  final int filledSlots;

  void _onPressed(BuildContext context) {
    final cb = onAddMeal;
    if (cb != null) {
      cb();
      return;
    }
    context.goNamed(AppRoute.mealPlan.name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppSizes.shadowCard,
      ),
      padding: const EdgeInsets.all(AppSizes.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MealsHeaderRow(filled: filledSlots, total: scheduledSlots),
          const SizedBox(height: AppSizes.sm),
          AppCard(
            variant: AppCardVariant.dashed,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'No Meals Mapped Yet',
                  textAlign: TextAlign.center,
                  style: AppTypography.emptyStateTitle,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Drag & drop or click meals below to add them',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.fgFaint,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                AppPillButton(
                  label: '+ Add',
                  variant: AppPillButtonVariant.ghost,
                  onPressed: () => _onPressed(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealsHeaderRow extends StatelessWidget {
  const _MealsHeaderRow({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              "TODAY'S MEALS",
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.greenDeep,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Text(
            '$filled/$total',
            style: AppTypography.caption.copyWith(
              color: AppColors.fgFaint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
