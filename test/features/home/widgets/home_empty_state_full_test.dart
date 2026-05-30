// NIB-111 — Optional widget-level coverage for `HomeEmptyStateFull`.
//
// Verifies the Ready-to-Start card + Getting Started Tips render and that
// the CTA invokes the supplied `onCreateMealPlan` callback when provided.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SafeArea(child: child)));

void main() {
  testWidgets(
    'renders ReadyToStartCard title + body + Create First Meal CTA',
    (tester) async {
      await tester.pumpWidget(
        _wrap(HomeEmptyStateFull(onCreateMealPlan: () {})),
      );

      expect(find.text('Ready to start?'), findsOneWidget);
      expect(
        find.text("Track allergen introductions and plan baby's meals."),
        findsOneWidget,
      );
      expect(find.text('Create First Meal'), findsOneWidget);
    },
  );

  testWidgets(
    'renders the 3 Getting Started Tips section',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(HomeEmptyStateFull(onCreateMealPlan: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Getting Started Tips'), findsOneWidget);
      expect(find.byType(TipCard), findsNWidgets(3));
      expect(find.text('Start with single-ingredient foods'), findsOneWidget);
      expect(find.text('Introduce allergens early'), findsOneWidget);
      expect(find.text('Watch, wait, repeat'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Create First Meal invokes the onCreateMealPlan callback',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _wrap(HomeEmptyStateFull(onCreateMealPlan: () => calls += 1)),
      );

      await tester.tap(find.text('Create First Meal'));
      await tester.pumpAndSettle();

      expect(calls, 1);
    },
  );
}
