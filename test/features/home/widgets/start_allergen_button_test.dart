// Widget coverage for `StartAllergenButton` — the tall two-line "Start New
// Allergen" CTA rendered in the lime hero (light) and inside the burgundy
// ongoing card (onDark). Asserts both copy lines render and the tap fires
// regardless of palette.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  for (final onDark in [false, true]) {
    group('StartAllergenButton (onDark: $onDark)', () {
      testWidgets('renders both copy lines', (tester) async {
        await tester.pumpWidget(
          _wrap(StartAllergenButton(onPressed: () {}, onDark: onDark)),
        );

        expect(find.text('Start New Allergen'), findsOneWidget);
        expect(find.text('Introduce 1 allergen at 1 time'), findsOneWidget);
      });

      testWidgets('tap fires onPressed', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrap(
            StartAllergenButton(
              onPressed: () => tapped = true,
              onDark: onDark,
            ),
          ),
        );

        await tester.tap(find.byType(StartAllergenButton));
        expect(tapped, isTrue);
      });
    });
  }

  testWidgets('exposes a labelled "Start New Allergen" button node', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(StartAllergenButton(onPressed: () {})));

    expect(find.bySemanticsLabel('Start New Allergen'), findsOneWidget);

    handle.dispose();
  });
}
