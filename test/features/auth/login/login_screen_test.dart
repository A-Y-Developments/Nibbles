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
    GoRoute(
      path: AppRoute.forgotPassword.path,
      name: AppRoute.forgotPassword.name,
      builder: (_, __) => const Scaffold(body: Text('Forgot stub')),
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

  testWidgets('renders BrandLogo, email + password fields, and submit', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    // Greeting copy locks the NIB-107 redesign.
    expect(find.text('Hi, Welcome!'), findsOneWidget);
  });

  testWidgets('social buttons (Google + Apple) are present', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_google_button')), findsOneWidget);
    expect(find.byKey(const Key('login_apple_button')), findsOneWidget);
  });

  testWidgets(
    'password toggle flips obscureText (eye -> eye-off icon swap)',
    (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      // Initial state: obscured -> visibility_off shown inside the password
      // field's suffix slot. Scope by ancestor to ignore unrelated icons.
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
      expect(
        iconInPasswordField(Icons.visibility_off_outlined),
        findsNothing,
      );
    },
  );

  testWidgets(
    'submit failure renders destructive caption (not red field borders)',
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
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Caption text rendered verbatim — NIB-107 deviation: caption, not
      // a red border on the field itself.
      expect(find.text('Invalid login credentials.'), findsOneWidget);
      // Fields themselves carry no errorText, so 'Please enter a valid email.'
      // (the AppTextField helper text) must NOT be present.
      expect(find.text('Please enter a valid email.'), findsNothing);
    },
  );

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

  testWidgets(
    'Apple tap calls controller.signInWithApple and logs analytics',
    (tester) async {
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
    },
  );

  testWidgets(
    'cancel-OAuth (Success(false)) shows NO error caption',
    (tester) async {
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
        containsAllInOrder([
          'login_method_selected',
          'social_login_cancelled',
        ]),
      );
    },
  );
}
