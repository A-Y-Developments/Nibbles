// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingCrashRecorderHash() =>
    r'4590b3d2e3ac5fdfeb41bd6bc2f297c6dbf9a33b';

/// Provider for the [OnboardingCrashRecorderFn]. Tests override this to
/// capture the recorded payload without hitting Crashlytics.
///
/// Copied from [onboardingCrashRecorder].
@ProviderFor(onboardingCrashRecorder)
final onboardingCrashRecorderProvider =
    Provider<OnboardingCrashRecorderFn>.internal(
      onboardingCrashRecorder,
      name: r'onboardingCrashRecorderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingCrashRecorderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingCrashRecorderRef = ProviderRef<OnboardingCrashRecorderFn>;
String _$onboardingControllerHash() =>
    r'22e4461096b5e11e189dcad6e68766ea819ebb78';

/// Single hoisted controller for the new onboarding flow.
///
/// keepAlive so back-nav (e.g. consent -> result -> readiness) does not lose
/// the name/dob/readiness/consent state captured at earlier stages.
///
/// Copied from [OnboardingController].
@ProviderFor(OnboardingController)
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>.internal(
      OnboardingController.new,
      name: r'onboardingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingController = Notifier<OnboardingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
