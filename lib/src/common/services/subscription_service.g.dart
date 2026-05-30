// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'0a5b4e13dd0c19f75cf8da447a27aa84b8a59922';

/// Stub SubscriptionService — will be wired in NIB-18.
/// Returns false by default; redirect logic sends users to paywall.
///
/// NIB-73 expands the surface with [info] so the Manage Subscription screen
/// can render plan / Started / Renewal from a single entitlement snapshot.
/// The shape mirrors what RevenueCat `customerInfo` will yield, so swapping
/// the stub for the real implementation is a no-op for the screen.
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
