import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/services/feedback_service.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_controller.dart';
import 'package:nibbles/src/features/profile/feedback/feedback_state.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../../support/fake_analytics.dart';

class _MockFeedbackService extends Mock implements FeedbackService {}

/// Captures the (reason, error string) tuple recorded by the controller's
/// non-fatal Crashlytics path, so tests can assert the P2 telemetry payload
/// without touching real Firebase.
class _CrashCapture {
  final List<({String? reason, String error})> calls = [];

  Future<void> record(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    calls.add((reason: reason, error: error.toString()));
  }
}

void main() {
  late _MockFeedbackService mockService;
  late FakeAnalytics fakeAnalytics;
  late _CrashCapture crashCapture;
  late ProviderContainer container;

  setUp(() {
    mockService = _MockFeedbackService();
    fakeAnalytics = FakeAnalytics();
    crashCapture = _CrashCapture();

    container = ProviderContainer(
      overrides: [
        feedbackServiceProvider.overrideWithValue(mockService),
        analyticsProvider.overrideWithValue(fakeAnalytics),
        feedbackCrashRecorderProvider.overrideWithValue(crashCapture.record),
      ],
    )
    // Hold the controller alive across awaits so state isn't lost to
    // auto-dispose between assertions.
    ..listen<FeedbackState>(feedbackControllerProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  FeedbackController readController() =>
      container.read(feedbackControllerProvider.notifier);

  group('FeedbackController.submit', () {
    test(
      'success: calls service, records logFeedbackSubmitted, returns true',
      () async {
        when(
          () => mockService.submit(any()),
        ).thenAnswer((_) async => const Result.success(null));

        readController().updateMessage('valid message');
        final ok = await readController().submit();

        // Drain pending fire-and-forget microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(ok, isTrue);
        verify(() => mockService.submit('valid message')).called(1);
        expect(fakeAnalytics.eventNames, contains('feedback_submitted'));
        expect(crashCapture.calls, isEmpty);

        final state = container.read(feedbackControllerProvider);
        expect(state.phase, FeedbackPhase.success);
        expect(state.errorMessage, isNull);
      },
    );

    test(
      'failure: sets errorMessage, records crash with reason, returns false',
      () async {
        when(() => mockService.submit(any())).thenAnswer(
          (_) async => const Result.failure(ServerException('save failed')),
        );

        readController().updateMessage('msg');
        final ok = await readController().submit();

        expect(ok, isFalse);
        final state = container.read(feedbackControllerProvider);
        expect(state.phase, FeedbackPhase.idle);
        expect(state.errorMessage, 'save failed');

        expect(crashCapture.calls, hasLength(1));
        expect(
          crashCapture.calls.first.reason,
          'profile_feedback_submit_failure',
        );
        expect(
          crashCapture.calls.first.error,
          contains('profile_feedback_submit_failure'),
        );
        expect(crashCapture.calls.first.error, contains('save failed'));

        // Analytics success event must NOT fire on the failure branch.
        expect(
          fakeAnalytics.eventNames,
          isNot(contains('feedback_submitted')),
        );
      },
    );

    test(
      'empty message: short-circuits without calling service or analytics',
      () async {
        // Default state.message is ''. No updateMessage call.
        final ok = await readController().submit();

        expect(ok, isFalse);
        verifyNever(() => mockService.submit(any()));
        expect(
          fakeAnalytics.eventNames,
          isNot(contains('feedback_submitted')),
        );
        expect(crashCapture.calls, isEmpty);
        expect(
          container.read(feedbackControllerProvider).phase,
          FeedbackPhase.idle,
        );
      },
    );

    test(
      'whitespace-only message: short-circuits without calling service',
      () async {
        readController().updateMessage('   \n\t  ');
        final ok = await readController().submit();

        expect(ok, isFalse);
        verifyNever(() => mockService.submit(any()));
      },
    );

    test(
      'updateMessage clears any prior errorMessage',
      () async {
        when(() => mockService.submit(any())).thenAnswer(
          (_) async => const Result.failure(NetworkException('offline')),
        );

        readController().updateMessage('first try');
        await readController().submit();
        expect(
          container.read(feedbackControllerProvider).errorMessage,
          'offline',
        );

        readController().updateMessage('first try edited');
        expect(
          container.read(feedbackControllerProvider).errorMessage,
          isNull,
        );
      },
    );
  });
}
