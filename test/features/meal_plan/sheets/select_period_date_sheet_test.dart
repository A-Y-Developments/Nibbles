import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/features/meal_plan/sheets/select_period_date_sheet.dart';
import 'package:nibbles/src/features/meal_plan/widgets/inline_calendar.dart';

Future<DateTimeRange?> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  DateTimeRange? captured;
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

void main() {
  group('SelectPeriodDateSheet', () {
    testWidgets('renders Figma verbatim title + Custom meal plan CTA', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('Select Period Date'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      expect(
        find.widgetWithText(AppPillButton, 'Custom meal plan'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Start Date opens the inline calendar', (tester) async {
      await _open(tester);

      expect(find.byType(InlineCalendar), findsNothing);
      final today = DateTime.now();
      const monthAbbr = [
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
      final startText =
          '${monthAbbr[today.month - 1]} ${today.day}, '
          '${today.year}';
      await tester.tap(find.text(startText).first);
      await tester.pumpAndSettle();
      expect(find.byType(InlineCalendar), findsOneWidget);
    });

    testWidgets('tapping CTA pops the sheet with a DateTimeRange', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      DateTimeRange? captured;
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

      await tester.tap(find.widgetWithText(AppPillButton, 'Custom meal plan'));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(
        captured!.end.difference(captured!.start).inDays,
        6,
        reason: 'Default end = start + 6 days.',
      );
    });
  });
}
