import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/storage_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockFile extends Mock implements File {}

class _MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {
  _MockSupabaseStorageClient(this._mockFileApi);

  final MockStorageFileApi _mockFileApi;

  @override
  StorageFileApi from(String id) => _mockFileApi;
}

void main() {
  late MockSupabaseClient mockClient;
  late MockStorageFileApi mockFileApi;
  late StorageRepositoryImpl sut;
  late MockFile mockFile;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockFileApi = MockStorageFileApi();
    mockFile = MockFile();

    final mockStorageClient = _MockSupabaseStorageClient(mockFileApi);
    when(() => mockClient.storage).thenReturn(mockStorageClient);

    sut = StorageRepositoryImpl(supabaseClient: mockClient);
  });

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  group('uploadFile', () {
    test('returns Success with path on upload success', () async {
      when(() => mockFile.length()).thenAnswer((_) async => 1024 * 1024);
      when(
        () => mockFileApi.upload(any(), any()),
      ).thenAnswer((_) async => 'allergen-photos/baby-1/peanut_1.jpg');

      final result = await sut.uploadFile(
        'allergen-photos',
        'baby-1/peanut_1.jpg',
        mockFile,
      );

      expect(result, isA<Success<String>>());
      expect(
        (result as Success<String>).data,
        'allergen-photos/baby-1/peanut_1.jpg',
      );
    });

    test('returns Failure on StorageException', () async {
      when(() => mockFile.length()).thenAnswer((_) async => 1024 * 1024);
      when(
        () => mockFileApi.upload(any(), any()),
      ).thenThrow(const StorageException('Upload failed'));

      final result = await sut.uploadFile(
        'allergen-photos',
        'baby-1/peanut_1.jpg',
        mockFile,
      );

      expect(result, isA<Failure<String>>());
    });

    test('returns Failure when file exceeds 5MB', () async {
      when(() => mockFile.length()).thenAnswer((_) async => 6 * 1024 * 1024);

      final result = await sut.uploadFile(
        'allergen-photos',
        'baby-1/peanut_1.jpg',
        mockFile,
      );

      expect(result, isA<Failure<String>>());
      verifyNever(() => mockFileApi.upload(any(), any()));
    });
  });

  group('getSignedUrl', () {
    test('returns Success with URL', () async {
      when(
        () => mockFileApi.createSignedUrl(any(), any()),
      ).thenAnswer((_) async => 'https://example.com/signed');

      final result = await sut.getSignedUrl(
        'allergen-photos',
        'baby-1/peanut_1.jpg',
      );

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'https://example.com/signed');
    });

    test('returns Failure on StorageException', () async {
      when(
        () => mockFileApi.createSignedUrl(any(), any()),
      ).thenThrow(const StorageException('Not found'));

      final result = await sut.getSignedUrl(
        'allergen-photos',
        'baby-1/peanut_1.jpg',
      );

      expect(result, isA<Failure<String>>());
    });
  });
}
