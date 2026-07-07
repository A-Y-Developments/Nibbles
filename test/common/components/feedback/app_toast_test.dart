// Widget tests for the shared AppToast helper — covers success/error tone
// rendering and the shared auto-dismiss duration constant.
//
// `toastification` inserts its item via a post-frame callback, and the
// `AnimatedList` holding it only mounts on the frame after the overlay entry
// is first inserted — two pumps are needed after the triggering tap before
// the toast widget itself is queryable. Every test also pumps well past
// [kAppToastDuration] before finishing so the library's auto-close `Timer`
// fires and clears before test teardown (flutter_test asserts no pending
// timers survive a test).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/feedback/app_toast.dart';
import 'package:toastification/toastification.dart';

const _settleBuffer = Duration(milliseconds: 700);

Widget _hostFor(void Function(BuildContext context) onPressed) {
  return ToastificationWrapper(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text('trigger'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _showAndSettle(WidgetTester tester) async {
  await tester.tap(find.text('trigger'));
  await tester.pump();
  await tester.pump();
  await tester.pump(_settleBuffer);
}

Future<void> _flushAutoClose(WidgetTester tester) async {
  await tester.pump(kAppToastDuration + _settleBuffer);
  await tester.pump(_settleBuffer);
}

void main() {
  testWidgets('success toast renders the message with a check icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _hostFor((context) => AppToast.success(context, 'Profile updated.')),
    );
    await _showAndSettle(tester);

    expect(find.text('Profile updated.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await _flushAutoClose(tester);
  });

  testWidgets('error toast renders the message with an error icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _hostFor(
        (context) => AppToast.error(context, "Couldn't add items. Try again."),
      ),
    );
    await _showAndSettle(tester);

    expect(find.text("Couldn't add items. Try again."), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    await _flushAutoClose(tester);
  });

  testWidgets('toast auto-dismisses after kAppToastDuration', (tester) async {
    await tester.pumpWidget(
      _hostFor((context) => AppToast.success(context, 'Saved.')),
    );
    await _showAndSettle(tester);

    expect(find.text('Saved.'), findsOneWidget);

    await _flushAutoClose(tester);

    expect(find.text('Saved.'), findsNothing);
  });
}
