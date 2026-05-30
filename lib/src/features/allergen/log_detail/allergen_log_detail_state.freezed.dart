// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_log_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenLogDetailState {
  Allergen get allergen => throw _privateConstructorUsedError;
  AllergenLog get log => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  int get logNumber => throw _privateConstructorUsedError;

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenLogDetailStateCopyWith<AllergenLogDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenLogDetailStateCopyWith<$Res> {
  factory $AllergenLogDetailStateCopyWith(
    AllergenLogDetailState value,
    $Res Function(AllergenLogDetailState) then,
  ) = _$AllergenLogDetailStateCopyWithImpl<$Res, AllergenLogDetailState>;
  @useResult
  $Res call({Allergen allergen, AllergenLog log, String babyId, int logNumber});

  $AllergenCopyWith<$Res> get allergen;
  $AllergenLogCopyWith<$Res> get log;
}

/// @nodoc
class _$AllergenLogDetailStateCopyWithImpl<
  $Res,
  $Val extends AllergenLogDetailState
>
    implements $AllergenLogDetailStateCopyWith<$Res> {
  _$AllergenLogDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergen = null,
    Object? log = null,
    Object? babyId = null,
    Object? logNumber = null,
  }) {
    return _then(
      _value.copyWith(
            allergen: null == allergen
                ? _value.allergen
                : allergen // ignore: cast_nullable_to_non_nullable
                      as Allergen,
            log: null == log
                ? _value.log
                : log // ignore: cast_nullable_to_non_nullable
                      as AllergenLog,
            babyId: null == babyId
                ? _value.babyId
                : babyId // ignore: cast_nullable_to_non_nullable
                      as String,
            logNumber: null == logNumber
                ? _value.logNumber
                : logNumber // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenCopyWith<$Res> get allergen {
    return $AllergenCopyWith<$Res>(_value.allergen, (value) {
      return _then(_value.copyWith(allergen: value) as $Val);
    });
  }

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenLogCopyWith<$Res> get log {
    return $AllergenLogCopyWith<$Res>(_value.log, (value) {
      return _then(_value.copyWith(log: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AllergenLogDetailStateImplCopyWith<$Res>
    implements $AllergenLogDetailStateCopyWith<$Res> {
  factory _$$AllergenLogDetailStateImplCopyWith(
    _$AllergenLogDetailStateImpl value,
    $Res Function(_$AllergenLogDetailStateImpl) then,
  ) = __$$AllergenLogDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Allergen allergen, AllergenLog log, String babyId, int logNumber});

  @override
  $AllergenCopyWith<$Res> get allergen;
  @override
  $AllergenLogCopyWith<$Res> get log;
}

/// @nodoc
class __$$AllergenLogDetailStateImplCopyWithImpl<$Res>
    extends
        _$AllergenLogDetailStateCopyWithImpl<$Res, _$AllergenLogDetailStateImpl>
    implements _$$AllergenLogDetailStateImplCopyWith<$Res> {
  __$$AllergenLogDetailStateImplCopyWithImpl(
    _$AllergenLogDetailStateImpl _value,
    $Res Function(_$AllergenLogDetailStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergen = null,
    Object? log = null,
    Object? babyId = null,
    Object? logNumber = null,
  }) {
    return _then(
      _$AllergenLogDetailStateImpl(
        allergen: null == allergen
            ? _value.allergen
            : allergen // ignore: cast_nullable_to_non_nullable
                  as Allergen,
        log: null == log
            ? _value.log
            : log // ignore: cast_nullable_to_non_nullable
                  as AllergenLog,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        logNumber: null == logNumber
            ? _value.logNumber
            : logNumber // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AllergenLogDetailStateImpl implements _AllergenLogDetailState {
  const _$AllergenLogDetailStateImpl({
    required this.allergen,
    required this.log,
    required this.babyId,
    required this.logNumber,
  });

  @override
  final Allergen allergen;
  @override
  final AllergenLog log;
  @override
  final String babyId;
  @override
  final int logNumber;

  @override
  String toString() {
    return 'AllergenLogDetailState(allergen: $allergen, log: $log, babyId: $babyId, logNumber: $logNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenLogDetailStateImpl &&
            (identical(other.allergen, allergen) ||
                other.allergen == allergen) &&
            (identical(other.log, log) || other.log == log) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.logNumber, logNumber) ||
                other.logNumber == logNumber));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, allergen, log, babyId, logNumber);

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenLogDetailStateImplCopyWith<_$AllergenLogDetailStateImpl>
  get copyWith =>
      __$$AllergenLogDetailStateImplCopyWithImpl<_$AllergenLogDetailStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenLogDetailState implements AllergenLogDetailState {
  const factory _AllergenLogDetailState({
    required final Allergen allergen,
    required final AllergenLog log,
    required final String babyId,
    required final int logNumber,
  }) = _$AllergenLogDetailStateImpl;

  @override
  Allergen get allergen;
  @override
  AllergenLog get log;
  @override
  String get babyId;
  @override
  int get logNumber;

  /// Create a copy of AllergenLogDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenLogDetailStateImplCopyWith<_$AllergenLogDetailStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
