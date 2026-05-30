import 'dart:async';

import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/paywall/paywall_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paywall_controller.g.dart';

/// NIB-55 — paywall (Try for $0 sheet) controller.
///
/// Loads the default trial offering on build and exposes
/// [purchaseDefault] / [restore] as the two CTA handlers. Results are
/// returned to the UI so the screen owns the P1 modal surface (per
/// error-handling.md the controller never throws and never decides UI).
///
/// Analytics fired here:
/// * `paywall_viewed`            — on first build.
/// * `subscription_started`      — on `purchaseDefault` success.
/// * `subscription_restored`     — on `restore` success.
@riverpod
class PaywallController extends _$PaywallController {
  @override
  PaywallState build() {
    unawaited(_logPaywallViewed());
    // Defer the offerings fetch a microtask so the notifier is initialised
    // before `_loadOfferings` reassigns `state` (Riverpod forbids writing
    // `state` synchronously from inside `build`).
    Future.microtask(_loadOfferings);
    return PaywallState.initial();
  }

  Future<void> _logPaywallViewed() async {
    try {
      await ref.read(analyticsProvider).logPaywallViewed();
    } on Object catch (_) {
      // Best-effort; never block UI.
    }
  }

  /// Re-runs the offerings fetch. Wired to the inline-error retry CTA so a
  /// transient failure on first build is recoverable without rebuilding the
  /// whole sheet.
  Future<void> reloadOfferings() => _loadOfferings();

  Future<void> _loadOfferings() async {
    state = state.copyWith(
      phase: PaywallPhase.loading,
      errorMessage: null,
    );
    final result = await ref.read(subscriptionServiceProvider.notifier)
        .loadOfferings();
    result.fold(
      onSuccess: (offering) {
        state = state.copyWith(
          phase: PaywallPhase.ready,
          offering: offering,
        );
      },
      onFailure: (error) {
        state = state.copyWith(
          phase: PaywallPhase.error,
          errorMessage: error.message,
        );
      },
    );
  }

  /// Triggers the default-package purchase. Returns the [Result] so the
  /// screen can render the P1 modal with the RC message verbatim on
  /// failure. Sets [PaywallAction.purchasing] for the duration.
  Future<Result<void>> purchaseDefault() async {
    if (state.action != PaywallAction.none) {
      // Guard against double-tap while a prior action is still in flight.
      return const Result.success(null);
    }
    state = state.copyWith(action: PaywallAction.purchasing);
    final result = await ref.read(subscriptionServiceProvider.notifier)
        .purchaseDefault();

    final productId = state.offering?.productId ?? '';
    result.whenOrNull(
      success: (_) => unawaited(_logSubscriptionStarted(productId)),
    );

    state = state.copyWith(action: PaywallAction.none);
    return result;
  }

  /// Restore CTA — re-checks RevenueCat for an existing entitlement. Returns
  /// the [Result] so the screen can show the P1 "No active subscription
  /// found." modal on `NotFoundException`, or fall through on success.
  Future<Result<void>> restore() async {
    if (state.action != PaywallAction.none) {
      return const Result.success(null);
    }
    state = state.copyWith(action: PaywallAction.restoring);
    final result = await ref.read(subscriptionServiceProvider.notifier)
        .restore();

    result.whenOrNull(
      success: (_) => unawaited(_logSubscriptionRestored()),
    );

    state = state.copyWith(action: PaywallAction.none);
    return result;
  }

  Future<void> _logSubscriptionStarted(String productId) async {
    try {
      await ref
          .read(analyticsProvider)
          .logSubscriptionStarted(productId: productId);
    } on Object catch (_) {
      // Best-effort; never block UI.
    }
  }

  Future<void> _logSubscriptionRestored() async {
    try {
      await ref.read(analyticsProvider).logSubscriptionRestored();
    } on Object catch (_) {
      // Best-effort; never block UI.
    }
  }
}
