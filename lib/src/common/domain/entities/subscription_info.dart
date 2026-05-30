import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_info.freezed.dart';

/// Subscription entitlement snapshot consumed by the Manage Subscription
/// screen (NIB-73). Sourced from RevenueCat `customerInfo` once the real
/// SubscriptionService lands — currently synthesized from the stub bool.
///
/// `planLabel` is the user-facing plan name ("Free Trial", "Premium", or a
/// product display name). When [isActive] is false the other fields are null.
@freezed
class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    required bool isActive,
    String? planLabel,
    DateTime? startedAt,
    DateTime? renewsAt,
    @Default(false) bool isTrial,
  }) = _SubscriptionInfo;
}
