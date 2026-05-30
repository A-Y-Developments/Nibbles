// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resetPasswordControllerHash() =>
    r'cbc677883b683d49dbd19df8dfd229fc4c3ecdf7';

/// NIB-115 — Reset password / AU-03 controller.
///
/// Drives the three Figma states for forget-password 3/4/5:
///   971:10136 (initial guidance), 971:10148 (too short),
///   971:10160 (mismatch).
///
/// Copied from [ResetPasswordController].
@ProviderFor(ResetPasswordController)
final resetPasswordControllerProvider =
    AutoDisposeNotifierProvider<
      ResetPasswordController,
      ResetPasswordState
    >.internal(
      ResetPasswordController.new,
      name: r'resetPasswordControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$resetPasswordControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ResetPasswordController = AutoDisposeNotifier<ResetPasswordState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
