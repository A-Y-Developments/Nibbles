// freezed copies @JsonKey field annotations into generated parts, triggering a
// false-positive from very_good_analysis on the generated getter declarations.
// ignore_for_file: invalid_annotation_target
import 'dart:convert';

import 'package:nibbles/src/app/constants/allergen_emoji.dart';
import 'package:nibbles/src/common/data/sources/local/hive_service.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/allergen_program_state.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'allergen_repository.g.dart';

abstract interface class AllergenRepository {
  /// ALLRG-01: Fetch all 9 allergens ordered by sequence_order.
  /// Serves from Hive cache if available; fetches from Supabase on cache miss
  /// or when [refresh] is true.
  Future<Result<List<Allergen>>> getAllergens({bool refresh = false});

  /// ALLRG-02: Fetch allergen_program_state for the given baby.
  Future<Result<AllergenProgramState>> getProgramState(String babyId);

  /// ALLRG-03: Fetch all allergen_logs for baby, optionally filtered.
  Future<Result<List<AllergenLog>>> getLogs(
    String babyId, {
    String? allergenKey,
  });

  /// ALLRG-05: Insert allergen_log row.
  Future<Result<AllergenLog>> saveLog(AllergenLog log);

  /// Update an existing allergen_log row by id. Writes the editable fields
  /// (emoji_taste, had_reaction, notes, attachment_title,
  /// attachment_description, log_date, photo_url) and returns the refreshed
  /// row mapped to [AllergenLog].
  Future<Result<AllergenLog>> updateLog(AllergenLog log);

  /// Deletes an allergen_log row by id. Caller is responsible for cleaning
  /// up any associated photo via the storage repository.
  Future<Result<void>> deleteLog(String logId);

  /// ALLRG-06: Insert reaction_details row.
  Future<Result<ReactionDetail>> saveReactionDetail(ReactionDetail detail);

  /// ALLRG-07: Advance program state to next allergen.
  Future<Result<void>> advanceProgramState(
    String babyId,
    String nextAllergenKey,
    int nextSequenceOrder,
  );

  /// ALLRG-08: Mark program as completed.
  Future<Result<void>> completeProgramState(String babyId);

  /// ALLRG-09: Fetch reaction_details for a given log.
  Future<Result<ReactionDetail?>> getReactionDetail(String logId);
}

class AllergenRepositoryImpl implements AllergenRepository {
  AllergenRepositoryImpl({
    SupabaseClient? supabaseClient,
    HiveService? hiveService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _hive = hiveService ?? HiveService();

  final SupabaseClient _supabase;
  final HiveService _hive;

  static const _cacheKey = 'allergens_list';

  @override
  Future<Result<List<Allergen>>> getAllergens({bool refresh = false}) async {
    if (!refresh) {
      final cached = _hive.allergensBox.get(_cacheKey);
      if (cached != null) {
        try {
          final list = (jsonDecode(cached) as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(Allergen.fromJson)
              .toList();
          return Result.success(list);
        } on Object {
          // Cache corrupt — fall through to remote fetch.
        }
      }
    }

    try {
      final data = await _supabase
          .from('allergens')
          .select()
          .order('sequence_order');

      final allergens = (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_allergenFromRow)
          .toList();

      await _hive.allergensBox.put(
        _cacheKey,
        jsonEncode(allergens.map((a) => a.toJson()).toList()),
      );

      return Result.success(allergens);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<AllergenProgramState>> getProgramState(String babyId) async {
    try {
      final data = await _supabase
          .from('allergen_program_state')
          .select()
          .eq('baby_id', babyId)
          .single();

      return Result.success(_programStateFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<List<AllergenLog>>> getLogs(
    String babyId, {
    String? allergenKey,
  }) async {
    try {
      var query = _supabase
          .from('allergen_logs')
          .select()
          .eq('baby_id', babyId);

      if (allergenKey != null) {
        query = query.eq('allergen_key', allergenKey);
      }

      final data = await query.order('created_at');
      return Result.success(
        (data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(_logFromRow)
            .toList(),
      );
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<AllergenLog>> saveLog(AllergenLog log) async {
    try {
      final data = await _supabase
          .from('allergen_logs')
          .insert({
            'baby_id': log.babyId,
            'allergen_key': log.allergenKey,
            'had_reaction': log.hadReaction,
            'log_date': _formatDate(log.logDate),
            if (log.emojiTaste != null)
              'emoji_taste': log.emojiTaste!.toJson(),
            if (log.notes != null) 'notes': log.notes,
            if (log.attachmentTitle != null)
              'attachment_title': log.attachmentTitle,
            if (log.attachmentDescription != null)
              'attachment_description': log.attachmentDescription,
            if (log.photoUrl != null) 'photo_url': log.photoUrl,
          })
          .select()
          .single();

      return Result.success(_logFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<AllergenLog>> updateLog(AllergenLog log) async {
    try {
      final data = await _supabase
          .from('allergen_logs')
          .update({
            'emoji_taste': log.emojiTaste?.toJson(),
            'had_reaction': log.hadReaction,
            'notes': log.notes,
            'attachment_title': log.attachmentTitle,
            'attachment_description': log.attachmentDescription,
            'log_date': _formatDate(log.logDate),
            'photo_url': log.photoUrl,
          })
          .eq('id', log.id)
          .select()
          .single();

      return Result.success(_logFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> deleteLog(String logId) async {
    try {
      await _supabase.from('allergen_logs').delete().eq('id', logId);
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<ReactionDetail>> saveReactionDetail(
    ReactionDetail detail,
  ) async {
    try {
      final data = await _supabase
          .from('reaction_details')
          .insert({
            'log_id': detail.logId,
            'severity': detail.severity.toJson(),
            'symptoms': detail.symptoms,
            if (detail.notes != null) 'notes': detail.notes,
          })
          .select()
          .single();

      return Result.success(_reactionDetailFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> advanceProgramState(
    String babyId,
    String nextAllergenKey,
    int nextSequenceOrder,
  ) async {
    try {
      await _supabase
          .from('allergen_program_state')
          .update({
            'current_allergen_key': nextAllergenKey,
            'current_sequence_order': nextSequenceOrder,
          })
          .eq('baby_id', babyId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> completeProgramState(String babyId) async {
    try {
      await _supabase
          .from('allergen_program_state')
          .update({'status': AllergenProgramStatus.completed.toJson()})
          .eq('baby_id', babyId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  @override
  Future<Result<ReactionDetail?>> getReactionDetail(String logId) async {
    try {
      final data = await _supabase
          .from('reaction_details')
          .select()
          .eq('log_id', logId)
          .limit(1)
          .maybeSingle();

      if (data == null) return const Result.success(null);
      return Result.success(_reactionDetailFromRow(data));
    } on PostgrestException catch (e) {
      return Result.failure(ServerException(e.message));
    } on Object {
      return const Result.failure(UnknownException());
    }
  }

  // --- Row mappers ---

  Allergen _allergenFromRow(Map<String, dynamic> row) {
    final key = row['key'] as String;
    return Allergen(
      key: key,
      name: row['display_name'] as String,
      sequenceOrder: row['sequence_order'] as int,
      emoji: AllergenEmoji.get(key),
    );
  }

  AllergenLog _logFromRow(Map<String, dynamic> row) {
    final tasteRaw = row['emoji_taste'] as String?;
    final logDateRaw = row['log_date'] as String?;
    final createdAt = DateTime.parse(row['created_at'] as String);
    return AllergenLog(
      id: row['id'] as String,
      babyId: row['baby_id'] as String,
      allergenKey: row['allergen_key'] as String,
      hadReaction: row['had_reaction'] as bool,
      logDate: logDateRaw != null ? DateTime.parse(logDateRaw) : createdAt,
      createdAt: createdAt,
      emojiTaste: tasteRaw != null ? EmojiTasteX.fromJson(tasteRaw) : null,
      notes: row['notes'] as String?,
      attachmentTitle: row['attachment_title'] as String?,
      attachmentDescription: row['attachment_description'] as String?,
      photoUrl: row['photo_url'] as String?,
    );
  }

  AllergenProgramState _programStateFromRow(Map<String, dynamic> row) =>
      AllergenProgramState(
        id: row['id'] as String,
        babyId: row['baby_id'] as String,
        currentAllergenKey: row['current_allergen_key'] as String,
        currentSequenceOrder: row['current_sequence_order'] as int,
        status: AllergenProgramStatusX.fromJson(row['status'] as String),
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );

  ReactionDetail _reactionDetailFromRow(Map<String, dynamic> row) =>
      ReactionDetail(
        id: row['id'] as String,
        logId: row['log_id'] as String,
        severity: ReactionSeverityX.fromJson(row['severity'] as String),
        symptoms: (row['symptoms'] as List<dynamic>).cast<String>(),
        notes: row['notes'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

@Riverpod(keepAlive: true)
AllergenRepository allergenRepository(
  // Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
  // ignore: deprecated_member_use_from_same_package
  AllergenRepositoryRef ref,
) => AllergenRepositoryImpl();
