// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manageSubscriptionControllerHash() =>
    r'35fbe2622c6daacd3f6ab1a6f2e2cc211863e4fe';

/// AsyncNotifier for the Manage Subscription screen (NIB-73).
///
/// Reads the entitlement snapshot from [SubscriptionService.info]. Surfaces
/// repository failures as an `AsyncError` so the screen can render the P1
/// error placeholder + retry (mirrors the Profile screen error UI).
///
/// Copied from [ManageSubscriptionController].
@ProviderFor(ManageSubscriptionController)
final manageSubscriptionControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ManageSubscriptionController,
      ManageSubscriptionState
    >.internal(
      ManageSubscriptionController.new,
      name: r'manageSubscriptionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manageSubscriptionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManageSubscriptionController =
    AutoDisposeAsyncNotifier<ManageSubscriptionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
