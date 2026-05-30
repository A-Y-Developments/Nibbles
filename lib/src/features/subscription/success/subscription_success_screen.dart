import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/common/components/brand/quatrefoil.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_controller.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-130 — passive post-purchase transition screen.
///
/// Two visual phases:
///   * loading: petal blob + faint uppercase "LOADING" caption.
///   * success: petal blob + bold "You all set!" body label, then auto-routes
///     to `/home` after [SubscriptionSuccessController.successDwell].
///
/// No interactive elements; back is blocked while provisioning is in flight
/// (and on the success frame until the auto-route fires) per spec.
class SubscriptionSuccessScreen extends ConsumerStatefulWidget {
  const SubscriptionSuccessScreen({super.key});

  @override
  ConsumerState<SubscriptionSuccessScreen> createState() =>
      _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState
    extends ConsumerState<SubscriptionSuccessScreen> {
  Timer? _routeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_logScreenView());
    });
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    super.dispose();
  }

  Future<void> _logScreenView() async {
    try {
      await Analytics.instance.logScreenView(
        screenName: 'subscription_success',
      );
    } on Object catch (_) {
      // Best-effort; never surface to the UI.
    }
  }

  void _scheduleRoute() {
    _routeTimer?.cancel();
    _routeTimer = Timer(
      SubscriptionSuccessController.successDwell,
      () {
        if (!mounted) return;
        context.goNamed(AppRoute.home.name);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Schedule the auto-route exactly once on the loading→success transition.
    // Listening (not watching) keeps the build pure; the timer + mounted guard
    // make double-fires safe.
    ref.listen<SubscriptionSuccessPhase>(
      subscriptionSuccessControllerProvider,
      (prev, next) {
        if (next == SubscriptionSuccessPhase.success &&
            prev != SubscriptionSuccessPhase.success) {
          _scheduleRoute();
        }
      },
    );

    final phase = ref.watch(subscriptionSuccessControllerProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.butterSoft,
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _PetalBlob(key: Key('subscription_success_blob')),
              _PhaseLabel(phase: phase),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layered petal mark mimicking the Figma `LoadingAnimation` frame:
/// a pale outer quatrefoil + a sage inner quatrefoil + a soft butter glow
/// dot at the core (Quatrefoil's circle core alone reads as flat).
class _PetalBlob extends StatelessWidget {
  const _PetalBlob({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.avatarXl * 1.84,
      height: AppSizes.avatarXl * 1.84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pale-butter petal blob (spec petal layer 1+2 composite).
          const Quatrefoil(
            size: AppSizes.avatarXl * 1.84,
            coreColor: AppColors.butter,
          ),
          // Inner sage petal — smaller, scales down to ~52% of outer.
          const Quatrefoil(
            size: AppSizes.avatarXl * 0.96,
            petalColor: AppColors.green,
            coreColor: AppColors.greenDeep,
          ),
          // Soft butter glow dot at the center (spec blurred lime dot).
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.butter,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.butter.withValues(alpha: 0.9),
                  blurRadius: AppSizes.sm,
                  spreadRadius: AppSizes.xs,
                ),
              ],
            ),
            child: const SizedBox(
              width: AppSizes.sp12 * 1.4,
              height: AppSizes.sp12 * 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Phase caption — faint uppercase "Loading" overlay inside the petal animation
/// in the loading phase; bold "You all set!" body label below the animation in
/// the success phase. Verbatim copy from the Figma frame (1290:10122).
class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel({required this.phase});

  final SubscriptionSuccessPhase phase;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (phase == SubscriptionSuccessPhase.loading) {
      // "Loading" — Inter Regular 12.8 / 19.2 / tracking 4.33 / UPPERCASE,
      // rendered low-contrast (cream on butter-soft) per spec.
      return Positioned.fill(
        child: Align(
          alignment: const Alignment(0, 0.34),
          child: Text(
            'Loading'.toUpperCase(),
            key: const Key('subscription_success_loading_label'),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.cream,
              fontSize: 12.8,
              height: 19.2 / 12.8,
              letterSpacing: 4.33,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    // success — "You all set!" body label below the animation.
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0, 0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md + AppSizes.sp2,
          ),
          child: Text(
            'You all set!',
            key: const Key('subscription_success_done_label'),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
