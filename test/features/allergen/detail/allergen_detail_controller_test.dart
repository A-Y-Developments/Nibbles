import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_controller.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

const _allergenKey = 'peanut';
const _babyId = 'baby-001';

final _baby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

ProviderContainer _makeContainer({
  required BabyProfileService babyProfile,
  required AllergenService allergen,
}) {
  final container = ProviderContainer(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(babyProfile),
      allergenServiceProvider.overrideWithValue(allergen),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late _MockBabyProfileService mockBabyProfile;
  late _MockAllergenService mockAllergen;

  setUp(() {
    mockBabyProfile = _MockBabyProfileService();
    mockAllergen = _MockAllergenService();
    when(
      () => mockBabyProfile.getBaby(),
    ).thenAnswer((_) async => _baby);
  });

  tearDown(resetMocktailState);

  group('AllergenDetailController.build error paths', () {
    test('throws when getAllergens returns failure', () async {
      when(
        () => mockAllergen.getAllergens(),
      ).thenAnswer(
        (_) async =>
            const Result.failure(NetworkException('connection refused')),
      );

      final container = _makeContainer(
        babyProfile: mockBabyProfile,
        allergen: mockAllergen,
      );

      await expectLater(
        container
            .read(allergenDetailControllerProvider(_allergenKey).future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws when allergenKey not found in allergen list', () async {
      when(
        () => mockAllergen.getAllergens(),
      ).thenAnswer(
        (_) async => const Result.success(<Allergen>[]),
      );

      final container = _makeContainer(
        babyProfile: mockBabyProfile,
        allergen: mockAllergen,
      );

      await expectLater(
        container
            .read(allergenDetailControllerProvider(_allergenKey).future),
        throwsA(isA<UnknownException>()),
      );
    });
  });
}
