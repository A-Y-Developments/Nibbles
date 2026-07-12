import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_motion.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/entities/subscription_info.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_subscription_overlay.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_controller.dart';
import 'package:nibbles/src/features/subscription/manage/manage_subscription_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-73 — Manage Subscription screen.
///
/// Two render branches keyed on `SubscriptionInfo.isActive`:
///   * not-subscribed (Figma 1207:11462): butter info card + "Go Premium" pill.
///   * subscribed/trial (Figma 1207:11737): butter plan card + Started/Renewal
///     timeline + "Cancel Subscription" pill.
///
/// Reachable from Profile via `/subscription/manage`. Route is intentionally
/// kept off `gatedPaths` (routes.dart) so onboarded users can land here.
class ManageSubscriptionScreen extends ConsumerStatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  ConsumerState<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState
    extends ConsumerState<ManageSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_logScreenView());
    });
  }

  Future<void> _logScreenView() async {
    try {
      await ref
          .read(analyticsProvider)
          .logScreenView(screenName: 'manage_subscription');
    } on Object catch (_) {
      // Analytics is best-effort; never surface to the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(manageSubscriptionControllerProvider);

    final phaseKey = asyncState.isLoading
        ? 'loading'
        : asyncState.hasError
        ? 'error'
        : 'data';

    return AnimatedSwitcher(
      duration: AppDurations.fade,
      switchInCurve: AppCurves.standard,
      switchOutCurve: AppCurves.standard,
      child: KeyedSubtree(
        key: ValueKey(phaseKey),
        child: asyncState.when(
          loading: () => const GradientScaffold(
            body: SafeArea(
              bottom: false,
              child: Center(
                key: Key('manage_subscription_loading'),
                child: BrandFlowerLoader.small(),
              ),
            ),
          ),
          error: (err, _) => _ManageSubscriptionError(
            message: err is AppException
                ? err.message
                : 'Couldn’t load your subscription. Please try again.',
            onRetry: () => ref.invalidate(manageSubscriptionControllerProvider),
          ),
          data: (state) => _ManageSubscriptionBody(state: state),
        ),
      ),
    );
  }
}

class _ManageSubscriptionBody extends StatelessWidget {
  const _ManageSubscriptionBody({required this.state});

  final ManageSubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final info = state.info;

    void goBack() => context.canPop() ? context.pop() : context.go('/home');

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ManageSubscriptionHeader(onBack: goBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  0,
                  AppSizes.md,
                  AppSizes.pagePaddingV,
                ),
                child: AnimatedSwitcher(
                  duration: AppDurations.fade,
                  switchInCurve: AppCurves.standard,
                  switchOutCurve: AppCurves.standard,
                  child: KeyedSubtree(
                    key: ValueKey(info.isActive),
                    child: info.isActive
                        ? _SubscribedSection(info: info)
                        : const _NotSubscribedSection(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.pagePaddingV,
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.fade,
                switchInCurve: AppCurves.standard,
                switchOutCurve: AppCurves.standard,
                child: info.isActive
                    ? AppPillButton(
                        key: const Key('manage_subscription_cancel_cta'),
                        label: 'Cancel Subscription',
                        variant: AppPillButtonVariant.ghost,
                        size: AppPillButtonSize.small,
                        onPressed: () => _onCancelPressed(context),
                      )
                    : AppPillButton(
                        key: const Key('manage_subscription_go_premium_cta'),
                        label: 'Go Premium',
                        size: AppPillButtonSize.small,
                        onPressed: () =>
                            context.pushNamed(AppRoute.paywall.name),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCancelPressed(BuildContext context) {
    // NIB-82: surface the cancel-reason bottom sheet (Figma 1216:12019).
    // The sheet handles its own analytics, the deep-link to the OS
    // subscription page, and the P2 SnackBar on URL-open failure.
    unawaited(showCancelSubscriptionOverlay(context));
  }
}

/// Header row — back chip + "Manage Subscription" title (Title 3/Bold).
/// Mirrors the structure of `ProfileHeader` but uses the verbatim screen
/// title from the Figma spec.
class _ManageSubscriptionHeader extends StatelessWidget {
  const _ManageSubscriptionHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sp12,
        AppSizes.sm - 2,
        AppSizes.sp12,
        AppSizes.lg,
      ),
      child: Row(
        children: [
          AppRoundButton(
            key: const Key('manage_subscription_back_button'),
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            tone: AppRoundButtonTone.ghost,
            size: AppRoundButtonSize.small,
            semanticLabel: 'Back',
          ),
          const SizedBox(width: AppSizes.sp2),
          Text(
            'Manage Subscription',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.fgStrong,
            ),
          ),
        ],
      ),
    );
  }
}

/// Not-subscribed branch (Figma 1207:11462). Single butter-soft card with the
/// `nibbles` wordmark + crown badge + status copy.
class _NotSubscribedSection extends StatelessWidget {
  const _NotSubscribedSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyLarge?.copyWith(color: AppColors.text);

    return _BrandCard(
      key: const Key('manage_subscription_not_subscribed_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandLockup(),
          const SizedBox(height: AppSizes.sp12),
          Text('You are not subscribed', style: body),
          const SizedBox(height: AppSizes.sp12),
          Text(
            'You have a free Nibbles account. You can purchase a Premium '
            'subscription to access our full recipe, content and features.',
            style: body,
          ),
        ],
      ),
    );
  }
}

/// Subscribed/trial branch (Figma 1207:11737). "You are subscribed to :"
/// intro + butter card (wordmark + plan label) + Started/Renewal timeline +
/// reassurance paragraph.
class _SubscribedSection extends StatelessWidget {
  const _SubscribedSection({required this.info});

  final SubscriptionInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyLarge?.copyWith(color: AppColors.text);
    final planLabel = info.planLabel ?? 'Premium';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verbatim copy — leading space before the colon is intentional
        // ("You are subscribed to :"). Preserved per ticket AC.
        Text('You are subscribed to :', style: body),
        const SizedBox(height: AppSizes.sp12),
        _BrandCard(
          key: const Key('manage_subscription_plan_card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandLockup(),
              const SizedBox(height: AppSizes.xs),
              Text(
                planLabel,
                key: const Key('manage_subscription_plan_label'),
                style: body,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _Timeline(startedAt: info.startedAt, renewsAt: info.renewsAt),
        const SizedBox(height: AppSizes.md),
        Text(
          'You can cancel your subscription plan. If you cancel, you can '
          'keep using the subscription until the next billing date.',
          style: body,
        ),
      ],
    );
  }
}

/// Butter-soft surface with a 1px butter border + radius 10. Used by both the
/// not-subscribed info card and the subscribed plan card. Mirrors the
/// construction of `PremiumTeaserCard` so the visual rhythm matches Profile.
class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.butterSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.butter),
      ),
      padding: const EdgeInsets.all(AppSizes.sp12),
      child: child,
    );
  }
}

/// `nibbles` wordmark scaled to ~22px next to the crown badge (26x26 butter
/// square). Identical to `PremiumTeaserCard`'s inline lockup.
class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final wordmark = AppTypography.brandWordmark.copyWith(
      fontSize: 22,
      letterSpacing: 22 * -0.02,
    );

    return Row(
      children: [
        Text('nibbles', style: wordmark),
        const SizedBox(width: AppSizes.sp12),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.butter,
            borderRadius: BorderRadius.circular(AppSizes.sm),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            size: 18,
            color: AppColors.greenDeep,
          ),
        ),
      ],
    );
  }
}

/// Two-row vertical timeline: Started (lime + check, completed) above Renewal
/// (neutral + radio_button_unchecked, future). A 1px sage stem connects the
/// two dots. Mirrors Figma 1207:11737 timeline composition.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.startedAt, required this.renewsAt});

  final DateTime? startedAt;
  final DateTime? renewsAt;

  static String _formatDdMmYyyy(DateTime? date) {
    if (date == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppColors.text,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineRow(
          dot: const _TimelineDot(
            key: Key('manage_subscription_timeline_started_dot'),
            completed: true,
          ),
          // Verbatim copy preserves the trailing space before the value
          // ("Started : "). Per ticket AC.
          label: 'Started : ',
          value: _formatDdMmYyyy(startedAt),
          valueKey: const Key('manage_subscription_started_value'),
          labelStyle: labelStyle,
        ),
        // Vertical sage connector between the two dots.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
          child: Row(
            children: [
              SizedBox(
                width: _TimelineDot._size,
                child: Center(
                  child:
                      const SizedBox(
                        width: 1,
                        height: AppSizes.sp12,
                        child: ColoredBox(color: AppColors.green),
                      ).animate().scaleY(
                        begin: 0,
                        end: 1,
                        alignment: Alignment.topCenter,
                        delay: AppDurations.base,
                        duration: AppDurations.slide,
                        curve: AppCurves.emphasized,
                      ),
                ),
              ),
            ],
          ),
        ),
        _TimelineRow(
          dot: const _TimelineDot(
            key: Key('manage_subscription_timeline_renewal_dot'),
            completed: false,
          ),
          // Verbatim copy preserves the trailing space ("Renewal : ").
          label: 'Renewal : ',
          value: _formatDdMmYyyy(renewsAt),
          valueKey: const Key('manage_subscription_renewal_value'),
          labelStyle: labelStyle,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.dot,
    required this.label,
    required this.value,
    required this.valueKey,
    required this.labelStyle,
  });

  final Widget dot;
  final String label;
  final String value;
  final Key valueKey;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        dot,
        const SizedBox(width: AppSizes.sp12),
        Text(label, style: labelStyle),
        const SizedBox(width: AppSizes.lg),
        Flexible(
          child: Text(value, key: valueKey, style: labelStyle),
        ),
      ],
    );
  }
}

/// 31x31 circle dot. Completed state = lime fill + dark check; future state =
/// neutral fill + outlined radio. Matches Figma chips 1207:11844 / 1207:11848.
class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.completed, super.key});

  final bool completed;

  static const double _size = 31;

  @override
  Widget build(BuildContext context) {
    final bg = completed ? AppColors.butter : AppColors.switchTrackOff;
    const fg = AppColors.greenDeep;

    final dot = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(
        completed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
        size: 18,
        color: fg,
      ),
    );

    if (!completed) return dot;

    return dot
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          duration: AppDurations.base,
          curve: AppCurves.emphasized,
        )
        .fadeIn(duration: AppDurations.fast);
  }
}

/// Error placeholder — mirrors `_ProfileError` (profile_screen.dart) so the
/// Manage Subscription screen has the same retry affordance under P1.
class _ManageSubscriptionError extends StatelessWidget {
  const _ManageSubscriptionError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.pagePaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl,
                  color: AppColors.destructive,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  message,
                  key: const Key('manage_subscription_error_message'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.fgMuted,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSizes.lg),
                  FilledButton(
                    key: const Key('manage_subscription_retry_button'),
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
