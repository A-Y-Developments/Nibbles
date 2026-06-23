import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/intro/onboarding_intro_screen.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// NIB-60 — widget tests for `OnboardingIntroScreen`.
///
/// Pins:
///   - Eyebrow + slide-1 verbatim copy on first paint.
///   - "Let's Go!" is the single CTA.
///   - Tapping "Let's Go!" flips `app_has_launched` AND routes to /auth/login
///     immediately (no per-slide stepping — slides auto-advance on their own).
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

  testWidgets('renders eyebrow + slide-1 verbatim copy + "Let\'s Go!" CTA', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const OnboardingIntroScreen(), overrides()));
    await tester.pumpAndSettle();

    expect(find.text("We'll Help You with"), findsOneWidget);
    expect(find.text('Meal Prep Guidance'), findsOneWidget);
    expect(
      find.text(
        "We'll help you plan, prepare, and stay consistent with smarter "
        'daily meal choices.',
      ),
      findsOneWidget,
    );

    final primary = tester.widget<AppPillButton>(
      find.byKey(const Key('onboarding_intro_primary')),
    );
    expect(primary.label, "Let's Go!");
  });

  testWidgets('"Let\'s Go!" flips app_has_launched and routes to /auth/login', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const OnboardingIntroScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_intro_primary')));
    await tester.pumpAndSettle();

    verify(mockFlags.setHasLaunched).called(1);
    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });
}
