import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/components/buttons/app_pill_button.dart';
import 'package:nibbles/src/common/components/controls/app_sliding_segmented_control.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_screen.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../support/fake_analytics.dart';

class MockShoppingListService extends Mock implements ShoppingListService {}

const _babyId = 'baby-001';
final _now = DateTime(2026, 3, 24);

ShoppingListItem _makeItem({
  String id = 'item-1',
  String name = 'Apples',
  bool isChecked = false,
}) => ShoppingListItem(
  id: id,
  babyId: _babyId,
  name: name,
  isChecked: isChecked,
  source: ShoppingListSource.manual,
  createdAt: _now,
);

Widget _buildSut(MockShoppingListService svc) => ProviderScope(
  overrides: [
    currentBabyIdProvider.overrideWith((ref) async => _babyId),
    shoppingListServiceProvider.overrideWithValue(svc),
    analyticsProvider.overrideWithValue(FakeAnalytics()),
  ],
  child: const MaterialApp(home: ShoppingListScreen()),
);

void main() {
  late MockShoppingListService mockService;

  setUpAll(() {
    registerFallbackValue(_makeItem());
    registerFallbackValue(<ShoppingListItem>[]);
    registerFallbackValue(_now);
    // Suppress clipboard platform channel errors in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') return null;
          if (call.method == 'Clipboard.getData') return {'text': ''};
          return null;
        });
  });

  setUp(() {
    mockService = MockShoppingListService();
    // Default: empty list
    when(
      () => mockService.getItems(any()),
    ).thenAnswer((_) async => const Result.success([]));
  });

  // ---------------------------------------------------------------------------
  // Header / chrome
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - chrome', () {
    testWidgets('renders Shopping List title + segmented tabs', (tester) async {
      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.byType(AppSlidingSegmentedControl), findsOneWidget);
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Bought'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Empty state — Figma 971:9989
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - empty state', () {
    testWidgets('List tab shows verbatim empty-state copy + no CTA', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      expect(find.text('You don’t have any list yet'), findsOneWidget);
      // No browse-recipes CTA in this frame.
      expect(find.text('Browse recipes to get started'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Items rendering
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - items rendering', () {
    testWidgets('unchecked items appear in List tab', (tester) async {
      when(() => mockService.getItems(any())).thenAnswer(
        (_) async => Result.success([
          _makeItem(),
          _makeItem(id: 'item-2', name: 'Bananas'),
        ]),
      );

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsOneWidget);
    });

    testWidgets('checked item appears in Bought tab and not in List tab', (
      tester,
    ) async {
      when(() => mockService.getItems(any())).thenAnswer(
        (_) async => Result.success([
          _makeItem(),
          _makeItem(id: 'item-2', name: 'Bananas', isChecked: true),
        ]),
      );

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      // Apples on List tab, Bananas not
      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsNothing);

      // Switch to Bought tab via segmented control
      await tester.tap(find.text('Bought'));
      await tester.pumpAndSettle();

      expect(find.text('Bananas'), findsOneWidget);
      expect(find.text('Apples'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Check / uncheck — tap the square checkbox
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - check', () {
    testWidgets('tapping the square checkbox calls checkItem', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.checkItem(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      // The square checkbox sits to the left of the row label inside the row
      // card. Tap roughly at the box's center (~24px left of the label).
      final apples = find.text('Apples');
      final rowBox = tester.getRect(apples);
      await tester.tapAt(Offset(rowBox.left - 24, rowBox.center.dy));
      await tester.pumpAndSettle();

      verify(() => mockService.checkItem('item-1')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // Delete — per-row cancel chip → P2 toast on failure, no confirm dialog
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - delete', () {
    testWidgets('cancel chip directly deletes (no confirm dialog)', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.deleteItem(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pumpAndSettle();

      verify(() => mockService.deleteItem('item-1')).called(1);
      // No AlertDialog should ever surface.
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('delete failure surfaces P2 toast', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.deleteItem(any()),
      ).thenAnswer((_) async => const Result.failure(UnknownException('boom')));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't delete item. Try again."), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Clear shopping list menu — Figma 971:9936 / 971:9958
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - clear all', () {
    testWidgets('Clear shopping list opens the verbatim confirmation sheet', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      // Open overflow menu via the green-deep more_horiz chip.
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear shopping list'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to delete?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      // Legacy AlertDialog must not surface.
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping Delete calls clearAll and empties the list', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.clearAll(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear shopping list'));
      await tester.pumpAndSettle();

      // Disambiguate from the SwipeRevealRow's hidden "Delete" pill — the
      // bottom-sheet's Delete button is wrapped in AppPillButton.
      await tester.tap(find.widgetWithText(AppPillButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => mockService.clearAll(_babyId)).called(1);
      expect(find.text('You don’t have any list yet'), findsOneWidget);
    });

    testWidgets('tapping Cancel dismisses the sheet without clearing', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear shopping list'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockService.clearAll(any()));
      expect(find.text('Are you sure you want to delete?'), findsNothing);
      expect(find.text('Apples'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Copy to Clipboard menu — Figma 971:9889
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - clipboard', () {
    testWidgets('Copy to Clipboard shows success snackbar', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(() => mockService.copyToClipboard(any())).thenReturn('• Apples');

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy to Clipboard'));
      await tester.pumpAndSettle();

      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('Copy to Clipboard shows error snackbar when clipboard fails', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(() => mockService.copyToClipboard(any())).thenReturn('• Apples');
      // Override clipboard to throw
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') throw Exception('fail');
            return null;
          });

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy to Clipboard'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't copy. Try again."), findsOneWidget);

      // Restore normal clipboard mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') return null;
            if (call.method == 'Clipboard.getData') return {'text': ''};
            return null;
          });
    });
  });

  // ---------------------------------------------------------------------------
  // Add flow via the "+" chip → Add Ingredients sheet — Figma 971:9872
  //   Optimistic insert (appears immediately) then reconcile with the server,
  //   and P2 toast on add failure.
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - add', () {
    testWidgets('adding via the sheet inserts optimistically then reconciles', (
      tester,
    ) async {
      final backing = <ShoppingListItem>[];
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success(List.of(backing)));
      when(() => mockService.addManualItem(any(), any())).thenAnswer((_) async {
        backing.add(_makeItem(id: 'server-1', name: 'Carrots'));
        return const Result.success(null);
      });

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Carrots');
      await tester.tap(find.text('Add'));

      // Optimistic: the row is present before the server refetch settles.
      await tester.pump();
      expect(find.text('Carrots'), findsOneWidget);

      // Reconciled: still present after the invalidate/refetch resolves.
      await tester.pumpAndSettle();
      expect(find.text('Carrots'), findsOneWidget);
      verify(() => mockService.addManualItem(_babyId, 'Carrots')).called(1);
    });

    testWidgets('add failure surfaces P2 toast', (tester) async {
      when(() => mockService.addManualItem(any(), any())).thenAnswer(
        (_) async => const Result.failure(UnknownException('boom')),
      );

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Carrots');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't add items. Try again."), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Check / uncheck moves items between the List and Bought tabs
  //   (optimistic — no refetch; state.listItems / boughtItems re-partition).
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - check/uncheck moves between tabs', () {
    testWidgets('checking an item moves it from List to Bought', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.checkItem(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      final rowBox = tester.getRect(find.text('Apples'));
      await tester.tapAt(Offset(rowBox.left - 24, rowBox.center.dy));
      await tester.pumpAndSettle();

      // Gone from the List tab.
      expect(find.text('Apples'), findsNothing);

      // Present on the Bought tab.
      await tester.tap(find.text('Bought'));
      await tester.pumpAndSettle();
      expect(find.text('Apples'), findsOneWidget);
    });

    testWidgets('unchecking a Bought item calls uncheck and moves it to List', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem(isChecked: true)]));
      when(
        () => mockService.uncheckItem(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      // Item starts on the Bought tab.
      await tester.tap(find.text('Bought'));
      await tester.pumpAndSettle();

      final rowBox = tester.getRect(find.text('Apples'));
      await tester.tapAt(Offset(rowBox.left - 24, rowBox.center.dy));
      await tester.pumpAndSettle();

      verify(() => mockService.uncheckItem('item-1')).called(1);
      // Gone from Bought.
      expect(find.text('Apples'), findsNothing);

      // Back on the List tab.
      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();
      expect(find.text('Apples'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Swipe-to-delete — Figma 971:9915. Drag the row left to reveal the burgundy
  // Delete pill, then tap it to commit (distinct from the per-row cancel chip).
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - swipe to delete', () {
    testWidgets('swiping a row left reveals the Delete pill which commits', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.deleteItem(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.drag(find.text('Apples'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockService.deleteItem('item-1')).called(1);
      // Direct commit — no confirm dialog for a swipe delete.
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Empty state — Bought tab (List-empty is covered above)
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - Bought empty state', () {
    testWidgets('Bought tab shows the empty-state copy when nothing bought', (
      tester,
    ) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bought'));
      await tester.pumpAndSettle();

      expect(find.text('You don’t have any list yet'), findsOneWidget);
      expect(find.text('Apples'), findsNothing);
    });
  });
}
