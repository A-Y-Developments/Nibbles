import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/onboarding/baby_setup/baby_setup_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'baby_setup_controller.g.dart';

@riverpod
class BabySetupController extends _$BabySetupController {
  @override
  BabySetupState build() {
    final now = DateTime.now();
    final defaultDob = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 180));
    return BabySetupState(dob: defaultDob);
  }

  void updateName(String value) {
    state = state.copyWith(
      babyName: BabyNameInput.dirty(value),
      errorMessage: null,
    );
  }

  void updateDob(DateTime value) {
    state = state.copyWith(dob: value, errorMessage: null);
  }

  void updateGender(Gender value) {
    state = state.copyWith(gender: value, errorMessage: null);
  }

  void nextStep() {
    state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  Future<bool> submit() async {
    if (state.dob == null || state.gender == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(babyProfileServiceProvider)
        .createBaby(state.babyName.value, state.dob!, state.gender!);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        return false;
      },
    );
  }
}
