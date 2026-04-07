import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/profile_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockBabyProfileService extends Mock implements BabyProfileService {}

class MockAllergenService extends Mock implements AllergenService {}

class MockAuthRepository extends Mock implements AuthRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _babyId = 'baby-001';

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _peanutAllergen = Allergen(
  key: 'peanut',
  name: 'Peanut',
  sequenceOrder: 1,
  emoji: '🥜',
);

const _safePeanutItem = AllergenBoardItem(
  allergen: _peanutAllergen,
  logs: [],
  status: AllergenStatus.safe,
);

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget screen, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, __) => screen)],
    ),
  ),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockBabyProfileService mockBabyService;
  late MockAllergenService mockAllergenService;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockBabyService = MockBabyProfileService();
    mockAllergenService = MockAllergenService();
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(
      () => mockAuthRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
  });

  List<Override> buildOverrides() => [
    babyProfileServiceProvider.overrideWithValue(mockBabyService),
    allergenServiceProvider.overrideWithValue(mockAllergenService),
    authRepositoryProvider.overrideWithValue(mockAuthRepo),
  ];

  void stubCommon({List<AllergenBoardItem> boardItems = const []}) {
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(
      () => mockAllergenService.getAllergenBoardSummary(_babyId),
    ).thenAnswer((_) async => Result.success(boardItems));
  }

  // -------------------------------------------------------------------------
  // Baby info
  // -------------------------------------------------------------------------

  testWidgets('baby name, age, gender and subscription label shown correctly', (
    tester,
  ) async {
    stubCommon();

    await tester.pumpWidget(_wrap(const ProfileScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.text('Lily'), findsOneWidget);
    expect(find.textContaining('old'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Trial'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Safe allergens — with data
  // -------------------------------------------------------------------------

  testWidgets('safe allergen chips shown for AllergenStatus.safe allergens', (
    tester,
  ) async {
    stubCommon(boardItems: [_safePeanutItem]);

    await tester.pumpWidget(_wrap(const ProfileScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.text('Peanut'), findsOneWidget);
    expect(find.text('🥜'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Safe allergens — empty state
  // -------------------------------------------------------------------------

  testWidgets('empty state shown when no safe allergens confirmed', (
    tester,
  ) async {
    stubCommon();

    await tester.pumpWidget(_wrap(const ProfileScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    expect(
      find.text('No safe allergens confirmed yet. Keep going!'),
      findsOneWidget,
    );
  });

  // -------------------------------------------------------------------------
  // Sign out — dialog shown
  // -------------------------------------------------------------------------

  testWidgets('tapping Sign Out button shows confirmation dialog', (
    tester,
  ) async {
    stubCommon();

    await tester.pumpWidget(_wrap(const ProfileScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_sign_out_button')));
    await tester.pumpAndSettle();

    expect(find.text('Sign Out'), findsWidgets);
    expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Sign out — dialog No
  // -------------------------------------------------------------------------

  testWidgets('tapping No dismisses dialog and keeps profile screen', (
    tester,
  ) async {
    stubCommon();

    await tester.pumpWidget(_wrap(const ProfileScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_sign_out_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to sign out?'), findsNothing);
    expect(find.byKey(const Key('profile_sign_out_button')), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Sign out — dialog Yes
  // -------------------------------------------------------------------------

  testWidgets('tapping Yes calls AuthService.signOut', (tester) async {
    stubCommon();
    when(
      () => mockAuthRepo.signOut(),
    ).thenAnswer((_) async => const Result.success(null));

    await tester.pumpWidget(_wrap(const ProfileScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile_sign_out_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    verify(() => mockAuthRepo.signOut()).called(1);
  });
}
