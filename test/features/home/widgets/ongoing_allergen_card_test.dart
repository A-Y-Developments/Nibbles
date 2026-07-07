// Widget coverage for `OngoingAllergenCard` — the burgundy "ongoing allergen"
// card in the Home hero. Asserts the name + "N/3 times" copy, the 3-segment
// progress bar, the conditional inset start button and the tap callbacks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_segment_bar.dart';
import 'package:nibbles/src/features/home/widgets/ongoing_allergen_card.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

OngoingAllergenCard _card({
  List<bool> reactionFlags = const [false, false],
  bool showStartButton = false,
  VoidCallback? onTap,
  VoidCallback? onStart,
}) => OngoingAllergenCard(
  allergenKey: 'milk',
  displayName: 'Milk',
  reactionFlags: reactionFlags,
  showStartButton: showStartButton,
  onTap: onTap ?? () {},
  onStart: onStart,
);

void main() {
  group('OngoingAllergenCard — content', () {
    testWidgets('renders name + "N/3 times" + a 3-segment bar', (tester) async {
      await tester.pumpWidget(_wrap(_card()));

      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('2/3 times'), findsOneWidget);
      expect(find.byType(DetailSegmentBar), findsOneWidget);
    });

    testWidgets('a reaction exposure still counts toward the total', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_card(reactionFlags: const [false, true])));

      expect(find.text('2/3 times'), findsOneWidget);
    });

    testWidgets('exposure count is clamped to the 3-times target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_card(reactionFlags: const [false, false, false, false, false])),
      );

      expect(find.text('3/3 times'), findsOneWidget);
    });
  });

  group('OngoingAllergenCard — inset start button', () {
    testWidgets('absent when showStartButton is false', (tester) async {
      await tester.pumpWidget(_wrap(_card()));

      expect(find.byType(StartAllergenButton), findsNothing);
    });

    testWidgets('present when showStartButton is true', (tester) async {
      await tester.pumpWidget(_wrap(_card(showStartButton: true)));

      expect(find.byType(StartAllergenButton), findsOneWidget);
    });

    testWidgets('inset start button fires onStart', (tester) async {
      var started = false;
      await tester.pumpWidget(
        _wrap(_card(showStartButton: true, onStart: () => started = true)),
      );

      await tester.tap(find.byType(StartAllergenButton));
      expect(started, isTrue);
    });
  });

  group('OngoingAllergenCard — row tap', () {
    testWidgets('tapping the row fires onTap', (tester) async {
      var opened = false;
      await tester.pumpWidget(_wrap(_card(onTap: () => opened = true)));

      await tester.tap(find.byType(InkWell));
      expect(opened, isTrue);
    });
  });
}
