import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/onboarding/name/onboarding_name_screen.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

/// NIB-105 — widget tests for `OnboardingNameScreen` (NIB-66).
///
/// Pins:
///   - destructive caption ("You must fill the name") AFTER the field is
///     dirtied and emptied — never on a fresh paint.
///   - Next CTA is disabled until first-name is valid.
///   - Tapping Next pushes the concatenated `'First Last'.trim()` to
///     `OnboardingController.updateName`.
GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingName.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingName.path,
      name: AppRoute.onboardingName.name,
      builder: (_, __) => screen,
    ),
    GoRoute(
      path: AppRoute.onboardingDob.path,
      name: AppRoute.onboardingDob.name,
      builder: (_, __) => const Scaffold(body: Center(child: Text('DOB_STUB'))),
    ),
  ],
);

Widget _wrap({required Widget screen, List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _routerFor(screen)),
    );

void main() {
  testWidgets('renders both fields + disabled Next on first paint', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(screen: const OnboardingNameScreen()));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('onboarding_first_name_field')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('onboarding_last_name_field')), findsOneWidget);

    // Next CTA exists but is disabled — AppPillButton renders Material with no
    // onPressed; assert via the widget's `onPressed` rather than visual color
    // (decoration changes are kit-coupled and brittle).
    final nextBtnFinder = find.byKey(const Key('onboarding_name_next'));
    final btn = tester.widget<AppPillButton>(nextBtnFinder);
    expect(btn.onPressed, isNull);

    // Caption: not shown until the field has been dirtied (NIB-66 contract).
    expect(find.text('You must fill the name'), findsNothing);
  });

  testWidgets(
    'destructive caption appears AFTER user types + clears the first name',
    (tester) async {
      await tester.pumpWidget(_wrap(screen: const OnboardingNameScreen()));
      await tester.pumpAndSettle();

      // Type then clear: _firstDirty flips on first change; validator catches
      // empty -> caption shows.
      await tester.enterText(
        find.byKey(const Key('onboarding_first_name_field')),
        'L',
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('onboarding_first_name_field')),
        '',
      );
      await tester.pump();

      final caption = find.text('You must fill the name');
      expect(caption, findsOneWidget);
      final captionText = tester.widget<Text>(caption);
      expect(captionText.style?.color, AppColors.destructive);

      // CTA stays disabled in the empty/invalid state.
      final btn = tester.widget<AppPillButton>(
        find.byKey(const Key('onboarding_name_next')),
      );
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets(
    'tapping Next stores "First Last".trim() on the hoisted controller and '
    'navigates to /onboarding/dob',
    (tester) async {
      // Pre-seed a container so we can read state post-nav and inject the same
      // container into the ProviderScope override.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _routerFor(const OnboardingNameScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('onboarding_first_name_field')),
        '  Lily  ',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_last_name_field')),
        '  Putra  ',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('onboarding_name_next')));
      await tester.pumpAndSettle();

      // Controller stores the trimmed + joined string.
      expect(
        container.read(onboardingControllerProvider).babyName.value,
        'Lily Putra',
      );
      // Navigation actually fired -> DOB stub rendered.
      expect(find.text('DOB_STUB'), findsOneWidget);
    },
  );

  testWidgets(
    'last name omitted -> only first name persisted (no trailing space)',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _routerFor(const OnboardingNameScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('onboarding_first_name_field')),
        'Lily',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding_name_next')));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingControllerProvider).babyName.value,
        'Lily',
      );
    },
  );
}
