// NIB-131 — widget tests for the reusable LoadingConfirmation composite.
//
// Covers:
//   - Loading phase: blob + UPPERCASE "Loading" caption visible at full
//     opacity; success label laid out but transparent (zero layout shift on
//     transition).
//   - Success phase: success label fully visible; "Loading" caption stays
//     mounted at 0.55 opacity (cross-fade snapshot from the Figma audit).
//   - Caller-supplied keys propagate to the blob + both labels so screen-
//     level tests can target them.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/feedback/loading_confirmation.dart';

const _blobKey = Key('test_blob');
const _loadingKey = Key('test_loading');
const _successKey = Key('test_success');

Widget _hostFor(LoadingConfirmationPhase phase) => MaterialApp(
  home: Scaffold(
    body: LoadingConfirmation(
      phase: phase,
      successLabel: 'You all set!',
      blobKey: _blobKey,
      loadingLabelKey: _loadingKey,
      successLabelKey: _successKey,
    ),
  ),
);

/// Reads the *target* opacity of the [AnimatedOpacity] wrapping the widget
/// keyed [key]. Target (not currently-tweened) opacity deterministically
/// reflects the phase regardless of where the cross-fade sits at the moment
/// of the assertion.
double _opacityOf(WidgetTester tester, Key key) {
  final ancestor = tester.widget<AnimatedOpacity>(
    find.ancestor(of: find.byKey(key), matching: find.byType(AnimatedOpacity)),
  );
  return ancestor.opacity;
}

void main() {
  testWidgets('loading phase renders blob + UPPERCASE caption at full opacity',
      (tester) async {
    await tester.pumpWidget(_hostFor(LoadingConfirmationPhase.loading));
    await tester.pump();

    expect(find.byKey(_blobKey), findsOneWidget);
    expect(find.byKey(_loadingKey), findsOneWidget);
    // Verbatim copy from Figma — uppercased via `.toUpperCase()` per spec
    // (Inter Regular 12.8 / tracking 4.33 / uppercase).
    expect(find.text('LOADING'), findsOneWidget);

    // Success label is always in the tree so the layout never shifts on
    // transition — visibility is gated by AnimatedOpacity.
    expect(find.byKey(_successKey), findsOneWidget);
    expect(find.text('You all set!'), findsOneWidget);
    expect(_opacityOf(tester, _successKey), 0.0);
    expect(_opacityOf(tester, _loadingKey), 1.0);
  });

  testWidgets('success phase shows success label and fades loading caption',
      (tester) async {
    await tester.pumpWidget(_hostFor(LoadingConfirmationPhase.success));
    await tester.pump();

    expect(find.byKey(_successKey), findsOneWidget);
    expect(find.text('You all set!'), findsOneWidget);
    // Caption stays mounted but low-opacity per the Figma cross-fade snapshot.
    expect(find.text('LOADING'), findsOneWidget);
    expect(_opacityOf(tester, _successKey), 1.0);
    expect(_opacityOf(tester, _loadingKey), 0.55);
  });

  testWidgets('caller-supplied success label overrides the default',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingConfirmation(
            phase: LoadingConfirmationPhase.success,
            successLabel: 'Custom done copy',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Custom done copy'), findsOneWidget);
    expect(find.text('You all set!'), findsNothing);
  });
}
