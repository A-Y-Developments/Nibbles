// Widget tests for the bespoke Important Feeding Principles screen.
//
// Asserts:
//   * the hero banner image renders
//   * all section headings + key card titles render
//   * the CTA routes to the allergen tracker
//
// Firebase platform-interface packages are transitive deps; the public barrels
// don't re-export FirebaseAnalyticsPlatform/setupFirebaseCoreMocks. Test-only.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/features/starting_guide/feeding_principles/feeding_principles_screen.dart';
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

class _AllergenTrackerStub extends StatelessWidget {
  const _AllergenTrackerStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('TRACKER_STUB')));
}

GoRouter _makeRouter() => GoRouter(
  initialLocation: '/feeding-principles',
  routes: [
    GoRoute(
      path: AppRoute.startingGuide.path,
      name: AppRoute.startingGuide.name,
      builder: (_, __) => const Scaffold(body: Center(child: Text('HUB_STUB'))),
    ),
    GoRoute(
      path: '/feeding-principles',
      builder: (_, __) => const FeedingPrinciplesScreen(),
    ),
    GoRoute(
      path: AppRoute.allergenTracker.path,
      name: AppRoute.allergenTracker.name,
      builder: (_, __) => const _AllergenTrackerStub(),
    ),
  ],
);

Widget _buildSut() =>
    ProviderScope(child: MaterialApp.router(routerConfig: _makeRouter()));

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 4200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildSut());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  testWidgets('renders hero banner, headings, and key card titles', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Iron-Rich Essentials'), findsOneWidget);
    expect(find.text('Common Allergen'), findsOneWidget);
    expect(find.text('Offering a Variety of Foods'), findsOneWidget);
    expect(find.text('The Big 11'), findsOneWidget);
    expect(find.text('Items to Avoid'), findsOneWidget);
    expect(find.text('Ready to Start Introduce Allergens?'), findsOneWidget);
  });

  testWidgets('renders the 6+ Months pill and an allergen chip', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('6+ Months'), findsOneWidget);
    expect(find.text('Almond'), findsOneWidget);
    expect(find.text('Sesame'), findsOneWidget);
  });

  testWidgets('CTA → routes to allergen tracker', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Start Introducing Allergens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Introducing Allergens'));
    await tester.pumpAndSettle();

    expect(find.text('TRACKER_STUB'), findsOneWidget);
  });
}
