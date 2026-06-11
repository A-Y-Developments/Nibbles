import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/inline_calendar.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_empty_state.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_header.dart';

const _monthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDisplayDate(DateTime d) {
  return '${_monthAbbr[d.month - 1]} ${d.day}, ${d.year}';
}

Future<void> _pump(
  WidgetTester tester, {
  required String babyName,
  int ageMonths = 4,
  ValueChanged<DateTimeRange>? onCreate,
}) async {
  // Give the screen extra height so the CTA + calendars fit in the viewport
  // without scrolling — keeps taps deterministic.
  tester.view.physicalSize = const Size(1080, 2800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MealPlanEmptyState(
          babyName: babyName,
          ageMonths: ageMonths,
          onCreateMealPlan: onCreate ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('MealPlanEmptyState', () {
    testWidgets('renders Figma verbatim copy with babyName', (tester) async {
      await _pump(tester, babyName: 'Oliver');

      // Header from MealPlanHeader.
      expect(find.byType(MealPlanHeader), findsOneWidget);
      expect(find.text('Meal Planner for Oliver'), findsOneWidget);
      expect(find.text('4 Month'), findsOneWidget);

      // Form labels + verbatim caption under the flower.
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      expect(find.text("Let's create a meal plan for Oliver!"), findsOneWidget);
    });

    testWidgets(
      'CTA is enabled by default — defaults are today + (today + 6 days)',
      (tester) async {
        await _pump(tester, babyName: 'Oliver');

        final cta = find.widgetWithText(AppPillButton, 'Create meal plan');
        expect(cta, findsOneWidget);

        // Enabled on first paint because defaults are populated.
        expect(tester.widget<AppPillButton>(cta).onPressed, isNotNull);
      },
    );

    testWidgets('tapping a date field opens the inline calendar', (
      tester,
    ) async {
      await _pump(tester, babyName: 'Oliver');

      expect(find.byType(InlineCalendar), findsNothing);

      // The field is tappable via its `MMM d, yyyy` value text inside the
      // GestureDetector. Use today's value to find the Start Date row.
      final today = DateTime.now();
      final startText = _formatDisplayDate(
        DateTime(today.year, today.month, today.day),
      );
      await tester.tap(find.text(startText).first);
      await tester.pumpAndSettle();
      expect(find.byType(InlineCalendar), findsOneWidget);

      // Toggle the same field — should close.
      await tester.tap(find.text(startText).first);
      await tester.pumpAndSettle();
      expect(find.byType(InlineCalendar), findsNothing);
    });

    testWidgets(
      'picking a Start Date keeps CTA enabled (form auto-bumps end)',
      (tester) async {
        DateTimeRange? captured;
        await _pump(tester, babyName: 'Oliver', onCreate: (r) => captured = r);

        final cta = find.widgetWithText(AppPillButton, 'Create meal plan');
        final today = DateTime.now();
        final startText = _formatDisplayDate(
          DateTime(today.year, today.month, today.day),
        );

        // Open the Start Date inline calendar and pick day 28 of the
        // focused month (day 28 exists in every month).
        await tester.tap(find.text(startText).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('28').first);
        await tester.pumpAndSettle();

        // CTA must remain enabled — the form auto-bumps end if needed so
        // end >= start.
        expect(
          tester.widget<AppPillButton>(cta).onPressed,
          isNotNull,
          reason: 'Form must auto-bump end so range stays valid.',
        );

        await tester.tap(cta);
        await tester.pumpAndSettle();
        expect(captured, isNotNull);
        expect(!captured!.end.isBefore(captured!.start), isTrue);
      },
    );

    testWidgets(
      'tapping CTA emits the picked DateTimeRange via onCreateMealPlan',
      (tester) async {
        DateTimeRange? captured;
        await _pump(tester, babyName: 'Oliver', onCreate: (r) => captured = r);

        final cta = find.widgetWithText(AppPillButton, 'Create meal plan');
        await tester.tap(cta);
        await tester.pumpAndSettle();

        expect(captured, isNotNull);
        expect(
          captured!.end.difference(captured!.start).inDays,
          6,
          reason: 'Default end = start + 6 days.',
        );
      },
    );
  });
}
