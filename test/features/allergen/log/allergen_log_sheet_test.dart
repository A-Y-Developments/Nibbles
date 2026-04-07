import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_sheet.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';

class MockAllergenLogController extends AllergenLogController {
  @override
  AllergenLogState build() => const AllergenLogState();
}

void main() {
  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        allergenLogControllerProvider.overrideWith(
          MockAllergenLogController.new,
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: AllergenLogSheet(
              babyId: 'baby-1',
              allergenKey: 'peanut',
              allergenName: 'Peanut',
              allergenEmoji: '🥜',
            ),
          ),
        ),
      ),
    );
  }

  group('AllergenLogSheet', () {
    testWidgets('shows header with allergen name', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Peanut'), findsWidgets);
    });

    testWidgets('shows three taste options', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Love it'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
      expect(find.text('Dislike'), findsOneWidget);
    });

    testWidgets('reaction toggle is visible', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Any reaction?'), findsOneWidget);
      expect(find.byKey(const Key('reaction_toggle')), findsOneWidget);
    });

    testWidgets('reaction toggle expands severity chips', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Severity chips should not be visible initially
      expect(find.text('Mild'), findsNothing);

      // Toggle reaction on via the SwitchListTile
      await tester.tap(find.byKey(const Key('reaction_toggle')));
      await tester.pumpAndSettle();

      // Now severity chips should be visible
      expect(find.text('Mild'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Severe'), findsOneWidget);
    });

    testWidgets('photo capture button is present', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('photo_capture_button')), findsOneWidget);
    });
  });
}
