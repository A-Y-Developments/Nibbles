// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'starting_guide_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$startingGuideControllerHash() =>
    r'92f0e78aa5c837bc7237432cba6348eea1b55021';

/// AsyncNotifier for the Starting Guide hub.
///
/// Returns the hardcoded [kStartingGuideArticles] list. Async-shaped so the
/// screens treat the data the same way they would a future remote source.
///
/// Copied from [StartingGuideController].
@ProviderFor(StartingGuideController)
final startingGuideControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      StartingGuideController,
      StartingGuideState
    >.internal(
      StartingGuideController.new,
      name: r'startingGuideControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$startingGuideControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StartingGuideController =
    AutoDisposeAsyncNotifier<StartingGuideState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
