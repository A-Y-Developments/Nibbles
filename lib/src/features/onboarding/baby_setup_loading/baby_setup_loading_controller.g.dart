// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_setup_loading_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$babySetupLoadingControllerHash() =>
    r'47fc54d284050f8898b3e1f3f66019305d029434';

/// NIB-137 — passive transition shown after the consent step submits
/// successfully and before the user lands on /home.
///
/// The actual `createBaby` future is owned by `OnboardingController.submit`
/// (NIB-100) — by the time this screen mounts, the baby already exists and
/// `onboarding_done` is true. So this controller only owns the *dwell*:
///
///   1. Render [BabySetupLoadingPhase.loading] immediately.
///   2. After [minDwell], flip to [BabySetupLoadingPhase.ready] so the screen
///      schedules its auto-route to /home.
///   3. [maxTimeout] is the safety belt — if some future preload were to be
///      wired in here it would force-settle anyway. Today minDwell elapses
///      first so the timeout is functionally a no-op, but the constant is
///      kept so the screen's PopScope + timeout semantics stay clearly named.
///
/// Min dwell is sized so the petal animation never just flashes (per Figma
/// audit rotating-icon cluster spec) and aligns with the NIB-130 subscription
/// success screen's 1500ms floor.
///
/// Copied from [BabySetupLoadingController].
@ProviderFor(BabySetupLoadingController)
final babySetupLoadingControllerProvider =
    AutoDisposeNotifierProvider<
      BabySetupLoadingController,
      BabySetupLoadingPhase
    >.internal(
      BabySetupLoadingController.new,
      name: r'babySetupLoadingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$babySetupLoadingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BabySetupLoadingController =
    AutoDisposeNotifier<BabySetupLoadingPhase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
