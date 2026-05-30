// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedbackCrashRecorderHash() =>
    r'd1c749ee65e3484864e30b5687d51fc1cb9a8b1e';

/// Provider for the [FeedbackCrashRecorderFn]. Tests override this to capture
/// the recorded payload without hitting Crashlytics.
///
/// Copied from [feedbackCrashRecorder].
@ProviderFor(feedbackCrashRecorder)
final feedbackCrashRecorderProvider =
    Provider<FeedbackCrashRecorderFn>.internal(
      feedbackCrashRecorder,
      name: r'feedbackCrashRecorderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedbackCrashRecorderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedbackCrashRecorderRef = ProviderRef<FeedbackCrashRecorderFn>;
String _$feedbackControllerHash() =>
    r'4e646c81910ecf466b8af7128730f8c3710c3f15';

/// See also [FeedbackController].
@ProviderFor(FeedbackController)
final feedbackControllerProvider =
    AutoDisposeNotifierProvider<FeedbackController, FeedbackState>.internal(
      FeedbackController.new,
      name: r'feedbackControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedbackControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedbackController = AutoDisposeNotifier<FeedbackState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
