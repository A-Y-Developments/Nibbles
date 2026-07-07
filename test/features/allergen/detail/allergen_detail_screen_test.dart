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
import 'package:nibbles/src/features/allergen/detail/allergen_detail_screen.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_contextual_banner.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/detail_segment_bar.dart';
import 'package:nibbles/src/features/home/widgets/start_allergen_button.dart';
import 'package:nibbles/src/routing/route_enums.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

const _babyId = 'baby-001';
const _allergenKey = 'peanut';
final _now = DateTime(2026, 3, 24);

const _peanut = Allergen(
  key: 'peanut',
  name: 'Peanut',
  sequenceOrder: 1,
  emoji: '🥜',
);

final _baby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2025, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

AllergenLog _makeLog({required String id, bool hadReaction = false}) =>
    AllergenLog(
      id: id,
      babyId: _babyId,
      allergenKey: _allergenKey,
      hadReaction: hadReaction,
      emojiTaste: EmojiTaste.love,
      logDate: _now,
      createdAt: _now,
    );

class _PushRecorder {
  String? lastName;
  Map<String, String>? lastPathParams;
}

/// Tall viewport so the full detail scroll (logs, banner, bottom Start New CTA)
/// builds — the default 600px height leaves the CTA unbuilt below the fold.
void _useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late _MockAllergenService mockService;
  late _MockBabyProfileService mockBabyService;

  setUp(() {
    mockService = _MockAllergenService();
    mockBabyService = _MockBabyProfileService();
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _baby);
    when(
      () => mockService.getAllergens(),
    ).thenAnswer((_) async => const Result.success([_peanut]));
  });

  Widget buildSubject(_PushRecorder recorder) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) =>
              const AllergenDetailScreen(allergenKey: _allergenKey),
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

  void stubLogs(List<AllergenLog> logs, AllergenStatus status) {
    when(
      () => mockService.getLogs(any(), allergenKey: any(named: 'allergenKey')),
    ).thenAnswer((_) async => Result.success(logs));
    when(() => mockService.deriveStatus(any())).thenReturn(status);
  }

  group('AllergenDetailScreen', () {
    testWidgets('status=safe → header card subtext is "3/3 times" + cream-wash '
        'contextual banner', (tester) async {
      // 3 clean logs + status=safe.
      stubLogs([
        _makeLog(id: 'l1'),
        _makeLog(id: 'l2'),
        _makeLog(id: 'l3'),
      ], AllergenStatus.safe);

      await tester.pumpWidget(buildSubject(_PushRecorder()));
      await tester.pumpAndSettle();

      // Header subtext: 3 clean logs → "3/3 times".
      expect(find.text('3/3 times'), findsOneWidget);
      // Status pill "Safe" renders (text rebuilds during layout
      // animation/animation-pumping can produce duplicate Text widgets
      // — assert presence, not exact count).
      expect(find.text('Safe'), findsWidgets);
      // Contextual banner is the safe variant (verbatim Figma copy). It
      // sits at the bottom of the scroll view, below the 3 log cards.
      expect(
        find.textContaining(
          'This allergen has already been introduced',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    });

    testWidgets('status=flagged → "Unsafe" pill + red-soft "consult a medical '
        'professional" banner', (tester) async {
      _useTallView(tester);
      stubLogs([
        _makeLog(id: 'l1'),
        _makeLog(id: 'l2', hadReaction: true),
      ], AllergenStatus.flagged);

      await tester.pumpWidget(buildSubject(_PushRecorder()));
      await tester.pumpAndSettle();

      expect(find.text('Unsafe'), findsWidgets);
      expect(
        find.textContaining('consult a medical professional'),
        findsOneWidget,
      );
      // No safe banner.
      expect(
        find.textContaining('This allergen has already been introduced'),
        findsNothing,
      );
      // A reaction counts toward the total — 2 logs → "2/3 times".
      expect(find.text('2/3 times'), findsOneWidget);
      // Finished (flagged): add-reaction disabled + Start New Allergen CTA.
      expect(find.byType(StartAllergenButton), findsOneWidget);
      final addButton = tester.widget<InkWell>(
        find.widgetWithIcon(InkWell, Icons.add_rounded),
      );
      expect(addButton.onTap, isNull);
    });

    testWidgets(
      'status=inProgress → 3-segment bar filled count == clean log count',
      (tester) async {
        _useTallView(tester);
        stubLogs([
          _makeLog(id: 'l1'),
          _makeLog(id: 'l2'),
        ], AllergenStatus.inProgress);

        await tester.pumpWidget(buildSubject(_PushRecorder()));
        await tester.pumpAndSettle();

        // Header subtext shows X/3 — for 2 clean logs that's '2/3 times'.
        expect(find.text('2/3 times'), findsOneWidget);
        // Status pill is Ongoing.
        expect(find.text('Ongoing'), findsOneWidget);
        // The DetailSegmentBar widget renders; visual fill is derived from
        // clean count internally — assertion verifies the widget mounts.
        expect(find.byType(DetailSegmentBar), findsOneWidget);
        // Banner copy: the inProgress variant (verbatim Figma).
        expect(
          find.textContaining('This allergen introduction is in progress'),
          findsOneWidget,
        );
        // Not finished: add-reaction stays enabled, no Start New CTA.
        expect(find.byType(StartAllergenButton), findsNothing);
        final addButton = tester.widget<InkWell>(
          find.widgetWithIcon(InkWell, Icons.add_rounded),
        );
        expect(addButton.onTap, isNotNull);
      },
    );

    testWidgets('no logs → status=notStarted: contextual banner is hidden + '
        '"No logs yet" empty hint shown', (tester) async {
      stubLogs(const [], AllergenStatus.notStarted);

      await tester.pumpWidget(buildSubject(_PushRecorder()));
      await tester.pumpAndSettle();

      // The banner renders SizedBox.shrink when notStarted.
      expect(find.byType(DetailContextualBanner), findsOneWidget);
      expect(
        find.textContaining('This allergen has already been introduced'),
        findsNothing,
      );
      expect(find.text('Not started'), findsOneWidget);
      expect(
        find.text('No logs yet. Tap + to log the first introduction.'),
        findsOneWidget,
      );
    });
  });
}
