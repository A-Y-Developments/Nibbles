// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'c5ece94fd553c4d270b8e630aaf272b43ab7b3cd';

/// Stub SubscriptionService — to be wired through `purchases_flutter` in
/// NIB-18. State is the entitlement bool used by callers like the post-
/// purchase transition controller and the (currently deferred) router guard.
///
/// NIB-73 expands the surface with [info] so the Manage Subscription screen
/// can render plan / Started / Renewal from a single entitlement snapshot.
/// NIB-55 adds [loadOfferings] / [purchaseDefault] / [restore] so the paywall
/// reads its default trial offering and triggers purchase/restore at this
/// seam. Until NIB-18 lands the stub returns a fixed placeholder offering so
/// the UI never has to hardcode price strings, and the three P1 failure paths
/// (`purchaseFail` / `restoreNoEntitlement` / `offeringsLoadFail`) are wired
/// at the seam — tests override the provider to exercise them.
///
/// The shape mirrors what RevenueCat `customerInfo` will yield, so swapping
/// the stub for the real implementation is a no-op for callers.
///
/// Copied from [SubscriptionService].
@ProviderFor(SubscriptionService)
final subscriptionServiceProvider =
    AutoDisposeNotifierProvider<SubscriptionService, bool>.internal(
      SubscriptionService.new,
      name: r'subscriptionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubscriptionService = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
