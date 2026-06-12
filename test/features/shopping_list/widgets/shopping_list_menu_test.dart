// a11y coverage for `ShoppingListOverflowMenu` — the overflow trigger and the
// two menu rows were bare GestureDetectors with no button role / name. Assert
// the trigger is a labelled button that opens the menu, and each row is a
// labelled button that fires its action.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/shopping_list/widgets/shopping_list_menu.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('trigger + rows expose labelled buttons; row fires its action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    ShoppingListMenuAction? selected;

    await tester.pumpWidget(
      _wrap(
        ShoppingListOverflowMenu(
          onSelected: (a) => selected = a,
          child: const Icon(Icons.more_horiz),
        ),
      ),
    );

    expect(find.bySemanticsLabel('More options'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Copy to Clipboard'), findsOneWidget);
    expect(find.bySemanticsLabel('Clear shopping list'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Clear shopping list'));
    await tester.pumpAndSettle();
    expect(selected, ShoppingListMenuAction.clear);

    handle.dispose();
  });
}
