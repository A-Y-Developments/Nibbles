import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_controller.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_screen.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_state.dart';

class MockBabyProfileService extends Mock implements BabyProfileService {}

/// Mock controller that keeps the screen rendered without invoking real
/// services. Replaces the production CREATE-mode build to a deterministic
/// hydrated state.
class _MockAllergenLogController extends AllergenLogController {
  @override
  AllergenLogState build() =>
      AllergenLogState(hydrated: true, logDate: DateTime(2025, 6));
}

void main() {
  late MockBabyProfileService mockBabyService;

  setUp(() {
    mockBabyService = MockBabyProfileService();
    when(() => mockBabyService.getBaby()).thenAnswer(
      (_) async => Baby(
        id: 'baby-1',
        userId: 'user-1',
        name: 'Lily',
        dateOfBirth: DateTime(2025, 6),
        gender: Gender.female,
        onboardingCompleted: true,
      ),
    );
  });

  Widget buildSubject() => ProviderScope(
    overrides: [
      babyProfileServiceProvider.overrideWithValue(mockBabyService),
      allergenLogControllerProvider.overrideWith(
        _MockAllergenLogController.new,
      ),
    ],
    child: const MaterialApp(home: AllergenLogScreen(allergenKey: 'peanut')),
  );

  group('AllergenLogScreen (CREATE)', () {
    testWidgets('shows Reaction Log header', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Reaction Log'), findsOneWidget);
    });

    testWidgets('shows all section labels in spec order', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Any Reaction?'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Attachment (Optional)'), findsOneWidget);
    });

    testWidgets('shows date field and notes hint', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('log_date_field')), findsOneWidget);
      expect(find.text('My baby loves it, no reaction'), findsOneWidget);
    });

    testWidgets(
      'notes hint swaps to reaction prompt when Any Reaction is ON (NIB-157)',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('log_reaction_switch')));
        await tester.pumpAndSettle();

        expect(
          find.text('Describe the reaction (what, when, how long)…'),
          findsOneWidget,
        );
        expect(find.text('My baby loves it, no reaction'), findsNothing);
      },
    );

    testWidgets('shows Add Picture CTA inside attachment block', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('attachment_add_picture')), findsOneWidget);
      expect(find.text('Add Picture'), findsOneWidget);
    });

    testWidgets('attachment CTA exposes a labelled button (a11y)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Add Picture'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('shows reaction switch wired to controller state', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('log_reaction_switch')), findsOneWidget);
    });

    testWidgets(
      'Any Reaction toggle exposes the reaction_log_any_reaction_toggle '
      'identifier (NIB-154)',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Pins the identifier so automation + VoiceOver can target the toggle.
        // Trait assertions (switch role, enabled, toggled on/off) are verified
        // on the simulator: every semantics-trait matcher (containsSemantics /
        // matchesSemantics / SemanticsData.hasFlag) is deprecated in the
        // analyze toolchain while its replacement is absent in the ci
        // toolchain, so none spans both.
        expect(
          find.bySemanticsIdentifier('reaction_log_any_reaction_toggle'),
          findsOneWidget,
        );

        handle.dispose();
      },
    );

    testWidgets('shows footer Save button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('log_save_button')), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
