// Widget coverage for `HomeHeader` — focuses on the avatar's a11y contract:
// the tappable avatar must expose a labelled button role, and must stay a
// plain (non-button) graphic when no tap handler is wired.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/home/widgets/home_header.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('avatar exposes a Profile button + fires onAvatarTap', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        HomeHeader(
          babyName: 'Mia',
          ageMonths: 7,
          onAvatarTap: () => tapped = true,
        ),
      ),
    );

    // The avatar wraps in Semantics(button: true, label: 'Profile'); the
    // labelled node is the accessible name a screen reader announces (the
    // icon alone carried none). Tapping it must fire the handler.
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile'));
    expect(tapped, isTrue);

    handle.dispose();
  });

  testWidgets('no onAvatarTap -> avatar is not a button', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(const HomeHeader(babyName: 'Mia', ageMonths: 7)),
    );

    expect(find.bySemanticsLabel('Profile'), findsNothing);

    handle.dispose();
  });
}
