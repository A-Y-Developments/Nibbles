import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_edit_controller.g.dart';

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
    return ProfileEditSaveResult(
      success: true,
      emailChanged: emailChanged,
    );
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
