// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deleteAccountCrashRecorderHash() =>
    r'16e79ff904d8e06d9dcbd2b52a9f43e5d9ec1061';

/// Provider for the [DeleteAccountCrashRecorderFn]. Tests override this to
/// capture the recorded payload without hitting Crashlytics.
///
/// Copied from [deleteAccountCrashRecorder].
@ProviderFor(deleteAccountCrashRecorder)
final deleteAccountCrashRecorderProvider =
    Provider<DeleteAccountCrashRecorderFn>.internal(
      deleteAccountCrashRecorder,
      name: r'deleteAccountCrashRecorderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteAccountCrashRecorderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteAccountCrashRecorderRef =
    ProviderRef<DeleteAccountCrashRecorderFn>;
String _$deleteAccountControllerHash() =>
    r'ee41096e3d70a4e8da28923aa272c47ade44a638';

/// Drives the delete-account flow opened from Profile (NIB-78).
///
/// `submit(reason)` orchestrates the destructive sequence:
///  1. `AccountService.deleteAccount(reason)` (NIB-85 RPC).
///  2. On success: `LocalFlagService.clearAll()` wipes onboarding/completion
///     flags so a re-register on the same device replays onboarding cleanly.
///  3. Then `AuthService.signOut()` — the GoRouter redirect handles the
///     navigation to `/auth/login` (or `/onboarding/intro` since flags are
///     cleared).
///
/// On failure: `errorMessage` is set so the overlay can render an inline P1
/// error + retry CTA without dismissing.
///
/// Copied from [DeleteAccountController].
@ProviderFor(DeleteAccountController)
final deleteAccountControllerProvider =
    AutoDisposeNotifierProvider<
      DeleteAccountController,
      DeleteAccountState
    >.internal(
      DeleteAccountController.new,
      name: r'deleteAccountControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteAccountControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeleteAccountController = AutoDisposeNotifier<DeleteAccountState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
