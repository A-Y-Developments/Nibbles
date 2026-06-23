// Widget tests for the bespoke 5 Sign Readiness view.
//
// Asserts the signs card reflects the baby's persisted readiness result:
//   * score chip = signs met / 6
//   * each sign row shows a met (check) or not-met (cancel) glyph
//   * section heading uses the baby's first name

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/onboarding/readiness/readiness_signs.dart';
import 'package:nibbles/src/features/starting_guide/readiness_signs/readiness_signs_view.dart';

Baby _baby({required String name, required List<bool> signs}) => Baby(
  id: 'baby-1',
  userId: 'user-1',
  name: name,
  dateOfBirth: DateTime(2024, 6),
  gender: Gender.female,
  onboardingCompleted: true,
  readinessSigns: signs,
);

Future<void> _pump(WidgetTester tester, Baby? baby) async {
  tester.view.physicalSize = const Size(1080, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [currentBabyProvider.overrideWith((ref) async => baby)],
      child: MaterialApp(home: ReadinessSignsView(onBack: () {})),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('reflects the persisted result: 4/6 + name + per-sign glyphs', (
    tester,
  ) async {
    // Pediatrician gate + first 3 signs met, last 2 not -> 4/6.
    await _pump(
      tester,
      _baby(
        name: 'Asther Lee',
        signs: const [true, true, true, true, false, false],
      ),
    );

    expect(find.text('Readiness Signs'), findsOneWidget);
    expect(find.text('4/6'), findsOneWidget);
    expect(find.text('Asther readiness result'), findsOneWidget);

    for (final label in kReadinessSignLabels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
    expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(2));
  });

  testWidgets('no baby -> 0/6 with name fallback', (tester) async {
    await _pump(tester, null);

    expect(find.text('0/6'), findsOneWidget);
    expect(find.text('Your baby readiness result'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(6));
  });
}
