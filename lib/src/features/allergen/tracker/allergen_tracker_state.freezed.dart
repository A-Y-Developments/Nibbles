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
  List<RecentReaction> get recentReactions =>
      throw _privateConstructorUsedError;

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
    List<RecentReaction> recentReactions,
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
    Object? recentReactions = null,
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
            recentReactions: null == recentReactions
                ? _value.recentReactions
                : recentReactions // ignore: cast_nullable_to_non_nullable
                      as List<RecentReaction>,
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
    List<RecentReaction> recentReactions,
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
    Object? recentReactions = null,
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
        recentReactions: null == recentReactions
            ? _value._recentReactions
            : recentReactions // ignore: cast_nullable_to_non_nullable
                  as List<RecentReaction>,
      ),
    );
  }
}

/// @nodoc

class _$AllergenTrackerStateImpl implements _AllergenTrackerState {
  const _$AllergenTrackerStateImpl({
    required final List<AllergenBoardItem> boardItems,
    required this.programState,
    required final List<RecentReaction> recentReactions,
  }) : _boardItems = boardItems,
       _recentReactions = recentReactions;

  final List<AllergenBoardItem> _boardItems;
  @override
  List<AllergenBoardItem> get boardItems {
    if (_boardItems is EqualUnmodifiableListView) return _boardItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boardItems);
  }

  @override
  final AllergenProgramState programState;
  final List<RecentReaction> _recentReactions;
  @override
  List<RecentReaction> get recentReactions {
    if (_recentReactions is EqualUnmodifiableListView) return _recentReactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentReactions);
  }

  @override
  String toString() {
    return 'AllergenTrackerState(boardItems: $boardItems, programState: $programState, recentReactions: $recentReactions)';
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
              other._recentReactions,
              _recentReactions,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_boardItems),
    programState,
    const DeepCollectionEquality().hash(_recentReactions),
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
    required final List<RecentReaction> recentReactions,
  }) = _$AllergenTrackerStateImpl;

  @override
  List<AllergenBoardItem> get boardItems;
  @override
  AllergenProgramState get programState;
  @override
  List<RecentReaction> get recentReactions;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenTrackerStateImplCopyWith<_$AllergenTrackerStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecentReaction {
  String get allergenName => throw _privateConstructorUsedError;
  String get allergenEmoji => throw _privateConstructorUsedError;
  DateTime get logDate => throw _privateConstructorUsedError;
  ReactionSeverity? get severity => throw _privateConstructorUsedError;

  /// Create a copy of RecentReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentReactionCopyWith<RecentReaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentReactionCopyWith<$Res> {
  factory $RecentReactionCopyWith(
    RecentReaction value,
    $Res Function(RecentReaction) then,
  ) = _$RecentReactionCopyWithImpl<$Res, RecentReaction>;
  @useResult
  $Res call({
    String allergenName,
    String allergenEmoji,
    DateTime logDate,
    ReactionSeverity? severity,
  });
}

/// @nodoc
class _$RecentReactionCopyWithImpl<$Res, $Val extends RecentReaction>
    implements $RecentReactionCopyWith<$Res> {
  _$RecentReactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergenName = null,
    Object? allergenEmoji = null,
    Object? logDate = null,
    Object? severity = freezed,
  }) {
    return _then(
      _value.copyWith(
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
abstract class _$$RecentReactionImplCopyWith<$Res>
    implements $RecentReactionCopyWith<$Res> {
  factory _$$RecentReactionImplCopyWith(
    _$RecentReactionImpl value,
    $Res Function(_$RecentReactionImpl) then,
  ) = __$$RecentReactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String allergenName,
    String allergenEmoji,
    DateTime logDate,
    ReactionSeverity? severity,
  });
}

/// @nodoc
class __$$RecentReactionImplCopyWithImpl<$Res>
    extends _$RecentReactionCopyWithImpl<$Res, _$RecentReactionImpl>
    implements _$$RecentReactionImplCopyWith<$Res> {
  __$$RecentReactionImplCopyWithImpl(
    _$RecentReactionImpl _value,
    $Res Function(_$RecentReactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecentReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergenName = null,
    Object? allergenEmoji = null,
    Object? logDate = null,
    Object? severity = freezed,
  }) {
    return _then(
      _$RecentReactionImpl(
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
        severity: freezed == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as ReactionSeverity?,
      ),
    );
  }
}

/// @nodoc

class _$RecentReactionImpl implements _RecentReaction {
  const _$RecentReactionImpl({
    required this.allergenName,
    required this.allergenEmoji,
    required this.logDate,
    required this.severity,
  });

  @override
  final String allergenName;
  @override
  final String allergenEmoji;
  @override
  final DateTime logDate;
  @override
  final ReactionSeverity? severity;

  @override
  String toString() {
    return 'RecentReaction(allergenName: $allergenName, allergenEmoji: $allergenEmoji, logDate: $logDate, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentReactionImpl &&
            (identical(other.allergenName, allergenName) ||
                other.allergenName == allergenName) &&
            (identical(other.allergenEmoji, allergenEmoji) ||
                other.allergenEmoji == allergenEmoji) &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, allergenName, allergenEmoji, logDate, severity);

  /// Create a copy of RecentReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentReactionImplCopyWith<_$RecentReactionImpl> get copyWith =>
      __$$RecentReactionImplCopyWithImpl<_$RecentReactionImpl>(
        this,
        _$identity,
      );
}

abstract class _RecentReaction implements RecentReaction {
  const factory _RecentReaction({
    required final String allergenName,
    required final String allergenEmoji,
    required final DateTime logDate,
    required final ReactionSeverity? severity,
  }) = _$RecentReactionImpl;

  @override
  String get allergenName;
  @override
  String get allergenEmoji;
  @override
  DateTime get logDate;
  @override
  ReactionSeverity? get severity;

  /// Create a copy of RecentReaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentReactionImplCopyWith<_$RecentReactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
