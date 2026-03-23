import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/baby.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/gender.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/complete/allergen_complete_screen.dart';
import 'package:nibbles/src/features/allergen/detail/allergen_detail_screen.dart';
import 'package:nibbles/src/features/allergen/detail/widgets/gp_referral_block.dart';
import 'package:nibbles/src/features/allergen/log/allergen_log_sheet.dart';
import 'package:nibbles/src/routing/route_enums.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAllergenService extends Mock implements AllergenService {}

class MockBabyProfileService extends Mock implements BabyProfileService {}

class MockLocalFlagService extends Mock implements LocalFlagService {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _babyId = 'baby-001';
final _now = DateTime(2026, 3, 24);

final _fakeBaby = Baby(
  id: _babyId,
  userId: 'user-001',
  name: 'Lily',
  dateOfBirth: DateTime(2024, 6),
  gender: Gender.female,
  onboardingCompleted: true,
);

final _allergens = [
  const Allergen(key: 'peanut', name: 'Peanut', sequenceOrder: 1, emoji: '🥜'),
  const Allergen(key: 'egg', name: 'Egg', sequenceOrder: 2, emoji: '🥚'),
  const Allergen(key: 'dairy', name: 'Dairy', sequenceOrder: 3, emoji: '🥛'),
  const Allergen(
    key: 'tree_nuts',
    name: 'Tree Nuts',
    sequenceOrder: 4,
    emoji: '🌰',
  ),
  const Allergen(
    key: 'sesame',
    name: 'Sesame',
    sequenceOrder: 5,
    emoji: '🫘',
  ),
  const Allergen(key: 'soy', name: 'Soy', sequenceOrder: 6, emoji: '🫘'),
  const Allergen(key: 'wheat', name: 'Wheat', sequenceOrder: 7, emoji: '🌾'),
  const Allergen(key: 'fish', name: 'Fish', sequenceOrder: 8, emoji: '🐟'),
  const Allergen(
    key: 'shellfish',
    name: 'Shellfish',
    sequenceOrder: 9,
    emoji: '🦐',
  ),
];

AllergenProgramState _makeProgramState({
  String currentKey = 'peanut',
  int currentOrder = 1,
}) =>
    AllergenProgramState(
      id: 'ps-1',
      babyId: _babyId,
      currentAllergenKey: currentKey,
      currentSequenceOrder: currentOrder,
      status: AllergenProgramStatus.inProgress,
      createdAt: _now,
      updatedAt: _now,
    );

AllergenLog _makeLog({
  String id = 'log-1',
  String allergenKey = 'peanut',
  bool hadReaction = false,
}) =>
    AllergenLog(
      id: id,
      babyId: _babyId,
      allergenKey: allergenKey,
      emojiTaste: EmojiTaste.love,
      hadReaction: hadReaction,
      logDate: _now,
      createdAt: _now,
    );

// ---------------------------------------------------------------------------
// Widget helpers
// ---------------------------------------------------------------------------

GoRouter _routerFor(
  Widget screen, {
  String initialLocation = '/',
}) =>
    GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, __) => screen),
        GoRoute(
          path: '/home/profile',
          name: AppRoute.profile.name,
          builder: (_, __) => const Scaffold(body: Text('Profile')),
        ),
        GoRoute(
          path: '/home/allergen/reaction-log',
          name: AppRoute.reactionLog.name,
          builder: (_, __) => const Scaffold(body: Text('Reaction Log')),
        ),
      ],
    );

Widget _wrap(
  Widget screen,
  List<Override> overrides,
) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: _routerFor(screen),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAllergenService mockAllergenService;
  late MockBabyProfileService mockBabyService;
  late MockLocalFlagService mockLocalFlagService;

  setUpAll(() {
    registerFallbackValue(
      AllergenLog(
        id: '',
        babyId: '',
        allergenKey: '',
        emojiTaste: EmojiTaste.love,
        hadReaction: false,
        logDate: _now,
        createdAt: _now,
      ),
    );
    registerFallbackValue(
      ReactionDetail(
        id: '',
        logId: '',
        severity: ReactionSeverity.mild,
        symptoms: const [],
        createdAt: _now,
      ),
    );
    registerFallbackValue(_now);
  });

  setUp(() {
    mockAllergenService = MockAllergenService();
    mockBabyService = MockBabyProfileService();
    mockLocalFlagService = MockLocalFlagService();
  });

  List<Override> buildOverrides() => [
        allergenServiceProvider.overrideWithValue(mockAllergenService),
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
        localFlagServiceProvider.overrideWithValue(mockLocalFlagService),
      ];

  // -------------------------------------------------------------------------
  // Test 1: 3-day log flow — Proceed CTA appears after 3 logs
  // -------------------------------------------------------------------------

  testWidgets(
    '3-day allergen log → Proceed to next allergen CTA enabled',
    (tester) async {
      // Day 0: no logs yet → "Log Today" CTA visible
      when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
      when(() => mockAllergenService.getAllergens())
          .thenAnswer((_) async => Result.success(_allergens));
      when(() => mockAllergenService.getLogs(_babyId, allergenKey: 'peanut'))
          .thenAnswer((_) async => const Result.success([]));
      when(() => mockAllergenService.getProgramState(_babyId))
          .thenAnswer((_) async => Result.success(_makeProgramState()));
      when(() => mockAllergenService.hasLoggedToday(_babyId, 'peanut'))
          .thenAnswer((_) async => const Result.success(false));
      when(() => mockAllergenService.deriveStatus(any()))
          .thenReturn(AllergenStatus.notStarted);
      when(() => mockAllergenService.getReactionDetail(any()))
          .thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(
        _wrap(
          const AllergenDetailScreen(allergenKey: 'peanut'),
          buildOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('log_today_button')), findsOneWidget);
      expect(find.byKey(const Key('proceed_button')), findsNothing);

      // Day 3: all 3 logs done, no reactions → "Proceed" CTA visible
      final threeLogs = [
        _makeLog(id: 'l1'),
        _makeLog(id: 'l2'),
        _makeLog(id: 'l3'),
      ];
      when(() => mockAllergenService.getLogs(_babyId, allergenKey: 'peanut'))
          .thenAnswer((_) async => Result.success(threeLogs));
      when(() => mockAllergenService.hasLoggedToday(_babyId, 'peanut'))
          .thenAnswer((_) async => const Result.success(true));
      when(() => mockAllergenService.deriveStatus(any()))
          .thenReturn(AllergenStatus.safe);

      await tester.pumpWidget(
        _wrap(
          const AllergenDetailScreen(allergenKey: 'peanut'),
          buildOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // "Proceed to Next Allergen" button is shown
      expect(find.byKey(const Key('proceed_button')), findsOneWidget);
      expect(find.text('Proceed to Next Allergen'), findsOneWidget);

      // Day 3/3 progress chip shows complete state
      expect(find.text('Day 3/3 — Complete'), findsOneWidget);
    },
  );

  // -------------------------------------------------------------------------
  // Test 2: Same-day duplicate log blocked
  // -------------------------------------------------------------------------

  testWidgets(
    'same-day duplicate log blocked — P1 error shown',
    (tester) async {
    when(
      () => mockAllergenService.saveAllergenLog(
        babyId: any(named: 'babyId'),
        allergenKey: any(named: 'allergenKey'),
        emojiTaste: any(named: 'emojiTaste'),
        hadReaction: any(named: 'hadReaction'),
        reactionDetail: any(named: 'reactionDetail'),
      ),
    ).thenAnswer(
      (_) async => Result.failure(DuplicateLogException('Peanut')),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildOverrides(),
        child: const MaterialApp(
          home: Scaffold(
            body: AllergenLogSheet(
              babyId: _babyId,
              babyName: 'Lily',
              allergenKey: 'peanut',
              allergenName: 'Peanut',
              allergenEmoji: '🥜',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1 — taste: select Love it, tap Next
    await tester.tap(find.text('Love it'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taste_next_button')));
    await tester.pumpAndSettle();

    // Step 2 — reaction: select No Reaction, tap Save
    await tester.tap(find.text('No Reaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reaction_save_button')));
    await tester.pumpAndSettle();

    // Duplicate error message is shown on the reaction step
    expect(
      find.textContaining("You've already logged Peanut today"),
      findsOneWidget,
    );

    // saveLog was called exactly once — duplicate block is at service level,
    // no second insert occurs.
    verify(
      () => mockAllergenService.saveAllergenLog(
        babyId: _babyId,
        allergenKey: 'peanut',
        emojiTaste: EmojiTaste.love,
        hadReaction: false,
      ),
    ).called(1);
  });

  // -------------------------------------------------------------------------
  // Test 3: Reaction logged → allergen flagged → GP referral shown
  // -------------------------------------------------------------------------

  testWidgets(
    'reaction logged → allergen flagged → GP referral block visible',
    (tester) async {
      final reactionLog = _makeLog(id: 'log-r1', hadReaction: true);
      final reactionDetail = ReactionDetail(
        id: 'det-1',
        logId: 'log-r1',
        severity: ReactionSeverity.mild,
        symptoms: const ['Rash', 'Hives'],
        createdAt: _now,
      );

      when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
      when(() => mockAllergenService.getAllergens())
          .thenAnswer((_) async => Result.success(_allergens));
      when(() => mockAllergenService.getLogs(_babyId, allergenKey: 'peanut'))
          .thenAnswer((_) async => Result.success([reactionLog]));
      when(() => mockAllergenService.getProgramState(_babyId))
          .thenAnswer((_) async => Result.success(_makeProgramState()));
      when(() => mockAllergenService.hasLoggedToday(_babyId, 'peanut'))
          .thenAnswer((_) async => const Result.success(true));
      when(() => mockAllergenService.deriveStatus(any()))
          .thenReturn(AllergenStatus.flagged);
      when(() => mockAllergenService.getReactionDetail('log-r1'))
          .thenAnswer((_) async => Result.success(reactionDetail));

      await tester.pumpWidget(
        _wrap(
          const AllergenDetailScreen(allergenKey: 'peanut'),
          buildOverrides(),
        ),
      );
      await tester.pumpAndSettle();

      // GP referral block is visible for flagged allergen
      expect(find.byType(GpReferralBlock), findsOneWidget);

      // "Proceed to Next Allergen" is still available (with warning)
      expect(find.byKey(const Key('proceed_button')), findsOneWidget);
      expect(
        find.text('A reaction was recorded for this allergen.'),
        findsOneWidget,
      );

      // No "Log Today" button — allergen is done
      expect(find.byKey(const Key('log_today_button')), findsNothing);
    },
  );

  // -------------------------------------------------------------------------
  // Test 4: AL-08 program complete shown once
  // -------------------------------------------------------------------------

  testWidgets('AL-08 program complete — markShown called on CTA tap',
      (tester) async {
    final boardItems = _allergens
        .map(
          (a) => AllergenBoardItem(
            allergen: a,
            logs: const [],
            status: AllergenStatus.safe,
          ),
        )
        .toList();

    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _fakeBaby);
    when(() => mockAllergenService.getAllergenBoardSummary(_babyId))
        .thenAnswer((_) async => Result.success(boardItems));
    when(() => mockLocalFlagService.setProgramCompletionShown(any()))
        .thenReturn(null);

    await tester.pumpWidget(
      _wrap(const AllergenCompleteScreen(), buildOverrides()),
    );
    await tester.pumpAndSettle();

    // AL-08 shows baby name and completion copy
    expect(find.textContaining('Lily'), findsWidgets);
    expect(
      find.textContaining('has passed all 9 allergens'),
      findsOneWidget,
    );

    // Tap "View in Profile"
    await tester.tap(find.text('View in Profile'));
    await tester.pumpAndSettle();

    // Hive shown-once flag was set → screen will not show again for this baby
    verify(
      () => mockLocalFlagService.setProgramCompletionShown(_babyId),
    ).called(1);
  });
}
