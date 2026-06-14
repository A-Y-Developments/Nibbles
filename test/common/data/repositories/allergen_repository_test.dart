// Unit tests for [AllergenRepositoryImpl].
//
// Covers every public method through the injected `SupabaseClient` +
// `HiveService` seams:
//   * getAllergens — cache hit, corrupt cache fall-through, remote fetch +
//     cache write, refresh bypass, Postgrest / unknown failure mapping
//   * getProgramState / getLogs / saveLog / updateLog / deleteLog /
//     saveReactionDetail / advanceProgramState / completeProgramState /
//     getReactionDetail — row mapping, request payload shape, and the
//     PostgrestException → ServerException / Object → UnknownException
//     contract on every path.
//
// The Postgrest chain is faked with a single awaitable `_FakeChain` (the SDK
// builders implement `Future`, so mocktail `thenReturn` is off the table —
// see recipe_repository_test.dart for the original rationale). The fake
// records `eq` filters and `order` columns so payload assertions don't rely
// on implementation-internal URL building.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nibbles/src/common/data/repositories/allergen_repository.dart';
import 'package:nibbles/src/common/data/sources/local/hive_service.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen.dart';
import 'package:nibbles/src/common/domain/entities/allergen_log.dart';
import 'package:nibbles/src/common/domain/entities/reaction_detail.dart';
import 'package:nibbles/src/common/domain/enums/allergen_program_status.dart';
import 'package:nibbles/src/common/domain/enums/emoji_taste.dart';
import 'package:nibbles/src/common/domain/enums/reaction_severity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockHiveService extends Mock implements HiveService {}

class _MockAllergensBox extends Mock implements Box<String> {}

// ---------------------------------------------------------------------------
// Postgrest chain fake
// ---------------------------------------------------------------------------

/// One awaitable fake for the whole builder chain. `eq` / `order` / `limit`
/// keep the chain going (recording what they were called with on the owning
/// `_FakeQueryBuilder`); `select` / `single` / `maybeSingle` re-type the
/// chain. Awaiting resolves to the payload or throws the configured error.
class _FakeChain<T> implements PostgrestFilterBuilder<T> {
  _FakeChain({required _FakeQueryBuilder owner, Object? payload, Object? error})
    : _owner = owner,
      _payload = payload,
      _error = error;

  final _FakeQueryBuilder _owner;
  final Object? _payload;
  final Object? _error;

  Future<T> get _future =>
      _error != null ? Future<T>.error(_error) : Future<T>.value(_payload as T);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    _owner.filters.add((column, value));
    return this;
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    _owner.orderedBy = column;
    return this;
  }

  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) =>
      this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) =>
      _FakeChain<PostgrestList>(
        owner: _owner,
        payload: _payload,
        error: _error,
      );

  @override
  PostgrestTransformBuilder<PostgrestMap> single() =>
      _FakeChain<PostgrestMap>(owner: _owner, payload: _payload, error: _error);

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() =>
      _FakeChain<PostgrestMap?>(
        owner: _owner,
        payload: _payload,
        error: _error,
      );

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) => _future.then(onValue, onError: onError);

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Unexpected call on _FakeChain: ${invocation.memberName}',
    );
  }
}

/// Fake `from(...)` result. Records insert/update payloads and delete calls;
/// every verb hands back a `_FakeChain` resolving to the configured
/// payload / error.
// ignore: must_be_immutable
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  _FakeQueryBuilder({Object? payload, Object? error})
    : _payload = payload,
      _error = error;

  final Object? _payload;
  final Object? _error;

  final List<(String, Object)> filters = [];
  String? orderedBy;
  Object? inserted;
  Map<dynamic, dynamic>? updated;
  bool deleteCalled = false;

  _FakeChain<PostgrestList> get _chain =>
      _FakeChain<PostgrestList>(owner: this, payload: _payload, error: _error);

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) =>
      _chain;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    inserted = values;
    return _chain;
  }

  @override
  PostgrestFilterBuilder<PostgrestList> update(Map<dynamic, dynamic> values) {
    updated = values;
    return _chain;
  }

  @override
  PostgrestFilterBuilder<PostgrestList> delete() {
    deleteCalled = true;
    return _chain;
  }
}

// ---------------------------------------------------------------------------
// Row fixtures
// ---------------------------------------------------------------------------

Map<String, dynamic> _allergenRow({
  String key = 'peanut',
  String displayName = 'Peanut',
  int sequenceOrder = 1,
}) => <String, dynamic>{
  'key': key,
  'display_name': displayName,
  'sequence_order': sequenceOrder,
};

Map<String, dynamic> _logRow({
  String id = 'log-1',
  String babyId = 'baby-1',
  String allergenKey = 'peanut',
  bool hadReaction = false,
  String createdAt = '2026-06-01T10:00:00Z',
  String? logDate = '2026-06-02',
  String? emojiTaste = 'love',
  String? notes,
  String? attachmentTitle,
  String? attachmentDescription,
  String? photoUrl,
}) => <String, dynamic>{
  'id': id,
  'baby_id': babyId,
  'allergen_key': allergenKey,
  'had_reaction': hadReaction,
  'created_at': createdAt,
  'log_date': logDate,
  'emoji_taste': emojiTaste,
  'notes': notes,
  'attachment_title': attachmentTitle,
  'attachment_description': attachmentDescription,
  'photo_url': photoUrl,
};

Map<String, dynamic> _programStateRow({String status = 'in_progress'}) =>
    <String, dynamic>{
      'id': 'ps-1',
      'baby_id': 'baby-1',
      'current_allergen_key': 'egg',
      'current_sequence_order': 2,
      'status': status,
      'created_at': '2026-05-01T08:00:00Z',
      'updated_at': '2026-06-01T08:00:00Z',
    };

Map<String, dynamic> _reactionRow({
  String severity = 'moderate',
  List<dynamic> symptoms = const <dynamic>['hives', 'vomiting'],
  String? notes = 'around the mouth',
}) => <String, dynamic>{
  'id': 'rd-1',
  'log_id': 'log-1',
  'severity': severity,
  'symptoms': symptoms,
  'notes': notes,
  'created_at': '2026-06-01T11:00:00Z',
};

final _sampleLog = AllergenLog(
  id: 'log-1',
  babyId: 'baby-1',
  allergenKey: 'peanut',
  hadReaction: true,
  logDate: DateTime.utc(2026, 6, 2),
  createdAt: DateTime.utc(2026, 6, 1, 10),
);

Matcher _failsWith<E extends AppException>([String? message]) =>
    isA<E>().having((e) => e.message, 'message', message ?? anything);

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockHiveService mockHive;
  late _MockAllergensBox mockBox;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockHive = _MockHiveService();
    mockBox = _MockAllergensBox();
    when(() => mockHive.allergensBox).thenReturn(mockBox);
    when(() => mockBox.get(any<dynamic>())).thenReturn(null);
    when(() => mockBox.put(any<dynamic>(), any())).thenAnswer((_) async {});
  });

  tearDown(resetMocktailState);

  AllergenRepositoryImpl buildSut() => AllergenRepositoryImpl(
    supabaseClient: mockSupabase,
    hiveService: mockHive,
  );

  _FakeQueryBuilder stubTable(String table, {Object? payload, Object? error}) {
    final builder = _FakeQueryBuilder(payload: payload, error: error);
    when(() => mockSupabase.from(table)).thenAnswer((_) => builder);
    return builder;
  }

  group('getAllergens', () {
    test('cache hit returns decoded list without touching Supabase', () async {
      const cached = [
        Allergen(key: 'peanut', name: 'Peanut', sequenceOrder: 1, emoji: '🥜'),
        Allergen(key: 'egg', name: 'Egg', sequenceOrder: 2, emoji: '🥚'),
      ];
      when(
        () => mockBox.get('allergens_list'),
      ).thenReturn(jsonEncode(cached.map((a) => a.toJson()).toList()));

      final result = await buildSut().getAllergens();

      expect(result.dataOrNull, cached);
      verifyNever(() => mockSupabase.from(any()));
    });

    test('corrupt cache falls through to remote fetch', () async {
      when(() => mockBox.get('allergens_list')).thenReturn('not-json{');
      final _ = stubTable(
        'allergens',
        payload: <Map<String, dynamic>>[_allergenRow()],
      );

      final result = await buildSut().getAllergens();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull!.single.key, 'peanut');
    });

    test(
      'cache miss fetches ordered rows, maps emoji per key, writes cache',
      () async {
        final builder = stubTable(
          'allergens',
          payload: <Map<String, dynamic>>[
            _allergenRow(),
            _allergenRow(key: 'egg', displayName: 'Egg', sequenceOrder: 2),
          ],
        );

        final result = await buildSut().getAllergens();

        final allergens = result.dataOrNull!;
        expect(allergens, hasLength(2));
        expect(allergens[0].emoji, '🥜');
        expect(allergens[1].emoji, '🥚');
        expect(builder.orderedBy, 'sequence_order');

        final written =
            verify(
                  () => mockBox.put('allergens_list', captureAny()),
                ).captured.single
                as String;
        expect(
          (jsonDecode(written) as List).cast<Map<String, dynamic>>().map(
            Allergen.fromJson,
          ),
          allergens,
        );
      },
    );

    test('refresh: true bypasses a populated cache', () async {
      when(() => mockBox.get('allergens_list')).thenReturn(
        jsonEncode([
          const Allergen(
            key: 'stale',
            name: 'Stale',
            sequenceOrder: 99,
            emoji: '',
          ).toJson(),
        ]),
      );
      final _ = stubTable(
        'allergens',
        payload: <Map<String, dynamic>>[_allergenRow()],
      );

      final result = await buildSut().getAllergens(refresh: true);

      expect(result.dataOrNull!.single.key, 'peanut');
    });

    test('PostgrestException maps to ServerException with message', () async {
      final _ = stubTable(
        'allergens',
        error: const PostgrestException(message: 'rls denied'),
      );

      final result = await buildSut().getAllergens();

      expect(result.errorOrNull, _failsWith<ServerException>('rls denied'));
    });

    test('unexpected error maps to UnknownException', () async {
      final _ = stubTable('allergens', error: StateError('boom'));

      final result = await buildSut().getAllergens();

      expect(result.errorOrNull, _failsWith<UnknownException>());
    });
  });

  group('getProgramState', () {
    test('maps row to AllergenProgramState', () async {
      final builder = stubTable(
        'allergen_program_state',
        payload: _programStateRow(),
      );

      final result = await buildSut().getProgramState('baby-1');

      final state = result.dataOrNull!;
      expect(state.id, 'ps-1');
      expect(state.babyId, 'baby-1');
      expect(state.currentAllergenKey, 'egg');
      expect(state.currentSequenceOrder, 2);
      expect(state.status, AllergenProgramStatus.inProgress);
      expect(state.createdAt, DateTime.utc(2026, 5, 1, 8));
      expect(state.updatedAt, DateTime.utc(2026, 6, 1, 8));
      expect(builder.filters, [('baby_id', 'baby-1')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_program_state',
        error: const PostgrestException(message: 'no rows'),
      );

      final result = await buildSut().getProgramState('baby-1');

      expect(result.errorOrNull, _failsWith<ServerException>('no rows'));
    });

    test('unexpected error maps to UnknownException', () async {
      final _ = stubTable(
        'allergen_program_state',
        error: ArgumentError('bad'),
      );

      final result = await buildSut().getProgramState('baby-1');

      expect(result.errorOrNull, _failsWith<UnknownException>());
    });
  });

  group('getLogs', () {
    test('maps rows ordered by created_at, baby filter only', () async {
      final builder = stubTable(
        'allergen_logs',
        payload: <Map<String, dynamic>>[
          _logRow(),
          _logRow(id: 'log-2', emojiTaste: null, logDate: null),
        ],
      );

      final result = await buildSut().getLogs('baby-1');

      final logs = result.dataOrNull!;
      expect(logs, hasLength(2));
      expect(logs[0].emojiTaste, EmojiTaste.love);
      expect(logs[0].logDate, DateTime.parse('2026-06-02'));
      expect(logs[1].emojiTaste, isNull);
      expect(builder.orderedBy, 'created_at');
      expect(builder.filters, [('baby_id', 'baby-1')]);
    });

    test('null log_date falls back to created_at', () async {
      final _ = stubTable(
        'allergen_logs',
        payload: <Map<String, dynamic>>[_logRow(logDate: null)],
      );

      final result = await buildSut().getLogs('baby-1');

      expect(result.dataOrNull!.single.logDate, DateTime.utc(2026, 6, 1, 10));
    });

    test('allergenKey filter adds a second eq', () async {
      final builder = stubTable(
        'allergen_logs',
        payload: <Map<String, dynamic>>[],
      );

      await buildSut().getLogs('baby-1', allergenKey: 'egg');

      expect(builder.filters, [
        ('baby_id', 'baby-1'),
        ('allergen_key', 'egg'),
      ]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_logs',
        error: const PostgrestException(message: 'offline'),
      );

      final result = await buildSut().getLogs('baby-1');

      expect(result.errorOrNull, _failsWith<ServerException>('offline'));
    });
  });

  group('saveLog', () {
    test(
      'inserts required columns, formats log_date, omits null optionals',
      () async {
        final builder = stubTable('allergen_logs', payload: _logRow());

        final result = await buildSut().saveLog(_sampleLog);

        expect(result.isSuccess, isTrue);
        expect(builder.inserted, <String, dynamic>{
          'baby_id': 'baby-1',
          'allergen_key': 'peanut',
          'had_reaction': true,
          'log_date': '2026-06-02',
        });
      },
    );

    test('includes optionals when set and returns the mapped row', () async {
      final builder = stubTable(
        'allergen_logs',
        payload: _logRow(
          hadReaction: true,
          notes: 'sneezed',
          attachmentTitle: 'First taste',
          attachmentDescription: 'Tiny smear',
          photoUrl: 'https://cdn/x.jpg',
        ),
      );

      final result = await buildSut().saveLog(
        _sampleLog.copyWith(
          emojiTaste: EmojiTaste.dislike,
          notes: 'sneezed',
          attachmentTitle: 'First taste',
          attachmentDescription: 'Tiny smear',
          photoUrl: 'https://cdn/x.jpg',
        ),
      );

      final inserted = builder.inserted! as Map<String, dynamic>;
      expect(inserted['emoji_taste'], 'dislike');
      expect(inserted['notes'], 'sneezed');
      expect(inserted['attachment_title'], 'First taste');
      expect(inserted['attachment_description'], 'Tiny smear');
      expect(inserted['photo_url'], 'https://cdn/x.jpg');

      final log = result.dataOrNull!;
      expect(log.notes, 'sneezed');
      expect(log.photoUrl, 'https://cdn/x.jpg');
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_logs',
        error: const PostgrestException(message: 'constraint'),
      );

      final result = await buildSut().saveLog(_sampleLog);

      expect(result.errorOrNull, _failsWith<ServerException>('constraint'));
    });
  });

  group('updateLog', () {
    test(
      'writes every editable column (nulls included) filtered by id',
      () async {
        final builder = stubTable('allergen_logs', payload: _logRow());

        final result = await buildSut().updateLog(_sampleLog);

        expect(result.isSuccess, isTrue);
        expect(builder.updated, <String, dynamic>{
          'emoji_taste': null,
          'had_reaction': true,
          'notes': null,
          'attachment_title': null,
          'attachment_description': null,
          'log_date': '2026-06-02',
          'photo_url': null,
        });
        expect(builder.filters, [('id', 'log-1')]);
      },
    );

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_logs',
        error: const PostgrestException(message: 'rls denied'),
      );

      final result = await buildSut().updateLog(_sampleLog);

      expect(result.errorOrNull, _failsWith<ServerException>('rls denied'));
    });

    test('unexpected error maps to UnknownException', () async {
      final _ = stubTable('allergen_logs', error: StateError('boom'));

      final result = await buildSut().updateLog(_sampleLog);

      expect(result.errorOrNull, _failsWith<UnknownException>());
    });
  });

  group('deleteLog', () {
    test('deletes by id', () async {
      final builder = stubTable(
        'allergen_logs',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().deleteLog('log-9');

      expect(result.isSuccess, isTrue);
      expect(builder.deleteCalled, isTrue);
      expect(builder.filters, [('id', 'log-9')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_logs',
        error: const PostgrestException(message: 'denied'),
      );

      final result = await buildSut().deleteLog('log-9');

      expect(result.errorOrNull, _failsWith<ServerException>('denied'));
    });
  });

  group('saveReactionDetail', () {
    final detail = ReactionDetail(
      id: '',
      logId: 'log-1',
      severity: ReactionSeverity.moderate,
      symptoms: const ['hives', 'vomiting'],
      createdAt: DateTime.utc(2026, 6, 1, 11),
      notes: 'around the mouth',
    );

    test('inserts payload and maps the returned row', () async {
      final builder = stubTable('reaction_details', payload: _reactionRow());

      final result = await buildSut().saveReactionDetail(detail);

      expect(builder.inserted, <String, dynamic>{
        'log_id': 'log-1',
        'severity': 'moderate',
        'symptoms': ['hives', 'vomiting'],
        'notes': 'around the mouth',
      });
      final saved = result.dataOrNull!;
      expect(saved.id, 'rd-1');
      expect(saved.severity, ReactionSeverity.moderate);
      expect(saved.symptoms, ['hives', 'vomiting']);
      expect(saved.createdAt, DateTime.utc(2026, 6, 1, 11));
    });

    test('omits notes when null', () async {
      final builder = stubTable(
        'reaction_details',
        payload: _reactionRow(notes: null),
      );

      await buildSut().saveReactionDetail(
        ReactionDetail(
          id: '',
          logId: 'log-1',
          severity: ReactionSeverity.severe,
          symptoms: const ['swelling'],
          createdAt: DateTime.utc(2026, 6, 1, 11),
        ),
      );

      final inserted = builder.inserted! as Map<String, dynamic>;
      expect(inserted.containsKey('notes'), isFalse);
      expect(inserted['severity'], 'severe');
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'reaction_details',
        error: const PostgrestException(message: 'fk violation'),
      );

      final result = await buildSut().saveReactionDetail(detail);

      expect(result.errorOrNull, _failsWith<ServerException>('fk violation'));
    });
  });

  group('advanceProgramState', () {
    test('updates key + sequence filtered by baby', () async {
      final builder = stubTable(
        'allergen_program_state',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().advanceProgramState('baby-1', 'egg', 2);

      expect(result.isSuccess, isTrue);
      expect(builder.updated, <String, dynamic>{
        'current_allergen_key': 'egg',
        'current_sequence_order': 2,
      });
      expect(builder.filters, [('baby_id', 'baby-1')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_program_state',
        error: const PostgrestException(message: 'stale'),
      );

      final result = await buildSut().advanceProgramState('baby-1', 'egg', 2);

      expect(result.errorOrNull, _failsWith<ServerException>('stale'));
    });
  });

  group('completeProgramState', () {
    test('writes completed status filtered by baby', () async {
      final builder = stubTable(
        'allergen_program_state',
        payload: <Map<String, dynamic>>[],
      );

      final result = await buildSut().completeProgramState('baby-1');

      expect(result.isSuccess, isTrue);
      expect(builder.updated, <String, dynamic>{'status': 'completed'});
      expect(builder.filters, [('baby_id', 'baby-1')]);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'allergen_program_state',
        error: const PostgrestException(message: 'rls denied'),
      );

      final result = await buildSut().completeProgramState('baby-1');

      expect(result.errorOrNull, _failsWith<ServerException>('rls denied'));
    });

    test('unexpected error maps to UnknownException', () async {
      final _ = stubTable('allergen_program_state', error: StateError('boom'));

      final result = await buildSut().completeProgramState('baby-1');

      expect(result.errorOrNull, _failsWith<UnknownException>());
    });
  });

  group('getReactionDetail', () {
    test('maps the row when present', () async {
      final builder = stubTable('reaction_details', payload: _reactionRow());

      final result = await buildSut().getReactionDetail('log-1');

      expect(result.dataOrNull!.severity, ReactionSeverity.moderate);
      expect(builder.filters, [('log_id', 'log-1')]);
    });

    test('maybeSingle null resolves to Success(null)', () async {
      final _ = stubTable('reaction_details');

      final result = await buildSut().getReactionDetail('log-1');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test('PostgrestException maps to ServerException', () async {
      final _ = stubTable(
        'reaction_details',
        error: const PostgrestException(message: 'denied'),
      );

      final result = await buildSut().getReactionDetail('log-1');

      expect(result.errorOrNull, _failsWith<ServerException>('denied'));
    });
  });
}
