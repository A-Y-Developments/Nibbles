// a11y coverage for SelectedDaySlotList — the icon-only unassign button now
// carries a per-recipe "Remove {title} from day" tooltip (which also serves as
// its screen-reader label) and fires onRemoveAt with the card's positional
// index (duplicates are removed by position, not id).

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
  testWidgets('remove button has a per-recipe tooltip + fires onRemoveAt with '
      'the index', (tester) async {
    int? removedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDaySlotList(
            recipes: const [_recipe],
            onRemoveAt: (index) => removedIndex = index,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Remove Pea Puree from day'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove Pea Puree from day'));
    expect(removedIndex, 0);
  });
}
