// Widget tests for the Starting Guide article screen.
//
// Asserts:
//   * a known slug ('first-nibbles') renders the article's hero title and
//     section copy (verbatim from the Figma audit)
//   * tapping the article's primary inline CTA routes to recipe-library
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

class _MealPlanStub extends StatelessWidget {
  const _MealPlanStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('MEAL_PLAN_STUB')));
}

class _AllergenStub extends StatelessWidget {
  const _AllergenStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('ALLERGEN_STUB')));
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
    GoRoute(
      path: AppRoute.mealPlan.path,
      name: AppRoute.mealPlan.name,
      builder: (_, __) => const _MealPlanStub(),
    ),
    GoRoute(
      path: AppRoute.allergenTracker.path,
      name: AppRoute.allergenTracker.name,
      builder: (_, __) => const _AllergenStub(),
    ),
  ],
);

Widget _buildSut({required String slug}) => ProviderScope(
  child: MaterialApp.router(routerConfig: _makeRouter(slug: slug)),
);

Future<void> _pump(WidgetTester tester, {required String slug}) async {
  tester.view.physicalSize = const Size(1080, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildSut(slug: slug));
  await tester.pumpAndSettle();
}

/// Collects every CTA across the article's blocks (inline pair + ready-card)
/// so tests don't have to know the block layout.
List<GuideCta> _allCtas(GuideArticle article) {
  final out = <GuideCta>[];
  for (final block in article.blocks) {
    if (block is InlineCtaPairBlock) {
      out.add(block.primary);
      final secondary = block.secondary;
      if (secondary != null) out.add(secondary);
    } else if (block is ReadyToStartCardBlock) {
      out.add(block.cta);
    }
  }
  return out;
}

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  group('StartingGuideArticleScreen — known slug', () {
    testWidgets(
      "'first-nibbles' renders the article's hub title in the header",
      (tester) async {
        const slug = 'first-nibbles';
        await _pump(tester, slug: slug);

        final article = kStartingGuideArticles.firstWhere(
          (a) => a.slug == slug,
        );

        // Hub title is verbatim from Figma — it shows in the header and the
        // hero card so we expect it at least once.
        expect(find.text(article.title), findsWidgets);
      },
    );

    testWidgets(
      "'first-nibbles' renders every section heading + info-card title",
      (tester) async {
        const slug = 'first-nibbles';
        await _pump(tester, slug: slug);

        final article = kStartingGuideArticles.firstWhere(
          (a) => a.slug == slug,
        );

        for (final block in article.blocks) {
          if (block is SectionHeadingBlock) {
            expect(
              find.text(block.text),
              findsWidgets,
              reason: 'section heading "${block.text}" missing',
            );
          } else if (block is InfoCardBlock) {
            expect(
              find.text(block.title),
              findsOneWidget,
              reason: 'info card "${block.title}" missing',
            );
          }
        }
      },
    );

    testWidgets(
      "'first-nibbles' lays EVIDENCE INFORMED + No Fluf side by side",
      (tester) async {
        await _pump(tester, slug: 'first-nibbles');

        final evidence = find.text('EVIDENCE INFORMED');
        final noFluf = find.text('No Fluf');
        expect(evidence, findsOneWidget);
        expect(noFluf, findsOneWidget);

        // Figma 971:8730 — the two cards share a row: same top edge, No Fluf
        // sits to the right of EVIDENCE INFORMED.
        final ePos = tester.getTopLeft(evidence);
        final nPos = tester.getTopLeft(noFluf);
        expect(ePos.dy, nPos.dy);
        expect(nPos.dx, greaterThan(ePos.dx));
      },
    );

    testWidgets(
      "'first-nibbles' primary CTA → routes to recipe-library",
      (tester) async {
        const slug = 'first-nibbles';
        await _pump(tester, slug: slug);

        final article = kStartingGuideArticles.firstWhere(
          (a) => a.slug == slug,
        );
        final ctas = _allCtas(article);
        final primary = ctas.firstWhere(
          (c) => c.routeName == AppRoute.recipeLibrary.name,
        );

        await tester.ensureVisible(find.text(primary.label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(primary.label));
        await tester.pumpAndSettle();

        expect(find.text('LIBRARY_STUB'), findsOneWidget);
      },
    );

    testWidgets(
      "'introduction' renders Essential Nutrients icon tiles",
      (tester) async {
        await _pump(tester, slug: 'introduction');

        for (final label in ['Iron', 'Minerals', 'Vitamins', 'Zinc']) {
          expect(find.text(label), findsWidgets);
        }
      },
    );

    testWidgets(
      "'feeding-principles' renders 'The Big 11' allergen chips",
      (tester) async {
        await _pump(tester, slug: 'feeding-principles');

        // Sample a few chips from The Big 11. 'Egg' is also in the iron-rich
        // grid as 'Eggs' (plural) — checking distinct labels avoids overlap.
        for (final label in ['Almond', 'Cashew', 'Wallnut', 'Sesame']) {
          expect(
            find.text(label),
            findsWidgets,
            reason: 'allergen chip "$label" missing',
          );
        }
      },
    );

    testWidgets(
      "'readiness-signs' renders the Readiness Signs checklist + score",
      (tester) async {
        await _pump(tester, slug: 'readiness-signs');

        expect(find.text('Readiness Signs'), findsOneWidget);
        expect(find.text('3/5'), findsOneWidget);
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
