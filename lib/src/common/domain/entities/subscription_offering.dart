import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_offering.freezed.dart';

/// Domain representation of a RevenueCat `StoreProduct` offering.
///
/// Only the fields the paywall needs are captured: a stable product identifier,
/// the formatted price the StoreProduct surfaces (locale-aware, currency-
/// symboled — never compose this in the UI) and a short cadence label
/// (e.g. `yearly`). NIB-18 will wire this through `purchases_flutter` and
/// replace the placeholder offering in `SubscriptionService`.
@freezed
class SubscriptionOffering with _$SubscriptionOffering {
  const factory SubscriptionOffering({
    required String productId,
    required String priceString,
    required String periodLabel,
    required int trialDays,
  }) = _SubscriptionOffering;
}
