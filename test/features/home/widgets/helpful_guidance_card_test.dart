// NIB-77 — Verbatim-copy guard for `HelpfulGuidanceCard`.
//
// The Figma audit (home-populated, node 1242:10567) requires the three
// tip cards + disclaimer to render the exact strings from `verbatim copy`
// — paraphrasing is explicitly out per the ticket AC. This test pins the
// copy so a future drift fails loudly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/home/widgets/helpful_guidance_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

void main() {
  testWidgets('renders section title + three verbatim tip cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const HelpfulGuidanceCard()));
    await tester.pumpAndSettle();

    expect(find.text('Helpful Guidance'), findsOneWidget);

    // Verbatim from the audit (trailing space on the first title is the
    // canonical Figma value — preserve it).
    expect(find.text('No fruit yet today '), findsOneWidget);
    expect(find.text('Dinner is a good chance for ...'), findsOneWidget);

    expect(find.text('Offer water with each meal'), findsOneWidget);
    expect(find.text('Small sips in an open cup from 6 month'), findsOneWidget);

    expect(find.text('Milk feeds still the priority'), findsOneWidget);
    expect(
      find.text('Breastmilk or formula remains the main nutrition at 8 months'),
      findsOneWidget,
    );
  });

  testWidgets('renders Important Health Disclaimer card verbatim', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const HelpfulGuidanceCard()));
    await tester.pumpAndSettle();

    expect(find.text('Important Health Disclaimer'), findsOneWidget);
    expect(
      find.text(
        'Our recommendations are intended for educational purposes '
        'only and should not be considered medical advice.',
      ),
      findsOneWidget,
    );
  });
}
