// Widget tests for the multi-day Add-to-Meal-Plan bottom sheet
// (NIB-84 Figma 971:9346 / 971:9481).
//
// Drives `showAddToMealPlanSheet(context, babyId: ...)` and asserts:
//   * the sheet renders the verbatim 'Meal Plan' title + 'X selected' counter
//   * the bottom CTA flips between 'Add to Meal Plan' (disabled, 0 days) and
//     'X Days Selected' (forest-dark, enabled)
//   * tapping a day-row 'Add' button toggles selection
//   * confirm pops the sheet with a Set<DateTime> of the picked days
//   * the native showDatePicker IS NOT used by this sheet (no DialogRoute)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart';

const _babyId = 'baby-001';

/// Opens the multi-day sheet and returns its pending result Future.
Future<Future<Set<DateTime>?>> _openSheet(WidgetTester tester) async {
  late Future<Set<DateTime>?> pending;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                pending = showAddToMealPlanSheet(context, babyId: _babyId);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  return pending;
}

Future<void> _setupViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Locates the bottom CTA AppPillButton (`Add to Meal Plan` or
/// `N Day(s) Selected`).
Finder _ctaFinder() => find.byWidgetPredicate(
  (w) =>
      w is AppPillButton &&
      (w.label == 'Add to Meal Plan' ||
          w.label.endsWith('Day Selected') ||
          w.label.endsWith('Days Selected')),
);

void main() {
  group('AddToMealPlanSheet — initial render', () {
    testWidgets(
      'shows "Meal Plan" title, "0 selected" counter, and disabled CTA',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        expect(find.text('Meal Plan'), findsOneWidget);
        expect(find.text('0 selected'), findsOneWidget);
        expect(find.text('Add to Meal Plan'), findsOneWidget);

        final cta = tester.widget<AppPillButton>(_ctaFinder());
        expect(cta.onPressed, isNull);
      },
    );

    testWidgets(
      'the default-expanded day row exposes an "Add" pill button',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        // The first day row is expanded by default → "Add" pill is visible.
        expect(find.widgetWithText(AppPillButton, 'Add'), findsOneWidget);
      },
    );
  });

  group('AddToMealPlanSheet — counter + CTA gating', () {
    testWidgets(
      'tapping the day "Add" pill toggles the counter and enables the CTA',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        await tester.tap(find.widgetWithText(AppPillButton, 'Add'));
        await tester.pump();

        expect(find.text('1 selected'), findsOneWidget);
        // CTA flips to "1 Day Selected" (singular) once a day is picked.
        expect(find.text('1 Day Selected'), findsOneWidget);

        final cta = tester.widget<AppPillButton>(_ctaFinder());
        expect(cta.onPressed, isNotNull);
      },
    );

    testWidgets(
      'toggling the same day twice → counter returns to 0 + CTA disabled',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        await tester.tap(find.widgetWithText(AppPillButton, 'Add'));
        await tester.pump();
        expect(find.text('1 selected'), findsOneWidget);

        // After selection the pill label flips to "Added".
        await tester.tap(find.widgetWithText(AppPillButton, 'Added'));
        await tester.pump();
        expect(find.text('0 selected'), findsOneWidget);
        expect(find.text('Add to Meal Plan'), findsOneWidget);

        final cta = tester.widget<AppPillButton>(_ctaFinder());
        expect(cta.onPressed, isNull);
      },
    );
  });

  group('AddToMealPlanSheet — confirm flow', () {
    testWidgets(
      'confirm with 3 days → Navigator.pop returns Set<DateTime> of 3 entries',
      (tester) async {
        await _setupViewport(tester);
        final pending = await _openSheet(tester);

        // Pick day 0 (default-expanded).
        // (Day-0 chevron is keyboard_arrow_up; days 1..13 are
        // keyboard_arrow_down, listed in tree order.)
        await tester.tap(find.widgetWithText(AppPillButton, 'Add'));
        await tester.pumpAndSettle(const Duration(milliseconds: 220));

        // Expand day 1 — at this point chevron-down list is
        // [day1, day2, ..., day13], so .first is day1.
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
        await tester.pumpAndSettle(const Duration(milliseconds: 220));
        await tester.tap(find.widgetWithText(AppPillButton, 'Add'));
        await tester.pumpAndSettle(const Duration(milliseconds: 220));

        // Expand day 2 — chevron-down list is now [day0, day2, ..., day13],
        // so day2 is at(1).
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down).at(1));
        await tester.pumpAndSettle(const Duration(milliseconds: 220));
        await tester.tap(find.widgetWithText(AppPillButton, 'Add'));
        await tester.pumpAndSettle(const Duration(milliseconds: 220));

        expect(find.text('3 selected'), findsOneWidget);
        expect(find.text('3 Days Selected'), findsOneWidget);

        // Tap the CTA pill — its label is the verbatim "3 Days Selected".
        await tester.tap(find.widgetWithText(AppPillButton, '3 Days Selected'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        final picked = await pending;
        expect(picked, isNotNull);
        expect(picked, hasLength(3));
      },
    );

    testWidgets('native showDatePicker is NEVER mounted by this sheet', (
      tester,
    ) async {
      await _setupViewport(tester);
      await _openSheet(tester);

      // The Material native date picker uses CalendarDatePicker; assert it
      // is NOT present in the tree.
      expect(find.byType(CalendarDatePicker), findsNothing);
      expect(find.byType(DatePickerDialog), findsNothing);
    });
  });
}
