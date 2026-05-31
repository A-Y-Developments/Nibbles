// Widget tests for the redesigned Add-to-Shoplist sheet (NIB-75 / NIB-68).
//
// Drives `showAddToShoppingListSheet(context, ingredients)` and asserts:
//   * each row renders a leading checkbox and a trailing remove ('Remove')
//     button
//   * 'Select All' picks every visible row → CTA enabled
//   * 'Unselect All' clears every selection → CTA disabled
//   * per-row remove drops the ingredient from the visible list and decrements
//     the CTA count
//   * confirm pops the sheet with the picked ingredient names
//   * dismiss without confirm returns null

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/controls/app_checkbox.dart';
import 'package:nibbles/src/common/domain/entities/ingredient.dart';
import 'package:nibbles/src/features/recipe/detail/widgets/add_to_shopping_list_sheet.dart';

const _ingredients = [
  Ingredient(name: 'Avocado', quantity: '1 whole'),
  Ingredient(name: 'Bread', quantity: '2 slices'),
  Ingredient(name: 'Olive oil', quantity: '1 tsp'),
];

/// Pumps a host scaffold that opens the sheet via an 'Open' button and
/// returns the pending result Future. The result Future is captured before
/// the test awaits the sheet's dismissal animation so the test can pop and
/// inspect it.
Future<Future<List<String>?>> _openSheet(WidgetTester tester) async {
  late Future<List<String>?> pending;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                pending = showAddToShoppingListSheet(context, _ingredients);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  return pending;
}

void main() {
  Future<void> setupViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('AddToShoppingListSheet — initial render', () {
    testWidgets(
      'shows ingredient names + leading checkbox + trailing remove button',
      (tester) async {
        await setupViewport(tester);
        await _openSheet(tester);

        expect(find.text('Add to Shoplist'), findsOneWidget);
        for (final ing in _ingredients) {
          expect(find.text(ing.name), findsOneWidget);
        }
        // 3 rows → 3 checkboxes, 3 'Remove' semantic labels.
        expect(find.byType(AppCheckbox), findsNWidgets(3));
        expect(find.bySemanticsLabel('Remove'), findsNWidgets(3));
        // Pre-selected by default → CTA shows full count.
        expect(find.text('Add (3)'), findsOneWidget);
      },
    );

    testWidgets(
      'all rows are pre-selected → Select All label is Unselect All',
      (tester) async {
        await setupViewport(tester);
        await _openSheet(tester);

        // Initial state: all selected → toggle reads 'Unselect All'.
        expect(find.text('Unselect All'), findsOneWidget);
        expect(find.text('Select All'), findsNothing);
      },
    );
  });

  group('AddToShoppingListSheet — select all toggle', () {
    testWidgets('tap Unselect All → CTA disabled (Add (0))', (tester) async {
      await setupViewport(tester);
      await _openSheet(tester);

      await tester.tap(find.text('Unselect All'));
      await tester.pump();

      // Now everything is deselected; CTA shows count 0.
      expect(find.text('Add (0)'), findsOneWidget);
      expect(find.text('Select All'), findsOneWidget);
    });

    testWidgets('tap Select All after deselecting → CTA enabled (Add (3))', (
      tester,
    ) async {
      await setupViewport(tester);
      await _openSheet(tester);

      await tester.tap(find.text('Unselect All'));
      await tester.pump();

      await tester.tap(find.text('Select All'));
      await tester.pump();

      expect(find.text('Add (3)'), findsOneWidget);
    });
  });

  group('AddToShoppingListSheet — per-row remove', () {
    testWidgets('tap remove on a row → ingredient hidden + count decrements', (
      tester,
    ) async {
      await setupViewport(tester);
      await _openSheet(tester);

      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Add (3)'), findsOneWidget);

      // Tap the second row's Remove button (index 1 == 'Bread').
      await tester.tap(find.bySemanticsLabel('Remove').at(1));
      await tester.pump();

      expect(find.text('Bread'), findsNothing);
      expect(find.text('Add (2)'), findsOneWidget);
    });
  });

  group('AddToShoppingListSheet — confirm + dismiss', () {
    testWidgets(
      'confirm → Navigator.pop returns the selected ingredient names',
      (tester) async {
        await setupViewport(tester);
        final pending = await _openSheet(tester);

        // Deselect 'Bread' (index 1).
        await tester.tap(find.text('Bread'));
        await tester.pump();
        expect(find.text('Add (2)'), findsOneWidget);

        await tester.tap(find.text('Add (2)'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        final names = await pending;
        expect(names, ['Avocado', 'Olive oil']);
      },
    );

    testWidgets('dismiss without confirm → returns null', (tester) async {
      await setupViewport(tester);
      final pending = await _openSheet(tester);

      // Drag down to dismiss the modal sheet by routing back via Navigator.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final result = await pending;
      expect(result, isNull);
    });
  });
}
