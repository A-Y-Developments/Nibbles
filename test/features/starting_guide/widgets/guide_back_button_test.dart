// a11y coverage for `GuideBackButton` — an icon-only back button that had no
// accessible name. Assert it now exposes a "Back" button that fires onTap.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/starting_guide/widgets/guide_back_button.dart';

void main() {
  testWidgets('exposes a "Back" button + fires onTap', (tester) async {
    final handle = tester.ensureSemantics();
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GuideBackButton(onTap: () => tapped = true)),
      ),
    );

    expect(find.bySemanticsLabel('Back'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    expect(tapped, isTrue);

    handle.dispose();
  });
}
