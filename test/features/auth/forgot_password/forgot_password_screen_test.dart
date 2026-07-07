import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/forgot_password/forgot_password_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.forgotPassword.path,
  routes: [
    GoRoute(path: AppRoute.forgotPassword.path, builder: (_, __) => screen),
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.name,
      builder: (_, __) => const Scaffold(body: Text('Login stub')),
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
    'renders butter back pill (top-left), email field, and bottom Confirm CTA',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const ForgotPasswordScreen(), buildOverrides()),
      );
      await tester.pumpAndSettle();

      // Back pill — the first-nibbles rebuild renders an InkWell pill with the
      // back arrow + a 'Back' semantics label (no AppRoundButton).
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Email field present.
      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);

      // Bottom-pinned Confirm CTA.
      expect(find.byKey(const Key('forgot_submit_button')), findsOneWidget);
      final pillButton = tester.widget<AppPillButton>(
        find.byKey(const Key('forgot_submit_button')),
      );
      expect(pillButton.label, 'Confirm');
    },
  );

  testWidgets('tapping back pill pops back to the previous route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoute.login.path,
      routes: [
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (_, __) => const Scaffold(body: Text('Login stub')),
        ),
        GoRoute(
          path: AppRoute.forgotPassword.path,
          name: AppRoute.forgotPassword.name,
          builder: (_, __) => const ForgotPasswordScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildOverrides(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(router.pushNamed(AppRoute.forgotPassword.name));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Real flow reaches this screen via push, so back must pop to login.
    expect(find.text('Login stub'), findsOneWidget);
  });

  testWidgets('submit failure renders GENERIC enumeration-safe caption '
      '(never "email not found")', (tester) async {
    when(() => mockRepo.resetPassword(any())).thenAnswer(
      // Whatever the backend returns — even a leaky "User not found" —
      // the screen must collapse it into the generic message.
      (_) async => const Result.failure(ServerException('User not found.')),
    );

    await tester.pumpWidget(
      _wrap(const ForgotPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('forgot_email_field')),
      'jane@example.com',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('forgot_submit_button')));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't send the reset link. Please try again."),
      findsOneWidget,
    );
    // Enumeration safety: must NOT leak whether the email exists.
    expect(find.textContaining('not found'), findsNothing);
    expect(find.textContaining("doesn't exist"), findsNothing);
  });

  // NIB-200 — client-side validation: empty/malformed input shows the specific
  // validation caption, NOT the generic backend-failure caption, and never
  // reaches the backend.
  testWidgets(
    'empty email + Confirm shows the validation caption (not generic)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const ForgotPasswordScreen(), buildOverrides()),
      );
      await tester.pumpAndSettle();

      // Submit with the field left empty.
      await tester.tap(find.byKey(const Key('forgot_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(
        find.text("Couldn't send the reset link. Please try again."),
        findsNothing,
      );
      verifyNever(() => mockRepo.resetPassword(any()));
    },
  );

  testWidgets('malformed email + Confirm shows the validation caption', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const ForgotPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('forgot_email_field')),
      'notanemail',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('forgot_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(
      find.text("Couldn't send the reset link. Please try again."),
      findsNothing,
    );
    verifyNever(() => mockRepo.resetPassword(any()));
  });

  testWidgets('success transitions to the confirmation sub-view '
      '(check-your-email + back-to-login)', (tester) async {
    when(
      () => mockRepo.resetPassword(any()),
    ).thenAnswer((_) async => const Result.success(null));

    await tester.pumpWidget(
      _wrap(const ForgotPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('forgot_email_field')),
      'jane@example.com',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('forgot_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.byKey(const Key('forgot_back_to_login')), findsOneWidget);
    // Input view is gone.
    expect(find.byKey(const Key('forgot_email_field')), findsNothing);
    expect(find.byKey(const Key('forgot_submit_button')), findsNothing);
  });

  testWidgets('email field disables autocorrect + suggestions', (tester) async {
    await tester.pumpWidget(
      _wrap(const ForgotPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('forgot_email_field')),
        matching: find.byType(TextField),
      ),
    );
    expect(textField.autocorrect, isFalse);
    expect(textField.enableSuggestions, isFalse);
  });
}
