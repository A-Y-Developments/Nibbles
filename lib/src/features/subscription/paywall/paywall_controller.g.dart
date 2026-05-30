// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paywallControllerHash() => r'06a9028e6b66dd5ef1ed5cbb1551fe0597f51071';

/// NIB-55 — paywall (Try for $0 sheet) controller.
///
/// Loads the default trial offering on build and exposes
/// [purchaseDefault] / [restore] as the two CTA handlers. Results are
/// returned to the UI so the screen owns the P1 modal surface (per
/// error-handling.md the controller never throws and never decides UI).
///
/// Analytics fired here:
/// * `paywall_viewed`            — on first build.
/// * `subscription_started`      — on `purchaseDefault` success.
/// * `subscription_restored`     — on `restore` success.
///
/// Copied from [PaywallController].
@ProviderFor(PaywallController)
final paywallControllerProvider =
    AutoDisposeNotifierProvider<PaywallController, PaywallState>.internal(
      PaywallController.new,
      name: r'paywallControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paywallControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PaywallController = AutoDisposeNotifier<PaywallState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
