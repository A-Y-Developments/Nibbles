import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/inline_calendar.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_empty_state.dart';

Future<void> _pump(
  WidgetTester tester, {
  required String babyName,
  ValueChanged<DateTimeRange>? onCreate,
}) async {
  // Give the screen extra height so the CTA + calendars fit in the viewport
  // without scrolling — keeps taps deterministic.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MealPlanEmptyState(
          babyName: babyName,
          onCreateMealPlan: onCreate ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('MealPlanEmptyState', () {
    testWidgets('renders babyName in copy', (tester) async {
      await _pump(tester, babyName: 'Lily');
      expect(find.textContaining("Lily's meals"), findsOneWidget);
      expect(find.text('Ready to start?'), findsOneWidget);
    });

    testWidgets('CTA is disabled until both start and end are set', (
      tester,
    ) async {
      await _pump(tester, babyName: 'Lily');

      final cta = find.widgetWithText(AppPillButton, 'Create meal plan');
      expect(cta, findsOneWidget);

      // Initially disabled (no dates picked).
      expect(tester.widget<AppPillButton>(cta).onPressed, isNull);

      // Tap Start Date hint → inline calendar appears.
      await tester.tap(find.text('Select start date'));
      await tester.pumpAndSettle();
      expect(find.byType(InlineCalendar), findsOneWidget);

      // Pick day 10 → start date set, calendar closes.
      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();
      // CTA still disabled (end not set).
      expect(tester.widget<AppPillButton>(cta).onPressed, isNull);
    });

    testWidgets('tapping a date field opens the inline calendar', (
      tester,
    ) async {
      await _pump(tester, babyName: 'Lily');

      // No calendar at first.
      expect(find.byType(InlineCalendar), findsNothing);

      await tester.tap(find.text('Select start date'));
      await tester.pumpAndSettle();
      expect(find.byType(InlineCalendar), findsOneWidget);

      // Toggle the same field — should close.
      await tester.tap(find.text('Select start date'));
      await tester.pumpAndSettle();
      expect(find.byType(InlineCalendar), findsNothing);
    });

    testWidgets(
      'tapping CTA fires onCreateMealPlan with the picked DateTimeRange',
      (tester) async {
        DateTimeRange? captured;
        await _pump(
          tester,
          babyName: 'Lily',
          onCreate: (r) => captured = r,
        );

        // Pick start date.
        await tester.tap(find.text('Select start date'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('10').first);
        await tester.pumpAndSettle();

        // Pick end date — once start is picked the hint is no longer shown.
        // The picked-start row now reads its formatted date; the end-date row
        // still shows the placeholder.
        await tester.tap(find.text('Select end date'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('20').first);
        await tester.pumpAndSettle();

        // CTA should now be enabled.
        final cta = find.widgetWithText(AppPillButton, 'Create meal plan');
        expect(
          tester.widget<AppPillButton>(cta).onPressed,
          isNotNull,
          reason: 'CTA should enable once both dates are picked.',
        );

        await tester.tap(cta);
        await tester.pumpAndSettle();

        expect(captured, isNotNull);
        expect(captured!.start.day, 10);
        expect(captured!.end.day, 20);
      },
    );
  });
}
