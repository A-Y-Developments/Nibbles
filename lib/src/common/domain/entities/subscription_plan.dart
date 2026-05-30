import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_plan.freezed.dart';

/// Domain entity for a purchasable subscription plan (NIB-61).
///
/// Source of truth for the all-plans picker bottom sheet. Repositories map
/// RevenueCat `Package` / `StoreProduct` DTOs into this entity; the widget
/// layer never touches RevenueCat types directly (architecture rule).
///
/// Fields:
///   * [id] — opaque package identifier (e.g. RevenueCat `Package.identifier`).
///     Passed back to the purchase pipeline; never rendered.
///   * [title] — verbatim display title ("Annual" / "Monthly").
///   * [priceLabel] — pre-formatted localized price + period
///     (e.g. "$29.99 yearly").
///   * [period] — coarse cadence used for analytics + selection-default logic.
///   * [isRecommended] — true for the package that should be selected by
///     default and decorated with the "Recomended" badge.
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String title,
    required String priceLabel,
    required SubscriptionPlanPeriod period,
    @Default(false) bool isRecommended,
  }) = _SubscriptionPlan;
}

/// Coarse plan cadence — used for `plan_selected` analytics + the "annual is
/// recommended" default selection rule. Maps RevenueCat `PackageType` once
/// NIB-18 wires the real provider.
enum SubscriptionPlanPeriod {
  monthly,
  annual;

  /// Snake-case value emitted to analytics (`plan_selected{period}`).
  String get analyticsValue => switch (this) {
    SubscriptionPlanPeriod.monthly => 'monthly',
    SubscriptionPlanPeriod.annual => 'annual',
  };
}
