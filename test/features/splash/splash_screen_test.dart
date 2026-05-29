// The Firebase platform-interface packages are transitive deps of
// firebase_analytics / firebase_core; the public barrels don't re-export
// FirebaseAnalyticsPlatform or setupFirebaseCoreMocks, so this test imports
// them directly (test-only).
// ignore_for_file: depend_on_referenced_packages

// Widget tests for SplashScreen (NIB-88).
//
// Covers:
//   - P0 boot failure renders the full-screen 'Try again' retry UI.
//   - Tapping retry invalidates the controller and re-runs boot; navigation
//     fires ONLY on the success state (never on loading/error) and never
//     infinite-loops.
//   - Analytics: a fake FirebaseAnalytics platform proves logAppOpen (boot) and
//     logScreenView('splash') (first frame) are emitted. Analytics has no DI
//     seam, so we record at the platform layer instead of mutating prod code.

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Mocks / fakes
// ---------------------------------------------------------------------------

class MockBabyProfileService extends Mock implements BabyProfileService {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

/// Always-logged-in [AuthService] with an empty auth stream: the controller's
/// session-settle fast path returns immediately, so boot resolution is gated
/// only by the (real) brand floor we pump past in the tests.
class FakeAuthService extends AuthService {
  @override
  bool build() => true;

  @override
  Stream<AuthState> get authStateStream => const Stream.empty();
}

/// Records platform-level analytics calls. [FirebaseAnalyticsPlatform] is meant
/// to be extended (default impls fill the unimplemented methods), so we only
/// override the delegate hook + logEvent.
class RecordingAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  RecordingAnalyticsPlatform() : super();

  final loggedEvents = <Map<String, Object?>>[];

  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) => this;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    loggedEvents.add({'name': name, 'parameters': parameters});
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _fakeBaby = Baby(
  id: 'baby-001',
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

/// Marker widget for the success destination so we can assert navigation fired.
class _HomeStub extends StatelessWidget {
  const _HomeStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('HOME_STUB')));
}

GoRouter _makeRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const _HomeStub()),
    GoRoute(
      path: '/auth/login',
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('LOGIN_STUB'))),
    ),
    GoRoute(
      path: '/onboarding/intro',
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('INTRO_STUB'))),
    ),
  ],
);

Widget _buildSut({
  required MockBabyProfileService babyProfile,
  required MockLocalFlagService flags,
  required GoRouter router,
}) => ProviderScope(
  overrides: [
    authServiceProvider.overrideWith(FakeAuthService.new),
    babyProfileServiceProvider.overrideWithValue(babyProfile),
    localFlagServiceProvider.overrideWithValue(flags),
  ],
  child: MaterialApp.router(routerConfig: router),
);

void main() {
  // Boot Firebase against the core mock so the lazily-built Analytics singleton
  // (Analytics.instance -> FirebaseAnalytics.instance -> Firebase.app()) does
  // not throw, and route its delegate to a recorder we can assert on.
  //
  // FirebaseAnalytics caches its delegate per app instance, so the platform
  // instance is fixed on first use. Install ONE recorder before any access and
  // clear it per test, rather than swapping instances each setUp.
  final analytics = RecordingAnalyticsPlatform();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = analytics;
  });

  late MockBabyProfileService babyProfile;
  late MockLocalFlagService flags;

  setUp(() {
    analytics.loggedEvents.clear();

    babyProfile = MockBabyProfileService();
    flags = MockLocalFlagService();
    // Default: returning user, already onboarded -> success path -> /home.
    when(flags.hasLaunched).thenReturn(true);
    when(() => babyProfile.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => babyProfile.onboardingCompleted).thenAnswer((_) async => true);
  });

  // ---------------------------------------------------------------------------
  // P0 error + retry
  // ---------------------------------------------------------------------------

  testWidgets(
    'P0 boot failure renders the Try again retry UI (no navigation)',
    (tester) async {
      when(
        () => babyProfile.getBaby(),
      ).thenThrow(Exception('no connectivity'));
      final router = _makeRouter();

      await tester.pumpWidget(
        _buildSut(babyProfile: babyProfile, flags: flags, router: router),
      );
      // Pump past the brand floor (~1800ms) so boot resolves to the error.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Try again'), findsOneWidget);
      // navigation must NOT fire on the error state.
      expect(find.text('HOME_STUB'), findsNothing);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    },
  );

  testWidgets(
    'tapping Try again re-runs boot; navigates to /home only on success',
    (tester) async {
      // First boot fails, retry succeeds: getBaby throws once, then resolves.
      var attempts = 0;
      when(() => babyProfile.getBaby()).thenAnswer((_) async {
        attempts++;
        if (attempts == 1) throw Exception('no connectivity');
        return _fakeBaby;
      });
      final router = _makeRouter();

      await tester.pumpWidget(
        _buildSut(babyProfile: babyProfile, flags: flags, router: router),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // Error state surfaced, no navigation yet.
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('HOME_STUB'), findsNothing);

      // Retry: invalidates the provider and re-runs the whole boot.
      await tester.tap(find.text('Try again'));
      await tester.pump(); // schedule the rebuild
      await tester.pump(const Duration(seconds: 2)); // past brand floor again
      await tester.pumpAndSettle();

      // Navigation fired exactly on the success state.
      expect(find.text('HOME_STUB'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      // Bounded retry: boot ran twice (initial + one retry), not a loop.
      expect(attempts, 2);
    },
  );

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  testWidgets(
    'emits app_open (boot) and screen_view(splash) (first frame)',
    (tester) async {
      final router = _makeRouter();

      await tester.pumpWidget(
        _buildSut(babyProfile: babyProfile, flags: flags, router: router),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final names = analytics.loggedEvents.map((e) => e['name']).toList();
      expect(names, contains('app_open'));
      expect(names, contains('screen_view'));

      final screenView = analytics.loggedEvents.firstWhere(
        (e) => e['name'] == 'screen_view',
      );
      final params = screenView['parameters'] as Map<String, Object?>?;
      expect(params?['screen_name'], 'splash');
    },
  );
}
