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
  String ageRange = '6m+',
  List<String> allergenTags = const ['peanut'],
  List<String> nutritionTags = const ['Iron-Rich'],
}) => Recipe(
  id: id,
  title: title,
  ageRange: ageRange,
  allergenTags: allergenTags,
  nutritionTags: nutritionTags,
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
  ValueChanged<String>? onRecipeTap,
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
          onRecipeTap: onRecipeTap ?? (_) {},
          onMenuSelected: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('DayAccordionCard', () {
    testWidgets('non-empty collapsed: header visible, body hidden', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {'r-1': _recipe()},
        isExpanded: false,
      );

      expect(find.textContaining('30 May'), findsOneWidget);
      expect(find.text('Peanut Butter Toast'), findsNothing);
      expect(find.text('Add'), findsNothing);
    });

    testWidgets('non-empty expanded: recipe row title + nutrition + age chips '
        '+ Add pill', (tester) async {
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {'r-1': _recipe()},
        isExpanded: true,
      );

      expect(find.text('Peanut Butter Toast'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      // Nutrition + age chips render (allergen chips are no longer shown).
      expect(find.text('Iron-Rich'), findsOneWidget);
      expect(find.text('6m+'), findsOneWidget);
    });

    testWidgets('expanded: only the first 2 nutrition tags render', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {
          'r-1': _recipe(
            nutritionTags: const ['Iron-Rich', 'High Energy', 'Extra'],
          ),
        },
        isExpanded: true,
      );

      expect(find.text('Iron-Rich'), findsOneWidget);
      expect(find.text('High Energy'), findsOneWidget);
      expect(find.text('Extra'), findsNothing);
    });

    testWidgets('empty day: dashed "No meal plan yet" + Add always visible', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        entries: const [],
        recipes: const {},
        isExpanded: false,
      );

      expect(find.text('No meal plan yet'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('non-empty header tap fires onToggle', (tester) async {
      var toggled = 0;
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {'r-1': _recipe()},
        isExpanded: false,
        onToggle: () => toggled++,
      );

      await tester.tap(find.textContaining('30 May'));
      await tester.pumpAndSettle();

      expect(toggled, 1);
    });

    testWidgets('empty-day "Add" pill tap fires onAdd', (tester) async {
      var added = 0;
      await _pumpCard(
        tester,
        entries: const [],
        recipes: const {},
        isExpanded: false,
        onAdd: () => added++,
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(added, 1);
    });

    testWidgets('recipe row exposes a labelled button + fires onRecipeTap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      String? tappedRecipeId;
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {'r-1': _recipe()},
        isExpanded: true,
        onRecipeTap: (id) => tappedRecipeId = id,
      );

      expect(find.bySemanticsLabel('Peanut Butter Toast'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Peanut Butter Toast'));
      await tester.pumpAndSettle();
      expect(tappedRecipeId, 'r-1');

      handle.dispose();
    });

    testWidgets('flagged allergen is surfaced in the row button label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpCard(
        tester,
        entries: [_entry()],
        recipes: {'r-1': _recipe()},
        isExpanded: true,
        flaggedAllergenKeys: const {'peanut'},
      );

      expect(
        find.bySemanticsLabel('Peanut Butter Toast, flagged: Peanut'),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
