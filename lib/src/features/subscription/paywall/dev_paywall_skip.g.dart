// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_paywall_skip.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$devPaywallSkipEnabledHash() =>
    r'd297cc2287a421252fa6d69772f7383f30be0c7a';

/// NIB-150 — dev-flavor-only seam past the M2 paywall gate (SB-01) so
/// automated QA flows can finish onboarding without a StoreKit purchase.
/// Session-scoped on purpose: nothing is persisted, prod flavor never
/// renders the affordance and the redirect ignores the flag outside dev.
///
/// Copied from [devPaywallSkipEnabled].
@ProviderFor(devPaywallSkipEnabled)
final devPaywallSkipEnabledProvider = Provider<bool>.internal(
  devPaywallSkipEnabled,
  name: r'devPaywallSkipEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$devPaywallSkipEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DevPaywallSkipEnabledRef = ProviderRef<bool>;
String _$devPaywallSkipHash() => r'bfff4b3e9b7de1e43d4f0a69f4ba090b0d51e396';

/// See also [DevPaywallSkip].
@ProviderFor(DevPaywallSkip)
final devPaywallSkipProvider = NotifierProvider<DevPaywallSkip, bool>.internal(
  DevPaywallSkip.new,
  name: r'devPaywallSkipProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$devPaywallSkipHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DevPaywallSkip = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
