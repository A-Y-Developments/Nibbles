// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_success_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionSuccessControllerHash() =>
    r'e12fe3c3ee4f743115c9397d927fa28ca8bb2b25';

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
///
/// Copied from [SubscriptionSuccessController].
@ProviderFor(SubscriptionSuccessController)
final subscriptionSuccessControllerProvider =
    AutoDisposeNotifierProvider<
      SubscriptionSuccessController,
      SubscriptionSuccessPhase
    >.internal(
      SubscriptionSuccessController.new,
      name: r'subscriptionSuccessControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionSuccessControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubscriptionSuccessController =
    AutoDisposeNotifier<SubscriptionSuccessPhase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
