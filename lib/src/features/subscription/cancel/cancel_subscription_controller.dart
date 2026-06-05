import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_reason.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_subscription_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cancel_subscription_controller.g.dart';

/// Drives the cancel-subscription reason overlay (NIB-82).
///
/// `submit(reason)` is the only mutator:
///  1. Sets `isSubmitting = true`.
///  2. Fires `subscription_cancel_started` + `subscription_cancel_reason`
///     analytics (PII-free `analyticsKey`).
///  3. Deep-links to the OS-managed subscription page via
///     [SubscriptionService.openManagementPage]. Apps cannot programmatically
///     cancel App Store / Play subscriptions — the OS owns the cancel UI.
///  4. Returns `true` on success so the overlay can dismiss itself, `false`
///     on URL-open failure so the overlay can surface the P2 SnackBar.
@riverpod
class CancelSubscriptionController extends _$CancelSubscriptionController {
  @override
  CancelSubscriptionState build() => const CancelSubscriptionState();

  Future<bool> submit(CancelReason reason) async {
    // Re-entrancy guard: the overlay's Continue CTA disable is presentational
    // (isSubmitting flips on a next-frame rebuild), so a same-frame double-tap
    // can re-enter before the button greys out — double-firing the deep-link
    // launch + both intent analytics events. Mirror PaywallController
    // (purchaseDefault/restore) + delete-account (PR #337): bail if already in
    // flight.
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true);

    // Fire-and-forget intent events BEFORE the deep-link so we capture
    // user intent even if the OS rejects the URL. Awaiting here would
    // serialize the analytics RTT in front of the launch.
    final analytics = ref.read(analyticsProvider);
    unawaited(
      analytics.logSubscriptionCancelStarted(reason: reason.analyticsKey),
    );
    unawaited(
      analytics.logSubscriptionCancelReason(reason: reason.analyticsKey),
    );

    final result = await ref
        .read(subscriptionServiceProvider.notifier)
        .openManagementPage();

    // Drop the in-flight flag regardless of outcome — the overlay either
    // dismisses on success or remains open with both CTAs re-enabled on
    // failure (the SnackBar lives on the parent route, NOT inline).
    state = state.copyWith(isSubmitting: false);

    return switch (result) {
      Success<void>() => true,
      Failure<void>() => false,
    };
  }
}
