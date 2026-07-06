// Widget coverage for `HelpfulGuidanceCard`.
//
// The redesign drives the card from an injected `List<GuidanceTip>`
// (`homeDayViewProvider(babyId).guidance`) rather than fixed copy: one white
// tip card per entry plus the always-present health disclaimer.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/app/constants/guidance_tips.dart';
import 'package:nibbles/src/common/domain/entities/guidance_tip.dart';
import 'package:nibbles/src/features/home/widgets/helpful_guidance_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

const _tips = <GuidanceTip>[
  GuidanceTip(
    id: 'tip_water',
    iconKey: 'cup',
    title: 'Offer water with each meal',
    body: 'Small sips in an open cup from 6 months',
  ),
  GuidanceTip(
    id: 'tip_milk',
    iconKey: 'bottle',
    title: 'Milk feeds still the priority',
    body: 'Breastmilk or formula remains the main nutrition at 8 months',
  ),
];

void main() {
  testWidgets('renders one tip card per injected tip', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const HelpfulGuidanceCard(tips: _tips)));
    await tester.pumpAndSettle();

    expect(find.text('Helpful Guidance'), findsOneWidget);

    for (final tip in _tips) {
      expect(find.text(tip.title), findsOneWidget);
      expect(find.text(tip.body), findsOneWidget);
    }
  });

  testWidgets('always renders the health disclaimer card', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const HelpfulGuidanceCard(tips: _tips)));
    await tester.pumpAndSettle();

    expect(find.text('Important Health Disclaimer'), findsOneWidget);
    expect(find.text(GuidanceTips.healthDisclaimerBody), findsOneWidget);
  });

  testWidgets('empty tips -> disclaimer still renders, no tip cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(const HelpfulGuidanceCard(tips: <GuidanceTip>[])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Helpful Guidance'), findsOneWidget);
    expect(find.text('Important Health Disclaimer'), findsOneWidget);
    expect(find.text(_tips.first.title), findsNothing);
  });
}
