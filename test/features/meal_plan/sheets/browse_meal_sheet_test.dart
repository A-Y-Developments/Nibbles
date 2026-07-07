import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/recipe.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/recipe_service.dart';
import 'package:nibbles/src/features/meal_plan/sheets/browse_meal_sheet.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _MockRecipeService extends Mock implements RecipeService {}

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

const _babyId = 'baby-001';

Baby _babyAged(int months) {
  final now = DateTime.now();
  return Baby(
    id: _babyId,
    userId: 'user-001',
    name: 'Testy',
    dateOfBirth: DateTime(now.year, now.month - months),
    gender: Gender.preferNotToSay,
    onboardingCompleted: true,
  );
}

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
  late _MockBabyProfileService mockBabyProfileService;
  late FakeAnalytics fakeAnalytics;

  setUp(() {
    mockRecipeService = _MockRecipeService();
    mockAllergenService = _MockAllergenService();
    mockBabyProfileService = _MockBabyProfileService();
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
    Baby? baby,
    DateTime? startDate,
    DateTime? endDate,
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
    when(() => mockBabyProfileService.getBaby()).thenAnswer((_) async => baby);

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
          babyProfileServiceProvider.overrideWithValue(mockBabyProfileService),
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
                      startDate: startDate ?? DateTime(2026, 5, 30),
                      endDate: endDate ?? DateTime(2026, 6, 5),
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

    testWidgets('Next → review "Map Meals" returns picks on Navigator.pop', (
      tester,
    ) async {
      await openSheet(
        tester,
        recipes: const [_safeA, _safeB],
        flaggedKeys: const {},
      );

      await tester.tap(find.text(_safeA.title).first);
      await tester.pump();

      // Advance to the review sheet, then confirm with "Map Meals".
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Map Meals'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final result = await pendingResult;
      expect(result, hasLength(1));
      expect(result!.single.id, _safeA.id);
    });

    testWidgets(
      'single-date entry: "Add" commits directly, skipping the review sheet',
      (tester) async {
        await openSheet(
          tester,
          recipes: const [_safeA, _safeB],
          flaggedKeys: const {},
          startDate: DateTime(2026, 5, 30),
          endDate: DateTime(2026, 5, 30),
        );

        // Footer CTA reads "Add" (not "Next") when the day is fixed.
        expect(find.text('Add'), findsOneWidget);
        expect(find.text('Next'), findsNothing);

        await tester.tap(find.text(_safeA.title).first);
        await tester.pump();

        await tester.tap(find.text('Add'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // No review sheet appears — the picks pop straight back.
        expect(find.text('Map Meals'), findsNothing);
        final result = await pendingResult;
        expect(result, hasLength(1));
        expect(result!.single.id, _safeA.id);
      },
    );

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

    testWidgets('NIB-162: recommendation hides recipes above the baby age', (
      tester,
    ) async {
      const egg10mo = Recipe(
        id: 'egg-10',
        title: 'Veggie Egg Frittata',
        ageRange: '10+ months',
        allergenTags: ['egg'],
        ingredients: [],
        steps: [],
        howToServe: 'Serve.',
      );
      await openSheet(
        tester,
        recipes: const [egg10mo],
        flaggedKeys: const {},
        statuses: {..._allSafeStatuses(), 'egg': AllergenStatus.inProgress},
        baby: _babyAged(6),
      );

      // 10-month recipe is too old for a 6-month-old → recommendation
      // carousel suppressed, but the recipe still lives in the unfiltered
      // master list (filtering is scoped to recommendations only).
      expect(find.textContaining('Recommendation for'), findsNothing);
      expect(find.text('Veggie Egg Frittata'), findsOneWidget);
    });

    testWidgets('NIB-162: recommendation keeps age-appropriate recipes', (
      tester,
    ) async {
      const egg10mo = Recipe(
        id: 'egg-10',
        title: 'Veggie Egg Frittata',
        ageRange: '10+ months',
        allergenTags: ['egg'],
        ingredients: [],
        steps: [],
        howToServe: 'Serve.',
      );
      await openSheet(
        tester,
        recipes: const [egg10mo],
        flaggedKeys: const {},
        statuses: {..._allSafeStatuses(), 'egg': AllergenStatus.inProgress},
        baby: _babyAged(12),
      );

      // 12-month-old → 10-month recipe is appropriate → carousel shows.
      expect(find.textContaining('Recommendation for'), findsOneWidget);
    });

    testWidgets(
      'header renders verbatim "Browse Meal" title and weekday range',
      (tester) async {
        await openSheet(tester, recipes: const [_safeA], flaggedKeys: const {});

        expect(find.text('Browse Meal'), findsOneWidget);
        // openSheet uses DateTime(2026, 5, 30) → DateTime(2026, 6, 5).
        // 2026-05-30 is a Saturday; 2026-06-05 is a Friday.
        expect(find.text('Sat, 30 - Fri 5 June'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping selected counter chip toggles review mode (hides search)',
      (tester) async {
        await openSheet(
          tester,
          recipes: const [_safeA, _safeB],
          flaggedKeys: const {},
        );

        // Select one recipe.
        await tester.tap(find.text(_safeA.title).first);
        await tester.pump();

        // Browse mode shows the search field.
        expect(find.text('Search recipe'), findsOneWidget);

        // Enter review mode via the selected pill — search + carousels hide.
        await tester.tap(find.text('1 selected'));
        await tester.pump();

        expect(find.text('Search recipe'), findsNothing);
      },
    );

    testWidgets('search field uses verbatim "Search recipe" hint', (
      tester,
    ) async {
      await openSheet(
        tester,
        recipes: const [_safeA, _safeB],
        flaggedKeys: const {},
      );

      expect(find.text('Search recipe'), findsOneWidget);
    });

    testWidgets('close (X) icon dismisses the sheet with a null result', (
      tester,
    ) async {
      await openSheet(
        tester,
        recipes: const [_safeA, _safeB],
        flaggedKeys: const {},
      );

      // The header close icon — Icons.close is unique to the sheet header.
      await tester.tap(find.byIcon(Icons.close));
      // Drive the sheet dismissal animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final result = await pendingResult;
      expect(result, isNull);
    });
  });
}
