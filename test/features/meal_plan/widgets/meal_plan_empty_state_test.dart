import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_empty_state.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_plan_header.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_prep_calendar.dart';

Future<void> _pump(
  WidgetTester tester, {
  required String babyName,
  int ageMonths = 4,
  ValueChanged<DateTimeRange>? onSetMealPrep,
  ValueChanged<DateTimeRange>? onFillInMyself,
}) async {
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MealPlanEmptyState(
          babyName: babyName,
          ageMonths: ageMonths,
          onSetMealPrep: onSetMealPrep ?? (_) {},
          onFillInMyself: onFillInMyself ?? (_) {},
        ),
      ),
    ),
  );
}

/// Picks a start + end day via the two inline [MealPrepCalendar]s so the CTAs
/// become enabled. Uses days 15 → 20 of the focused (current) month.
Future<void> _pickRange(WidgetTester tester) async {
  // Open the START field (both fields show the placeholder initially).
  await tester.tap(find.text('dd/MM/yyyy').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('15').first);
  await tester.pumpAndSettle();

  // Only the END field still shows the placeholder now.
  await tester.tap(find.text('dd/MM/yyyy'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('20').first);
  await tester.pumpAndSettle();
}

void main() {
  group('MealPlanEmptyState', () {
    testWidgets('renders header + caption + both CTAs (disabled initially)', (
      tester,
    ) async {
      await _pump(tester, babyName: 'Oliver');

      expect(find.byType(MealPlanHeader), findsOneWidget);
      expect(find.text('Meal Planner for Oliver'), findsOneWidget);
      expect(find.text('4 Month'), findsOneWidget);
      expect(find.text("Let's create meal plan for Oliver!"), findsOneWidget);

      // Overflow is hidden on the empty state.
      expect(find.byType(MealPlanOverflowButton), findsNothing);

      final setCta = find.widgetWithText(AppPillButton, 'Set a Meal Prep');
      final fillCta = find.widgetWithText(AppPillButton, 'Fill in myself');
      expect(setCta, findsOneWidget);
      expect(fillCta, findsOneWidget);
      // Disabled until a valid range is chosen.
      expect(tester.widget<AppPillButton>(setCta).onPressed, isNull);
      expect(tester.widget<AppPillButton>(fillCta).onPressed, isNull);
    });

    testWidgets('tapping a date field reveals a MealPrepCalendar', (
      tester,
    ) async {
      await _pump(tester, babyName: 'Oliver');

      expect(find.byType(MealPrepCalendar), findsNothing);
      await tester.tap(find.text('dd/MM/yyyy').first);
      await tester.pumpAndSettle();
      expect(find.byType(MealPrepCalendar), findsWidgets);
    });

    testWidgets('choosing a range enables the CTAs and "Set a Meal Prep" '
        'fires onSetMealPrep with the range', (tester) async {
      DateTimeRange? captured;
      await _pump(
        tester,
        babyName: 'Oliver',
        onSetMealPrep: (r) => captured = r,
      );

      await _pickRange(tester);

      final setCta = find.widgetWithText(AppPillButton, 'Set a Meal Prep');
      expect(tester.widget<AppPillButton>(setCta).onPressed, isNotNull);

      await tester.tap(setCta);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(!captured!.end.isBefore(captured!.start), isTrue);
    });

    testWidgets('"Fill in myself" fires onFillInMyself with the range', (
      tester,
    ) async {
      DateTimeRange? captured;
      await _pump(
        tester,
        babyName: 'Oliver',
        onFillInMyself: (r) => captured = r,
      );

      await _pickRange(tester);

      final fillCta = find.widgetWithText(AppPillButton, 'Fill in myself');
      expect(tester.widget<AppPillButton>(fillCta).onPressed, isNotNull);

      await tester.tap(fillCta);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
    });
  });
}
