import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_edit_state.freezed.dart';

@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    required String firstName,
    required String lastName,
    required String email,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ProfileEditState;
}
