import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/features/meal_plan/widgets/inline_calendar.dart';

Future<void> _pump(
  WidgetTester tester, {
  required DateTime focusedMonth,
  DateTime? selectedDate,
  DateTime? minDate,
  DateTime? maxDate,
  ValueChanged<DateTime>? onDaySelected,
  ValueChanged<DateTime>? onMonthChanged,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: InlineCalendar(
          selectedDate: selectedDate,
          focusedMonth: focusedMonth,
          onDaySelected: onDaySelected ?? (_) {},
          onMonthChanged: onMonthChanged ?? (_) {},
          minDate: minDate,
          maxDate: maxDate,
        ),
      ),
    ),
  );
}

void main() {
  group('InlineCalendar', () {
    testWidgets('day tap fires onDaySelected with the correct date', (
      tester,
    ) async {
      DateTime? selected;
      await _pump(
        tester,
        focusedMonth: DateTime(2026, 5),
        onDaySelected: (d) => selected = d,
      );

      // Tap day 15 of May 2026 — uses last text match for the digit.
      await tester.tap(find.text('15'));
      await tester.pump();

      expect(selected, DateTime(2026, 5, 15));
    });

    testWidgets('chevron taps fire onMonthChanged with prev/next month', (
      tester,
    ) async {
      DateTime? changedTo;
      await _pump(
        tester,
        focusedMonth: DateTime(2026, 5),
        onMonthChanged: (d) => changedTo = d,
      );

      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(changedTo, DateTime(2026, 6));

      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump();
      expect(changedTo, DateTime(2026, 4));
    });

    testWidgets('today cell is visually distinguished (border decoration)', (
      tester,
    ) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await _pump(tester, focusedMonth: DateTime(today.year, today.month));

      final todayCells = find.descendant(
        of: find.byType(InlineCalendar),
        matching: find.text('${today.day}'),
      );
      expect(todayCells, findsWidgets);

      // Walk up to the nearest Container with a circle BoxDecoration and
      // assert the today border/background is the butterSoft + green-bordered
      // styling. We check via at least one ancestor Container.
      final containers = tester.widgetList<Container>(
        find.ancestor(of: todayCells.first, matching: find.byType(Container)),
      );
      final hasTodayDeco = containers.any((c) {
        final d = c.decoration;
        if (d is! BoxDecoration) return false;
        return d.color == AppColors.butterSoft && d.border != null;
      });
      expect(
        hasTodayDeco,
        isTrue,
        reason: 'Today cell must use butterSoft fill + bordered styling.',
      );
    });

    testWidgets('selected day is visually distinguished (greenDeep fill)', (
      tester,
    ) async {
      await _pump(
        tester,
        focusedMonth: DateTime(2026, 5),
        selectedDate: DateTime(2026, 5, 15),
      );

      final cell = find.descendant(
        of: find.byType(InlineCalendar),
        matching: find.text('15'),
      );
      expect(cell, findsOneWidget);

      final containers = tester.widgetList<Container>(
        find.ancestor(of: cell, matching: find.byType(Container)),
      );
      final hasSelected = containers.any((c) {
        final d = c.decoration;
        if (d is! BoxDecoration) return false;
        return d.color == AppColors.greenDeep && d.shape == BoxShape.circle;
      });
      expect(
        hasSelected,
        isTrue,
        reason: 'Selected day must use greenDeep circular fill.',
      );
    });

    testWidgets(
      'days outside minDate/maxDate are visually disabled (untappable)',
      (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          focusedMonth: DateTime(2026, 5),
          minDate: DateTime(2026, 5, 10),
          maxDate: DateTime(2026, 5, 20),
          onDaySelected: (_) => tapped++,
        );

        // 5 May is before minDate → tapping should be a no-op.
        await tester.tap(find.text('5'));
        await tester.pump();
        // 25 May is after maxDate → tapping should be a no-op.
        await tester.tap(find.text('25'));
        await tester.pump();
        expect(tapped, 0);

        // Tap a day inside range to confirm the callback still fires.
        await tester.tap(find.text('15'));
        await tester.pump();
        expect(tapped, 1);
      },
    );
  });
}
