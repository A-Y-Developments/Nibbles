// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenDetailState {
  Allergen get allergen => throw _privateConstructorUsedError;
  List<AllergenLog> get logs => throw _privateConstructorUsedError;
  AllergenProgramState get programState => throw _privateConstructorUsedError;
  bool get hasLoggedToday => throw _privateConstructorUsedError;
  AllergenStatus get status => throw _privateConstructorUsedError;
  Map<String, ReactionDetail> get reactionDetails =>
      throw _privateConstructorUsedError;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenDetailStateCopyWith<AllergenDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenDetailStateCopyWith<$Res> {
  factory $AllergenDetailStateCopyWith(
    AllergenDetailState value,
    $Res Function(AllergenDetailState) then,
  ) = _$AllergenDetailStateCopyWithImpl<$Res, AllergenDetailState>;
  @useResult
  $Res call({
    Allergen allergen,
    List<AllergenLog> logs,
    AllergenProgramState programState,
    bool hasLoggedToday,
    AllergenStatus status,
    Map<String, ReactionDetail> reactionDetails,
  });

  $AllergenCopyWith<$Res> get allergen;
  $AllergenProgramStateCopyWith<$Res> get programState;
}

/// @nodoc
class _$AllergenDetailStateCopyWithImpl<$Res, $Val extends AllergenDetailState>
    implements $AllergenDetailStateCopyWith<$Res> {
  _$AllergenDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergen = null,
    Object? logs = null,
    Object? programState = null,
    Object? hasLoggedToday = null,
    Object? status = null,
    Object? reactionDetails = null,
  }) {
    return _then(
      _value.copyWith(
            allergen: null == allergen
                ? _value.allergen
                : allergen // ignore: cast_nullable_to_non_nullable
                      as Allergen,
            logs: null == logs
                ? _value.logs
                : logs // ignore: cast_nullable_to_non_nullable
                      as List<AllergenLog>,
            programState: null == programState
                ? _value.programState
                : programState // ignore: cast_nullable_to_non_nullable
                      as AllergenProgramState,
            hasLoggedToday: null == hasLoggedToday
                ? _value.hasLoggedToday
                : hasLoggedToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AllergenStatus,
            reactionDetails: null == reactionDetails
                ? _value.reactionDetails
                : reactionDetails // ignore: cast_nullable_to_non_nullable
                      as Map<String, ReactionDetail>,
          )
          as $Val,
    );
  }

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenCopyWith<$Res> get allergen {
    return $AllergenCopyWith<$Res>(_value.allergen, (value) {
      return _then(_value.copyWith(allergen: value) as $Val);
    });
  }

  /// Create a copy of AllergenDetailState
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
abstract class _$$AllergenDetailStateImplCopyWith<$Res>
    implements $AllergenDetailStateCopyWith<$Res> {
  factory _$$AllergenDetailStateImplCopyWith(
    _$AllergenDetailStateImpl value,
    $Res Function(_$AllergenDetailStateImpl) then,
  ) = __$$AllergenDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Allergen allergen,
    List<AllergenLog> logs,
    AllergenProgramState programState,
    bool hasLoggedToday,
    AllergenStatus status,
    Map<String, ReactionDetail> reactionDetails,
  });

  @override
  $AllergenCopyWith<$Res> get allergen;
  @override
  $AllergenProgramStateCopyWith<$Res> get programState;
}

/// @nodoc
class __$$AllergenDetailStateImplCopyWithImpl<$Res>
    extends _$AllergenDetailStateCopyWithImpl<$Res, _$AllergenDetailStateImpl>
    implements _$$AllergenDetailStateImplCopyWith<$Res> {
  __$$AllergenDetailStateImplCopyWithImpl(
    _$AllergenDetailStateImpl _value,
    $Res Function(_$AllergenDetailStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergen = null,
    Object? logs = null,
    Object? programState = null,
    Object? hasLoggedToday = null,
    Object? status = null,
    Object? reactionDetails = null,
  }) {
    return _then(
      _$AllergenDetailStateImpl(
        allergen: null == allergen
            ? _value.allergen
            : allergen // ignore: cast_nullable_to_non_nullable
                  as Allergen,
        logs: null == logs
            ? _value._logs
            : logs // ignore: cast_nullable_to_non_nullable
                  as List<AllergenLog>,
        programState: null == programState
            ? _value.programState
            : programState // ignore: cast_nullable_to_non_nullable
                  as AllergenProgramState,
        hasLoggedToday: null == hasLoggedToday
            ? _value.hasLoggedToday
            : hasLoggedToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AllergenStatus,
        reactionDetails: null == reactionDetails
            ? _value._reactionDetails
            : reactionDetails // ignore: cast_nullable_to_non_nullable
                  as Map<String, ReactionDetail>,
      ),
    );
  }
}

/// @nodoc

class _$AllergenDetailStateImpl implements _AllergenDetailState {
  const _$AllergenDetailStateImpl({
    required this.allergen,
    required final List<AllergenLog> logs,
    required this.programState,
    required this.hasLoggedToday,
    required this.status,
    final Map<String, ReactionDetail> reactionDetails =
        const <String, ReactionDetail>{},
  }) : _logs = logs,
       _reactionDetails = reactionDetails;

  @override
  final Allergen allergen;
  final List<AllergenLog> _logs;
  @override
  List<AllergenLog> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  @override
  final AllergenProgramState programState;
  @override
  final bool hasLoggedToday;
  @override
  final AllergenStatus status;
  final Map<String, ReactionDetail> _reactionDetails;
  @override
  @JsonKey()
  Map<String, ReactionDetail> get reactionDetails {
    if (_reactionDetails is EqualUnmodifiableMapView) return _reactionDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactionDetails);
  }

  @override
  String toString() {
    return 'AllergenDetailState(allergen: $allergen, logs: $logs, programState: $programState, hasLoggedToday: $hasLoggedToday, status: $status, reactionDetails: $reactionDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenDetailStateImpl &&
            (identical(other.allergen, allergen) ||
                other.allergen == allergen) &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            (identical(other.programState, programState) ||
                other.programState == programState) &&
            (identical(other.hasLoggedToday, hasLoggedToday) ||
                other.hasLoggedToday == hasLoggedToday) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._reactionDetails,
              _reactionDetails,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    allergen,
    const DeepCollectionEquality().hash(_logs),
    programState,
    hasLoggedToday,
    status,
    const DeepCollectionEquality().hash(_reactionDetails),
  );

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenDetailStateImplCopyWith<_$AllergenDetailStateImpl> get copyWith =>
      __$$AllergenDetailStateImplCopyWithImpl<_$AllergenDetailStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenDetailState implements AllergenDetailState {
  const factory _AllergenDetailState({
    required final Allergen allergen,
    required final List<AllergenLog> logs,
    required final AllergenProgramState programState,
    required final bool hasLoggedToday,
    required final AllergenStatus status,
    final Map<String, ReactionDetail> reactionDetails,
  }) = _$AllergenDetailStateImpl;

  @override
  Allergen get allergen;
  @override
  List<AllergenLog> get logs;
  @override
  AllergenProgramState get programState;
  @override
  bool get hasLoggedToday;
  @override
  AllergenStatus get status;
  @override
  Map<String, ReactionDetail> get reactionDetails;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenDetailStateImplCopyWith<_$AllergenDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
