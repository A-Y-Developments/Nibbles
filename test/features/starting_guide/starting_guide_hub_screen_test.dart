// Widget tests for the Starting Guide hub screen.
//
// Asserts:
//   * one [ArticleCard] is rendered per entry in [kStartingGuideArticles]
//   * tapping a card pushes `/home/recipe/guide/:slug` with the right slug
//     via GoRouter (asserted by a stub article-route that surfaces the slug)
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
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_hub_screen.dart';
import 'package:nibbles/src/features/starting_guide/widgets/article_card.dart';
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

/// Stub article route — surfaces the slug it was given so the test can
/// assert the right slug was pushed by the tap handler.
class _ArticleStub extends StatelessWidget {
  const _ArticleStub({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('ARTICLE_STUB:$slug')));
}

GoRouter _makeRouter() => GoRouter(
  initialLocation: AppRoute.startingGuide.path,
  routes: [
    GoRoute(
      path: AppRoute.startingGuide.path,
      name: AppRoute.startingGuide.name,
      builder: (_, __) => const StartingGuideHubScreen(),
    ),
    GoRoute(
      path: AppRoute.startingGuideArticle.path,
      name: AppRoute.startingGuideArticle.name,
      builder: (_, state) =>
          _ArticleStub(slug: state.pathParameters['slug'] ?? ''),
    ),
  ],
);

Widget _buildSut() {
  return ProviderScope(child: MaterialApp.router(routerConfig: _makeRouter()));
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildSut());
    await tester.pumpAndSettle();
  }

  group('StartingGuideHubScreen — render', () {
    testWidgets(
      'renders one ArticleCard per GuideArticle in kStartingGuideArticles',
      (tester) async {
        await pump(tester);

        expect(
          find.byType(ArticleCard),
          findsNWidgets(kStartingGuideArticles.length),
        );
        // Sanity check: at least one known title is on screen.
        expect(find.text(kStartingGuideArticles.first.title), findsOneWidget);
      },
    );

    testWidgets('renders the hub header title (no subtitle, per Figma)', (
      tester,
    ) async {
      await pump(tester);

      // Figma 971:8642 — the hub header is title-only; there is no subtitle.
      expect(find.text('Starting Guide'), findsWidgets);
      expect(find.textContaining('Bite-sized reads'), findsNothing);
    });
  });

  group('StartingGuideHubScreen — card navigation', () {
    testWidgets(
      'tapping the first ArticleCard pushes /home/recipe/guide/:slug',
      (tester) async {
        await pump(tester);

        final firstArticle = kStartingGuideArticles.first;
        await tester.tap(find.byType(ArticleCard).first);
        await tester.pumpAndSettle();

        // The stub renders the slug it received.
        expect(find.text('ARTICLE_STUB:${firstArticle.slug}'), findsOneWidget);
      },
    );

    testWidgets('tapping the second ArticleCard pushes the right slug', (
      tester,
    ) async {
      // Sanity: at least 2 articles exist.
      assert(
        kStartingGuideArticles.length >= 2,
        'expected at least 2 starting-guide articles',
      );
      await pump(tester);

      final secondArticle = kStartingGuideArticles[1];
      await tester.tap(find.byType(ArticleCard).at(1));
      await tester.pumpAndSettle();

      expect(find.text('ARTICLE_STUB:${secondArticle.slug}'), findsOneWidget);
    });
  });
}
