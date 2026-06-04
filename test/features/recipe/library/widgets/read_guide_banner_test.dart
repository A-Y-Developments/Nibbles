// a11y coverage for `ReadGuideBanner` — the "Read Guide" CTA is styled as a
// button but was a bare InkWell with no button role; assert it now exposes a
// labelled button that activates the handler.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/recipe/library/widgets/read_guide_banner.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('Read Guide CTA exposes a labelled button + fires onTap', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var tapped = false;

    await tester.pumpWidget(_wrap(ReadGuideBanner(onTap: () => tapped = true)));
    await tester.pump();

    expect(find.bySemanticsLabel('Read Guide'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Read Guide'));
    expect(tapped, isTrue);

    handle.dispose();
  });
}
