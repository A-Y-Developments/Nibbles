import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/entities/subscription_info.dart';

part 'manage_subscription_state.freezed.dart';

/// State for the Manage Subscription screen (NIB-73).
///
/// `info` is hydrated from `SubscriptionService.info()` — the screen branches
/// on `info.isActive` to render the not-subscribed (Go Premium CTA) vs the
/// subscribed/trial (plan card + timeline + Cancel CTA) layout.
@freezed
class ManageSubscriptionState with _$ManageSubscriptionState {
  const factory ManageSubscriptionState({
    required SubscriptionInfo info,
  }) = _ManageSubscriptionState;
}
