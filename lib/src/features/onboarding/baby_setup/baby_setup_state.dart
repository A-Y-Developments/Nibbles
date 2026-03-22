import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/domain/formz/baby_name_input.dart';

part 'baby_setup_state.freezed.dart';

@freezed
class BabySetupState with _$BabySetupState {
  const factory BabySetupState({
    @Default(0) int step,
    @Default(BabyNameInput.pure()) BabyNameInput babyName,
    DateTime? dob,
    Gender? gender,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _BabySetupState;
}
