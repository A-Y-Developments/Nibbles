// NIB-82 — widget tests for the cancel-subscription reason overlay.
//
// Covers:
//   - Sheet renders verbatim heading (U+2019 apostrophe) on open.
//   - Continue is disabled until a reason chip is tapped.
//   - Tapping Continue:
//       * fires `subscription_cancel_started` + `subscription_cancel_reason`
//         with the stable `analyticsKey` (NOT the verbatim label).
//       * calls SubscriptionService.openManagementPage (via the injected
//         launcher fn — never hits the platform channel).
//       * pops the sheet on success.
//   - URL-open failure surfaces the P2 SnackBar and keeps the sheet open.
//   - Cancel and close (X) pop the sheet without launching anything.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/services/subscription_service.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_reason.dart';
import 'package:nibbles/src/features/subscription/cancel/cancel_subscription_overlay.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../support/fake_analytics.dart';

/// Verbatim sheet heading from Figma 1216:12029 (U+2019 apostrophe).
const _kHeading = 'Tell us why you’re canceling';

/// First reason label — verbatim from Figma 1216:12030.
const _kFirstReasonLabel = 'I achieved my goal already';

/// Stable analytics key for the first reason. MUST match the enum mapping in
/// lib/src/features/subscription/cancel/cancel_reason.dart.
const _kFirstReasonAnalyticsKey = 'achieved_goal';

class _LaunchRecorder {
  int calls = 0;
  Uri? lastUri;
  LaunchMode? lastMode;
  bool result = true;

  Future<bool> call(Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
    calls += 1;
    lastUri = uri;
    lastMode = mode;
    return Future.value(result);
  }
}

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('open_sheet'),
              onPressed: () => showCancelSubscriptionOverlay(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open_sheet')));
  await tester.pumpAndSettle();
}

/// Default test surface is 800x600 — too short for the 92% bottom sheet to
/// fit the chips + both CTAs. Bump to a tall portrait window large enough
/// for everything to render on-screen.
Future<void> _setTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// 30s budget — tight enough to catch settle hangs introduced by future
// changes to the deep-link wiring.
const _testTimeout = Timeout(Duration(seconds: 30));

void main() {
  late FakeAnalytics fakeAnalytics;
  late _LaunchRecorder launcher;

  setUp(() {
    fakeAnalytics = FakeAnalytics();
    launcher = _LaunchRecorder();
  });

  List<Override> overrides() => [
    analyticsProvider.overrideWithValue(fakeAnalytics),
    subscriptionLaunchUrlProvider.overrideWithValue(launcher.call),
  ];

  testWidgets('renders verbatim heading + 6 reason chips on open', (
    tester,
  ) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    expect(find.text(_kHeading), findsOneWidget);
    for (var i = 0; i < CancelReason.values.length; i++) {
      expect(find.byKey(Key('cancel_subscription_reason_$i')), findsOneWidget);
    }
    // First reason label — verbatim from Figma.
    expect(find.text(_kFirstReasonLabel), findsOneWidget);
  }, timeout: _testTimeout);

  testWidgets('Continue is disabled when no reason is selected', (
    tester,
  ) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    final continueBtn = tester.widget<AppPillButton>(
      find.byKey(const Key('cancel_subscription_continue_button')),
    );
    expect(continueBtn.onPressed, isNull);
  }, timeout: _testTimeout);

  testWidgets('tapping a reason chip enables Continue', (tester) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    await tester.tap(find.byKey(const Key('cancel_subscription_reason_0')));
    await tester.pumpAndSettle();

    final continueBtn = tester.widget<AppPillButton>(
      find.byKey(const Key('cancel_subscription_continue_button')),
    );
    expect(continueBtn.onPressed, isNotNull);
  }, timeout: _testTimeout);

  testWidgets(
    'tapping Continue logs analytics with analyticsKey and launches URL',
    (tester) async {
      await _setTallSurface(tester);
      await tester.pumpWidget(_wrap(overrides()));
      await _openSheet(tester);

      await tester.tap(find.byKey(const Key('cancel_subscription_reason_0')));
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('cancel_subscription_continue_button')),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('cancel_subscription_continue_button')),
      );
      await tester.pumpAndSettle();

      // Both intent events fire BEFORE the launch.
      expect(
        fakeAnalytics.eventNames,
        containsAll(<String>[
          'subscription_cancel_started',
          'subscription_cancel_reason',
        ]),
      );
      final startedEvt = fakeAnalytics.calls.firstWhere(
        (c) => c.name == 'subscription_cancel_started',
      );
      expect(startedEvt.parameters['reason'], _kFirstReasonAnalyticsKey);
      final reasonEvt = fakeAnalytics.calls.firstWhere(
        (c) => c.name == 'subscription_cancel_reason',
      );
      expect(reasonEvt.parameters['reason'], _kFirstReasonAnalyticsKey);

      // Launcher hit exactly once, in externalApplication mode.
      expect(launcher.calls, 1);
      expect(launcher.lastMode, LaunchMode.externalApplication);
      expect(launcher.lastUri, isNotNull);

      // Sheet popped on success.
      expect(find.text(_kHeading), findsNothing);
    },
    timeout: _testTimeout,
  );

  testWidgets(
    'URL-open failure surfaces P2 SnackBar and keeps sheet open',
    (tester) async {
      launcher.result = false;
      await _setTallSurface(tester);
      await tester.pumpWidget(_wrap(overrides()));
      await _openSheet(tester);

      await tester.tap(find.byKey(const Key('cancel_subscription_reason_0')));
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('cancel_subscription_continue_button')),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('cancel_subscription_continue_button')),
      );
      await tester.pumpAndSettle();

      // Sheet remains open so the user can retry.
      expect(find.text(_kHeading), findsOneWidget);
      // Verbatim P2 toast copy.
      expect(
        find.text("Couldn't open subscription settings. Try again."),
        findsOneWidget,
      );
    },
    timeout: _testTimeout,
  );

  testWidgets(
    'tapping Cancel pops the sheet without launching anything',
    (tester) async {
      await _setTallSurface(tester);
      await tester.pumpWidget(_wrap(overrides()));
      await _openSheet(tester);

      expect(find.text(_kHeading), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('cancel_subscription_cancel_button')),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('cancel_subscription_cancel_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text(_kHeading), findsNothing);
      expect(launcher.calls, 0);
      // Cancel must NOT have fired the intent events.
      expect(
        fakeAnalytics.eventNames,
        isNot(contains('subscription_cancel_started')),
      );
    },
    timeout: _testTimeout,
  );

  testWidgets('close (X) pops the sheet without launching anything', (
    tester,
  ) async {
    await _setTallSurface(tester);
    await tester.pumpWidget(_wrap(overrides()));
    await _openSheet(tester);

    expect(find.text(_kHeading), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel_subscription_close_button')));
    await tester.pumpAndSettle();

    expect(find.text(_kHeading), findsNothing);
    expect(launcher.calls, 0);
  }, timeout: _testTimeout);
}
