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

    // Auth repo — starts logged in
    when(() => mockAuthRepo.isLoggedIn).thenReturn(true);
    when(() => mockAuthRepo.authStateStream)
        .thenAnswer((_) => const Stream.empty());

    // Local flags — app has launched, onboarding complete
    when(() => mockLocalFlagService.hasLaunched()).thenReturn(true);
    when(() => mockLocalFlagService.isOnboardingReadinessDone())
        .thenReturn(true);
    when(() => mockLocalFlagService.isOnboardingBabySetupDone())
        .thenReturn(true);

    // Baby profile + allergen board (needed to render ProfileScreen)
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => mockAllergenService.getAllergenBoardSummary(_babyId))
        .thenAnswer((_) async => const Result.success(<AllergenBoardItem>[]));
  });

  testWidgets(
    'sign out clears session and navigates to /auth/login; '
    'app_has_launched flag is not reset',
    (tester) async {
      when(() => mockAuthRepo.signOut())
          .thenAnswer((_) async => const Result.success(null));

      // Build ProviderContainer with all overrides
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          babyProfileServiceProvider.overrideWithValue(mockBabyService),
          allergenServiceProvider.overrideWithValue(mockAllergenService),
          localFlagServiceProvider.overrideWithValue(mockLocalFlagService),
        ],
      );
      addTearDown(container.dispose);

      // GoRouter refresh notifier — re-evaluates redirect when auth changes
      final authState = ValueNotifier<bool>(
        container.read(authServiceProvider),
      );
      container.listen<bool>(authServiceProvider, (_, next) {
        authState.value = next;
      });
      addTearDown(authState.dispose);

      final router = GoRouter(
        initialLocation: '/',
        refreshListenable: authState,
        redirect: (ctx, state) {
          final isLoggedIn = container.read(authServiceProvider);
          if (!isLoggedIn && state.matchedLocation != AppRoute.login.path) {
            return AppRoute.login.path;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoute.login.path,
            name: AppRoute.login.name,
            builder: (_, __) => const Scaffold(body: Text('Login Screen')),
          ),
          GoRoute(
            path: AppRoute.profileEdit.path,
            name: AppRoute.profileEdit.name,
            builder: (_, __) => const Scaffold(body: Text('Edit Profile')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Profile screen is visible
      expect(find.byKey(const Key('profile_sign_out_button')), findsOneWidget);

      // Tap Sign Out
      await tester.tap(find.byKey(const Key('profile_sign_out_button')));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);

      // Confirm sign out
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Assert: Supabase session cleared — isLoggedIn = false
      expect(container.read(authServiceProvider), isFalse);

      // Assert: navigated to /auth/login
      expect(find.text('Login Screen'), findsOneWidget);

      // Assert: app_has_launched flag was NOT reset
      verifyNever(() => mockLocalFlagService.setHasLaunched());
    },
  );
}
