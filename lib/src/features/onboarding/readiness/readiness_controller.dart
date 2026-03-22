import 'package:nibbles/src/features/onboarding/readiness/readiness_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readiness_controller.g.dart';

@riverpod
class ReadinessController extends _$ReadinessController {
  @override
  ReadinessState build() => ReadinessState(answers: List.filled(6, null));

  void answer(int questionIndex, {required bool isYes}) {
    state = state.copyWith(
      answers: List<bool?>.from(state.answers)..[questionIndex] = isYes,
    );
  }

  /// Called after question 6 — advances to warning or completes.
  void finish() {
    final hasAnyUnsure = state.answers.any((a) => a == false);
    if (hasAnyUnsure) {
      state = state.copyWith(showWarning: true);
    }
  }

  void goBack() {
    state = state.copyWith(showWarning: false);
  }

  void reset() {
    state = ReadinessState(answers: List.filled(6, null));
  }
}
