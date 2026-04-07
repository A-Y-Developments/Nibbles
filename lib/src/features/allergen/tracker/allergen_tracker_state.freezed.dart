// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_tracker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenTrackerState {
  List<AllergenBoardItem> get boardItems => throw _privateConstructorUsedError;
  AllergenProgramState get programState => throw _privateConstructorUsedError;
  List<RecentLogEntry> get recentLogs => throw _privateConstructorUsedError;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenTrackerStateCopyWith<AllergenTrackerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenTrackerStateCopyWith<$Res> {
  factory $AllergenTrackerStateCopyWith(
    AllergenTrackerState value,
    $Res Function(AllergenTrackerState) then,
  ) = _$AllergenTrackerStateCopyWithImpl<$Res, AllergenTrackerState>;
  @useResult
  $Res call({
    List<AllergenBoardItem> boardItems,
    AllergenProgramState programState,
    List<RecentLogEntry> recentLogs,
  });

  $AllergenProgramStateCopyWith<$Res> get programState;
}

/// @nodoc
class _$AllergenTrackerStateCopyWithImpl<
  $Res,
  $Val extends AllergenTrackerState
>
    implements $AllergenTrackerStateCopyWith<$Res> {
  _$AllergenTrackerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boardItems = null,
    Object? programState = null,
    Object? recentLogs = null,
  }) {
    return _then(
      _value.copyWith(
            boardItems: null == boardItems
                ? _value.boardItems
                : boardItems // ignore: cast_nullable_to_non_nullable
                      as List<AllergenBoardItem>,
            programState: null == programState
                ? _value.programState
                : programState // ignore: cast_nullable_to_non_nullable
                      as AllergenProgramState,
            recentLogs: null == recentLogs
                ? _value.recentLogs
                : recentLogs // ignore: cast_nullable_to_non_nullable
                      as List<RecentLogEntry>,
          )
          as $Val,
    );
  }

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenProgramStateCopyWith<$Res> get programState {
    return $AllergenProgramStateCopyWith<$Res>(_value.programState, (value) {
      return _then(_value.copyWith(programState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AllergenTrackerStateImplCopyWith<$Res>
    implements $AllergenTrackerStateCopyWith<$Res> {
  factory _$$AllergenTrackerStateImplCopyWith(
    _$AllergenTrackerStateImpl value,
    $Res Function(_$AllergenTrackerStateImpl) then,
  ) = __$$AllergenTrackerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AllergenBoardItem> boardItems,
    AllergenProgramState programState,
    List<RecentLogEntry> recentLogs,
  });

  @override
  $AllergenProgramStateCopyWith<$Res> get programState;
}

/// @nodoc
class __$$AllergenTrackerStateImplCopyWithImpl<$Res>
    extends _$AllergenTrackerStateCopyWithImpl<$Res, _$AllergenTrackerStateImpl>
    implements _$$AllergenTrackerStateImplCopyWith<$Res> {
  __$$AllergenTrackerStateImplCopyWithImpl(
    _$AllergenTrackerStateImpl _value,
    $Res Function(_$AllergenTrackerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boardItems = null,
    Object? programState = null,
    Object? recentLogs = null,
  }) {
    return _then(
      _$AllergenTrackerStateImpl(
        boardItems: null == boardItems
            ? _value._boardItems
            : boardItems // ignore: cast_nullable_to_non_nullable
                  as List<AllergenBoardItem>,
        programState: null == programState
            ? _value.programState
            : programState // ignore: cast_nullable_to_non_nullable
                  as AllergenProgramState,
        recentLogs: null == recentLogs
            ? _value._recentLogs
            : recentLogs // ignore: cast_nullable_to_non_nullable
                  as List<RecentLogEntry>,
      ),
    );
  }
}

/// @nodoc

class _$AllergenTrackerStateImpl implements _AllergenTrackerState {
  const _$AllergenTrackerStateImpl({
    required final List<AllergenBoardItem> boardItems,
    required this.programState,
    required final List<RecentLogEntry> recentLogs,
  }) : _boardItems = boardItems,
       _recentLogs = recentLogs;

  final List<AllergenBoardItem> _boardItems;
  @override
  List<AllergenBoardItem> get boardItems {
    if (_boardItems is EqualUnmodifiableListView) return _boardItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boardItems);
  }

  @override
  final AllergenProgramState programState;
  final List<RecentLogEntry> _recentLogs;
  @override
  List<RecentLogEntry> get recentLogs {
    if (_recentLogs is EqualUnmodifiableListView) return _recentLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentLogs);
  }

  @override
  String toString() {
    return 'AllergenTrackerState(boardItems: $boardItems, programState: $programState, recentLogs: $recentLogs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenTrackerStateImpl &&
            const DeepCollectionEquality().equals(
              other._boardItems,
              _boardItems,
            ) &&
            (identical(other.programState, programState) ||
                other.programState == programState) &&
            const DeepCollectionEquality().equals(
              other._recentLogs,
              _recentLogs,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_boardItems),
    programState,
    const DeepCollectionEquality().hash(_recentLogs),
  );

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenTrackerStateImplCopyWith<_$AllergenTrackerStateImpl>
  get copyWith =>
      __$$AllergenTrackerStateImplCopyWithImpl<_$AllergenTrackerStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenTrackerState implements AllergenTrackerState {
  const factory _AllergenTrackerState({
    required final List<AllergenBoardItem> boardItems,
    required final AllergenProgramState programState,
    required final List<RecentLogEntry> recentLogs,
  }) = _$AllergenTrackerStateImpl;

  @override
  List<AllergenBoardItem> get boardItems;
  @override
  AllergenProgramState get programState;
  @override
  List<RecentLogEntry> get recentLogs;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenTrackerStateImplCopyWith<_$AllergenTrackerStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecentLogEntry {
  String get allergenKey => throw _privateConstructorUsedError;
  String get allergenName => throw _privateConstructorUsedError;
  String get allergenEmoji => throw _privateConstructorUsedError;
  DateTime get logDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  EmojiTaste get taste => throw _privateConstructorUsedError;
  bool get hadReaction => throw _privateConstructorUsedError;
  ReactionSeverity? get severity => throw _privateConstructorUsedError;

  /// Create a copy of RecentLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentLogEntryCopyWith<RecentLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentLogEntryCopyWith<$Res> {
  factory $RecentLogEntryCopyWith(
    RecentLogEntry value,
    $Res Function(RecentLogEntry) then,
  ) = _$RecentLogEntryCopyWithImpl<$Res, RecentLogEntry>;
  @useResult
  $Res call({
    String allergenKey,
    String allergenName,
    String allergenEmoji,
    DateTime logDate,
    DateTime createdAt,
    EmojiTaste taste,
    bool hadReaction,
    ReactionSeverity? severity,
  });
}

/// @nodoc
class _$RecentLogEntryCopyWithImpl<$Res, $Val extends RecentLogEntry>
    implements $RecentLogEntryCopyWith<$Res> {
  _$RecentLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergenKey = null,
    Object? allergenName = null,
    Object? allergenEmoji = null,
    Object? logDate = null,
    Object? createdAt = null,
    Object? taste = null,
    Object? hadReaction = null,
    Object? severity = freezed,
  }) {
    return _then(
      _value.copyWith(
            allergenKey: null == allergenKey
                ? _value.allergenKey
                : allergenKey // ignore: cast_nullable_to_non_nullable
                      as String,
            allergenName: null == allergenName
                ? _value.allergenName
                : allergenName // ignore: cast_nullable_to_non_nullable
                      as String,
            allergenEmoji: null == allergenEmoji
                ? _value.allergenEmoji
                : allergenEmoji // ignore: cast_nullable_to_non_nullable
                      as String,
            logDate: null == logDate
                ? _value.logDate
                : logDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            taste: null == taste
                ? _value.taste
                : taste // ignore: cast_nullable_to_non_nullable
                      as EmojiTaste,
            hadReaction: null == hadReaction
                ? _value.hadReaction
                : hadReaction // ignore: cast_nullable_to_non_nullable
                      as bool,
            severity: freezed == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as ReactionSeverity?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecentLogEntryImplCopyWith<$Res>
    implements $RecentLogEntryCopyWith<$Res> {
  factory _$$RecentLogEntryImplCopyWith(
    _$RecentLogEntryImpl value,
    $Res Function(_$RecentLogEntryImpl) then,
  ) = __$$RecentLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String allergenKey,
    String allergenName,
    String allergenEmoji,
    DateTime logDate,
    DateTime createdAt,
    EmojiTaste taste,
    bool hadReaction,
    ReactionSeverity? severity,
  });
}

/// @nodoc
class __$$RecentLogEntryImplCopyWithImpl<$Res>
    extends _$RecentLogEntryCopyWithImpl<$Res, _$RecentLogEntryImpl>
    implements _$$RecentLogEntryImplCopyWith<$Res> {
  __$$RecentLogEntryImplCopyWithImpl(
    _$RecentLogEntryImpl _value,
    $Res Function(_$RecentLogEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecentLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergenKey = null,
    Object? allergenName = null,
    Object? allergenEmoji = null,
    Object? logDate = null,
    Object? createdAt = null,
    Object? taste = null,
    Object? hadReaction = null,
    Object? severity = freezed,
  }) {
    return _then(
      _$RecentLogEntryImpl(
        allergenKey: null == allergenKey
            ? _value.allergenKey
            : allergenKey // ignore: cast_nullable_to_non_nullable
                  as String,
        allergenName: null == allergenName
            ? _value.allergenName
            : allergenName // ignore: cast_nullable_to_non_nullable
                  as String,
        allergenEmoji: null == allergenEmoji
            ? _value.allergenEmoji
            : allergenEmoji // ignore: cast_nullable_to_non_nullable
                  as String,
        logDate: null == logDate
            ? _value.logDate
            : logDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        taste: null == taste
            ? _value.taste
            : taste // ignore: cast_nullable_to_non_nullable
                  as EmojiTaste,
        hadReaction: null == hadReaction
            ? _value.hadReaction
            : hadReaction // ignore: cast_nullable_to_non_nullable
                  as bool,
        severity: freezed == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as ReactionSeverity?,
      ),
    );
  }
}

/// @nodoc

class _$RecentLogEntryImpl implements _RecentLogEntry {
  const _$RecentLogEntryImpl({
    required this.allergenKey,
    required this.allergenName,
    required this.allergenEmoji,
    required this.logDate,
    required this.createdAt,
    required this.taste,
    required this.hadReaction,
    required this.severity,
  });

  @override
  final String allergenKey;
  @override
  final String allergenName;
  @override
  final String allergenEmoji;
  @override
  final DateTime logDate;
  @override
  final DateTime createdAt;
  @override
  final EmojiTaste taste;
  @override
  final bool hadReaction;
  @override
  final ReactionSeverity? severity;

  @override
  String toString() {
    return 'RecentLogEntry(allergenKey: $allergenKey, allergenName: $allergenName, allergenEmoji: $allergenEmoji, logDate: $logDate, createdAt: $createdAt, taste: $taste, hadReaction: $hadReaction, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentLogEntryImpl &&
            (identical(other.allergenKey, allergenKey) ||
                other.allergenKey == allergenKey) &&
            (identical(other.allergenName, allergenName) ||
                other.allergenName == allergenName) &&
            (identical(other.allergenEmoji, allergenEmoji) ||
                other.allergenEmoji == allergenEmoji) &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.taste, taste) || other.taste == taste) &&
            (identical(other.hadReaction, hadReaction) ||
                other.hadReaction == hadReaction) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    allergenKey,
    allergenName,
    allergenEmoji,
    logDate,
    createdAt,
    taste,
    hadReaction,
    severity,
  );

  /// Create a copy of RecentLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentLogEntryImplCopyWith<_$RecentLogEntryImpl> get copyWith =>
      __$$RecentLogEntryImplCopyWithImpl<_$RecentLogEntryImpl>(
        this,
        _$identity,
      );
}

abstract class _RecentLogEntry implements RecentLogEntry {
  const factory _RecentLogEntry({
    required final String allergenKey,
    required final String allergenName,
    required final String allergenEmoji,
    required final DateTime logDate,
    required final DateTime createdAt,
    required final EmojiTaste taste,
    required final bool hadReaction,
    required final ReactionSeverity? severity,
  }) = _$RecentLogEntryImpl;

  @override
  String get allergenKey;
  @override
  String get allergenName;
  @override
  String get allergenEmoji;
  @override
  DateTime get logDate;
  @override
  DateTime get createdAt;
  @override
  EmojiTaste get taste;
  @override
  bool get hadReaction;
  @override
  ReactionSeverity? get severity;

  /// Create a copy of RecentLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentLogEntryImplCopyWith<_$RecentLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
