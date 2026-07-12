// Widget tests for the redesigned Add-to-Shoplist sheet (NIB-75 / NIB-68).
//
// Drives `showAddToShoppingListSheet(context, ingredients)` and asserts:
//   * each row renders a leading checkbox and a trailing remove
//     ('Remove <name>') button
//   * 'Select all' picks every visible row → CTA enabled
//   * 'Deselect all' clears every selection → CTA disabled
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
        // 3 rows → 3 checkboxes, 3 per-name 'Remove <name>' semantic labels.
        expect(find.byType(AppCheckbox), findsNWidgets(3));
        expect(find.bySemanticsLabel(RegExp('^Remove ')), findsNWidgets(3));
        // Pre-selected by default → CTA shows full count.
        expect(find.text('Add (3) items'), findsOneWidget);
      },
    );

    testWidgets('all rows are pre-selected → toggle label is Deselect all', (
      tester,
    ) async {
      await setupViewport(tester);
      await _openSheet(tester);

      // Initial state: all selected → toggle reads 'Deselect all'.
      expect(find.text('Deselect all'), findsOneWidget);
      expect(find.text('Select all'), findsNothing);
    });
  });

  group('AddToShoppingListSheet — select all toggle', () {
    testWidgets('tap Deselect all → CTA disabled (Add (0) items)', (
      tester,
    ) async {
      await setupViewport(tester);
      await _openSheet(tester);

      await tester.tap(find.text('Deselect all'));
      await tester.pump();

      // Now everything is deselected; CTA shows count 0.
      expect(find.text('Add (0) items'), findsOneWidget);
      expect(find.text('Select all'), findsOneWidget);
    });

    testWidgets('tap Select all after deselecting → CTA enabled (Add (3))', (
      tester,
    ) async {
      await setupViewport(tester);
      await _openSheet(tester);

      await tester.tap(find.text('Deselect all'));
      await tester.pump();

      await tester.tap(find.text('Select all'));
      // The CTA label cross-fades via AnimatedSwitcher inside AppPillButton;
      // rapid (3)->(0)->(3) label flips leave a stale outgoing 'Add (3) items'
      // Text mid-transition. Advance past the fade so only the final label
      // remains mounted.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Add (3) items'), findsOneWidget);
    });
  });

  group('AddToShoppingListSheet — per-row remove', () {
    testWidgets('tap remove on a row → ingredient hidden + count decrements', (
      tester,
    ) async {
      await setupViewport(tester);
      await _openSheet(tester);

      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Add (3) items'), findsOneWidget);

      // Tap the second row's Remove button ('Bread').
      await tester.tap(find.bySemanticsLabel('Remove Bread'));
      await tester.pump();

      expect(find.text('Bread'), findsNothing);
      expect(find.text('Add (2) items'), findsOneWidget);
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
        expect(find.text('Add (2) items'), findsOneWidget);

        await tester.tap(find.text('Add (2) items'));
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
