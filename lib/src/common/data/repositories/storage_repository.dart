import 'dart:io';

import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'storage_repository.g.dart';

abstract interface class StorageRepository {
  Future<Result<String>> uploadFile(String bucket, String path, File file);
  Future<Result<String>> getSignedUrl(
    String bucket,
    String path, {
    int expiresIn,
  });
}

class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const _maxFileSize = 5 * 1024 * 1024; // 5MB

  @override
  Future<Result<String>> uploadFile(
    String bucket,
    String path,
    File file,
  ) async {
    try {
      final fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        return const Result.failure(
          ServerException('Photo exceeds 5MB limit.'),
        );
      }

      final storagePath = await _supabase.storage
          .from(bucket)
          .upload(path, file);

      return Result.success(storagePath);
    } on StorageException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<String>> getSignedUrl(
    String bucket,
    String path, {
    int expiresIn = 3600,
  }) async {
    try {
      final url = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);

      return Result.success(url);
    } on StorageException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }
}

@Riverpod(keepAlive: true)
StorageRepository storageRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  StorageRepositoryRef ref,
) => StorageRepositoryImpl();
