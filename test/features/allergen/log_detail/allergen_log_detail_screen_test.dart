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
import 'package:nibbles/src/common/services/helpers/derive_allergen_status.dart';
import 'package:nibbles/src/common/services/local_flag_service.dart';
import 'package:nibbles/src/features/allergen/log_detail/allergen_log_detail_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';
import 'package:nibbles/src/routing/route_enums.dart';

import '../../../support/fake_analytics.dart';

class _MockAllergenService extends Mock implements AllergenService {}

class _MockBabyProfileService extends Mock implements BabyProfileService {}

class _MockLocalFlagService extends Mock implements LocalFlagService {}

const _babyId = 'baby-001';
const _allergenKey = 'peanut';
const _logId = 'log-1';
final _logDate = DateTime(2026, 5);

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

AllergenLog _makeLog({
  bool hadReaction = false,
  String? notes,
  String? attachmentTitle,
  String? attachmentDescription,
  String? photoUrl,
}) => AllergenLog(
  id: _logId,
  babyId: _babyId,
  allergenKey: _allergenKey,
  hadReaction: hadReaction,
  emojiTaste: EmojiTaste.love,
  logDate: _logDate,
  createdAt: _logDate,
  notes: notes,
  attachmentTitle: attachmentTitle,
  attachmentDescription: attachmentDescription,
  photoUrl: photoUrl,
);

void main() {
  late _MockAllergenService mockService;
  late _MockBabyProfileService mockBabyService;
  late _MockLocalFlagService mockFlags;

  setUp(() {
    mockService = _MockAllergenService();
    mockBabyService = _MockBabyProfileService();
    mockFlags = _MockLocalFlagService();
    when(() => mockBabyService.getBaby()).thenAnswer((_) async => _baby);
    when(
      () => mockService.getAllergens(),
    ).thenAnswer((_) async => const Result.success([_peanut]));
    when(
      () => mockService.getSignedPhotoUrl(any()),
    ).thenAnswer((_) async => const Result.success('https://photo.test/p.jpg'));
    // Default: AL-08 already shown → the post-delete gate short-circuits and
    // the screen just pops (the behaviour the non-completion tests expect).
    when(
      () => mockFlags.isProgramCompletionShown(any()),
    ).thenReturn(true);
  });

  void stubLogs(List<AllergenLog> logs) {
    when(
      () => mockService.getLogs(
        any(),
        allergenKey: any(named: 'allergenKey'),
      ),
    ).thenAnswer((_) async => Result.success(logs));
  }

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/log',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('ROOT_STUB')),
          routes: [
            GoRoute(
              path: 'log',
              builder: (_, __) => const AllergenLogDetailScreen(
                allergenKey: _allergenKey,
                logId: _logId,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoute.allergenLogEdit.path,
          name: AppRoute.allergenLogEdit.name,
          builder: (_, __) => const Scaffold(body: Text('EDIT_STUB')),
        ),
        GoRoute(
          path: AppRoute.allergenComplete.path,
          name: AppRoute.allergenComplete.name,
          builder: (_, __) => const Scaffold(body: Text('AL08_STUB')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        allergenServiceProvider.overrideWithValue(mockService),
        babyProfileServiceProvider.overrideWithValue(mockBabyService),
        localFlagServiceProvider.overrideWithValue(mockFlags),
        analyticsProvider.overrideWithValue(FakeAnalytics()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('AllergenLogDetailScreen', () {
    testWidgets(
      'Tried-Safe + no attachment: app bar "Reaction Log", "Log 1", "Safe" '
      'pill, "Date" + "Notes" fields, no "Attachment (Optional)"',
      (tester) async {
        stubLogs([_makeLog(notes: 'My baby love it, no reaction')]);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Reaction Log'), findsOneWidget);
        expect(find.text('Log 1'), findsOneWidget);
        expect(find.text('Safe'), findsOneWidget);
        expect(find.text('Date'), findsOneWidget);
        expect(find.text('May 1, 2026'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('My baby love it, no reaction'), findsOneWidget);
        expect(find.text('Attachment (Optional)'), findsNothing);
        expect(find.text('Change Picture'), findsNothing);
      },
    );

    testWidgets(
      'Tried-Unsafe + no attachment: "Unsafe" pill renders, no attachment '
      'block',
      (tester) async {
        stubLogs([_makeLog(hadReaction: true, notes: 'Rash on cheek')]);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Log 1'), findsOneWidget);
        expect(find.text('Unsafe'), findsOneWidget);
        expect(find.text('Safe'), findsNothing);
        expect(find.text('Attachment (Optional)'), findsNothing);
      },
    );

    testWidgets(
      'Tried-Safe + attachment: "Attachment (Optional)" label, attachment '
      'title/description, and "Change Picture" CTA are rendered',
      (tester) async {
        stubLogs([
          _makeLog(
            notes: 'My baby love it, no reaction',
            attachmentTitle: 'Rash on cheek area',
            attachmentDescription: 'Taken 30 min after feeding',
            photoUrl: 'allergen-attachments/$_babyId/p.jpg',
          ),
        ]);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Attachment (Optional)'), findsOneWidget);
        expect(find.text('Rash on cheek area'), findsOneWidget);
        expect(find.text('Taken 30 min after feeding'), findsOneWidget);
        expect(find.text('Change Picture'), findsOneWidget);
      },
    );

    testWidgets(
      'Tried-Unsafe + attachment: Unsafe pill + attachment block visible',
      (tester) async {
        stubLogs([
          _makeLog(
            hadReaction: true,
            notes: 'Rash on cheek',
            attachmentTitle: 'Rash on cheek area',
            attachmentDescription: 'Taken 30 min after feeding',
            photoUrl: 'allergen-attachments/$_babyId/p.jpg',
          ),
        ]);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Unsafe'), findsOneWidget);
        expect(find.text('Attachment (Optional)'), findsOneWidget);
        expect(find.text('Change Picture'), findsOneWidget);
        expect(find.text('Rash on cheek area'), findsOneWidget);
      },
    );

    testWidgets(
      '3-dot menu overlay exposes "Edit Reactions" and "Delete Log"',
      (tester) async {
        stubLogs([_makeLog(notes: 'note')]);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('log_detail_menu')));
        await tester.pumpAndSettle();

        expect(find.text('Edit Reactions'), findsOneWidget);
        expect(find.text('Delete Log'), findsOneWidget);
      },
    );

    testWidgets(
      'Delete row opens the Figma confirmation popup with verbatim copy + '
      'Cancel/Delete pill buttons; Cancel dismisses without deleting',
      (tester) async {
        stubLogs([_makeLog(notes: 'note')]);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('log_detail_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('log_actions_menu_delete')));
        await tester.pumpAndSettle();

        // Verbatim Figma copy (1525:31338).
        expect(find.text('Are you sure you want to delete?'), findsOneWidget);
        expect(
          find.byKey(const Key('delete_log_cancel_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('delete_log_confirm_button')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('delete_log_cancel_button')));
        await tester.pumpAndSettle();

        verifyNever(
          () => mockService.deleteAllergenLog(
            logId: any(named: 'logId'),
            photoPath: any(named: 'photoPath'),
          ),
        );
      },
    );

    testWidgets(
      'Confirming the delete popup calls deleteAllergenLog with the log id + '
      'photo path',
      (tester) async {
        stubLogs([
          _makeLog(
            attachmentTitle: 'Rash on cheek area',
            photoUrl: 'allergen-attachments/$_babyId/p.jpg',
          ),
        ]);
        when(
          () => mockService.deleteAllergenLog(
            logId: any(named: 'logId'),
            photoPath: any(named: 'photoPath'),
          ),
        ).thenAnswer((_) async => const Result.success(null));

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('log_detail_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('log_actions_menu_delete')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('delete_log_confirm_button')));
        await tester.pumpAndSettle();

        verify(
          () => mockService.deleteAllergenLog(
            logId: _logId,
            photoPath: 'allergen-attachments/$_babyId/p.jpg',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Deleting a log that completes the program (all allergens safe, AL-08 '
      'not yet shown) flips the once-only flag + routes to AL-08, not pop',
      (tester) async {
        // A reaction log whose deletion flips its allergen flagged → safe,
        // completing the program (every allergen derives to safe post-delete).
        stubLogs([_makeLog(hadReaction: true, notes: 'Rash on cheek')]);
        when(
          () => mockService.deleteAllergenLog(
            logId: any(named: 'logId'),
            photoPath: any(named: 'photoPath'),
          ),
        ).thenAnswer((_) async => const Result.success(null));
        when(
          () => mockFlags.isProgramCompletionShown(any()),
        ).thenReturn(false);
        when(
          () => mockFlags.markProgramCompletionShown(any()),
        ).thenAnswer((_) async {});
        when(() => mockService.getAllergenStatuses(any())).thenAnswer(
          (_) async => Result.success({
            for (final key in kAllergenKeys) key: AllergenStatus.safe,
          }),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('log_detail_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('log_actions_menu_delete')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('delete_log_confirm_button')));
        await tester.pumpAndSettle();

        // Routed to AL-08 instead of popping back to the detail's parent.
        expect(find.text('AL08_STUB'), findsOneWidget);
        expect(find.text('ROOT_STUB'), findsNothing);
        verify(
          () => mockFlags.markProgramCompletionShown(_babyId),
        ).called(1);
      },
    );
  });
}
