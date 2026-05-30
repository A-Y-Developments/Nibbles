import 'package:nibbles/src/common/services/feedback_service.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_controller.g.dart';

@riverpod
class FeedbackController extends _$FeedbackController {
  @override
  FeedbackState build() => const FeedbackState();

  void updateMessage(String value) {
    state = state.copyWith(message: value, errorMessage: null);
  }

  /// Submits the current message. Returns true on success, false on
  /// failure. The Send button is gated on a non-blank message + not
  /// already submitting, so we only need to short-circuit those here as
  /// belt-and-braces.
  Future<bool> submit() async {
    final trimmed = state.message.trim();
    if (trimmed.isEmpty || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref.read(feedbackServiceProvider).submit(trimmed);

    return result.when(
      success: (_) {
        state = state.copyWith(isSubmitting: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }
}
