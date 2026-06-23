import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/login/login_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.login.path,
  routes: [
    GoRoute(path: AppRoute.login.path, builder: (_, __) => screen),
    GoRoute(
      path: AppRoute.register.path,
      name: AppRoute.register.name,
      builder: (_, __) => const Scaffold(body: Text('Register stub')),
    ),
  ],
);

Widget _wrap(Widget screen, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(routerConfig: _routerFor(screen)),
);

void main() {
  late MockAuthRepository mockRepo;
  late MockLocalFlagService mockFlags;
  late FakeAnalytics fakeAnalytics;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockFlags = MockLocalFlagService();
    fakeAnalytics = FakeAnalytics();
    when(() => mockRepo.isLoggedIn).thenReturn(false);
    when(
      () => mockRepo.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(mockFlags.isOnboardingBabySetupDone).thenReturn(true);
  });

  List<Override> buildOverrides() => [
    authRepositoryProvider.overrideWithValue(mockRepo),
    localFlagServiceProvider.overrideWithValue(mockFlags),
    analyticsProvider.overrideWithValue(fakeAnalytics),
  ];

  // -------------------------------------------------------------------------
  // State 1 — empty
  // -------------------------------------------------------------------------

  testWidgets(
    'empty state — brand mark, verbatim copy, both input fields, primary CTA',
    (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      // Brand mark is the Quatrefoil (NIB-107 swapped the lockup for the
      // bare butter mark per Figma node 1015:13496).
      expect(find.byType(Quatrefoil), findsOneWidget);

      // Verbatim copy per Figma — smart apostrophes intentional.
      expect(find.text('Hi, Welcome!'), findsOneWidget);
      expect(
        find.text('Login to continue tracking your\nbaby’s healthy growth.'),
        findsOneWidget,
      );
      expect(find.text('Email address'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Or login with'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.text('Don’t have an account?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Keys for downstream wiring.
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('login_google_button')), findsOneWidget);
      expect(find.byKey(const Key('login_apple_button')), findsOneWidget);
      expect(find.byKey(const Key('login_signup_link')), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // State 2 — filled / focus
  // -------------------------------------------------------------------------

  testWidgets(
    'filled state — typing in both inputs keeps the eye toggle visible '
    'and flips obscureText on tap',
    (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'tuffahati128@gmail.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'supersecret',
      );
      await tester.pump();

      Finder iconInPasswordField(IconData icon) => find.descendant(
        of: find.byKey(const Key('login_password_field')),
        matching: find.byIcon(icon),
      );

      expect(
        iconInPasswordField(Icons.visibility_off_outlined),
        findsOneWidget,
      );
      expect(iconInPasswordField(Icons.visibility_outlined), findsNothing);

      await tester.tap(iconInPasswordField(Icons.visibility_off_outlined));
      await tester.pump();

      expect(iconInPasswordField(Icons.visibility_outlined), findsOneWidget);
      expect(iconInPasswordField(Icons.visibility_off_outlined), findsNothing);
    },
  );

  // -------------------------------------------------------------------------
  // State 3 — auth error
  // -------------------------------------------------------------------------

  testWidgets(
    'error state — submit failure renders the Supabase error verbatim '
    'under the password input (hardcoded copy is replaced by the live '
    'backend message per project P1 rule)',
    (tester) async {
      when(() => mockRepo.signIn(any(), any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('Invalid login credentials.')),
      );

      await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'jane@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'badpassword',
      );
      // CTA is gated on canSubmit — pump so the rebuilt (enabled) button
      // receives the tap.
      await tester.pump();
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockRepo.signIn('jane@example.com', 'badpassword'),
      ).called(1);

      // Error caption renders once, under the password field.
      expect(find.text('Invalid login credentials.'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // Social auth paths
  // -------------------------------------------------------------------------

  testWidgets(
    'Google tap calls controller.signInWithGoogle and logs analytics',
    (tester) async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(true));

      await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      final googleBtn = find.byKey(const Key('login_google_button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      verify(() => mockRepo.signInWithGoogle()).called(1);
      expect(
        fakeAnalytics.eventNames,
        containsAllInOrder(['login_method_selected', 'login_success']),
      );
    },
  );

  testWidgets('Apple tap calls controller.signInWithApple and logs analytics', (
    tester,
  ) async {
    when(
      () => mockRepo.signInWithApple(),
    ).thenAnswer((_) async => const Result.success(true));

    await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    final appleBtn = find.byKey(const Key('login_apple_button'));
    await tester.ensureVisible(appleBtn);
    await tester.pumpAndSettle();
    await tester.tap(appleBtn);
    await tester.pumpAndSettle();

    verify(() => mockRepo.signInWithApple()).called(1);
    expect(
      fakeAnalytics.eventNames,
      containsAllInOrder(['login_method_selected', 'login_success']),
    );
  });

  testWidgets('cancel-OAuth (Success(false)) shows NO error caption', (
    tester,
  ) async {
    when(
      () => mockRepo.signInWithGoogle(),
    ).thenAnswer((_) async => const Result.success(false));

    await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    final googleBtn = find.byKey(const Key('login_google_button'));
    await tester.ensureVisible(googleBtn);
    await tester.pumpAndSettle();
    await tester.tap(googleBtn);
    await tester.pumpAndSettle();

    // Nothing in the destructive caption slot — controller stays clean.
    expect(find.textContaining('failed'), findsNothing);
    expect(find.textContaining('cancel'), findsNothing);
    // Cancellation logs the cancel event (no error UI).
    expect(
      fakeAnalytics.eventNames,
      containsAllInOrder(['login_method_selected', 'social_login_cancelled']),
    );
  });

  // -------------------------------------------------------------------------
  // Sign Up footer navigation
  // -------------------------------------------------------------------------

  testWidgets('Sign Up link navigates to the register route', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    final signUp = find.byKey(const Key('login_signup_link'));
    await tester.ensureVisible(signUp);
    await tester.pumpAndSettle();
    await tester.tap(signUp);
    await tester.pumpAndSettle();

    expect(find.text('Register stub'), findsOneWidget);
  });
}
