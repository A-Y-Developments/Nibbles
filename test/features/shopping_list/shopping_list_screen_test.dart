import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_screen.dart';

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
  // Empty state
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - empty state', () {
    testWidgets('List tab shows empty state when no items', (tester) async {
      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      expect(
        find.text("It seems you don't have any shopping list :("),
        findsOneWidget,
      );
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

      // Switch to Bought tab
      await tester.tap(find.text('Bought'));
      await tester.pumpAndSettle();

      expect(find.text('Bananas'), findsOneWidget);
      expect(find.text('Apples'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Check / uncheck
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - check', () {
    testWidgets('tapping checkbox calls checkItem on the service', (
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

      // Tap the Checkbox widget
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      verify(() => mockService.checkItem('item-1')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // Delete with confirmation dialog
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - delete', () {
    testWidgets('delete icon tap shows confirmation dialog', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      // Tap the trash icon
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Delete item'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('confirm Yes → deleteItem called', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(
        () => mockService.deleteItem(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Tap Yes in dialog
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      verify(() => mockService.deleteItem('item-1')).called(1);
    });

    testWidgets('confirm No → deleteItem never called', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      verifyNever(() => mockService.deleteItem(any()));
    });
  });

  // ---------------------------------------------------------------------------
  // Clear list menu
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - clear list', () {
    testWidgets('Clear list menu shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      // Open overflow menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear list'));
      await tester.pumpAndSettle();

      expect(find.text('Clear list'), findsWidgets);
      expect(
        find.text('This will delete all items. Are you sure?'),
        findsOneWidget,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Copy to clipboard
  // ---------------------------------------------------------------------------

  group('ShoppingListScreen - clipboard', () {
    testWidgets('Copy to clipboard shows success snackbar', (tester) async {
      when(
        () => mockService.getItems(any()),
      ).thenAnswer((_) async => Result.success([_makeItem()]));
      when(() => mockService.copyToClipboard(any())).thenReturn('• Apples');

      await tester.pumpWidget(_buildSut(mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy to clipboard'));
      await tester.pumpAndSettle();

      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('Copy to clipboard shows error snackbar when clipboard fails', (
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

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy to clipboard'));
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
}
