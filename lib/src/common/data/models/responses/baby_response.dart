// freezed copies @JsonKey field annotations into generated parts, triggering a
// false-positive from very_good_analysis on the generated getter declarations.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'baby_response.freezed.dart';
part 'baby_response.g.dart';

@freezed
class BabyResponse with _$BabyResponse {
  const factory BabyResponse({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'date_of_birth') required String dateOfBirth,
    required String gender,
    @JsonKey(name: 'onboarding_completed') required bool onboardingCompleted,
  }) = _BabyResponse;

  factory BabyResponse.fromJson(Map<String, dynamic> json) =>
      _$BabyResponseFromJson(json);
}
