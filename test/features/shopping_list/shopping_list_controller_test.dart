import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';
import 'package:nibbles/src/features/shopping_list/shopping_list_controller.dart';
import 'package:nibbles/src/logging/analytics.dart';

import '../../support/fake_analytics.dart';

class _MockShoppingListService extends Mock implements ShoppingListService {}

const _babyId = 'baby-001';
final _t0 = DateTime(2026);

ShoppingListItem _item({
  String id = 'item-1',
  String name = 'Apples',
  bool isChecked = false,
}) => ShoppingListItem(
  id: id,
  babyId: _babyId,
  name: name,
  isChecked: isChecked,
  source: ShoppingListSource.manual,
  createdAt: _t0,
);

void main() {
  late _MockShoppingListService svc;
  late FakeAnalytics analytics;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') return null;
          if (call.method == 'Clipboard.getData') {
            return {'text': ''};
          }
          return null;
        });
  });

  setUp(() {
    svc = _MockShoppingListService();
    analytics = FakeAnalytics();
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        shoppingListServiceProvider.overrideWithValue(svc),
        analyticsProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  ShoppingListController notifier(ProviderContainer c) =>
      c.read(shoppingListControllerProvider(_babyId).notifier);

  group('build()', () {
    test('returns loaded items on success', () async {
      final items = [_item()];
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success(items));

      final state = await makeContainer().read(
        shoppingListControllerProvider(_babyId).future,
      );

      expect(state.items, items);
    });

    test('enters error state on getItems failure', () async {
      const error = ServerException('load failed');
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => const Result.failure(error));

      final c = makeContainer();
      await expectLater(notifier(c).future, throwsA(isA<ServerException>()));

      expect(c.read(shoppingListControllerProvider(_babyId)).hasError, isTrue);
    });
  });

  group('addManual()', () {
    test('is a no-op for empty string', () async {
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => const Result.success([]));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);
      await notifier(c).addManual('   ');

      verifyNever(() => svc.addManualItem(any(), any()));
    });

    test('optimistic insert then reloads with server items', () async {
      final initial = <ShoppingListItem>[];
      final reloaded = [_item(id: 'server-1')];

      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success(initial));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success(reloaded));
      when(
        () => svc.addManualItem(any(), any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      await notifier(c).addManual('Apples');

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items, reloaded);
      expect(analytics.eventNames, contains('shopping_item_added'));
      expect(
        analytics.calls
            .firstWhere((e) => e.name == 'shopping_item_added')
            .parameters['source'],
        'manual',
      );
    });

    test('does not fire analytics when add fails', () async {
      final initial = [_item()];
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success(initial));
      when(() => svc.addManualItem(any(), any())).thenAnswer(
        (_) async => const Result<void>.failure(NetworkException('fail')),
      );

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      await expectLater(
        notifier(c).addManual('Bread'),
        throwsA(isA<NetworkException>()),
      );

      expect(analytics.eventNames, isNot(contains('shopping_item_added')));
    });

    test('reverts optimistic insert on failure', () async {
      final initial = [_item()];
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success(initial));
      when(() => svc.addManualItem(any(), any())).thenAnswer(
        (_) async => const Result<void>.failure(NetworkException('fail')),
      );

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      await expectLater(
        notifier(c).addManual('Bread'),
        throwsA(isA<NetworkException>()),
      );

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items, initial);
    });
  });

  group('check()', () {
    test('optimistically marks item checked', () async {
      final item = _item();
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(
        () => svc.checkItem(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);
      await notifier(c).check('item-1');

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items.first.isChecked, isTrue);
      expect(analytics.eventNames, contains('shopping_item_checked'));
    });

    test('reverts on failure', () async {
      final item = _item();
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(() => svc.checkItem(any())).thenAnswer(
        (_) async => const Result<void>.failure(NetworkException('fail')),
      );

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      await expectLater(
        notifier(c).check('item-1'),
        throwsA(isA<NetworkException>()),
      );

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items.first.isChecked, isFalse);
      expect(analytics.eventNames, isNot(contains('shopping_item_checked')));
    });
  });

  group('uncheck()', () {
    test('optimistically marks item unchecked', () async {
      final item = _item(isChecked: true);
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(
        () => svc.uncheckItem(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);
      await notifier(c).uncheck('item-1');

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items.first.isChecked, isFalse);
      expect(analytics.eventNames, contains('shopping_item_unchecked'));
    });

    test('reverts on failure', () async {
      final item = _item(isChecked: true);
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(() => svc.uncheckItem(any())).thenAnswer(
        (_) async => const Result<void>.failure(NetworkException('fail')),
      );

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      await expectLater(
        notifier(c).uncheck('item-1'),
        throwsA(isA<NetworkException>()),
      );

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items.first.isChecked, isTrue);
      expect(analytics.eventNames, isNot(contains('shopping_item_unchecked')));
    });
  });

  group('delete()', () {
    test('optimistically removes item', () async {
      final item = _item();
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(
        () => svc.deleteItem(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);
      await notifier(c).delete('item-1');

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items, isEmpty);
      expect(analytics.eventNames, contains('shopping_item_deleted'));
      expect(
        analytics.calls
            .firstWhere((e) => e.name == 'shopping_item_deleted')
            .parameters['via'],
        'button',
      );
    });

    test('records via=swipe when supplied by the call site', () async {
      final item = _item();
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(
        () => svc.deleteItem(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);
      await notifier(c).delete('item-1', via: 'swipe');

      expect(
        analytics.calls
            .firstWhere((e) => e.name == 'shopping_item_deleted')
            .parameters['via'],
        'swipe',
      );
    });

    test('reverts removed item on failure', () async {
      final item = _item();
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([item]));
      when(() => svc.deleteItem(any())).thenAnswer(
        (_) async => const Result<void>.failure(NetworkException('fail')),
      );

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      await expectLater(
        notifier(c).delete('item-1'),
        throwsA(isA<NetworkException>()),
      );

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items, [item]);
      expect(analytics.eventNames, isNot(contains('shopping_item_deleted')));
    });
  });

  group('clearAll()', () {
    test('clears all items on success', () async {
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([_item()]));
      when(
        () => svc.clearAll(any()),
      ).thenAnswer((_) async => const Result<void>.success(null));

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);
      await notifier(c).clearAll();

      final state = c.read(shoppingListControllerProvider(_babyId)).valueOrNull;
      expect(state?.items, isEmpty);
      expect(analytics.eventNames, contains('shopping_list_cleared'));
    });

    test('throws on failure', () async {
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([_item()]));
      when(() => svc.clearAll(any())).thenAnswer(
        (_) async => const Result<void>.failure(NetworkException('fail')),
      );

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      await expectLater(
        notifier(c).clearAll(),
        throwsA(isA<NetworkException>()),
      );

      expect(analytics.eventNames, isNot(contains('shopping_list_cleared')));
    });
  });

  group('copyToClipboard()', () {
    test('returns true when state is loaded', () async {
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => Result.success([_item()]));
      when(() => svc.copyToClipboard(any())).thenReturn('• Apples');

      final c = makeContainer();
      await c.read(shoppingListControllerProvider(_babyId).future);

      final result = await notifier(c).copyToClipboard();
      expect(result, isTrue);
      expect(analytics.eventNames, contains('shopping_list_copied'));
    });

    test('returns false when state is null', () async {
      const error = ServerException('fail');
      when(
        () => svc.getItems(any()),
      ).thenAnswer((_) async => const Result.failure(error));

      final c = makeContainer();
      await expectLater(notifier(c).future, throwsA(isA<Object>()));

      final result = await notifier(c).copyToClipboard();
      expect(result, isFalse);
      expect(analytics.eventNames, isNot(contains('shopping_list_copied')));
    });
  });
}
