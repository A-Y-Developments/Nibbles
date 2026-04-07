import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/shopping_list_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/shopping_list_item.dart';
import 'package:nibbles/src/common/domain/enums/shopping_list_source.dart';
import 'package:nibbles/src/common/services/shopping_list_service.dart';

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {}

const _babyId = 'baby-001';
final _now = DateTime(2026, 3, 24);

ShoppingListItem _makeItem({
  String id = 'item-1',
  String name = 'Apples',
  bool isChecked = false,
  ShoppingListSource source = ShoppingListSource.manual,
}) => ShoppingListItem(
  id: id,
  babyId: _babyId,
  name: name,
  isChecked: isChecked,
  source: source,
  createdAt: _now,
);

void main() {
  late MockShoppingListRepository mockRepo;
  late ShoppingListService sut;

  setUpAll(() {
    registerFallbackValue(_makeItem());
    registerFallbackValue(<ShoppingListItem>[]);
    registerFallbackValue(_now);
  });

  setUp(() {
    mockRepo = MockShoppingListRepository();
    sut = ShoppingListService(mockRepo);
  });

  // ---------------------------------------------------------------------------
  // addFromRecipe
  // ---------------------------------------------------------------------------

  group('ShoppingListService.addFromRecipe', () {
    test(
      'creates items with source=recipe, isChecked=false, id empty',
      () async {
        when(
          () => mockRepo.addItems(any()),
        ).thenAnswer((_) async => const Result.success(null));

        await sut.addFromRecipe(_babyId, 'r1', ['Avocado', 'Bread']);

        final captured =
            verify(() => mockRepo.addItems(captureAny())).captured.single
                as List<ShoppingListItem>;
        expect(captured, hasLength(2));
        expect(captured[0].name, 'Avocado');
        expect(captured[1].name, 'Bread');
        for (final item in captured) {
          expect(item.source, ShoppingListSource.recipe);
          expect(item.isChecked, isFalse);
          expect(item.id, '');
          expect(item.babyId, _babyId);
        }
      },
    );

    test('repo failure propagates', () async {
      when(() => mockRepo.addItems(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.addFromRecipe(_babyId, 'r1', ['Avocado']);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // addManualItem
  // ---------------------------------------------------------------------------

  group('ShoppingListService.addManualItem', () {
    test('creates item with source=manual', () async {
      when(
        () => mockRepo.addItems(any()),
      ).thenAnswer((_) async => const Result.success(null));

      await sut.addManualItem(_babyId, 'Milk');

      final captured =
          verify(() => mockRepo.addItems(captureAny())).captured.single
              as List<ShoppingListItem>;
      expect(captured, hasLength(1));
      expect(captured.first.name, 'Milk');
      expect(captured.first.source, ShoppingListSource.manual);
      expect(captured.first.isChecked, isFalse);
      expect(captured.first.id, '');
    });

    test('repo failure propagates', () async {
      when(() => mockRepo.addItems(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.addManualItem(_babyId, 'Milk');

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // checkItem
  // ---------------------------------------------------------------------------

  group('ShoppingListService.checkItem', () {
    test('calls setChecked with isChecked=true', () async {
      when(
        () => mockRepo.setChecked(any(), isChecked: any(named: 'isChecked')),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.checkItem('item-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.setChecked('item-1', isChecked: true)).called(1);
    });

    test('repo failure propagates', () async {
      when(
        () => mockRepo.setChecked(any(), isChecked: any(named: 'isChecked')),
      ).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.checkItem('item-1');

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // clearAll
  // ---------------------------------------------------------------------------

  group('ShoppingListService.clearAll', () {
    test('delegates to repo.clearAll with correct babyId', () async {
      when(
        () => mockRepo.clearAll(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await sut.clearAll(_babyId);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepo.clearAll(_babyId)).called(1);
    });

    test('repo failure propagates', () async {
      when(() => mockRepo.clearAll(any())).thenAnswer(
        (_) async => const Result.failure(ServerException('DB error')),
      );

      final result = await sut.clearAll(_babyId);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // copyToClipboard (pure function — no mock needed)
  // ---------------------------------------------------------------------------

  group('ShoppingListService.copyToClipboard', () {
    test('formats unchecked items as bullet list', () {
      final items = [
        _makeItem(),
        _makeItem(name: 'Bananas'),
        _makeItem(name: 'Carrots'),
      ];

      final text = sut.copyToClipboard(items);

      expect(text, '• Apples\n• Bananas\n• Carrots');
    });

    test('empty list returns empty string', () {
      final text = sut.copyToClipboard([]);

      expect(text, '');
    });

    test('single item has no trailing newline', () {
      final text = sut.copyToClipboard([_makeItem(name: 'Milk')]);

      expect(text, '• Milk');
    });
  });
}
