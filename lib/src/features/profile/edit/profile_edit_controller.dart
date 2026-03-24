import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/edit/profile_edit_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_edit_controller.g.dart';

@riverpod
class ProfileEditController extends _$ProfileEditController {
  @override
  Future<ProfileEditState> build(String babyId) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) throw const UnknownException('Baby profile not found.');
    return ProfileEditState(
      name: baby.name,
      dob: baby.dateOfBirth,
      gender: baby.gender,
    );
  }

  void updateName(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(name: value, errorMessage: null));
  }

  void updateDob(DateTime value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(dob: value, errorMessage: null));
  }

  void updateGender(Gender value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(gender: value, errorMessage: null));
  }

  Future<bool> save() async {
    final current = state.valueOrNull;
    if (current == null) return false;

    state = AsyncData(current.copyWith(isLoading: true, errorMessage: null));

    final result = await ref
        .read(babyProfileServiceProvider)
        .updateBaby(babyId, current.name, current.dob, current.gender);

    return result.when(
      success: (_) {
        state = AsyncData(current.copyWith(isLoading: false));
        return true;
      },
      failure: (error) {
        state = AsyncData(
          current.copyWith(isLoading: false, errorMessage: error.message),
        );
        return false;
      },
    );
  }
}
