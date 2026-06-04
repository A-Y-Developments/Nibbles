// a11y coverage for PickedRecipeRow — the bare InkWell tap-to-assign target
// now exposes a labelled button; the assigned-day badge is surfaced in the
// accessible name (excludeSemantics would otherwise drop it).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/picked_recipe_row.dart';

const _recipe = Recipe(
  id: 'r1',
  title: 'Pea Puree',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('exposes a labelled button + fires onTap', (tester) async {
    final handle = tester.ensureSemantics();
    var tapped = false;

    await tester.pumpWidget(
      _wrap(PickedRecipeRow(recipe: _recipe, onTap: () => tapped = true)),
    );

    expect(find.bySemanticsLabel('Pea Puree'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pea Puree'));
    expect(tapped, isTrue);

    handle.dispose();
  });

  testWidgets('assignedLabel is surfaced in the button label', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(
        PickedRecipeRow(recipe: _recipe, onTap: () {}, assignedLabel: 'Tue 3'),
      ),
    );

    expect(
      find.bySemanticsLabel('Pea Puree, assigned to Tue 3'),
      findsOneWidget,
    );

    handle.dispose();
  });
}
