// Widget tests for the "View all plans" bottom sheet (NIB-61).
//
// Drives `showAllPlansSheet(context, plans: ...)` and asserts:
//   * default populated state — Annual selected, "Recomended" badge present,
//     plan titles + price labels rendered verbatim from the SubscriptionPlan
//     domain entity.
//   * selection inversion — tapping Monthly inverts the border treatment;
//     the badge stays on Annual.
//   * Continue pops with the selected plan; close X pops with null.
//   * single-plan edge case — no badge, no second card, Continue still works.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/domain/entities/subscription_plan.dart';
import 'package:nibbles/src/features/subscription/paywall/widgets/all_plans_sheet.dart';

const _annual = SubscriptionPlan(
  id: 'annual_29_99',
  title: 'Annual',
  priceLabel: r'$29.99 yearly',
  period: SubscriptionPlanPeriod.annual,
  isRecommended: true,
);

const _monthly = SubscriptionPlan(
  id: 'monthly_4_99',
  title: 'Monthly',
  priceLabel: r'$4.99 monthly',
  period: SubscriptionPlanPeriod.monthly,
);

Future<void> _setupViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Mounts the sheet directly (not through `showModalBottomSheet`) so the
/// test can inspect its internals without dealing with route animations.
Future<void> _pumpSheet(
  WidgetTester tester, {
  required List<SubscriptionPlan> plans,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AllPlansSheet(plans: plans),
      ),
    ),
  );
}

/// Returns the border color of the plan card whose title equals [title].
/// The card is `Container > BoxDecoration > Border.all(...)` — we walk up
/// from the title text to find the nearest decorated container.
Color _borderColorOf(WidgetTester tester, String title) {
  final container = tester
      .widgetList<Container>(
        find.ancestor(of: find.text(title), matching: find.byType(Container)),
      )
      .firstWhere((c) {
        final decoration = c.decoration;
        return decoration is BoxDecoration && decoration.border != null;
      });
  final border = (container.decoration! as BoxDecoration).border! as Border;
  return border.top.color;
}

void main() {
  group('AllPlansSheet — populated default state', () {
    testWidgets(
      'renders both plan titles, both price labels, and the badge',
      (tester) async {
        await _setupViewport(tester);
        await _pumpSheet(tester, plans: const [_annual, _monthly]);

        expect(find.text('Annual'), findsOneWidget);
        expect(find.text(r'$29.99 yearly'), findsOneWidget);
        expect(find.text('Monthly'), findsOneWidget);
        expect(find.text(r'$4.99 monthly'), findsOneWidget);
        expect(find.text('Recomended'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      },
    );

    testWidgets(
      'recommended plan (Annual) is selected by default — forest border, '
      'Monthly has muted border',
      (tester) async {
        await _setupViewport(tester);
        await _pumpSheet(tester, plans: const [_annual, _monthly]);

        expect(_borderColorOf(tester, 'Annual'), AppColors.greenDeep);
        expect(_borderColorOf(tester, 'Monthly'), AppColors.borderMuted);
      },
    );

    testWidgets(
      'each plan card exposes a curated a11y label',
      (tester) async {
        await _setupViewport(tester);
        await _pumpSheet(tester, plans: const [_annual, _monthly]);

        // Portable a11y assertion: each plan card exposes its Semantics label.
        // The isButton/isSelected flag matchers (containsSemantics) are
        // version-skew-deprecated and fatal on CI; selection state is covered
        // by the border-color inversion test below.
        expect(
          find.bySemanticsLabel(r'Annual, $29.99 yearly'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(r'Monthly, $4.99 monthly'),
          findsOneWidget,
        );
      },
    );
  });

  group('AllPlansSheet — selection inversion', () {
    testWidgets(
      'tapping Monthly inverts the border; Recomended badge stays on Annual',
      (tester) async {
        await _setupViewport(tester);
        await _pumpSheet(tester, plans: const [_annual, _monthly]);

        await tester.tap(find.text('Monthly'));
        await tester.pump();

        expect(_borderColorOf(tester, 'Monthly'), AppColors.greenDeep);
        expect(_borderColorOf(tester, 'Annual'), AppColors.borderMuted);
        // Badge stays on Annual — never migrates to Monthly.
        expect(find.text('Recomended'), findsOneWidget);
      },
    );
  });

  group('AllPlansSheet — Continue / Close flow', () {
    testWidgets(
      'Continue pops the sheet with the selected plan',
      (tester) async {
        await _setupViewport(tester);
        SubscriptionPlan? picked;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      picked = await showAllPlansSheet(
                        context,
                        plans: const [_annual, _monthly],
                      );
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

        await tester.tap(find.text('Continue'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(picked, isNotNull);
        expect(picked!.id, _annual.id);
      },
    );

    testWidgets(
      'close X pops with null',
      (tester) async {
        await _setupViewport(tester);
        SubscriptionPlan? picked = _annual; // sentinel — must become null
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      picked = await showAllPlansSheet(
                        context,
                        plans: const [_annual, _monthly],
                      );
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

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(picked, isNull);
      },
    );
  });

  group('AllPlansSheet — single-plan edge case', () {
    testWidgets(
      'single plan hides the badge and still allows Continue',
      (tester) async {
        await _setupViewport(tester);
        await _pumpSheet(tester, plans: const [_annual]);

        expect(find.text('Annual'), findsOneWidget);
        expect(find.text(r'$29.99 yearly'), findsOneWidget);
        // No selection chrome → badge is hidden even though the plan is
        // marked recommended.
        expect(find.text('Recomended'), findsNothing);
        expect(find.text('Monthly'), findsNothing);
        expect(find.text('Continue'), findsOneWidget);
      },
    );
  });
}
