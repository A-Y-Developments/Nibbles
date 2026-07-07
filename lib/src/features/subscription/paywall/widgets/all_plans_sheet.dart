import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/domain/entities/subscription_plan.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Pixel constants pulled verbatim from the Figma audit (frame 1216:11891 —
/// see /Users/adithyafp_/Projects/nibbles/.figma-audit/subscription-no-plan/
/// overlay-all-plans/report.md). Spec values that map byte-identically to a
/// design token use `AppSizes` directly at the call site; only these two stay
/// local: 34 has no `AppSizes` token, and 42 coincides with
/// `AppSizes.segmentedHeight` but is semantically a button height (a
/// coincidental value collision, not a reusable token).
const double _kContinueHeight = 42;
const double _kCloseButtonSize = 34;

/// Plan name + price text styles per the Figma `Headline/SemiBold` (Parkinsans
/// 15/22 600) + `Body/Regular` (Figtree 15/22 400) tokens. Defined inline so
/// the sheet matches the variables.json mapping exactly without rerouting
/// through the broader `AppTypography` ramp.
const TextStyle _kPlanTitleStyle = TextStyle(
  fontFamily: 'Parkinsans',
  fontSize: 15,
  fontWeight: FontWeight.w600,
  height: 22 / 15,
  color: AppColors.text,
);

/// Shows the "View all plans" bottom sheet (NIB-61). Returns the selected
/// plan when the user confirms via "Continue", or `null` on dismiss (close X,
/// scrim tap, system back).
///
/// The caller is responsible for handing the returned plan to the purchase
/// pipeline (NIB-55 paywall controller / NIB-18 subscription service). This
/// widget is intentionally purchase-agnostic so its data source stays domain
/// (`SubscriptionPlan`) and never references RevenueCat types directly.
///
/// `initialPlanId` lets the caller restore a prior selection across opens;
/// when null, the recommended plan is selected (falling back to the first
/// plan in [plans]).
Future<SubscriptionPlan?> showAllPlansSheet(
  BuildContext context, {
  required List<SubscriptionPlan> plans,
  String? initialPlanId,
}) {
  assert(plans.isNotEmpty, 'showAllPlansSheet requires at least one plan');
  return showModalBottomSheet<SubscriptionPlan>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radius3xl),
      ),
    ),
    builder: (_) => AllPlansSheet(plans: plans, initialPlanId: initialPlanId),
  );
}

/// The bottom sheet body. Exposed (not private) so widget tests can mount it
/// without a parent overlay/route.
@visibleForTesting
class AllPlansSheet extends StatefulWidget {
  const AllPlansSheet({required this.plans, this.initialPlanId, super.key});

  final List<SubscriptionPlan> plans;
  final String? initialPlanId;

  @override
  State<AllPlansSheet> createState() => _AllPlansSheetState();
}

class _AllPlansSheetState extends State<AllPlansSheet> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = _resolveInitialSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_logViewed());
    });
  }

  String _resolveInitialSelection() {
    final initial = widget.initialPlanId;
    if (initial != null &&
        widget.plans.any((SubscriptionPlan p) => p.id == initial)) {
      return initial;
    }
    final recommended = widget.plans
        .where((SubscriptionPlan p) => p.isRecommended)
        .map((SubscriptionPlan p) => p.id);
    if (recommended.isNotEmpty) return recommended.first;
    return widget.plans.first.id;
  }

  Future<void> _logViewed() async {
    try {
      await Analytics.instance.logAllPlansViewed();
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  Future<void> _logPlanSelected(SubscriptionPlan plan) async {
    try {
      await Analytics.instance.logPlanSelected(
        period: plan.period.analyticsValue,
      );
    } on Object catch (_) {
      // Best-effort.
    }
  }

  void _onSelect(SubscriptionPlan plan) {
    if (_selectedId == plan.id) return;
    setState(() => _selectedId = plan.id);
    unawaited(_logPlanSelected(plan));
  }

  void _onContinue() {
    final plan = widget.plans.firstWhere(
      (SubscriptionPlan p) => p.id == _selectedId,
      orElse: () => widget.plans.first,
    );
    Navigator.of(context).pop(plan);
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSingle = widget.plans.length == 1;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CloseButton(onTap: _onClose),
            const SizedBox(height: AppSizes.lg),
            // Per spec edge case — single configured package hides the
            // selection chrome (no card border treatment, no "Recomended"
            // badge) and shows only the Continue CTA. We still render the
            // single plan as a borderless title/price stack so the sheet
            // doesn't collapse to a bare button.
            if (isSingle)
              _SinglePlanRow(plan: widget.plans.first)
            else
              ..._buildPlanList(),
            const SizedBox(height: AppSizes.lg),
            _ContinueButton(onPressed: _onContinue),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlanList() {
    final widgets = <Widget>[];
    for (var i = 0; i < widget.plans.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: AppSizes.lg));
      final plan = widget.plans[i];
      widgets.add(
        _PlanCard(
          plan: plan,
          isSelected: plan.id == _selectedId,
          onTap: () => _onSelect(plan),
        ),
      );
    }
    return widgets;
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Close',
      button: true,
      child: SizedBox(
        width: _kCloseButtonSize,
        height: _kCloseButtonSize,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(
                Icons.close,
                size: AppSizes.iconMd,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-plan layout (edge case) — no border, no badge, no tap target since
/// there is nothing else to switch to. Just the title + price stack so the
/// user can still see what they are about to purchase.
class _SinglePlanRow extends StatelessWidget {
  const _SinglePlanRow({required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.title, style: _kPlanTitleStyle),
          const SizedBox(height: AppSizes.xs),
          Text(
            plan.priceLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.greenDeep
        : AppColors.borderMuted;
    final priceStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: AppColors.text);
    // The "Recomended" badge overlaps the top edge of the Annual card; using
    // Stack + clipBehavior:none lets it spill ~22px above the card boundary
    // without altering layout flow (matches Figma absolute positioning).
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Single-select plan card: expose selected + button role so a screen
        // reader announces which plan is picked (mirrors CancelReasonChip).
        Semantics(
          button: true,
          selected: isSelected,
          label: '${plan.title}, ${plan.priceLabel}',
          child: ExcludeSemantics(
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.sp12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.title, style: _kPlanTitleStyle),
                      const SizedBox(height: AppSizes.xs),
                      Text(plan.priceLabel, style: priceStyle),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (plan.isRecommended)
          const Positioned(
            right: AppSizes.md,
            top: -AppSizes.sp20,
            child: _RecommendedBadge(),
          ),
      ],
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(AppSizes.radius3xl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sp12,
          vertical: AppSizes.xs,
        ),
        // "Recomended" is intentionally misspelled — verbatim per Figma spec
        // (frame 1216:11898). Pending PO confirmation before fixing.
        child: Text(
          'Recomended',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kContinueHeight,
      child: Material(
        color: AppColors.greenDeep,
        borderRadius: BorderRadius.circular(AppSizes.radius2xl),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radius2xl),
          child: Center(
            child: Text(
              'Continue',
              style: _kPlanTitleStyle.copyWith(color: AppColors.surface),
            ),
          ),
        ),
      ),
    );
  }
}
