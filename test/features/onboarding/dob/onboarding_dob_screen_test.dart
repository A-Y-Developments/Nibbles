import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/onboarding/dob/onboarding_dob_screen.dart';
import 'package:nibbles/src/features/onboarding/onboarding_controller.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockLocalFlagService extends Mock implements LocalFlagService {}

/// NIB-74 — widget tests for `OnboardingDobScreen`.
///
/// Pins:
///   - Title interpolates the captured baby first name (not literal "Oliver").
///   - Body subtitle copy is verbatim from Figma.
///   - Default age preview reads "6 Months" out of the box (no stored DOB).
///   - Age chip updates live as a wheel scrolls.
///   - Tapping Next persists the picked DOB onto the hoisted controller,
///     flips the phase-A `onboarding_baby_setup_done` flag, and navigates to
///     `/onboarding/readiness`.
GoRouter _routerFor(Widget screen) => GoRouter(
  initialLocation: AppRoute.onboardingDob.path,
  routes: [
    GoRoute(
      path: AppRoute.onboardingDob.path,
      name: AppRoute.onboardingDob.name,
      builder: (_, __) => screen,
    ),
    GoRoute(
      path: AppRoute.onboardingReadiness.path,
      name: AppRoute.onboardingReadiness.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('READINESS_STUB'))),
    ),
    GoRoute(
      path: AppRoute.onboardingName.path,
      name: AppRoute.onboardingName.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('NAME_STUB'))),
    ),
  ],
);

ProviderContainer _makeContainer({
  required LocalFlagService flags,
  String babyName = 'Lily',
}) {
  final container = ProviderContainer(
    overrides: [localFlagServiceProvider.overrideWithValue(flags)],
  );
  addTearDown(container.dispose);
  container.read(onboardingControllerProvider.notifier).updateName(babyName);
  return container;
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: _routerFor(const OnboardingDobScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockLocalFlagService flags;

  setUp(() {
    flags = _MockLocalFlagService();
    when(flags.setOnboardingBabySetupDone).thenAnswer((_) async {});
  });

  testWidgets(
    'renders title with captured first name + verbatim body subtitle + '
    'default "6 Months" age chip',
    (tester) async {
      final container = _makeContainer(flags: flags, babyName: 'Lily Putra');
      await _pumpScreen(tester, container: container);

      // Title is composed via Text.rich — assert each span verbatim.
      expect(find.textContaining('When was '), findsOneWidget);
      expect(find.textContaining('Lily'), findsOneWidget);
      expect(find.textContaining(' born?'), findsOneWidget);

      // Body subtitle (verbatim).
      expect(
        find.text('We use this to suggest the right foods at the right time.'),
        findsOneWidget,
      );

      // Default DOB is 6 months ago → chip reads "6 Months".
      final chip = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('onboarding_dob_age_label')),
          matching: find.byType(Text),
        ),
      );
      expect(chip.data, '6 Months');
    },
  );

  testWidgets('age chip updates when the year wheel scrolls', (tester) async {
    final container = _makeContainer(flags: flags);
    await _pumpScreen(tester, container: container);

    // Drag the YEAR wheel down so the centered item moves to an EARLIER year
    // (older baby). Item extent is 44px; 88px ≈ 2 yrs back. We assert the
    // chip moved off the default "6 Months", not the precise value (depends
    // on today's date and clamp behavior).
    await tester.drag(
      find.byKey(const Key('onboarding_dob_year_wheel')),
      const Offset(0, 88),
    );
    await tester.pumpAndSettle();

    final chip = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('onboarding_dob_age_label')),
        matching: find.byType(Text),
      ),
    );
    expect(chip.data, isNot('6 Months'));
    expect(chip.data, isNot('Less than a month'));
  });

  testWidgets('Next persists the picked DOB, flips onboarding_baby_setup_done, '
      'navigates to /onboarding/readiness', (tester) async {
    final container = _makeContainer(flags: flags);
    await _pumpScreen(tester, container: container);

    // Tap Next without scrolling — default DOB (≈ 6 months ago) is valid.
    await tester.tap(find.byKey(const Key('onboarding_dob_next')));
    await tester.pumpAndSettle();

    // Controller has a DOB stored.
    final dob = container.read(onboardingControllerProvider).dob;
    expect(dob, isNotNull);

    // Flag flip fired exactly once.
    verify(flags.setOnboardingBabySetupDone).called(1);

    // Navigation landed on the readiness stub.
    expect(find.text('READINESS_STUB'), findsOneWidget);
  });

  testWidgets(
    'Back button navigates to /onboarding/name when no pop target exists',
    (tester) async {
      final container = _makeContainer(flags: flags);
      await _pumpScreen(tester, container: container);

      await tester.tap(find.byKey(const Key('onboarding_dob_back')));
      await tester.pumpAndSettle();

      expect(find.text('NAME_STUB'), findsOneWidget);
    },
  );

  testWidgets(
    'pre-seeded DOB from controller pre-positions the wheels to that date',
    (tester) async {
      // A DOB ~12 months ago should render "12 Months" on first paint.
      final twelveMonthsAgo = () {
        final now = DateTime.now();
        var year = now.year;
        var month = now.month - 12;
        while (month <= 0) {
          month += 12;
          year -= 1;
        }
        return DateTime(year, month, now.day);
      }();

      final container = _makeContainer(flags: flags);
      container
          .read(onboardingControllerProvider.notifier)
          .updateDob(twelveMonthsAgo);

      await _pumpScreen(tester, container: container);

      final chip = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('onboarding_dob_age_label')),
          matching: find.byType(Text),
        ),
      );
      expect(chip.data, '12 Months');
    },
  );

  testWidgets('renders three column headers and three wheels', (tester) async {
    final container = _makeContainer(flags: flags);
    await _pumpScreen(tester, container: container);

    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);

    expect(find.byType(CupertinoPicker), findsNWidgets(3));
    expect(find.byKey(const Key('onboarding_dob_year_wheel')), findsOneWidget);
    expect(find.byKey(const Key('onboarding_dob_month_wheel')), findsOneWidget);
    expect(find.byKey(const Key('onboarding_dob_day_wheel')), findsOneWidget);

    // Next CTA renders.
    expect(
      tester.widget<AppPillButton>(
        find.byKey(const Key('onboarding_dob_next')),
      ),
      isNotNull,
    );
  });

  testWidgets('selection lime band renders BEHIND the picker text, not over it '
      '(no opaque selectionOverlay)', (tester) async {
    final container = _makeContainer(flags: flags);
    await _pumpScreen(tester, container: container);

    final wheel = find.byKey(const Key('onboarding_dob_year_wheel'));

    // The CupertinoPicker no longer paints an opaque selectionOverlay —
    // it is an empty SizedBox so the value text stays legible.
    final picker = tester.widget<CupertinoPicker>(
      find.descendant(of: wheel, matching: find.byType(CupertinoPicker)),
    );
    expect(picker.selectionOverlay, isA<SizedBox>());

    // A lime band Container sits inside the same column as a sibling of the
    // picker (the background pill). Match by its lime decoration color.
    final limeBand = find.descendant(
      of: wheel,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == AppColors.lime,
      ),
    );
    expect(limeBand, findsOneWidget);

    // The selected value text (greenDeep) still renders.
    final selectedText = find.descendant(
      of: wheel,
      matching: find.byWidgetPredicate(
        (w) => w is Text && w.style?.color == AppColors.greenDeep,
      ),
    );
    expect(selectedText, findsWidgets);
  });
}
