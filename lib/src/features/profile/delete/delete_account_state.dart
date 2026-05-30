import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_state.freezed.dart';

@freezed
class DeleteAccountState with _$DeleteAccountState {
  const factory DeleteAccountState({
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _DeleteAccountState;
}
