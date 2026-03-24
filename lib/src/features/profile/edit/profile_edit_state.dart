import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';

part 'profile_edit_state.freezed.dart';

@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    required String name,
    required DateTime dob,
    required Gender gender,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ProfileEditState;
}
