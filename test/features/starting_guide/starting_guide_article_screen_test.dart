// Widget tests for the Starting Guide article screen.
//
// Asserts:
//   * a known slug ('first-nibbles') renders the matching article's title,
//     all sections, and its terminal CTA label
//   * tapping the terminal CTA calls `goNamed` on a known top-level route
//     — asserted by a stub destination route that surfaces the routed path
//   * an unknown slug falls back to the in-screen 'Article not found' UI
//     (no crash, no exception)
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
import 'package:nibbles/src/features/starting_guide/starting_guide_article_screen.dart';
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

GoRouter _makeRouter({required String slug}) => GoRouter(
  initialLocation: AppRoute.startingGuideArticle.path.replaceFirst(
    ':slug',
    slug,
  ),
  routes: [
    GoRoute(
      path: AppRoute.startingGuide.path,
      name: AppRoute.startingGuide.name,
      builder: (_, __) => const Scaffold(body: Center(child: Text('HUB_STUB'))),
    ),
    GoRoute(
      path: AppRoute.startingGuideArticle.path,
      name: AppRoute.startingGuideArticle.name,
      builder: (_, state) =>
          StartingGuideArticleScreen(slug: state.pathParameters['slug'] ?? ''),
    ),
    GoRoute(
      path: AppRoute.recipeLibrary.path,
      name: AppRoute.recipeLibrary.name,
      builder: (_, __) => const _RecipeLibraryStub(),
    ),
  ],
);

Widget _buildSut({required String slug}) => ProviderScope(
  child: MaterialApp.router(routerConfig: _makeRouter(slug: slug)),
);

Future<void> _pump(WidgetTester tester, {required String slug}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildSut(slug: slug));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  group('StartingGuideArticleScreen — known slug', () {
    testWidgets(
      "'first-nibbles' renders the matching article's title and CTA",
      (tester) async {
        const slug = 'first-nibbles';
        await _pump(tester, slug: slug);

        final article = kStartingGuideArticles.firstWhere(
          (a) => a.slug == slug,
        );

        // Title is rendered (it appears in the hero card AND header — at least
        // one).
        expect(find.text(article.title), findsWidgets);
        // Terminal CTA label is rendered exactly once.
        expect(find.text(article.terminalCta!.label), findsOneWidget);
      },
    );

    testWidgets("'first-nibbles' renders every section heading", (
      tester,
    ) async {
      const slug = 'first-nibbles';
      await _pump(tester, slug: slug);

      final article = kStartingGuideArticles.firstWhere((a) => a.slug == slug);

      for (final section in article.sections) {
        expect(find.text(section.heading), findsOneWidget);
      }
    });

    testWidgets(
      "'first-nibbles' terminal CTA tap → goNamed routes to recipe-library",
      (tester) async {
        const slug = 'first-nibbles';
        await _pump(tester, slug: slug);

        final article = kStartingGuideArticles.firstWhere(
          (a) => a.slug == slug,
        );
        expect(article.terminalCta!.routeName, AppRoute.recipeLibrary.name);

        await tester.tap(find.text(article.terminalCta!.label));
        await tester.pumpAndSettle();

        // Routed to the recipe-library stub.
        expect(find.text('LIBRARY_STUB'), findsOneWidget);
      },
    );
  });

  group('StartingGuideArticleScreen — fallback', () {
    testWidgets(
      'unknown slug falls back to the not-found scaffold (no crash)',
      (tester) async {
        await _pump(tester, slug: 'this-slug-does-not-exist');

        // The not-found UI surfaces a dedicated title — assert it's present
        // and the loader spinner is gone.
        expect(find.text('Article not found'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
