import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/meal_plan_entry.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/features/meal_plan/widgets/day_accordion_card.dart';

const _babyId = 'baby-001';

MealPlanEntry _entry({
  String id = 'mp-1',
  String recipeId = 'r-1',
  DateTime? planDate,
}) => MealPlanEntry(
  id: id,
  babyId: _babyId,
  recipeId: recipeId,
  planDate: planDate ?? DateTime(2026, 5, 30),
);

Recipe _recipe({
  String id = 'r-1',
  String title = 'Peanut Butter Toast',
  List<String> tags = const ['peanut'],
}) => Recipe(
  id: id,
  title: title,
  ageRange: '6m+',
  allergenTags: tags,
  ingredients: const [],
  steps: const [],
  howToServe: 'Serve.',
);

Future<void> _pumpCard(
  WidgetTester tester, {
  required List<MealPlanEntry> entries,
  required Map<String, Recipe> recipes,
  required bool isExpanded,
  VoidCallback? onToggle,
  VoidCallback? onAdd,
  Set<String> flaggedAllergenKeys = const {},
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DayAccordionCard(
          day: DateTime(2026, 5, 30),
          entries: entries,
          recipes: recipes,
          flaggedAllergenKeys: flaggedAllergenKeys,
          isExpanded: isExpanded,
          onToggle: onToggle ?? () {},
          onAdd: onAdd ?? () {},
          onRecipeTap: (_) {},
          onMenuSelected: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('DayAccordionCard', () {
    testWidgets('collapsed: header visible, body hidden', (tester) async {
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {'r-1': _recipe()},
        isExpanded: false,
      );

      // Header includes the date label e.g. "Sat 30 May".
      expect(find.textContaining('30 May'), findsOneWidget);
      // Body content (recipe title + Add pill) is hidden.
      expect(find.text('Peanut Butter Toast'), findsNothing);
      expect(find.text('+ Add'), findsNothing);
      expect(find.text('No meal plan yet.'), findsNothing);
    });

    testWidgets(
      'expanded + entries: recipe row renders with title + tag chips '
      '+ Add pill',
      (tester) async {
        await _pumpCard(
          tester,
          entries: [_entry()],
          recipes: {
            'r-1': _recipe(tags: const ['peanut', 'egg']),
          },
          isExpanded: true,
        );

        expect(find.text('Peanut Butter Toast'), findsOneWidget);
        expect(find.text('+ Add'), findsOneWidget);
        // Tag chips render with replaced underscore labels.
        expect(find.text('peanut'), findsOneWidget);
        expect(find.text('egg'), findsOneWidget);
        // No empty-state hint.
        expect(find.text('No meal plan yet.'), findsNothing);
      },
    );

    testWidgets(
      'expanded + entries: 3+ tags renders +N overflow chip after first 2',
      (tester) async {
        await _pumpCard(
          tester,
          entries: [_entry()],
          recipes: {
            'r-1': _recipe(tags: const ['peanut', 'egg', 'dairy', 'soy']),
          },
          isExpanded: true,
        );

        // First 2 tags visible.
        expect(find.text('peanut'), findsOneWidget);
        expect(find.text('egg'), findsOneWidget);
        // 4 - 2 = +2 overflow chip.
        expect(find.text('+2'), findsOneWidget);
        // Hidden tags should not render their labels.
        expect(find.text('dairy'), findsNothing);
        expect(find.text('soy'), findsNothing);
      },
    );

    testWidgets('expanded + empty: shows empty hint and Add pill', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        entries: const [],
        recipes: const {},
        isExpanded: true,
      );

      expect(find.text('No meal plan yet.'), findsOneWidget);
      expect(find.text('+ Add'), findsOneWidget);
    });

    testWidgets('header tap fires onToggle', (tester) async {
      var toggled = 0;
      await _pumpCard(
        tester,
        entries: const [],
        recipes: const {},
        isExpanded: false,
        onToggle: () => toggled++,
      );

      // Tap on the header text — the GestureDetector wraps the row.
      await tester.tap(find.textContaining('30 May'));
      await tester.pumpAndSettle();

      expect(toggled, 1);
    });

    testWidgets('"+ Add" pill tap fires onAdd', (tester) async {
      var added = 0;
      await _pumpCard(
        tester,
        entries: const [],
        recipes: const {},
        isExpanded: true,
        onAdd: () => added++,
      );

      await tester.tap(find.text('+ Add'));
      await tester.pumpAndSettle();

      expect(added, 1);
    });
  });
}
