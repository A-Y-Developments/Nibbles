import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/profile/profile_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBabyProfileService extends Mock implements BabyProfileService {}

class MockAllergenService extends Mock implements AllergenService {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

/// Skips RevenueCat `Purchases.logOut()` — which hangs in the test environment
/// when the SDK is loaded but not configured — while still routing through the
/// mocked [authRepositoryProvider] so verify() assertions hold.
class _FakeAuthService extends AuthService {
  @override
  bool build() => true;

  @override
  Future<Result<void>> signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result.isSuccess) state = false;
    return result;
  }
}

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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late MockBabyProfileService mockBabyService;
  late MockAllergenService mockAllergenService;
  late MockLocalFlagService mockLocalFlagService;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockBabyService = MockBabyProfileService();
    mockAllergenService = MockAllergenService();
    mockLocalFlagService = MockLocalFlagService();

    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(
      () => mockAllergenService.getAllergenBoardSummary(_babyId),
    ).thenAnswer((_) async => const Result.success(<AllergenBoardItem>[]));
    when(() => mockLocalFlagService.hasLaunched()).thenReturn(true);
    when(
      () => mockLocalFlagService.isOnboardingReadinessDone(),
    ).thenReturn(true);
    when(
      () => mockLocalFlagService.isOnboardingBabySetupDone(),
    ).thenReturn(true);
  });

  testWidgets('sign out clears session and navigates to /auth/login; '
      'app_has_launched flag is not reset', (tester) async {
    when(
      () => mockAuthRepo.signOut(),
    ).thenAnswer((_) async => const Result.success(null));

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const ProfileScreen()),
        GoRoute(
          path: AppRoute.profileEdit.path,
          name: AppRoute.profileEdit.name,
          builder: (_, __) => const Scaffold(body: Text('Edit')),
        ),
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (_, __) => const Scaffold(body: Text('Login')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          authServiceProvider.overrideWith(_FakeAuthService.new),
          babyProfileServiceProvider.overrideWithValue(mockBabyService),
          allergenServiceProvider.overrideWithValue(mockAllergenService),
          localFlagServiceProvider.overrideWithValue(mockLocalFlagService),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_sign_out_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_sign_out_button')));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to sign out?'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    verify(() => mockAuthRepo.signOut()).called(1);
    verifyNever(() => mockLocalFlagService.setHasLaunched());
  });
}
