// a11y coverage for SelectedDaySlotList — the icon-only unassign button now
// carries a "Remove from day" tooltip (which also serves as its screen-reader
// label) and fires onRemove with the recipe id.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/meal_plan/map/widgets/selected_day_slot_list.dart';

const _recipe = Recipe(
  id: 'r1',
  title: 'Pea Puree',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

void main() {
  testWidgets('remove button has a tooltip label + fires onRemove with id', (
    tester,
  ) async {
    String? removed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDaySlotList(
            recipes: const [_recipe],
            onRemove: (id) => removed = id,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Remove from day'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from day'));
    expect(removed, 'r1');
  });
}
