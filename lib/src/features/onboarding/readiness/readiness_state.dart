import 'package:freezed_annotation/freezed_annotation.dart';

part 'readiness_state.freezed.dart';

@freezed
class ReadinessState with _$ReadinessState {
  const factory ReadinessState({
    required List<bool?> answers,
    @Default(false) bool showWarning,
  }) = _ReadinessState;
}
