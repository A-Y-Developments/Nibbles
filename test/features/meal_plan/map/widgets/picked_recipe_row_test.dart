// a11y + interaction coverage for PickedRecipeRow — the reusable palette row
// exposes a labelled tap-to-assign button AND is wrapped in a Draggable<Recipe>
// so it can be dropped onto the day drop-zone.

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

    final label = find.bySemanticsLabel(
      'Pea Puree. Drag or tap to add to the selected day',
    );
    expect(label, findsOneWidget);

    await tester.tap(label);
    expect(tapped, isTrue);

    handle.dispose();
  });

  testWidgets('is wrapped in a Draggable<Recipe> carrying the recipe', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(PickedRecipeRow(recipe: _recipe, onTap: () {})),
    );

    final draggable = tester.widget<Draggable<Recipe>>(
      find.byType(Draggable<Recipe>),
    );
    expect(draggable.data, _recipe);
  });
}
