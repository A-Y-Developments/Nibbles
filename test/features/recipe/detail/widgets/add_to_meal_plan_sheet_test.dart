// Widget tests for the multi-day Add-to-Meal-Plan bottom sheet (NIB-68).
//
// Drives `showAddToMealPlanSheet(context, babyId: ...)` and asserts:
//   * the sheet shows the 'X Days Selected' counter and an 'Add to Meal Plan'
//     CTA
//   * the counter updates as day rows are toggled
//   * the CTA is disabled when 0 days are selected
//   * confirm pops the sheet with a Set<DateTime> of the picked days
//   * the native showDatePicker IS NOT used by this sheet (no DialogRoute)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/controls/app_checkbox.dart';
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

void main() {
  group('AddToMealPlanSheet — initial render', () {
    testWidgets(
      'shows the counter (0 Days Selected) + Add to Meal Plan CTA disabled',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        expect(find.text('Add to Meal Plan'), findsWidgets);
        expect(find.text('0 Days Selected'), findsOneWidget);

        // CTA AppPillButton — onPressed null when count == 0.
        final cta = tester.widget<AppPillButton>(find.byType(AppPillButton));
        expect(cta.onPressed, isNull);
      },
    );

    testWidgets(
      'current week is expanded by default → first day rows visible',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        // The default-expanded week has 7 day-row checkboxes.
        expect(find.byType(AppCheckbox), findsAtLeastNWidgets(7));
      },
    );
  });

  group('AddToMealPlanSheet — counter + CTA gating', () {
    testWidgets(
      'tapping a future day toggles the counter and enables the CTA',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        // Pick a future-dated day row — the first week is current; use a row
        // far enough out that it's in the future. Tap the LAST visible day row
        // (typically Sunday of the current week, which is at-or-after today).
        // To minimise flakiness across days-of-week we tap the last checkbox.
        await tester.tap(find.byType(AppCheckbox).last);
        await tester.pump();

        expect(find.text('1 Day Selected'), findsOneWidget);

        final cta = tester.widget<AppPillButton>(find.byType(AppPillButton));
        expect(cta.onPressed, isNotNull);
      },
    );

    testWidgets(
      'toggling the same day twice → counter returns to 0 + CTA disabled',
      (tester) async {
        await _setupViewport(tester);
        await _openSheet(tester);

        await tester.tap(find.byType(AppCheckbox).last);
        await tester.pump();
        expect(find.text('1 Day Selected'), findsOneWidget);

        await tester.tap(find.byType(AppCheckbox).last);
        await tester.pump();
        expect(find.text('0 Days Selected'), findsOneWidget);

        final cta = tester.widget<AppPillButton>(find.byType(AppPillButton));
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

        // Collapse the current week (some of whose rows may be past-dated
        // depending on today's weekday) and expand the NEXT week so every
        // day-row is guaranteed to be in the future and selectable.
        // Every WeekAccordion renders an Icons.expand_more chevron;
        // tapping the SECOND one switches the expansion to week index 1.
        await tester.tap(find.byIcon(Icons.expand_more).at(1));
        await tester.pumpAndSettle(const Duration(milliseconds: 220));

        // Now exactly 7 future-dated day-rows are visible. Pick the first 3.
        await tester.tap(find.byType(AppCheckbox).at(0));
        await tester.pump();
        await tester.tap(find.byType(AppCheckbox).at(1));
        await tester.pump();
        await tester.tap(find.byType(AppCheckbox).at(2));
        await tester.pump();
        expect(find.text('3 Days Selected'), findsOneWidget);

        // Tap the CTA pill — its label is exactly 'Add to Meal Plan'. There
        // are two widgets carrying that text (header title + button), so
        // tap the AppPillButton specifically.
        await tester.tap(find.byType(AppPillButton));
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
