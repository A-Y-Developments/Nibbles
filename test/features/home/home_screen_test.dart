import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/features/home/home_screen.dart';

// ---------------------------------------------------------------------------
// NIB-86: render-smoke tests only. The home screen now delegates to placeholder
// widgets (NIB-65 / NIB-77 / NIB-96 will implement). NIB-111 owns the full
// widget test suite once the leaf widgets land.
// ---------------------------------------------------------------------------

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockAllergenService extends Mock implements AllergenService {}

class _MockMealPlanService extends Mock implements MealPlanService {}

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

Widget _wrap(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())],
    ),
  ),
);

void main() {
  late _MockBabyProfileService mockBabyService;
  late _MockAllergenService mockAllergenService;
  late _MockMealPlanService mockMealPlanService;

  setUp(() {
    mockBabyService = _MockBabyProfileService();
    mockAllergenService = _MockAllergenService();
    mockMealPlanService = _MockMealPlanService();
  });

  List<Override> buildOverrides() => [
    babyProfileServiceProvider.overrideWithValue(mockBabyService),
    allergenServiceProvider.overrideWithValue(mockAllergenService),
    mealPlanServiceProvider.overrideWithValue(mockMealPlanService),
  ];

  testWidgets('renders without errors when baby + services resolve', (
    tester,
  ) async {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => mockAllergenService.getAllergenStatuses(_babyId)).thenAnswer(
      (_) async => const Result.success(<String, AllergenStatus>{}),
    );
    when(() => mockMealPlanService.getRolling7(_babyId)).thenAnswer(
      (_) async => const Result.success(<MealPlanEntry>[]),
    );

    await tester.pumpWidget(_wrap(buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('renders empty state scaffold when no baby exists', (
    tester,
  ) async {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => null);

    await tester.pumpWidget(_wrap(buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
