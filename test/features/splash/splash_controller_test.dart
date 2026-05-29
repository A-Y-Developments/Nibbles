import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/auth_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/splash/splash_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Mocks / fakes
// ---------------------------------------------------------------------------

class MockBabyProfileService extends Mock implements BabyProfileService {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

/// Drives [AuthService] without touching Supabase: [build] returns a seeded
/// logged-in value and [authStateStream] is fed by a controller the test owns,
/// letting us emit (or withhold) the session-settle signal deterministically.
class FakeAuthService extends AuthService {
  FakeAuthService({
    required bool initiallyLoggedIn,
    required Stream<AuthState> stream,
  }) : _initiallyLoggedIn = initiallyLoggedIn,
       _stream = stream;

  final bool _initiallyLoggedIn;
  final Stream<AuthState> _stream;

  @override
  bool build() {
    // Mirror the real AuthService: keep state in sync with auth events so a
    // late session-restore signal flips isLoggedIn (the race this kills).
    final sub = _stream.listen((s) => state = s.session != null);
    ref.onDispose(sub.cancel);
    return _initiallyLoggedIn;
  }

  @override
  Stream<AuthState> get authStateStream => _stream;
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

AuthState _sessionEvent({required bool loggedIn}) => AuthState(
  AuthChangeEvent.initialSession,
  loggedIn ? _FakeSession() : null,
);

class _FakeSession extends Fake implements Session {}

ProviderContainer _makeContainer({
  required bool initiallyLoggedIn,
  required Stream<AuthState> stream,
  required MockBabyProfileService babyProfile,
  required MockLocalFlagService flags,
}) {
  final container = ProviderContainer(
    overrides: [
      authServiceProvider.overrideWith(
        () => FakeAuthService(
          initiallyLoggedIn: initiallyLoggedIn,
          stream: stream,
        ),
      ),
      babyProfileServiceProvider.overrideWithValue(babyProfile),
      localFlagServiceProvider.overrideWithValue(flags),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late MockBabyProfileService babyProfile;
  late MockLocalFlagService flags;

  setUpAll(() => registerFallbackValue(_FakeSession()));

  setUp(() {
    babyProfile = MockBabyProfileService();
    flags = MockLocalFlagService();
    // Default: returning user who already finished onboarding.
    when(flags.hasLaunched).thenReturn(true);
    when(() => babyProfile.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => babyProfile.onboardingCompleted).thenAnswer((_) async => true);
  });

  test(
    'persisted session at t=0 routes to /home and holds the brand floor',
    () async {
      // Stream never emits — proves the fast path skips the settle await, so
      // the only thing gating resolution is the brand floor itself.
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      final sw = Stopwatch()..start();
      final route = await container.read(splashControllerProvider.future);
      sw.stop();

      expect(route, '/home');
      // Acceptance: splash shows for at least the brand-floor duration. Allow a
      // small scheduler slack below the 1800ms floor.
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(1700));
    },
  );

  test(
    'session restores after t=0 (false then settle event) routes to /home',
    () async {
      // Broadcast mirrors gotrue's BehaviorSubject: both AuthService.build and
      // the controller's `.first` can subscribe to the same stream.
      final controller = StreamController<AuthState>.broadcast();
      addTearDown(controller.close);
      final container = _makeContainer(
        initiallyLoggedIn: false,
        stream: controller.stream,
        babyProfile: babyProfile,
        flags: flags,
      );

      // After the controller subscribes, the FakeAuthService updates its own
      // state on the same event — emit a logged-in settle signal.
      final future = container.read(splashControllerProvider.future);
      await Future<void>.delayed(Duration.zero);
      controller.add(_sessionEvent(loggedIn: true));

      expect(await future, '/home');
    },
  );

  test('no session: settle event with null session routes to /auth/login', () async {
    final controller = StreamController<AuthState>.broadcast();
    addTearDown(controller.close);
    final container = _makeContainer(
      initiallyLoggedIn: false,
      stream: controller.stream,
      babyProfile: babyProfile,
      flags: flags,
    );

    final future = container.read(splashControllerProvider.future);
    await Future<void>.delayed(Duration.zero);
    controller.add(_sessionEvent(loggedIn: false));

    expect(await future, '/auth/login');
  });

  test(
    'stalled restore resolves via timeout to /auth/login, never hangs',
    () async {
      // A genuine stall: a broadcast stream that never emits AND never closes,
      // so `.first` would hang forever and only `.timeout` can resolve it.
      final controller = StreamController<AuthState>.broadcast();
      addTearDown(controller.close);
      final container = _makeContainer(
        initiallyLoggedIn: false,
        stream: controller.stream,
        babyProfile: babyProfile,
        flags: flags,
      );

      final route = await container.read(splashControllerProvider.future);

      expect(route, '/auth/login');
    },
    // Resolution depends on the real ~4s settle timeout firing.
    timeout: const Timeout(Duration(seconds: 15)),
  );

  test('first launch with no session routes to /onboarding/intro', () async {
    when(flags.hasLaunched).thenReturn(false);
    final controller = StreamController<AuthState>.broadcast();
    addTearDown(controller.close);
    final container = _makeContainer(
      initiallyLoggedIn: false,
      stream: controller.stream,
      babyProfile: babyProfile,
      flags: flags,
    );

    final future = container.read(splashControllerProvider.future);
    await Future<void>.delayed(Duration.zero);
    controller.add(_sessionEvent(loggedIn: false));

    expect(await future, '/onboarding/intro');
    verify(flags.setHasLaunched).called(1);
  });

  test(
    'guarded baby read failure surfaces as SplashBootException (P0)',
    () async {
      when(
        () => babyProfile.getBaby(),
      ).thenThrow(Exception('no connectivity'));
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      await expectLater(
        container.read(splashControllerProvider.future),
        throwsA(isA<SplashBootException>()),
      );
    },
  );

  // ---------------------------------------------------------------------------
  // Redirect matrix gaps (NIB-88) — branches not covered by NIB-64 above.
  // ---------------------------------------------------------------------------

  test(
    'logged in but no baby yet routes to /onboarding/intro',
    () async {
      // Returning, logged-in user whose remote profile has no baby row.
      when(() => babyProfile.getBaby()).thenAnswer((_) async => null);
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      expect(
        await container.read(splashControllerProvider.future),
        '/onboarding/intro',
      );
      // Never reached the flag-seeding (onboarding not complete).
      verifyNever(flags.setOnboardingReadinessDone);
      verifyNever(flags.setOnboardingBabySetupDone);
    },
  );

  test(
    'baby exists but onboarding incomplete routes to /onboarding/intro',
    () async {
      when(
        () => babyProfile.onboardingCompleted,
      ).thenAnswer((_) async => false);
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      expect(
        await container.read(splashControllerProvider.future),
        '/onboarding/intro',
      );
      verifyNever(flags.setOnboardingReadinessDone);
      verifyNever(flags.setOnboardingBabySetupDone);
    },
  );

  test(
    'all good (logged in, baby, onboarding done) routes to /home and '
    'seeds onboarding flags',
    () async {
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      expect(
        await container.read(splashControllerProvider.future),
        '/home',
      );
      // Supabase truth seeds local flags so reinstalls skip onboarding.
      verify(flags.setOnboardingReadinessDone).called(1);
      verify(flags.setOnboardingBabySetupDone).called(1);
    },
  );

  test(
    'reinstall: first launch but session restored -> backfills flags, /home',
    () async {
      // app_has_launched is false (fresh install) yet the keychain restored a
      // logged-in session: boot must NOT short-circuit to intro. It marks the
      // launch flag, falls through the Supabase checks, and seeds onboarding
      // flags so the reinstalled user lands on /home.
      when(flags.hasLaunched).thenReturn(false);
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      expect(
        await container.read(splashControllerProvider.future),
        '/home',
      );
      verify(flags.setHasLaunched).called(1);
      verify(flags.setOnboardingReadinessDone).called(1);
      verify(flags.setOnboardingBabySetupDone).called(1);
    },
  );

  test(
    'guarded onboardingCompleted read failure surfaces as '
    'SplashBootException (P0)',
    () async {
      // Second guarded read (after getBaby) throwing must also be rewrapped,
      // not leaked as a raw error.
      when(
        () => babyProfile.onboardingCompleted,
      ).thenThrow(Exception('no connectivity'));
      final container = _makeContainer(
        initiallyLoggedIn: true,
        stream: const Stream.empty(),
        babyProfile: babyProfile,
        flags: flags,
      );

      await expectLater(
        container.read(splashControllerProvider.future),
        throwsA(isA<SplashBootException>()),
      );
    },
  );
}
