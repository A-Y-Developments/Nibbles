import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/sheets/browse_meal_sheet.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _MockRecipeService extends Mock implements RecipeService {}

class _MockAllergenService extends Mock implements AllergenService {}

const _babyId = 'baby-001';

const _safeA = Recipe(
  id: 'safe-a',
  title: 'Avocado Mash',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _safeB = Recipe(
  id: 'safe-b',
  title: 'Banana Porridge',
  ageRange: '6m+',
  allergenTags: [],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

const _flagged = Recipe(
  id: 'flagged',
  title: 'Peanut Butter Toast',
  ageRange: '6m+',
  allergenTags: ['peanut'],
  ingredients: [],
  steps: [],
  howToServe: 'Serve.',
);

Map<String, AllergenStatus> _allSafeStatuses() => const {
      'peanut': AllergenStatus.safe,
      'egg': AllergenStatus.safe,
      'dairy': AllergenStatus.safe,
      'tree_nuts': AllergenStatus.safe,
      'sesame': AllergenStatus.safe,
      'soy': AllergenStatus.safe,
      'wheat': AllergenStatus.safe,
      'fish': AllergenStatus.safe,
      'shellfish': AllergenStatus.safe,
    };

void main() {
  late _MockRecipeService mockRecipeService;
  late _MockAllergenService mockAllergenService;
  late FakeAnalytics fakeAnalytics;

  setUp(() {
    mockRecipeService = _MockRecipeService();
    mockAllergenService = _MockAllergenService();
    fakeAnalytics = FakeAnalytics();
  });

  /// Reference holder so a test can await the eventual result of
  /// `showBrowseMealSheet` AFTER it dismisses. Never returned through an
  /// async function — that would force the test framework to await the
  /// (intentionally) never-completing modal Future before the next step
  /// runs, hanging the suite.
  late Future<List<Recipe>?> pendingResult;

  Future<void> openSheet(
    WidgetTester tester, {
    required List<Recipe> recipes,
    required Set<String> flaggedKeys,
    Map<String, AllergenStatus>? statuses,
  }) async {
    when(
      () => mockRecipeService.getAllRecipes(any()),
    ).thenAnswer((_) async => Result.success(recipes));
    when(
      () => mockRecipeService.getFlaggedAllergenKeys(any()),
    ).thenAnswer((_) async => Result.success(flaggedKeys));
    when(
      () => mockAllergenService.getAllergenStatuses(any()),
    ).thenAnswer((_) async => Result.success(statuses ?? _allSafeStatuses()));

    // Larger viewport so the sheet, CTA and rows are all on-screen.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeServiceProvider.overrideWithValue(mockRecipeService),
          allergenServiceProvider.overrideWithValue(mockAllergenService),
          analyticsProvider.overrideWithValue(fakeAnalytics),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    pendingResult = showBrowseMealSheet(
                      context,
                      babyId: _babyId,
                      startDate: DateTime(2026, 5, 30),
                      endDate: DateTime(2026, 6, 5),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    // Drive route + sheet entrance + _load() future. Avoid pumpAndSettle —
    // CircularProgressIndicator animates forever and would block forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.pump();
  }

  group('BrowseMealSheet', () {
    testWidgets('multi-select toggles selected counter', (tester) async {
      await openSheet(
        tester,
        recipes: const [_safeA, _safeB],
        flaggedKeys: const {},
      );

      expect(find.text('0 selected'), findsOneWidget);

      // Tap row for first recipe (the master list at the bottom).
      await tester.tap(find.text(_safeA.title).first);
      await tester.pump();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(find.text(_safeB.title).first);
      await tester.pump();
      expect(find.text('2 selected'), findsOneWidget);

      // Deselect.
      await tester.tap(find.text(_safeA.title).first);
      await tester.pump();
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets(
      'flagged recipes are rendered visually disabled and non-selectable',
      (tester) async {
        await openSheet(
          tester,
          recipes: const [_safeA, _flagged],
          flaggedKeys: const {'peanut'},
        );

        expect(find.text('0 selected'), findsOneWidget);

        // Tap the flagged recipe row — selected counter must NOT increment.
        await tester.tap(find.text(_flagged.title).first);
        await tester.pump();
        expect(find.text('0 selected'), findsOneWidget);

        // Tapping a safe recipe should still work.
        await tester.tap(find.text(_safeA.title).first);
        await tester.pump();
        expect(find.text('1 selected'), findsOneWidget);
      },
    );

    testWidgets('search filters by title (case-insensitive contains)', (
      tester,
    ) async {
      await openSheet(
        tester,
        recipes: const [_safeA, _safeB],
        flaggedKeys: const {},
      );

      await tester.enterText(find.byType(TextField), 'BANANA');
      await tester.pump();

      // Master-list row for Banana Porridge should still be visible.
      expect(find.text(_safeB.title), findsWidgets);
      // No-results placeholder should NOT show for the matching query.
      expect(find.textContaining('No results'), findsNothing);

      // Search for a string with no matches — placeholder should appear.
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.textContaining('No results for "zzz"'), findsOneWidget);
    });

    testWidgets('"Add (N)" returns picked recipes on Navigator.pop',
        (tester) async {
      await openSheet(
        tester,
        recipes: const [_safeA, _safeB],
        flaggedKeys: const {},
      );

      await tester.tap(find.text(_safeA.title).first);
      await tester.pump();

      // CTA reflects the count.
      expect(find.text('Add (1)'), findsOneWidget);

      await tester.tap(find.text('Add (1)'));
      // Drive the sheet dismissal animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final result = await pendingResult;
      expect(result, hasLength(1));
      expect(result!.single.id, _safeA.id);
    });

    testWidgets(
      'ongoing-allergen carousel is hidden when no inProgress status exists',
      (tester) async {
        await openSheet(
          tester,
          recipes: const [_safeA],
          flaggedKeys: const {},
          // All statuses safe → no ongoing allergen → no carousel header.
        );

        expect(find.textContaining('Recommendation for'), findsNothing);
      },
    );
  });
}
