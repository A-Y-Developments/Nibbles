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
    child: const MaterialApp(
      home: AllergenLogScreen(allergenKey: 'peanut'),
    ),
  );

  group('AllergenLogScreen (CREATE)', () {
    testWidgets('shows Add Log header', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Add Log'), findsOneWidget);
    });

    testWidgets('shows three taste options', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Love it'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
      expect(find.text('Dislike'), findsOneWidget);
    });

    testWidgets('shows reaction question', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Any reaction?'), findsOneWidget);
    });

    testWidgets('shows photo capture CTA', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Add Photo'), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('log_save_button')), findsOneWidget);
      expect(find.text('Save Log'), findsOneWidget);
    });
  });
}
