// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'a19ffaac6571296239894948843a8e744d000c54';

/// Stub SubscriptionService — will be wired in NIB-18.
/// Returns false by default; redirect logic sends users to paywall.
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
