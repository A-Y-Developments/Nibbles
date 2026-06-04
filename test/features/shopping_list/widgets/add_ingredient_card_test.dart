// a11y coverage for the Add-ingredient sheet's "Add" pill — a bare
// GestureDetector with no button role. Assert it exposes a labelled button
// that fires the onAdd handler.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/shopping_list/widgets/add_ingredient_card.dart';

void main() {
  testWidgets('Add pill exposes a labelled button + fires onAdd', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var added = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showAddIngredientSheet(
                  ctx,
                  controller: controller,
                  focusNode: focusNode,
                  onAdd: () => added = true,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Add'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add'));
    expect(added, isTrue);

    handle.dispose();
  });
}
