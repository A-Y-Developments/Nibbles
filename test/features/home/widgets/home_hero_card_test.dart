// Widget coverage for `HomeHeroCard` — the lime hero. Asserts the two coral
// stat rings expose the right numerator/denominator (allergen denominator is
// the fixed Big-11 count), the status chips gate on `ironRich` /
// `hasActiveProgramAllergen`, and the embedded hero allergen section switches
// on `heroState`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/home/home_state.dart';
import 'package:nibbles/src/features/home/widgets/home_hero_card.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_allergen_card.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Future<void> _pump(
  WidgetTester tester, {
  int mealCount = 1,
  int mealTarget = 2,
  int introducedCount = 4,
  bool ironRich = false,
  bool hasActiveProgramAllergen = false,
  HomeAllergenHeroState heroState = HomeAllergenHeroState.start,
  String? allergenKey = 'milk',
  List<bool> allergenReactionFlags = const [false, false],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    _wrap(
      HomeHeroCard(
        babyName: 'Milkshake',
        ageMonths: 7,
        dateOfBirth: DateTime(2025, 6),
        mealCount: mealCount,
        mealTarget: mealTarget,
        introducedCount: introducedCount,
        ironRich: ironRich,
        hasActiveProgramAllergen: hasActiveProgramAllergen,
        heroState: heroState,
        allergenKey: allergenKey,
        allergenDisplayName: allergenKey == null ? '' : 'Milk',
        allergenReactionFlags: allergenReactionFlags,
        onStartTracker: () {},
        onOpenDetail: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomeHeroCard — stat rings', () {
    testWidgets('renders both rings with correct numerator / denominator', (
      tester,
    ) async {
      // Defaults are the asserted values (mealCount 1 / target 2,
      // introducedCount 4 / 11).
      await _pump(tester);

      expect(find.text('TODAY MEALS'), findsOneWidget);
      expect(find.text('ALLERGEN'), findsOneWidget);
      // Numerators (the greeting is a single Text.rich, so plain-digit
      // Text finders here only match the ring values).
      expect(find.text('1'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      // Denominators — allergen ring is always out of the Big-11.
      expect(find.text('/2'), findsOneWidget);
      expect(find.text('/11'), findsOneWidget);
    });
  });

  group('HomeHeroCard — status chips', () {
    testWidgets('no chips when neither flag is set', (tester) async {
      await _pump(tester);

      expect(find.text('Iron Rich'), findsNothing);
      expect(find.text('Active Program Allergens'), findsNothing);
    });

    testWidgets('both chips render when both flags are set', (tester) async {
      await _pump(tester, ironRich: true, hasActiveProgramAllergen: true);

      expect(find.text('Iron Rich'), findsOneWidget);
      expect(find.text('Active Program Allergens'), findsOneWidget);
    });
  });

  group('HomeHeroCard — hero allergen section switches on heroState', () {
    testWidgets('start -> StartAllergenButton, no ongoing card', (
      tester,
    ) async {
      // `start` is the default heroState.
      await _pump(tester);

      expect(find.byType(StartAllergenButton), findsOneWidget);
      expect(find.byType(OngoingAllergenCard), findsNothing);
      expect(find.text('ONGOING ALLERGEN'), findsNothing);
    });

    testWidgets('ongoing -> OngoingAllergenCard without inset start', (
      tester,
    ) async {
      await _pump(tester, heroState: HomeAllergenHeroState.ongoing);

      expect(find.byType(OngoingAllergenCard), findsOneWidget);
      expect(find.text('ONGOING ALLERGEN'), findsOneWidget);
      expect(find.byType(StartAllergenButton), findsNothing);
    });

    testWidgets('finishedStartNext -> OngoingAllergenCard with inset start', (
      tester,
    ) async {
      await _pump(tester, heroState: HomeAllergenHeroState.finishedStartNext);

      expect(find.byType(OngoingAllergenCard), findsOneWidget);
      expect(find.byType(StartAllergenButton), findsOneWidget);
    });

    testWidgets('allDone -> neither start button nor ongoing card', (
      tester,
    ) async {
      await _pump(
        tester,
        heroState: HomeAllergenHeroState.allDone,
        allergenKey: null,
      );

      expect(find.byType(StartAllergenButton), findsNothing);
      expect(find.byType(OngoingAllergenCard), findsNothing);
    });
  });
}
