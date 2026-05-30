// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cancelSubscriptionControllerHash() =>
    r'f344e2d60dfc053868216ae225bdeaf52628468c';

/// Drives the cancel-subscription reason overlay (NIB-82).
///
/// `submit(reason)` is the only mutator:
///  1. Sets `isSubmitting = true`.
///  2. Fires `subscription_cancel_started` + `subscription_cancel_reason`
///     analytics (PII-free `analyticsKey`).
///  3. Deep-links to the OS-managed subscription page via
///     [SubscriptionService.openManagementPage]. Apps cannot programmatically
///     cancel App Store / Play subscriptions — the OS owns the cancel UI.
///  4. Returns `true` on success so the overlay can dismiss itself, `false`
///     on URL-open failure so the overlay can surface the P2 SnackBar.
///
/// Copied from [CancelSubscriptionController].
@ProviderFor(CancelSubscriptionController)
final cancelSubscriptionControllerProvider =
    AutoDisposeNotifierProvider<
      CancelSubscriptionController,
      CancelSubscriptionState
    >.internal(
      CancelSubscriptionController.new,
      name: r'cancelSubscriptionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cancelSubscriptionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CancelSubscriptionController =
    AutoDisposeNotifier<CancelSubscriptionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
