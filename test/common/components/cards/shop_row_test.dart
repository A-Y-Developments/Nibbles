import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/common/components/cards/shop_row.dart';

Widget _wrap({
  required String label,
  required bool isBought,
  required VoidCallback onToggle,
  required VoidCallback onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ShopRow(
          label: label,
          isBought: isBought,
          onToggle: onToggle,
          onDelete: onDelete,
        ),
      ),
    ),
  );
}

void main() {
  group('ShopRow (NIB-54)', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          label: 'Bananas',
          isBought: false,
          onToggle: () {},
          onDelete: () {},
        ),
      );

      expect(find.text('Bananas'), findsOneWidget);
    });

    testWidgets('tap on checkbox fires onToggle', (tester) async {
      var toggled = 0;
      await tester.pumpWidget(
        _wrap(
          label: 'Bananas',
          isBought: false,
          onToggle: () => toggled++,
          onDelete: () {},
        ),
      );

      // The unbought row has no check icon; tap the leading 22x22 box by
      // hitting the Semantics node flagged checked: false.
      final cb = find.byWidgetPredicate((w) {
        if (w is! Semantics) return false;
        final checked = w.properties.checked;
        return checked != null && !checked;
      });
      await tester.tap(cb);
      await tester.pump();

      expect(toggled, 1);
    });

    testWidgets('tap on delete fires onDelete', (tester) async {
      var deleted = 0;
      await tester.pumpWidget(
        _wrap(
          label: 'Bananas',
          isBought: false,
          onToggle: () {},
          onDelete: () => deleted++,
        ),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(deleted, 1);
    });

    testWidgets('bought state shows check glyph and strikethrough label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          label: 'Whole-wheat pasta',
          isBought: true,
          onToggle: () {},
          onDelete: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Check glyph rendered.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Label is strikethrough + faint.
      final label = tester.widget<Text>(find.text('Whole-wheat pasta'));
      expect(label.style?.decoration, TextDecoration.lineThrough);
      expect(label.style?.color, AppColors.fgFaint);
    });

    testWidgets('long label ellipsises', (tester) async {
      const longText = 'A really long ingredient name that should ellipsize';
      await tester.pumpWidget(
        _wrap(
          label: longText,
          isBought: false,
          onToggle: () {},
          onDelete: () {},
        ),
      );

      final label = tester.widget<Text>(find.text(longText));
      expect(label.overflow, TextOverflow.ellipsis);
      expect(label.maxLines, 1);
    });
  });
}
