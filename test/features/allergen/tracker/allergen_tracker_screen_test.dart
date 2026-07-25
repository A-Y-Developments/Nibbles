// Firebase platform-interface packages are transitive deps; the public barrels
// don't re-export FirebaseAnalyticsPlatform/setupFirebaseCoreMocks. Test-only.
// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_contextual_banner.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_screen.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_exposure_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/allergen_progress_card.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/start_introduce_card.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

/// No-op Firebase Analytics platform so the segment-change handler's
/// unawaited `Analytics.instance.logAllergenSegmentChanged(...)` doesn't throw.
class _NoopAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  _NoopAnalyticsPlatform() : super();

  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) => this;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {}
}

const _babyId = 'baby-001';
final _now = DateTime(2026, 3, 24);

final _baby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

const _allergens = [
  Allergen(key: 'milk', name: 'Milk', sequenceOrder: 1, emoji: '🥛'),
  Allergen(key: 'walnut', name: 'Walnut', sequenceOrder: 2, emoji: '🌰'),
  Allergen(key: 'peanut', name: 'Peanut', sequenceOrder: 3, emoji: '🥜'),
  Allergen(key: 'egg', name: 'Egg', sequenceOrder: 4, emoji: '🥚'),
  Allergen(key: 'cashew', name: 'Cashew', sequenceOrder: 5, emoji: '🌰'),
  Allergen(key: 'wheat', name: 'Wheat', sequenceOrder: 6, emoji: '🌾'),
  Allergen(key: 'prawn', name: 'Prawn', sequenceOrder: 7, emoji: '🦐'),
  Allergen(key: 'fish', name: 'Fish', sequenceOrder: 8, emoji: '🐟'),
  Allergen(key: 'sesame', name: 'Sesame', sequenceOrder: 9, emoji: '🫘'),
  Allergen(key: 'soybean', name: 'Soybean', sequenceOrder: 10, emoji: '🫘'),
  Allergen(key: 'almond', name: 'Almond', sequenceOrder: 11, emoji: '🌰'),
];

AllergenLog _makeLog({
  required String id,
  required String allergenKey,
  bool hadReaction = false,
}) => AllergenLog(
  id: id,
  babyId: _babyId,
  allergenKey: allergenKey,
  hadReaction: hadReaction,
  emojiTaste: EmojiTaste.love,
  logDate: _now,
  createdAt: _now,
);

/// Records the most-recent `pushNamed` so tests can assert navigation without
/// pulling in a real navigator stack.
class _PushRecorder {
  String? lastName;
  Map<String, String>? lastPathParams;
}

/// Tall viewport so the whole Keep Offering sliver (card, banner, log feed and
/// the bottom Start New CTA) builds — the default 600px height leaves the CTA
/// and add button unbuilt below the fold.
void _useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late _MockAllergenService mockService;
  late _MockBabyProfileService mockBabyService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = _NoopAnalyticsPlatform();
  });

  setUp(() {
    mockService = _MockAllergenService();
    mockBabyService = _MockBabyProfileService();
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _baby);
  });

  /// Stubs the three reads the tracker controller composes.
  void stubReads({
    required Map<String, AllergenStatus> statuses,
    List<AllergenLog> logs = const [],
  }) {
    when(
      () => mockService.getAllergens(),
    ).thenAnswer((_) async => const Result.success(_allergens));
    when(
      () => mockService.getAllergenStatuses(any()),
    ).thenAnswer((_) async => Result.success(statuses));
    when(
      () => mockService.getLogs(any()),
    ).thenAnswer((_) async => Result.success(logs));
    // Program-state read backs the "Introduce" selection overlay; a
    // failure degrades gracefully (no selected allergen). The board falls back
    // to the inProgress-status / most-recent-log display allergen.
    when(
      () => mockService.getProgramState(any()),
    ).thenAnswer((_) async => const Result.failure(UnknownException()));
  }

  Widget buildSubject(_PushRecorder recorder) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const AllergenTrackerScreen()),
        GoRoute(
          path: AppRoute.allergenDetail.path,
          name: AppRoute.allergenDetail.name,
          builder: (ctx, st) {
            recorder
              ..lastName = AppRoute.allergenDetail.name
              ..lastPathParams = st.pathParameters;
            // Poppable so the "refresh on return" test can navigate back.
            return Scaffold(
              body: TextButton(
                onPressed: ctx.pop,
                child: const Text('DETAIL_STUB'),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoute.allergenLogDetail.path,
          name: AppRoute.allergenLogDetail.name,
          builder: (_, __) => const Scaffold(body: Text('LOG_DETAIL_STUB')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        allergenServiceProvider.overrideWithValue(mockService),
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  // ---------------------------------------------------------------------------
  // Board content: Keep Offering, All Allergen, stat columns, segment switch.
  // ---------------------------------------------------------------------------

  group('AllergenTrackerScreen board', () {
    // milk ongoing, walnut + egg safe, peanut flagged, the remaining 7 not
    // introduced → Tolerated=2, Reaction Recorded=1, Keep Offering=1,
    // Not Introduced=7.
    Map<String, AllergenStatus> statusesMixed() => {
      'milk': AllergenStatus.inProgress,
      'walnut': AllergenStatus.safe,
      'peanut': AllergenStatus.flagged,
      'egg': AllergenStatus.safe,
      for (final a in _allergens.where(
        (a) => !const {'milk', 'walnut', 'peanut', 'egg'}.contains(a.key),
      ))
        a.key: AllergenStatus.notStarted,
    };

    testWidgets(
      'Keep Offering tab shows the in-progress allergen hero; switching to All '
      'Allergen reveals grouped sections AND the Not Introduced stat column',
      (tester) async {
        final logs = [
          _makeLog(id: 'm1', allergenKey: 'milk'),
          _makeLog(id: 'm2', allergenKey: 'milk'),
          _makeLog(id: 'w1', allergenKey: 'walnut'),
          _makeLog(id: 'w2', allergenKey: 'walnut'),
          _makeLog(id: 'w3', allergenKey: 'walnut'),
          _makeLog(id: 'p1', allergenKey: 'peanut', hadReaction: true),
          _makeLog(id: 'e1', allergenKey: 'egg'),
          _makeLog(id: 'e2', allergenKey: 'egg'),
          _makeLog(id: 'e3', allergenKey: 'egg'),
        ];
        stubReads(statuses: statusesMixed(), logs: logs);

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        // Keep Offering tab: burgundy exposure hero for the in-progress
        // allergen (milk) + its Reaction Log feed.
        expect(find.text('Allergen Exposure'), findsOneWidget);
        expect(find.byType(AllergenExposureCard), findsOneWidget);
        // "Tolerated" stat column is shown on the Keep Offering tab.
        expect(find.text('Tolerated'), findsOneWidget);
        expect(find.text('Reaction Recorded'), findsOneWidget);
        // Ring caption sits under the 4/11 fraction.
        expect(find.text('Introduced'), findsOneWidget);
        // The All-Allergen-only "Not Introduced" stat column is hidden here.
        expect(find.text('Not Introduced'), findsNothing);
        expect(find.text('Reaction Log', skipOffstage: false), findsOneWidget);

        // Switch to the All Allergen tab.
        await tester.tap(find.text('All Allergen'));
        await tester.pumpAndSettle();

        // Grouped sections — all three headers present. Sections below the
        // fold are not built by the lazy sliver, so match loosely; the
        // Already Tried header is always on-screen and pins the count format.
        expect(find.text('Already Tried'), findsOneWidget);
        expect(find.text('3/11 remaining'), findsOneWidget);
        expect(find.text('Keep Offering'), findsWidgets);
        expect(find.text('Not Introduced'), findsWidgets);
        // SliverList builds lazily — some StartIntroduceCards may be below
        // the fold. skipOffstage: false to include them.
        expect(
          find.byType(StartIntroduceCard, skipOffstage: false),
          findsWidgets,
        );
        // NIB-153 — every Introduce CTA carries a per-allergen
        // identifier so axe --id targeting is unambiguous.
        final semantics = tester.ensureSemantics();
        await tester.pump();
        final startIntroduceIdentifiers = tester
            .widgetList<StartIntroduceCard>(
              find.byType(StartIntroduceCard, skipOffstage: false),
            )
            .map(
              (card) =>
                  'allergen_start_introduce_button_'
                  '${card.allergen.key}',
            )
            .toList();
        expect(
          startIntroduceIdentifiers.toSet().length,
          startIntroduceIdentifiers.length,
        );
        for (final id in startIntroduceIdentifiers) {
          expect(
            find.bySemanticsIdentifier(id, skipOffstage: false),
            findsOneWidget,
            reason: id,
          );
        }
        semantics.dispose();
        // The flagged card badge uses the canonical "Unsafe" term (NIB-191).
        expect(find.text('Unsafe'), findsWidgets);
        // Stat-column numeric values: 7 not-tried, 1 flagged, 2 safe.
        expect(find.text('7'), findsWidgets);
        expect(find.text('1'), findsWidgets);
        expect(find.text('2'), findsWidgets);
      },
    );

    testWidgets(
      'Keep Offering tab keeps section scaffolding visible with per-section '
      'placeholders when there is no in-progress allergen',
      (tester) async {
        stubReads(
          statuses: {
            for (final a in _allergens) a.key: AllergenStatus.notStarted,
          },
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        // Section headers remain visible at zero data (Figma 1089:17373).
        expect(find.text('Allergen Exposure'), findsOneWidget);
        expect(find.text('Reaction Log', skipOffstage: false), findsOneWidget);
        // Per-section placeholders sit inside their sections.
        expect(
          find.text('No allergen is being introduced right now.'),
          findsOneWidget,
        );
        expect(
          find.text('No reactions logged yet', skipOffstage: false),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Keep Offering tab keeps the exposure hero + logs after an unsafe '
      'flags the allergen (feed does not vanish)',
      (tester) async {
        _useTallView(tester);
        // milk had an unsafe reaction → status flagged, no other inProgress
        // allergen and no active selection. The board must still surface milk
        // and its log via the most-recent-log fallback.
        stubReads(
          statuses: {
            'milk': AllergenStatus.flagged,
            for (final a in _allergens.where((a) => a.key != 'milk'))
              a.key: AllergenStatus.notStarted,
          },
          logs: [_makeLog(id: 'm1', allergenKey: 'milk', hadReaction: true)],
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        expect(find.byType(AllergenExposureCard), findsOneWidget);
        expect(find.text('Milk'), findsOneWidget);
        // The unsafe log row is present — not the empty placeholder.
        expect(find.text('Unsafe'), findsWidgets);
        expect(
          find.text('No reactions logged yet', skipOffstage: false),
          findsNothing,
        );
      },
    );

    testWidgets('Tapping Introduce opens the pre-introduce sheet '
        'WITHOUT navigating', (tester) async {
      stubReads(
        statuses: {
          for (final a in _allergens) a.key: AllergenStatus.notStarted,
        },
      );

      final recorder = _PushRecorder();
      await tester.pumpWidget(buildSubject(recorder));
      await tester.pumpAndSettle();

      // Switch to All Allergen so the Introduce cards render.
      await tester.tap(find.text('All Allergen'));
      await tester.pumpAndSettle();

      // Tap the first Introduce button.
      final firstStart = find.text('Introduce').first;
      await tester.ensureVisible(firstStart);
      await tester.tap(firstStart);
      await tester.pumpAndSettle();

      // The pre-introduce bottom sheet opens (first allergen in order = milk);
      // the selection is committed inside the sheet, not via a route.
      expect(find.text('Start Milk for 3 Times'), findsOneWidget);
      expect(recorder.lastName, isNull);
    });

    testWidgets('Introduce is disabled while another allergen is in progress', (
      tester,
    ) async {
      // egg is mid-introduction → single-active lock engaged.
      stubReads(
        statuses: {
          'egg': AllergenStatus.inProgress,
          for (final a in _allergens.where((a) => a.key != 'egg'))
            a.key: AllergenStatus.notStarted,
        },
        logs: [_makeLog(id: 'e1', allergenKey: 'egg')],
      );
      when(
        () => mockService.startIntroducingAllergen(
          babyId: any(named: 'babyId'),
          allergenKey: any(named: 'allergenKey'),
        ),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(buildSubject(_PushRecorder()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Allergen'));
      await tester.pumpAndSettle();

      final firstStart = find.text('Introduce').first;
      await tester.ensureVisible(firstStart);
      await tester.tap(firstStart);
      await tester.pumpAndSettle();

      // Locked: the CTA is disabled, so the service is never called.
      verifyNever(
        () => mockService.startIntroducingAllergen(
          babyId: any(named: 'babyId'),
          allergenKey: any(named: 'allergenKey'),
        ),
      );
    });

    testWidgets(
      'Tapping an allergen tile navigates to detail; returning refreshes '
      'the tracker so per-allergen status is not stale',
      (tester) async {
        stubReads(
          statuses: {
            'peanut': AllergenStatus.safe,
            for (final a in _allergens.where((a) => a.key != 'peanut'))
              a.key: AllergenStatus.notStarted,
          },
          logs: [
            _makeLog(id: 'p1', allergenKey: 'peanut'),
            _makeLog(id: 'p2', allergenKey: 'peanut'),
            _makeLog(id: 'p3', allergenKey: 'peanut'),
          ],
        );
        final recorder = _PushRecorder();
        await tester.pumpWidget(buildSubject(recorder));
        await tester.pumpAndSettle();

        // All Allergen renders an AllergenProgressCard for the safe peanut.
        await tester.tap(find.text('All Allergen'));
        await tester.pumpAndSettle();

        // Initial load fetched statuses exactly once (segment switch is local).
        verify(() => mockService.getAllergenStatuses(any())).called(1);

        final card = find.byType(AllergenProgressCard).first;
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();

        // Navigated to allergen-detail with the tapped key.
        expect(recorder.lastName, AppRoute.allergenDetail.name);
        expect(recorder.lastPathParams?['allergenKey'], 'peanut');
        expect(find.text('DETAIL_STUB'), findsOneWidget);

        // Return to the tracker → it must re-fetch (detail may have added a
        // log that changed this allergen's derived status).
        await tester.tap(find.text('DETAIL_STUB'));
        await tester.pumpAndSettle();

        verify(() => mockService.getAllergenStatuses(any())).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Ongoing tab — finished-state gating (banner + disabled add + Start New).
  // ---------------------------------------------------------------------------

  group('AllergenTrackerScreen — finished-state gating', () {
    testWidgets(
      'flagged ongoing allergen: contextual banner shows, add-reaction is '
      'disabled, and a Start New Allergen CTA appears',
      (tester) async {
        _useTallView(tester);
        stubReads(
          statuses: {
            'milk': AllergenStatus.flagged,
            for (final a in _allergens.where((a) => a.key != 'milk'))
              a.key: AllergenStatus.notStarted,
          },
          logs: [_makeLog(id: 'm1', allergenKey: 'milk', hadReaction: true)],
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        expect(find.byType(DetailContextualBanner), findsOneWidget);
        expect(find.byType(StartAllergenButton), findsOneWidget);

        // Add-reaction disabled → its InkWell has a null onTap.
        final addButton = tester.widget<InkWell>(
          find.widgetWithIcon(InkWell, Icons.add_rounded),
        );
        expect(addButton.onTap, isNull);
      },
    );

    testWidgets(
      'in-progress ongoing allergen: add-reaction enabled, no Start New CTA',
      (tester) async {
        _useTallView(tester);
        stubReads(
          statuses: {
            'milk': AllergenStatus.inProgress,
            for (final a in _allergens.where((a) => a.key != 'milk'))
              a.key: AllergenStatus.notStarted,
          },
          logs: [_makeLog(id: 'm1', allergenKey: 'milk')],
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        expect(find.byType(StartAllergenButton), findsNothing);

        // Add-reaction enabled → its InkWell has a non-null onTap.
        final addButton = tester.widget<InkWell>(
          find.widgetWithIcon(InkWell, Icons.add_rounded),
        );
        expect(addButton.onTap, isNotNull);
      },
    );

    testWidgets('Start New Allergen jumps to the All Allergen picker', (
      tester,
    ) async {
      _useTallView(tester);
      stubReads(
        statuses: {
          'milk': AllergenStatus.safe,
          for (final a in _allergens.where((a) => a.key != 'milk'))
            a.key: AllergenStatus.notStarted,
        },
        logs: [
          _makeLog(id: 'm1', allergenKey: 'milk'),
          _makeLog(id: 'm2', allergenKey: 'milk'),
          _makeLog(id: 'm3', allergenKey: 'milk'),
        ],
      );

      await tester.pumpWidget(buildSubject(_PushRecorder()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(StartAllergenButton));
      await tester.pumpAndSettle();

      // Grouped sections are now visible (tab switched locally).
      expect(find.text('Already Tried'), findsOneWidget);
      expect(find.byType(AllergenProgressCard), findsWidgets);
    });
  });
}
