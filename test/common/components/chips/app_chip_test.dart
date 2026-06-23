import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/chips/app_chip.dart';

void main() {
  testWidgets(
    'AppChip is content-sized inside a Wrap — not stretched to full width',
    (tester) async {
      // A Wrap hands its children loose-bounded constraints. A previous stray
      // `alignment: Alignment.center` made the chip greedily fill that width,
      // so chips stacked full-width instead of flowing inline. This pins the
      // chip to its intrinsic width.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: Wrap(children: [AppChip(label: 'Iron Rich')]),
            ),
          ),
        ),
      );

      final chipWidth = tester.getSize(find.byType(AppChip)).width;
      expect(chipWidth, lessThan(160));
    },
  );

  testWidgets('two short chips flow on the same Wrap line (inline)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: Wrap(
              children: [
                AppChip(label: 'Iron Rich'),
                AppChip(label: 'Protein'),
              ],
            ),
          ),
        ),
      ),
    );

    final chips = tester.widgetList<AppChip>(find.byType(AppChip)).toList();
    final a = tester.getTopLeft(find.byWidget(chips[0]));
    final b = tester.getTopLeft(find.byWidget(chips[1]));
    // Same line → identical dy; second chip sits to the right of the first.
    expect(a.dy, b.dy);
    expect(b.dx, greaterThan(a.dx));
  });
}
