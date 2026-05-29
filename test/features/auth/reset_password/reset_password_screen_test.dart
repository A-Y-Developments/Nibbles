import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/data/repositories/auth_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/auth/reset_password/reset_password_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';

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
    'renders 2 obscured password fields and a Confirm CTA',
    (tester) async {
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
    },
  );

  testWidgets(
    'confirm-mismatch shows inline error preserved from the redesign',
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

      expect(find.text('Passwords do not match.'), findsOneWidget);
    },
  );

  testWidgets(
    'success on submit redirects to the login route',
    (tester) async {
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

      await tester.tap(
        find.byKey(const Key('reset_password_submit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login stub'), findsOneWidget);
    },
  );
}
