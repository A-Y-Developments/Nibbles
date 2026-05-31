import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/allergen/log/widgets/attachment_sheet.dart';

class _ResultBox {
  AttachmentSheetResult? value;
  bool wasCalled = false;
}

/// Mounts a host page whose only button opens the Attachment sheet. Returns
/// a result holder updated when the sheet pops.
Future<_ResultBox> _openSheet(
  WidgetTester tester, {
  String? initialTitle,
  String? initialDescription,
}) async {
  final box = _ResultBox();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await showAttachmentSheet(
                  ctx,
                  initialTitle: initialTitle,
                  initialDescription: initialDescription,
                );
                box
                  ..value = result
                  ..wasCalled = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return box;
}

void main() {
  group('AttachmentSheet', () {
    testWidgets('renders title, fields and CTA buttons', (tester) async {
      await _openSheet(tester);

      expect(find.text('Attachment'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Tap to add photo'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('hydrates inputs from initial values', (tester) async {
      await _openSheet(
        tester,
        initialTitle: 'Seeded title',
        initialDescription: 'Seeded description',
      );

      expect(find.text('Seeded title'), findsOneWidget);
      expect(find.text('Seeded description'), findsOneWidget);
    });

    testWidgets(
      'Cancel returns null — typed text is discarded',
      (tester) async {
        final box = await _openSheet(tester);

        await tester.enterText(
          find.byKey(const Key('attachment_title_field')),
          'Should not commit',
        );
        await tester.tap(find.byKey(const Key('attachment_cancel_button')));
        await tester.pumpAndSettle();

        expect(box.wasCalled, isTrue);
        expect(box.value, isNull);
      },
    );

    testWidgets(
      'Add returns the typed title and description',
      (tester) async {
        final box = await _openSheet(tester);

        await tester.enterText(
          find.byKey(const Key('attachment_title_field')),
          'Rash on cheek area',
        );
        await tester.enterText(
          find.byKey(const Key('attachment_description_field')),
          'Taken 30 min after feeding',
        );
        await tester.tap(find.byKey(const Key('attachment_add_button')));
        await tester.pumpAndSettle();

        expect(box.wasCalled, isTrue);
        expect(box.value, isNotNull);
        expect(box.value!.title, 'Rash on cheek area');
        expect(box.value!.description, 'Taken 30 min after feeding');
        expect(box.value!.photoPath, isNull);
      },
    );
  });
}
