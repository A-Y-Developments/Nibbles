import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/success/subscription_success_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_success_controller.g.dart';

/// NIB-130 — passive two-phase transition shown after a successful purchase.
///
/// Loop:
/// 1. Render `loading` while we wait on entitlement provisioning. Two outs:
///    a. `SubscriptionService.isActive` flips to true → settle immediately.
///    b. `loadingTimeout` elapses → settle anyway (RC stub still returns
///       false; the upstream paywall — not this screen — is responsible for
///       surfacing a P1 modal on provisioning failure per NIB-130 spec).
///    Either way, a `loadingMinDwell` floor keeps the petal animation
///    on-screen long enough to read.
/// 2. Render `success` (animation + "You all set!"). The screen schedules a
///    short `successDwell` before navigating to `/home`.
@riverpod
class SubscriptionSuccessController extends _$SubscriptionSuccessController {
  /// Floor on the loading frame so the animation never just flashes.
  static const Duration loadingMinDwell = Duration(milliseconds: 1200);

  /// Cap on entitlement-wait. Past this we settle to success regardless —
  /// failure handling is upstream (see NIB-130 acceptance criteria).
  static const Duration loadingTimeout = Duration(seconds: 4);

  /// How long "You all set!" stays before the screen auto-routes to /home.
  /// Consumed by the success screen to schedule the `/home` push.
  static const Duration successDwell = Duration(milliseconds: 1500);

  Timer? _settleTimer;
  ProviderSubscription<bool>? _subSub;

  @override
  SubscriptionSuccessPhase build() {
    ref.onDispose(() {
      _settleTimer?.cancel();
      _subSub?.close();
    });

    // Fire-and-forget activation analytics on first build. Guarded against an
    // uninitialised Firebase in tests.
    unawaited(_logSubscriptionActivated());

    _scheduleSettle();
    return SubscriptionSuccessPhase.loading;
  }

  /// Settles the loading state. Resolves on whichever fires first —
  /// `SubscriptionService.isActive` flipping true OR the [loadingTimeout]
  /// elapsing — but never before [loadingMinDwell].
  void _scheduleSettle() {
    final isActive = ref.read(subscriptionServiceProvider);

    // Fast path — entitlement already active. Wait the min dwell, then flip.
    if (isActive) {
      _settleTimer = Timer(loadingMinDwell, _flipToSuccess);
      return;
    }

    // Slow path — schedule both the timeout AND a listener on the service.
    // First-fire wins, but both are still capped by min dwell via _flipAfter.
    final start = DateTime.now();
    _settleTimer = Timer(loadingTimeout, () => _flipAfter(start));
    _subSub = ref.listen<bool>(subscriptionServiceProvider, (_, next) {
      if (next) _flipAfter(start);
    });
  }

  /// Flips to success after honoring the min-dwell floor relative to [start].
  void _flipAfter(DateTime start) {
    _settleTimer?.cancel();
    final elapsed = DateTime.now().difference(start);
    final remaining = loadingMinDwell - elapsed;
    if (remaining <= Duration.zero) {
      _flipToSuccess();
      return;
    }
    _settleTimer = Timer(remaining, _flipToSuccess);
  }

  void _flipToSuccess() {
    if (state == SubscriptionSuccessPhase.success) return;
    state = SubscriptionSuccessPhase.success;
  }

  Future<void> _logSubscriptionActivated() async {
    try {
      // Reuse the existing logSubscriptionStarted event for activation —
      // NIB-90 introduces dedicated events; until then this is the closest
      // non-PII signal we can emit. Empty productId because the upstream
      // paywall owns the actual product attribution.
      await ref.read(analyticsProvider).logSubscriptionStarted(productId: '');
    } on Object catch (_) {
      // Best-effort; never block UI.
    }
  }
}
