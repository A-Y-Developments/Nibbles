// NIB-111 — Optional widget-level coverage for `OngoingIntroducedCard`.
//
// Asserts the empty branch collapses (`SizedBox.shrink`) and the in-progress
// branch surfaces the allergen's display name + emoji.

// Firebase platform-interface packages are transitive deps; the public
// barrels do not re-export FirebaseAnalyticsPlatform / setupFirebaseCoreMocks.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_introduced_card.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _NoopAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  _NoopAnalyticsPlatform() : super();

  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) => this;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {}
}

GoRouter _router(Widget child) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => Scaffold(body: child),
    ),
    GoRoute(
      path: AppRoute.allergenTracker.path,
      name: AppRoute.allergenTracker.name,
      builder: (_, __) =>
          const Scaffold(body: Center(child: Text('TRACKER_STUB'))),
    ),
  ],
);

Widget _wrap(Widget child) => MaterialApp.router(routerConfig: _router(child));

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  testWidgets('no inProgress allergen -> renders SizedBox.shrink (collapses)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const OngoingIntroducedCard(
          allergenStatuses: {
            'peanut': AllergenStatus.safe,
            'egg': AllergenStatus.notStarted,
          },
        ),
      ),
    );

    expect(find.text('ONGOING INTRODUCED'), findsNothing);
    // The card collapses; no name labels render.
    expect(find.text('Peanut'), findsNothing);
  });

  testWidgets(
    'one inProgress allergen -> renders ONGOING INTRODUCED + name + emoji',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OngoingIntroducedCard(
            allergenStatuses: {
              'peanut': AllergenStatus.inProgress,
              'egg': AllergenStatus.notStarted,
            },
            logCounts: {'peanut': 2},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ONGOING INTRODUCED'), findsOneWidget);
      expect(find.text('Peanut'), findsOneWidget);
      // Verbatim audit subhead (trailing space preserved): "2/3 times ".
      expect(find.text('2/3 times '), findsOneWidget);
      // Peanut emoji is in the AllergenEmoji constant — renders inside thumb.
      expect(find.text('🥜'), findsOneWidget);
    },
  );

  testWidgets(
    'logCounts absent -> falls back to 0/3 times subhead (verbatim)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OngoingIntroducedCard(
            allergenStatuses: {'peanut': AllergenStatus.inProgress},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0/3 times '), findsOneWidget);
    },
  );

  testWidgets('logCounts above target -> subhead clamps to 3/3 times', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const OngoingIntroducedCard(
          allergenStatuses: {'peanut': AllergenStatus.inProgress},
          logCounts: {'peanut': 7},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3/3 times '), findsOneWidget);
  });

  testWidgets('picks first inProgress in canonical kAllergenKeys order', (
    tester,
  ) async {
    // egg comes before dairy in the canonical sequence.
    await tester.pumpWidget(
      _wrap(
        const OngoingIntroducedCard(
          allergenStatuses: {
            'peanut': AllergenStatus.safe,
            'egg': AllergenStatus.inProgress,
            'dairy': AllergenStatus.inProgress,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Egg'), findsOneWidget);
    // Dairy should not be the surfaced card (egg wins by order).
    expect(find.text('Dairy'), findsNothing);
  });

  testWidgets(
    'multi-word allergen key (tree_nuts) is rendered title-cased with space',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const OngoingIntroducedCard(
            allergenStatuses: {'tree_nuts': AllergenStatus.inProgress},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tree Nuts'), findsOneWidget);
    },
  );

  testWidgets('tapping the card pushes the allergen tracker route', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const OngoingIntroducedCard(
          allergenStatuses: {'peanut': AllergenStatus.inProgress},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.text('TRACKER_STUB'), findsOneWidget);
  });

  testWidgets('exposes a labelled button via Semantics (a11y)', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(
        const OngoingIntroducedCard(
          allergenStatuses: {'peanut': AllergenStatus.inProgress},
          logCounts: {'peanut': 2},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Peanut, introduced 2 of 3 times'),
      findsOneWidget,
    );

    handle.dispose();
  });
}
