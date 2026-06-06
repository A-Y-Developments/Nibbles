// NIB-136: widget tests for the range-scoped Add to Shoplist bottom sheet.
//
// Covers the two captured Figma states (shoplist-03 most-selected / -04 all
// unselected), the Select All / Unselect All toggle, and the submit success
// + failure paths.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/meal_plan_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/meal_plan/widgets/range_add_to_shoplist_sheet.dart';

class _MockMealPlanService extends Mock implements MealPlanService {}

class _MockShoppingListService extends Mock implements ShoppingListService {}

const _babyId = 'baby-001';
final _start = DateTime(2026, 4, 20);
final _end = DateTime(2026, 4, 23);

const _ingredients = <String>[
  'Flour',
  'Sugar',
  'Butter',
  'Eggs',
  'Baking Powder',
  'Salt',
];

Future<void> _pumpSheet(
  WidgetTester tester, {
  required MealPlanService mealPlanService,
  required ShoppingListService shoppingListService,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mealPlanServiceProvider.overrideWithValue(mealPlanService),
        shoppingListServiceProvider.overrideWithValue(shoppingListService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showRangeAddToShoplistSheet(
                  context,
                  babyId: _babyId,
                  startDate: _start,
                  endDate: _end,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  late _MockMealPlanService mealPlanService;
  late _MockShoppingListService shoppingListService;

  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mealPlanService = _MockMealPlanService();
    shoppingListService = _MockShoppingListService();
  });

  // ---------------------------------------------------------------------------
  // Initial render — shoplist-03 baseline (all selected)
  // ---------------------------------------------------------------------------

  testWidgets(
    'renders verbatim header, date range, and all ingredients selected '
    '(shoplist-03 baseline)',
    (tester) async {
      when(
        () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(_ingredients));

      await _pumpSheet(
        tester,
        mealPlanService: mealPlanService,
        shoppingListService: shoppingListService,
      );

      // Wait for async load to settle.
      await tester.pump();

      // Verbatim copy.
      expect(find.text('Add to Shoplist'), findsOneWidget);
      expect(find.text('Mon, 20 - Thu 23 April'), findsOneWidget);
      // All ingredients visible.
      for (final name in _ingredients) {
        expect(find.text(name), findsOneWidget);
      }
      // Baseline = all selected → toggle reads "Unselect All", Add (N=count).
      expect(find.text('Unselect All'), findsOneWidget);
      expect(find.text('Add (${_ingredients.length})'), findsOneWidget);
      // Figma 971:7908 — the toggle is a butter-filled button (not outlined).
      final toggleBtn = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Unselect All'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(
        toggleBtn.style?.backgroundColor?.resolve({}),
        AppColors.butter,
      );
      // Range fetch invoked with the range bounds.
      verify(
        () =>
            mealPlanService.getRangeIngredientNames(_babyId, _start, _end),
      ).called(1);
    },
  );

  // ---------------------------------------------------------------------------
  // shoplist-04 — every ingredient unselected → 'Select All' toggle
  // ---------------------------------------------------------------------------

  testWidgets(
    'tapping Unselect All clears every pill and CTA becomes Add (0) disabled '
    '(shoplist-04 state)',
    (tester) async {
      when(
        () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(_ingredients));

      await _pumpSheet(
        tester,
        mealPlanService: mealPlanService,
        shoppingListService: shoppingListService,
      );
      await tester.pump();

      await tester.tap(find.text('Unselect All'));
      await tester.pump();

      // After clearing: toggle flips to 'Select All', CTA count drops to 0.
      expect(find.text('Select All'), findsOneWidget);
      expect(find.text('Add (0)'), findsOneWidget);
      // Add CTA is disabled when count is 0.
      final addBtn = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Add (0)'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(addBtn.onPressed, isNull);
    },
  );

  testWidgets(
    'Select All re-selects every pill and CTA shows full count',
    (tester) async {
      when(
        () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
      ).thenAnswer((_) async => const Result.success(_ingredients));

      await _pumpSheet(
        tester,
        mealPlanService: mealPlanService,
        shoppingListService: shoppingListService,
      );
      await tester.pump();

      // Clear → re-select.
      await tester.tap(find.text('Unselect All'));
      await tester.pump();
      await tester.tap(find.text('Select All'));
      await tester.pump();

      expect(find.text('Unselect All'), findsOneWidget);
      expect(find.text('Add (${_ingredients.length})'), findsOneWidget);
    },
  );

  // ---------------------------------------------------------------------------
  // Pill tap toggles selection — count updates dynamically
  // ---------------------------------------------------------------------------

  testWidgets('tapping a pill toggles its selection + decrements Add (N)',
      (tester) async {
    when(
      () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
    ).thenAnswer((_) async => const Result.success(_ingredients));

    await _pumpSheet(
      tester,
      mealPlanService: mealPlanService,
      shoppingListService: shoppingListService,
    );
    await tester.pump();

    expect(find.text('Add (${_ingredients.length})'), findsOneWidget);

    await tester.tap(find.text('Flour'));
    await tester.pump();

    expect(find.text('Add (${_ingredients.length - 1})'), findsOneWidget);
    // 'Unselect All' still shown — at least one selected.
    expect(find.text('Unselect All'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Submit success — pops sheet + shows P2 toast
  // ---------------------------------------------------------------------------

  testWidgets('submit success → calls addFromMealPlan, pops, shows P2 toast',
      (tester) async {
    when(
      () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
    ).thenAnswer((_) async => const Result.success(_ingredients));
    when(
      () => shoppingListService.addFromMealPlan(any(), any()),
    ).thenAnswer((_) async => const Result.success(null));

    await _pumpSheet(
      tester,
      mealPlanService: mealPlanService,
      shoppingListService: shoppingListService,
    );
    await tester.pump();

    await tester.tap(find.text('Add (${_ingredients.length})'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final captured =
        verify(() => shoppingListService.addFromMealPlan(_babyId, captureAny()))
            .captured
            .single as List<String>;
    expect(captured, equals(_ingredients));
    expect(find.text('Added to shopping list.'), findsOneWidget);
    expect(find.text('Add to Shoplist'), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // Submit failure — sheet stays open, P2 error toast
  // ---------------------------------------------------------------------------

  testWidgets('submit failure → sheet stays open + shows error toast',
      (tester) async {
    when(
      () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
    ).thenAnswer((_) async => const Result.success(_ingredients));
    when(
      () => shoppingListService.addFromMealPlan(any(), any()),
    ).thenAnswer(
      (_) async => const Result.failure(ServerException('DB error')),
    );

    await _pumpSheet(
      tester,
      mealPlanService: mealPlanService,
      shoppingListService: shoppingListService,
    );
    await tester.pump();

    await tester.tap(find.text('Add (${_ingredients.length})'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text("Couldn't add items. Try again."), findsOneWidget);
    // Sheet remains open after failure.
    expect(find.text('Add to Shoplist'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Load failure — error inline + Add hidden
  // ---------------------------------------------------------------------------

  testWidgets('load failure → shows inline error and hides bottom actions',
      (tester) async {
    when(
      () => mealPlanService.getRangeIngredientNames(any(), any(), any()),
    ).thenAnswer(
      (_) async => const Result.failure(ServerException('boom')),
    );

    await _pumpSheet(
      tester,
      mealPlanService: mealPlanService,
      shoppingListService: shoppingListService,
    );
    await tester.pump();

    expect(find.text('Could not load ingredients.'), findsOneWidget);
    expect(find.textContaining('Add ('), findsNothing);
    expect(find.text('Unselect All'), findsNothing);
    expect(find.text('Select All'), findsNothing);
  });
}
