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
import 'package:nibbles/src/features/auth/register/register_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.register.path,
  routes: [
    GoRoute(path: AppRoute.register.path, builder: (_, __) => screen),
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.name,
      builder: (_, __) => const Scaffold(body: Text('Login stub')),
    ),
    GoRoute(
      path: AppRoute.onboardingBabySetup.path,
      name: AppRoute.onboardingBabySetup.name,
      builder: (_, __) =>
          const Scaffold(body: Text('Baby setup stub')),
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

  testWidgets(
    'renders Quatrefoil logo mark, email + password fields, and submit — NO name field',
    (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      // NIB-112 redesign uses the quatrefoil-only mark (no wordmark BrandLogo).
      expect(find.byType(Quatrefoil), findsOneWidget);
      expect(find.text('Start Your Journey'), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);

      // NIB-107 redesign drops the name field entirely.
      expect(find.text('Name'), findsNothing);
      expect(find.text('Full name'), findsNothing);
      expect(find.text('Your name'), findsNothing);
      expect(find.byKey(const Key('register_name_field')), findsNothing);
    },
  );

  testWidgets('social buttons (Google + Apple) are present', (tester) async {
    await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register_google_button')), findsOneWidget);
    expect(find.byKey(const Key('register_apple_button')), findsOneWidget);
  });

  testWidgets(
    'valid-email checkmark appears only when EmailInput.isValid',
    (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      Finder checkInEmailField() => find.descendant(
        of: find.byKey(const Key('register_email_field')),
        matching: find.byIcon(Icons.check_circle_rounded),
      );

      // Initial — empty field, no check.
      expect(checkInEmailField(), findsNothing);

      // Invalid input — no check.
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'not-an-email',
      );
      await tester.pump();
      expect(checkInEmailField(), findsNothing);

      // Valid input — check appears.
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'jane@example.com',
      );
      await tester.pump();
      expect(checkInEmailField(), findsOneWidget);
    },
  );

  testWidgets(
    'password toggle flips obscureText (eye -> eye-off icon swap)',
    (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      Finder iconInPasswordField(IconData icon) => find.descendant(
        of: find.byKey(const Key('register_password_field')),
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
    'Google tap calls controller.signInWithGoogle and logs analytics',
    (tester) async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(true));

      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      final googleBtn = find.byKey(const Key('register_google_button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      verify(() => mockRepo.signInWithGoogle()).called(1);
      expect(
        fakeAnalytics.eventNames,
        containsAllInOrder(['sign_up_method_selected', 'sign_up_success']),
      );
    },
  );

  testWidgets(
    'Apple tap calls controller.signInWithApple and logs analytics',
    (tester) async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Result.success(true));

      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      final appleBtn = find.byKey(const Key('register_apple_button'));
      await tester.ensureVisible(appleBtn);
      await tester.pumpAndSettle();
      await tester.tap(appleBtn);
      await tester.pumpAndSettle();

      verify(() => mockRepo.signInWithApple()).called(1);
      expect(
        fakeAnalytics.eventNames,
        containsAllInOrder(['sign_up_method_selected', 'sign_up_success']),
      );
    },
  );

  testWidgets(
    'cancel-OAuth (Success(false)) shows NO error caption',
    (tester) async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Result.success(false));

      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      final googleBtn = find.byKey(const Key('register_google_button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('failed'), findsNothing);
      expect(find.textContaining('cancel'), findsNothing);
      expect(
        fakeAnalytics.eventNames,
        containsAllInOrder([
          'sign_up_method_selected',
          'social_login_cancelled',
        ]),
      );
    },
  );

  testWidgets(
    'submit failure renders the controller error message verbatim',
    (tester) async {
      when(() => mockRepo.signUp(any(), any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('Email already in use.')),
      );

      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      // Submit button is gated on isValid — enter a valid email + 8+ char pw.
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'jane@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'password123',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email already in use.'), findsOneWidget);
    },
  );

  testWidgets(
    'renders verbatim Figma copy — title, body, social labels, footer link',
    (tester) async {
      await tester.pumpWidget(_wrap(const RegisterScreen(), buildOverrides()));
      await tester.pumpAndSettle();

      expect(find.text('Start Your Journey'), findsOneWidget);
      expect(
        find.text(
          "Create an account to track your baby's\n"
          'nutrition and feeding progress.',
        ),
        findsOneWidget,
      );
      expect(find.text('Email address'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Or sign up with'), findsOneWidget);
      expect(find.text('Sign Up with Google'), findsOneWidget);
      expect(find.text('Sign Up with Apple Account'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    },
  );
}
