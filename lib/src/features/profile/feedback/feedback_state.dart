import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_state.freezed.dart';

@freezed
class FeedbackState with _$FeedbackState {
  const factory FeedbackState({
    @Default('') String message,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _FeedbackState;
}
