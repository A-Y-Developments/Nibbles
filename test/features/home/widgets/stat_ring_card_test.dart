// NIB-111 — Optional widget-level coverage for `StatRingCard`.
//
// Asserts the two ring values (TODAY MEALS + ALLERGEN) bind to the
// constructor inputs and that the optional `Iron Rich` chip is gated
// on `hasIronRichRecipes`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';
import 'package:nibbles/src/features/home/widgets/stat_ring_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('StatRingCard — labels + counts', () {
    testWidgets(
      'renders ALLERGEN ring with safeCount over the canonical /9 denominator',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const StatRingCard(
              safeCount: 3,
              flaggedCount: 1,
              notStartedCount: 5,
              inProgressCount: 0,
              todayMealCount: 1,
              todayMealTarget: 2,
            ),
          ),
        );

        expect(find.text('ALLERGEN'), findsOneWidget);
        expect(find.text('TODAY MEALS'), findsOneWidget);
        // Allergen ring: 3 / 9.
        expect(find.text('3'), findsOneWidget);
        expect(find.text('/9'), findsOneWidget);
        // Today meals ring: 1 / 2.
        expect(find.text('1'), findsOneWidget);
        expect(find.text('/2'), findsOneWidget);
      },
    );

    testWidgets('zero safeCount renders ring with 0/9', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatRingCard(
            safeCount: 0,
            flaggedCount: 0,
            notStartedCount: 9,
            inProgressCount: 0,
          ),
        ),
      );

      expect(find.text('0'), findsWidgets);
      expect(find.text('/9'), findsOneWidget);
      // Default todayMealTarget = 0 -> '/0'.
      expect(find.text('/0'), findsOneWidget);
    });
  });

  group('StatRingCard — Iron Rich chip gating', () {
    testWidgets(
      'hasIronRichRecipes = false -> only Active Program Allergens chip',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const StatRingCard(
              safeCount: 1,
              flaggedCount: 0,
              notStartedCount: 8,
              inProgressCount: 0,
            ),
          ),
        );

        expect(find.byType(AppChip), findsOneWidget);
        expect(find.text('✓ Active Program Allergens'), findsOneWidget);
        expect(find.text('✓ Iron Rich'), findsNothing);
      },
    );

    testWidgets('hasIronRichRecipes = true -> both chips render', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const StatRingCard(
            safeCount: 1,
            flaggedCount: 0,
            notStartedCount: 8,
            inProgressCount: 0,
            hasIronRichRecipes: true,
          ),
        ),
      );

      expect(find.byType(AppChip), findsNWidgets(2));
      expect(find.text('✓ Iron Rich'), findsOneWidget);
      expect(find.text('✓ Active Program Allergens'), findsOneWidget);
    });
  });
}
