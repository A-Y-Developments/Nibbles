import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/buttons/app_round_button.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/intro/onboarding_intro_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// NIB-60 — widget tests for `OnboardingIntroScreen`.
///
/// Pins:
///   - Verbatim slide copy (eyebrow + per-slide title/body) — protects against
///     paraphrase drift on the audit-source-of-truth spec.
///   - "Let's Go" is the CTA on ALL three slides (not "Continue").
///   - Dot indicator stays in sync with the live PageView page.
///   - Slide-1 back-arrow is a visible no-op (no nav happens).
///   - Last-slide "Let's Go" calls `setHasLaunched()` AND routes to /auth/login.
GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingIntro.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingIntro.path,
      name: AppRoute.onboardingIntro.name,
      builder: (_, __) => screen,
    ),
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('LOGIN_STUB'))),
    ),
  ],
);

Widget _wrap(Widget screen, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(routerConfig: _routerFor(screen)),
);

void main() {
  late _MockLocalFlagService mockFlags;

  setUp(() {
    mockFlags = _MockLocalFlagService();
    when(mockFlags.setHasLaunched).thenAnswer((_) {});
  });

  List<Override> overrides() => [
    localFlagServiceProvider.overrideWithValue(mockFlags),
  ];

  Color dotColor(WidgetTester tester, int index) {
    final box = tester.widget<AnimatedContainer>(
      find.byKey(Key('onboarding_intro_dot_$index')),
    );
    final decoration = box.decoration! as BoxDecoration;
    return decoration.color!;
  }

  testWidgets(
    'renders eyebrow + slide-1 verbatim copy + "Let\'s Go" CTA on first paint',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const OnboardingIntroScreen(), overrides()),
      );
      await tester.pumpAndSettle();

      // Eyebrow text repeats on every slide — only one is mounted at a time.
      expect(find.text("We'll Help You with"), findsOneWidget);
      expect(find.text('Meal Prep Guidance'), findsOneWidget);
      expect(
        find.text(
          "We'll help you plan, prepare, and stay consistent with smarter "
          'daily meal choices.',
        ),
        findsOneWidget,
      );

      // CTA label is "Let's Go" — not "Continue".
      final primary = tester.widget<AppPillButton>(
        find.byKey(const Key('onboarding_intro_primary')),
      );
      expect(primary.label, "Let's Go");

      // Back-arrow is always rendered (no-op on slide 1).
      expect(find.byKey(const Key('onboarding_intro_back')), findsOneWidget);
    },
  );

  testWidgets('tapping "Let\'s Go" on slide 1 advances to slide 2', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const OnboardingIntroScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
    await tester.pumpAndSettle();

    expect(find.text('Grocery Shopping'), findsOneWidget);
    // Slide-2 "Apple" shoplist row is part of the verbatim spec.
    expect(find.byKey(const Key('onboarding_intro_apple_row')), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    // CTA label stays "Let's Go" across slides.
    final primary = tester.widget<AppPillButton>(
      find.byKey(const Key('onboarding_intro_primary')),
    );
    expect(primary.label, "Let's Go");
  });

  testWidgets('dot indicator widens the active dot in sync with the page', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const OnboardingIntroScreen(), overrides()));
    await tester.pumpAndSettle();

    // Page 0: dot 0 is the wide pill (greenDeep), 1 and 2 are muted dots.
    expect(dotColor(tester, 0), AppColors.greenDeep);
    expect(dotColor(tester, 1), AppColors.borderMuted);
    expect(dotColor(tester, 2), AppColors.borderMuted);

    // Advance to page 2 — dots shift, dot 2 becomes the active pill.
    await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
    await tester.pumpAndSettle();

    expect(dotColor(tester, 0), AppColors.borderMuted);
    expect(dotColor(tester, 1), AppColors.borderMuted);
    expect(dotColor(tester, 2), AppColors.greenDeep);
  });

  testWidgets(
    'back-arrow on slide 1 is a no-op (button rendered, page does not change)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const OnboardingIntroScreen(), overrides()),
      );
      await tester.pumpAndSettle();

      // Sanity — slide 1 visible.
      expect(find.text('Meal Prep Guidance'), findsOneWidget);

      // Button exists and is hit-testable; tap.
      final back = find.byKey(const Key('onboarding_intro_back'));
      expect(back, findsOneWidget);
      final btn = tester.widget<AppRoundButton>(back);
      expect(btn.tone, AppRoundButtonTone.butter);
      await tester.tap(back);
      await tester.pumpAndSettle();

      // Still on slide 1.
      expect(find.text('Meal Prep Guidance'), findsOneWidget);
      expect(find.text('Grocery Shopping'), findsNothing);
    },
  );

  testWidgets(
    'last-slide "Let\'s Go" flips app_has_launched and routes to /auth/login',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const OnboardingIntroScreen(), overrides()),
      );
      await tester.pumpAndSettle();

      // Advance twice to land on slide 3.
      await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
      await tester.pumpAndSettle();
      expect(find.text('Recipes & Meal Planning'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
      await tester.pumpAndSettle();

      verify(mockFlags.setHasLaunched).called(1);
      expect(find.text('LOGIN_STUB'), findsOneWidget);
    },
  );
}
