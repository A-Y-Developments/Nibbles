import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/feedback/app_toast.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';
import '../../../support/supabase_test_env.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

// ---------------------------------------------------------------------------
// Router + widget helper
// ---------------------------------------------------------------------------

GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.resetPassword.path,
  routes: [
    GoRoute(path: AppRoute.resetPassword.path, builder: (_, __) => screen),
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

  // The screen reads `Supabase.instance` directly to pick home vs login after
  // a successful reset. Boot a no-persistence Supabase singleton so that read
  // returns a null session (→ login route) instead of throwing.
  setUpAll(ensureTestSupabaseInitialized);

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

  testWidgets('renders 2 obscured password fields and a Confirm CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const ResetPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset_password_new_field')), findsOneWidget);
    expect(
      find.byKey(const Key('reset_password_confirm_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reset_password_submit_button')),
      findsOneWidget,
    );
    final pill = tester.widget<AppPillButton>(
      find.byKey(const Key('reset_password_submit_button')),
    );
    expect(pill.label, 'Confirm');

    // Both visible TextField inputs are obscured (production has no
    // visibility toggle here — see PR body NOTE for spec deviation).
    final textFields = tester.widgetList<TextField>(
      find.descendant(
        of: find.byKey(const Key('reset_password_new_field')),
        matching: find.byType(TextField),
      ),
    );
    expect(textFields, isNotEmpty);
    for (final tf in textFields) {
      expect(tf.obscureText, isTrue);
    }
  });

  testWidgets('shows guidance helper under both fields in the initial state '
      '(Figma 971:10136)', (tester) async {
    await tester.pumpWidget(
      _wrap(const ResetPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Password must be at least 8 characters'),
      findsNWidgets(3),
    );
  });

  testWidgets(
    'shows "Password is too short" under both fields when password is short '
    '(Figma 971:10148)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const ResetPasswordScreen(), buildOverrides()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_password_new_field')),
        'short',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_confirm_field')),
        'short',
      );
      await tester.pump();

      expect(find.text('Password is too short'), findsNWidgets(2));
    },
  );

  testWidgets(
    "shows \"Password doesn't match\" helper on retype when values differ "
    '(Figma 971:10160)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const ResetPasswordScreen(), buildOverrides()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_password_new_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_confirm_field')),
        'mismatch456',
      );
      await tester.pump();

      expect(find.text("Password doesn't match"), findsOneWidget);
    },
  );

  testWidgets('success on submit redirects to the login route', (tester) async {
    when(
      () => mockRepo.updatePassword(any()),
    ).thenAnswer((_) async => const Result.success(null));

    await tester.pumpWidget(
      _wrap(const ResetPasswordScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('reset_password_new_field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('reset_password_confirm_field')),
      'password123',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('reset_password_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Login stub'), findsOneWidget);

    // AppToast starts a 3s auto-dismiss Timer; must advance past it before
    // the test ends.
    await tester.pump(kAppToastDuration + const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets(
    'backend failure (e.g. expired token) surfaces the error message inline '
    '(P1) and stays on the reset screen',
    (tester) async {
      when(() => mockRepo.updatePassword(any())).thenAnswer(
        (_) async =>
            const Result.failure(ServerException('Reset link has expired.')),
      );

      await tester.pumpWidget(
        _wrap(const ResetPasswordScreen(), buildOverrides()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_password_new_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('reset_password_confirm_field')),
        'password123',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('reset_password_submit_button')));
      await tester.pumpAndSettle();

      // Backend message shown verbatim; no navigation away from the screen.
      expect(find.text('Reset link has expired.'), findsOneWidget);
      expect(find.text('Login stub'), findsNothing);
    },
  );
}
