import 'package:freezed_annotation/freezed_annotation.dart';

part 'cancel_subscription_state.freezed.dart';

/// Cancel-subscription overlay state (NIB-82).
///
/// `isSubmitting` flips while `SubscriptionService.openManagementPage` is
/// in-flight so the overlay can disable both CTAs without dismissing. The
/// flow is fire-and-dismiss — failures surface as a transient P2 SnackBar
/// on the parent route (NOT an inline error block), so there is no
/// `errorMessage` here.
@freezed
class CancelSubscriptionState with _$CancelSubscriptionState {
  const factory CancelSubscriptionState({@Default(false) bool isSubmitting}) =
      _CancelSubscriptionState;
}
