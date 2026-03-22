import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';

part 'baby.freezed.dart';

@freezed
class Baby with _$Baby {
  const factory Baby({
    required String id,
    required String userId,
    required String name,
    required DateTime dateOfBirth,
    required Gender gender,
    required bool onboardingCompleted,
  }) = _Baby;
}
