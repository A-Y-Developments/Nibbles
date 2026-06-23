// Widget tests for the bespoke Baby's First Nibbles screen.
//
// Asserts:
//   * the page renders both section headings + all three focus-card titles
//   * EVIDENCE INFORMED and No Fluf sit side by side (same top edge)
//   * the primary CTA routes to recipe-library
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
import 'package:nibbles/src/features/starting_guide/first_nibbles/first_nibbles_screen.dart';
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

class _RecipeLibraryStub extends StatelessWidget {
  const _RecipeLibraryStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('LIBRARY_STUB')));
}

GoRouter _makeRouter() => GoRouter(
  initialLocation: '/first-nibbles',
  routes: [
    GoRoute(
      path: AppRoute.startingGuide.path,
      name: AppRoute.startingGuide.name,
      builder: (_, __) => const Scaffold(body: Center(child: Text('HUB_STUB'))),
    ),
    GoRoute(
      path: '/first-nibbles',
      builder: (_, __) => const FirstNibblesScreen(),
    ),
    GoRoute(
      path: AppRoute.recipeLibrary.path,
      name: AppRoute.recipeLibrary.name,
      builder: (_, __) => const _RecipeLibraryStub(),
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

  testWidgets('renders both section headings and all focus-card titles', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('We focuses on'), findsOneWidget);
    expect(find.text('Nibbles Goals'), findsOneWidget);
    expect(find.text('SIMPLE AND PRACTICAL'), findsOneWidget);
    expect(find.text('EVIDENCE INFORMED'), findsOneWidget);
    expect(find.text('No Fluf'), findsOneWidget);
  });

  testWidgets('lays EVIDENCE INFORMED + No Fluf side by side', (tester) async {
    await _pump(tester);

    final evidence = find.text('EVIDENCE INFORMED');
    final noFluf = find.text('No Fluf');
    expect(evidence, findsOneWidget);
    expect(noFluf, findsOneWidget);

    final ePos = tester.getTopLeft(evidence);
    final nPos = tester.getTopLeft(noFluf);
    expect(ePos.dy, nPos.dy);
    expect(nPos.dx, greaterThan(ePos.dx));
  });

  testWidgets('primary CTA → routes to recipe-library', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Explore Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore Recipes'));
    await tester.pumpAndSettle();

    expect(find.text('LIBRARY_STUB'), findsOneWidget);
  });
}
