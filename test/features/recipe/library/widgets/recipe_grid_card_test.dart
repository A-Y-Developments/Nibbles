// a11y coverage for `RecipeGridCard` — the tappable card must expose a
// labelled button role, and a flagged-allergen recipe must surface its
// "not safe" state in the accessible name (it is otherwise a visual-only
// chip a screen reader would miss).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/recipe/library/widgets/recipe_grid_card.dart';

Recipe _recipe({List<String> allergenTags = const <String>[]}) => Recipe(
  id: 'r1',
  title: 'Pea Puree',
  ageRange: '6+ months',
  allergenTags: allergenTags,
  ingredients: const [],
  steps: const [],
  howToServe: '',
);

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 158, height: 220, child: child)),
  ),
);

void main() {
  testWidgets('exposes a labelled button + fires onTap', (tester) async {
    final handle = tester.ensureSemantics();
    var tapped = false;

    await tester.pumpWidget(
      _wrap(RecipeGridCard(recipe: _recipe(), onTap: () => tapped = true)),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Pea Puree'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pea Puree'));
    expect(tapped, isTrue);

    handle.dispose();
  });

  testWidgets('flagged-allergen recipe surfaces "not safe" in the label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(
        RecipeGridCard(
          recipe: _recipe(allergenTags: const ['peanut']),
          onTap: () {},
          flaggedAllergenKeys: const {'peanut'},
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Pea Puree, not safe'), findsOneWidget);

    handle.dispose();
  });
}
