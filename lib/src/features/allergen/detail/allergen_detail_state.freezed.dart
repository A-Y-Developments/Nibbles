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
  AllergenStatus get status => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get babyName =>
      throw _privateConstructorUsedError; // First introduced = min(logDate), Last given = max(logDate).
  // Null when there are 0 logs.
  DateTime? get firstIntroduced => throw _privateConstructorUsedError;
  DateTime? get lastGiven => throw _privateConstructorUsedError;

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
    AllergenStatus status,
    String babyId,
    String babyName,
    DateTime? firstIntroduced,
    DateTime? lastGiven,
  });

  $AllergenCopyWith<$Res> get allergen;
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
    Object? status = null,
    Object? babyId = null,
    Object? babyName = null,
    Object? firstIntroduced = freezed,
    Object? lastGiven = freezed,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AllergenStatus,
            babyId: null == babyId
                ? _value.babyId
                : babyId // ignore: cast_nullable_to_non_nullable
                      as String,
            babyName: null == babyName
                ? _value.babyName
                : babyName // ignore: cast_nullable_to_non_nullable
                      as String,
            firstIntroduced: freezed == firstIntroduced
                ? _value.firstIntroduced
                : firstIntroduced // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastGiven: freezed == lastGiven
                ? _value.lastGiven
                : lastGiven // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
    AllergenStatus status,
    String babyId,
    String babyName,
    DateTime? firstIntroduced,
    DateTime? lastGiven,
  });

  @override
  $AllergenCopyWith<$Res> get allergen;
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
    Object? status = null,
    Object? babyId = null,
    Object? babyName = null,
    Object? firstIntroduced = freezed,
    Object? lastGiven = freezed,
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AllergenStatus,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        babyName: null == babyName
            ? _value.babyName
            : babyName // ignore: cast_nullable_to_non_nullable
                  as String,
        firstIntroduced: freezed == firstIntroduced
            ? _value.firstIntroduced
            : firstIntroduced // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastGiven: freezed == lastGiven
            ? _value.lastGiven
            : lastGiven // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$AllergenDetailStateImpl implements _AllergenDetailState {
  const _$AllergenDetailStateImpl({
    required this.allergen,
    required final List<AllergenLog> logs,
    required this.status,
    required this.babyId,
    required this.babyName,
    this.firstIntroduced,
    this.lastGiven,
  }) : _logs = logs;

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
  final AllergenStatus status;
  @override
  final String babyId;
  @override
  final String babyName;
  // First introduced = min(logDate), Last given = max(logDate).
  // Null when there are 0 logs.
  @override
  final DateTime? firstIntroduced;
  @override
  final DateTime? lastGiven;

  @override
  String toString() {
    return 'AllergenDetailState(allergen: $allergen, logs: $logs, status: $status, babyId: $babyId, babyName: $babyName, firstIntroduced: $firstIntroduced, lastGiven: $lastGiven)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenDetailStateImpl &&
            (identical(other.allergen, allergen) ||
                other.allergen == allergen) &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.babyName, babyName) ||
                other.babyName == babyName) &&
            (identical(other.firstIntroduced, firstIntroduced) ||
                other.firstIntroduced == firstIntroduced) &&
            (identical(other.lastGiven, lastGiven) ||
                other.lastGiven == lastGiven));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    allergen,
    const DeepCollectionEquality().hash(_logs),
    status,
    babyId,
    babyName,
    firstIntroduced,
    lastGiven,
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
    required final AllergenStatus status,
    required final String babyId,
    required final String babyName,
    final DateTime? firstIntroduced,
    final DateTime? lastGiven,
  }) = _$AllergenDetailStateImpl;

  @override
  Allergen get allergen;
  @override
  List<AllergenLog> get logs;
  @override
  AllergenStatus get status;
  @override
  String get babyId;
  @override
  String get babyName; // First introduced = min(logDate), Last given = max(logDate).
  // Null when there are 0 logs.
  @override
  DateTime? get firstIntroduced;
  @override
  DateTime? get lastGiven;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenDetailStateImplCopyWith<_$AllergenDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
