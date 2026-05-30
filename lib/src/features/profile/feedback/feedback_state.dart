import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_state.freezed.dart';

/// Lifecycle phase of the Give Feedback screen.
///
/// Mirrors the two artboards in the Figma spec (1207:15273 entry +
/// 1216:11913 success): `idle` renders the textarea + Send Feedback CTA,
/// `submitting` and `success` both render the brand-mark full-screen state
/// (caption swaps from "Loading" to "Feedback sent!" when the submit
/// resolves), then the screen auto-dismisses back to Profile.
enum FeedbackPhase { idle, submitting, success }

@freezed
class FeedbackState with _$FeedbackState {
  const factory FeedbackState({
    @Default('') String message,
    @Default(FeedbackPhase.idle) FeedbackPhase phase,
    String? errorMessage,
  }) = _FeedbackState;
}
