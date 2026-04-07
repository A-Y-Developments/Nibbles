import 'package:nibbles/src/common/data/models/responses/baby_response.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';

extension BabyResponseMapper on BabyResponse {
  Baby toDomain() {
    return Baby(
      id: id,
      userId: userId,
      name: name,
      dateOfBirth: DateTime.parse(dateOfBirth),
      gender: _parseGender(gender),
      onboardingCompleted: onboardingCompleted,
    );
  }
}

Gender _parseGender(String value) => switch (value) {
  'male' => Gender.male,
  'female' => Gender.female,
  _ => Gender.preferNotToSay,
};

extension GenderMapper on Gender {
  String toJson() => switch (this) {
    Gender.male => 'male',
    Gender.female => 'female',
    Gender.preferNotToSay => 'prefer_not_to_say',
  };
}
