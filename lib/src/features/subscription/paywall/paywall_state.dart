import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/subscription_offering.dart';

part 'paywall_state.freezed.dart';

/// Top-level phase the paywall is in.
///
/// * [loading] — initial offerings fetch in flight; renders the spinner
///   placeholder per error-handling spec.
/// * [ready] — offerings loaded; the populated sheet renders against
///   [PaywallState.offering].
/// * [error] — offerings load failed; renders the P3 fallback with retry.
enum PaywallPhase { loading, ready, error }

/// In-flight action initiated by the user. Mutually-exclusive so the two CTAs
/// can't both spin at once and so the secondary surfaces of the sheet (close,
/// view-all-plans) disable themselves while either is running.
enum PaywallAction { none, purchasing, restoring }

@freezed
class PaywallState with _$PaywallState {
  const factory PaywallState({
    required PaywallPhase phase,
    required PaywallAction action,
    SubscriptionOffering? offering,
    String? errorMessage,
  }) = _PaywallState;

  factory PaywallState.initial() => const PaywallState(
    phase: PaywallPhase.loading,
    action: PaywallAction.none,
  );
}
