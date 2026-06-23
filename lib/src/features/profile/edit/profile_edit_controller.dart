import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_state.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_edit_controller.g.dart';

/// Injectable Crashlytics recorder so unit tests can assert the non-fatal
/// payload without touching real Firebase. Mirrors the
/// `AllergenCrashRecorderFn` pattern from NIB-125.
typedef ProfileEditCrashRecorderFn =
    Future<void> Function(Object error, StackTrace stack, {String? reason});

Future<void> _defaultProfileEditCrashRecorder(
  Object error,
  StackTrace stack, {
  String? reason,
}) => FirebaseCrashlytics.instance.recordError(
  error,
  stack,
  reason: reason,
  // Non-fatal: updateEmail failures still surface a P1 inline error + retry.
  // ignore: avoid_redundant_argument_values
  fatal: false,
);

/// Provider for the [ProfileEditCrashRecorderFn]. Tests override this to
/// capture the recorded payload without hitting Crashlytics.
@Riverpod(keepAlive: true)
ProfileEditCrashRecorderFn profileEditCrashRecorder(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  ProfileEditCrashRecorderRef ref,
) => _defaultProfileEditCrashRecorder;

@riverpod
class ProfileEditController extends _$ProfileEditController {
  String _initialEmail = '';

  @override
  Future<ProfileEditState> build(String babyId) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) throw const UnknownException('Baby profile not found.');

    final parts = baby.name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? '' : parts.first;
    final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
    final email = ref.read(authServiceProvider.notifier).currentUserEmail ?? '';
    _initialEmail = email;

    return ProfileEditState(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }

  void updateFirstName(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(firstName: value, errorMessage: null));
  }

  void updateLastName(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(lastName: value, errorMessage: null));
  }

  void updateEmail(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(email: value, errorMessage: null));
  }

  /// Returns a [ProfileEditSaveResult] describing whether the save succeeded
  /// and whether an email change was requested (so the UI can show the
  /// confirmation-email notice).
  Future<ProfileEditSaveResult> save() async {
    final current = state.valueOrNull;
    if (current == null) {
      return const ProfileEditSaveResult(success: false);
    }

    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) {
      state = AsyncData(
        current.copyWith(
          isLoading: false,
          errorMessage: 'Baby profile not found.',
        ),
      );
      return const ProfileEditSaveResult(success: false);
    }

    state = AsyncData(current.copyWith(isLoading: true, errorMessage: null));

    final firstName = current.firstName.trim();
    final lastName = current.lastName.trim();
    final newName = lastName.isEmpty ? firstName : '$firstName $lastName';
    final newEmail = current.email.trim();

    final nameResult = await ref
        .read(babyProfileServiceProvider)
        .updateBaby(babyId, newName, baby.dateOfBirth, baby.gender);

    if (nameResult.isFailure) {
      state = AsyncData(
        current.copyWith(
          isLoading: false,
          errorMessage: nameResult.errorOrNull?.message,
        ),
      );
      return const ProfileEditSaveResult(success: false);
    }

    final emailChanged = newEmail != _initialEmail;
    if (emailChanged) {
      final emailResult = await ref
          .read(authServiceProvider.notifier)
          .updateEmail(newEmail);
      if (emailResult.isFailure) {
        // P1 path: record non-fatal BEFORE the UI shows the inline error.
        // Reason is a stable enum string — no email value, no PII.
        await ref.read(profileEditCrashRecorderProvider)(
          'profile_email_update_failure: '
          '${emailResult.errorOrNull?.message ?? 'unknown'}',
          StackTrace.current,
          reason: 'profile_email_update_failure',
        );
        state = AsyncData(
          current.copyWith(
            isLoading: false,
            errorMessage: emailResult.errorOrNull?.message,
          ),
        );
        return const ProfileEditSaveResult(success: false);
      }
    }

    state = AsyncData(current.copyWith(isLoading: false));
    // Success path — fire-and-forget. Param is a bool only (no PII).
    unawaited(
      ref
          .read(analyticsProvider)
          .logProfileEditSaved(emailChanged: emailChanged),
    );
    return ProfileEditSaveResult(success: true, emailChanged: emailChanged);
  }
}

class ProfileEditSaveResult {
  const ProfileEditSaveResult({
    required this.success,
    this.emailChanged = false,
  });

  final bool success;
  final bool emailChanged;
}
