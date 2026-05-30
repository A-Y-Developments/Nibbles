import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/components/feedback/loading_confirmation.dart';
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
/// Visuals come from the shared [LoadingConfirmation] composite (NIB-131
/// extraction). This screen owns the controller wiring, analytics, and
/// auto-route; the composite owns geometry + tokens + cross-fade.
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
    // Schedule the auto-route once on the loading -> success transition.
    // Listening (not watching) keeps the build pure; the timer + mounted
    // guard make double-fires safe.
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
    final mapped = phase == SubscriptionSuccessPhase.success
        ? LoadingConfirmationPhase.success
        : LoadingConfirmationPhase.loading;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: LoadingConfirmation(
          phase: mapped,
          successLabel: 'You all set!',
          blobKey: const Key('subscription_success_blob'),
          loadingLabelKey: const Key('subscription_success_loading_label'),
          successLabelKey: const Key('subscription_success_done_label'),
        ),
      ),
    );
  }
}
