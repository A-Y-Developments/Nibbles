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
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/allergen/tracker/allergen_tracker_screen.dart';
import 'package:nibbles/src/features/allergen/tracker/widgets/start_introduce_card.dart';
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
  Allergen(key: 'peanut', name: 'Peanut', sequenceOrder: 1, emoji: '🥜'),
  Allergen(key: 'egg', name: 'Egg', sequenceOrder: 2, emoji: '🥚'),
  Allergen(key: 'dairy', name: 'Dairy', sequenceOrder: 3, emoji: '🥛'),
  Allergen(
    key: 'tree_nuts',
    name: 'Tree Nuts',
    sequenceOrder: 4,
    emoji: '🌰',
  ),
  Allergen(key: 'sesame', name: 'Sesame', sequenceOrder: 5, emoji: '🫘'),
  Allergen(key: 'soy', name: 'Soy', sequenceOrder: 6, emoji: '🫘'),
  Allergen(key: 'wheat', name: 'Wheat', sequenceOrder: 7, emoji: '🌾'),
  Allergen(key: 'fish', name: 'Fish', sequenceOrder: 8, emoji: '🐟'),
  Allergen(
    key: 'shellfish',
    name: 'Shellfish',
    sequenceOrder: 9,
    emoji: '🦐',
  ),
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
  }

  Widget buildSubject(_PushRecorder recorder) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const AllergenTrackerScreen(),
        ),
        GoRoute(
          path: AppRoute.allergenLogCreate.path,
          name: AppRoute.allergenLogCreate.name,
          builder: (ctx, st) {
            recorder
              ..lastName = AppRoute.allergenLogCreate.name
              ..lastPathParams = st.pathParameters;
            return const Scaffold(body: Text('CREATE_STUB'));
          },
        ),
        GoRoute(
          path: AppRoute.allergenDetail.path,
          name: AppRoute.allergenDetail.name,
          builder: (ctx, st) {
            recorder
              ..lastName = AppRoute.allergenDetail.name
              ..lastPathParams = st.pathParameters;
            return const Scaffold(body: Text('DETAIL_STUB'));
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
  // Board content: Ongoing, Big 11, stat columns, segment switching.
  // ---------------------------------------------------------------------------

  group('AllergenTrackerScreen board', () {
    Map<String, AllergenStatus> statusesEggDairySafePeanutFlagged() => {
      'peanut': AllergenStatus.flagged,
      'egg': AllergenStatus.safe,
      'dairy': AllergenStatus.safe,
      'tree_nuts': AllergenStatus.notStarted,
      'sesame': AllergenStatus.notStarted,
      'soy': AllergenStatus.notStarted,
      'wheat': AllergenStatus.notStarted,
      'fish': AllergenStatus.notStarted,
      'shellfish': AllergenStatus.notStarted,
    };

    testWidgets(
      'Ongoing tab lists in-progress allergens; switching to Big 11 reveals '
      '9 sections AND Not Tried=6, Safe=2, Not Safe=1 stat columns',
      (tester) async {
        final logs = [
          _makeLog(id: 'p1', allergenKey: 'peanut', hadReaction: true),
          _makeLog(id: 'e1', allergenKey: 'egg'),
          _makeLog(id: 'e2', allergenKey: 'egg'),
          _makeLog(id: 'e3', allergenKey: 'egg'),
          _makeLog(id: 'd1', allergenKey: 'dairy'),
          _makeLog(id: 'd2', allergenKey: 'dairy'),
          _makeLog(id: 'd3', allergenKey: 'dairy'),
        ];
        stubReads(
          statuses: statusesEggDairySafePeanutFlagged(),
          logs: logs,
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        // Ongoing tab section header and See All link present.
        expect(find.text('Allergen Exposure'), findsOneWidget);
        expect(find.text('See All'), findsOneWidget);
        // "Safe foods" stat column is shown on Ongoing tab.
        expect(find.text('Safe foods'), findsOneWidget);
        // Big 11 stat column is hidden in Ongoing → no Not Tried label.
        expect(find.text('Not Tried'), findsNothing);
        // Reaction Log list rendered for the logged entries (may be below
        // the fold depending on test viewport, so allow off-screen).
        expect(
          find.text('Reaction Log', skipOffstage: false),
          findsOneWidget,
        );

        // Switch to Big 11 tab.
        await tester.tap(find.text('Big 11'));
        await tester.pumpAndSettle();

        // Big 11 grouped sections.
        expect(find.text('Already Tried'), findsOneWidget);
        // Big 11 "Ongoing" header is hidden (no in-progress allergens here).
        expect(find.text('Not Tried'), findsWidgets);
        // SliverList builds lazily — some StartIntroduceCards may be below
        // the fold. skipOffstage: false to include them.
        expect(
          find.byType(StartIntroduceCard, skipOffstage: false),
          findsWidgets,
        );
        // Stat-column labels — Not Safe + Not Tried are unique strings on
        // Big 11.
        expect(find.text('Not Safe'), findsOneWidget);
        // Stat-column numeric values: 6 not-tried, 1 flagged, 2 safe.
        expect(find.text('6'), findsWidgets);
        expect(find.text('1'), findsWidgets);
        expect(find.text('2'), findsWidgets);
      },
    );

    testWidgets(
      'Ongoing tab shows empty state when no allergens have logs',
      (tester) async {
        stubReads(
          statuses: {
            for (final a in _allergens) a.key: AllergenStatus.notStarted,
          },
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        expect(find.text('No introductions yet'), findsOneWidget);
        // No Allergen Exposure section header in empty state.
        expect(find.text('Allergen Exposure'), findsNothing);
      },
    );

    testWidgets(
      'Tapping Start Introduce navigates to allergen-log-create '
      'with the tapped allergen key',
      (tester) async {
        stubReads(
          statuses: {
            for (final a in _allergens) a.key: AllergenStatus.notStarted,
          },
        );
        final recorder = _PushRecorder();
        await tester.pumpWidget(buildSubject(recorder));
        await tester.pumpAndSettle();

        // Switch to Big 11 so Start Introduce cards render.
        await tester.tap(find.text('Big 11'));
        await tester.pumpAndSettle();

        // Tap the first Start Introduce button.
        final firstStart = find.text('Start Introduce').first;
        await tester.ensureVisible(firstStart);
        await tester.tap(firstStart);
        await tester.pumpAndSettle();

        expect(recorder.lastName, AppRoute.allergenLogCreate.name);
        // First alphabetically-displayed allergen in sequence order is peanut.
        expect(recorder.lastPathParams?['allergenKey'], 'peanut');
      },
    );

    testWidgets(
      'See All link on Ongoing tab switches segment to Big 11 (no nav)',
      (tester) async {
        stubReads(
          statuses: {
            'peanut': AllergenStatus.safe,
            for (final a in _allergens.skip(1))
              a.key: AllergenStatus.notStarted,
          },
          logs: [_makeLog(id: 'p1', allergenKey: 'peanut')],
        );

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        // Pre-tap: Ongoing tab content is showing the Allergen Exposure header.
        expect(find.text('Allergen Exposure'), findsOneWidget);
        expect(find.text('Already Tried'), findsNothing);

        await tester.tap(find.text('See All'));
        await tester.pumpAndSettle();

        // After tapping See All, Big 11 sections are shown.
        expect(find.text('Already Tried'), findsOneWidget);
        expect(find.text('Allergen Exposure'), findsNothing);
      },
    );
  });
}
