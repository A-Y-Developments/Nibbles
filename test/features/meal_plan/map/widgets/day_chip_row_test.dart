// a11y coverage for the map-flow day chip — the bare GestureDetector now
// exposes a single-select button (label = day, selected: state) and fires
// onSelect on tap.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/day_chip_row.dart';

void main() {
  testWidgets('day chip exposes a labelled button + fires onSelect', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    DateTime? selected;
    final day = DateTime(2026, 5, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayChipRow(
            startDate: day,
            endDate: day,
            selectedDay: day,
            onSelect: (d) => selected = d,
          ),
        ),
      ),
    );

    // Single-day range → exactly one chip, labelled "<weekday> 30 May".
    final chip = find.bySemanticsLabel(RegExp('30 May'));
    expect(chip, findsOneWidget);

    await tester.tap(chip);
    expect(selected, day);

    handle.dispose();
  });
}
