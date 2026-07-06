import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/sheets/select_period_date_sheet.dart';
import 'package:nibbles/src/features/meal_plan/widgets/meal_prep_calendar.dart';

Future<SelectPeriodResult?> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SelectPeriodResult? captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                captured = await showSelectPeriodDateSheet(context);
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Sheet'));
  await tester.pumpAndSettle();
  return captured;
}

/// Picks start (15) → end (20) of the focused month so the CTAs enable.
Future<void> _pickRange(WidgetTester tester) async {
  await tester.tap(find.text('dd/MM/yyyy').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('15').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('dd/MM/yyyy'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('20').first);
  await tester.pumpAndSettle();
}

void main() {
  group('SelectPeriodDateSheet', () {
    testWidgets('renders title + date fields + AI/manual CTA pair', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('Select Period Date'), findsOneWidget);
      expect(find.text('START DATE'), findsOneWidget);
      expect(find.text('END DATE'), findsOneWidget);
      expect(
        find.widgetWithText(AppPillButton, 'Generate with AI'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(AppPillButton, 'Fill in myself'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a date field reveals a MealPrepCalendar', (
      tester,
    ) async {
      await _open(tester);

      expect(find.byType(MealPrepCalendar), findsNothing);
      await tester.tap(find.text('dd/MM/yyyy').first);
      await tester.pumpAndSettle();
      expect(find.byType(MealPrepCalendar), findsWidgets);
    });

    testWidgets('Generate with AI pops SelectPeriodResult(mode: ai)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SelectPeriodResult? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    captured = await showSelectPeriodDateSheet(context);
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await _pickRange(tester);
      await tester.tap(find.widgetWithText(AppPillButton, 'Generate with AI'));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.mode, MealPrepMode.ai);
      expect(!captured!.range.end.isBefore(captured!.range.start), isTrue);
    });
  });
}
