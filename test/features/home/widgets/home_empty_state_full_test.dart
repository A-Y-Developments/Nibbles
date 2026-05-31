// NIB-96 — Widget-level coverage for `HomeEmptyStateFull`.
//
// Verifies the verbatim Figma copy on the Ready-to-Start card + the single
// Getting Started Tips card render, baby-name interpolation works, and the
// CTA invokes the supplied `onCreateMealPlan` callback when provided.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/cards/tip_card.dart';
import 'package:nibbles/src/features/home/widgets/home_empty_state_full.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SafeArea(child: child)));

void main() {
  testWidgets(
    'renders ReadyToStartCard title + spec body + Create First Meal CTA',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(
          HomeEmptyStateFull(
            babyName: 'Oliver',
            onCreateMealPlan: () {},
          ),
        ),
      );

      expect(find.text('Ready to Start?'), findsOneWidget);
      expect(
        find.text(
          "Begin Oliver's food journey by creating your first meal prep "
          'and introducing allergens safely.',
        ),
        findsOneWidget,
      );
      expect(find.text('Create First Meal'), findsOneWidget);
    },
  );

  testWidgets(
    'renders the single Getting Started Tips section with verbatim copy',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(HomeEmptyStateFull(onCreateMealPlan: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Helpful Guidance'), findsOneWidget);
      expect(find.byType(TipCard), findsOneWidget);
      expect(find.text('Getting Started Tips'), findsOneWidget);
      expect(
        find.text(
          'Start with single-ingredient purees and introduce one new food '
          'every 3-5 days to monitor for reactions.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    "falls back to neutral 'your baby's' phrasing when babyName is omitted",
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(HomeEmptyStateFull(onCreateMealPlan: () {})),
      );

      expect(
        find.text(
          "Begin your baby's food journey by creating your first meal prep "
          'and introducing allergens safely.',
        ),
        findsOneWidget,
      );
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
