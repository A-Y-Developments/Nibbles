// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'readiness_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReadinessState {
  List<bool?> get answers => throw _privateConstructorUsedError;
  bool get showWarning => throw _privateConstructorUsedError;

  /// Create a copy of ReadinessState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReadinessStateCopyWith<ReadinessState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadinessStateCopyWith<$Res> {
  factory $ReadinessStateCopyWith(
    ReadinessState value,
    $Res Function(ReadinessState) then,
  ) = _$ReadinessStateCopyWithImpl<$Res, ReadinessState>;
  @useResult
  $Res call({List<bool?> answers, bool showWarning});
}

/// @nodoc
class _$ReadinessStateCopyWithImpl<$Res, $Val extends ReadinessState>
    implements $ReadinessStateCopyWith<$Res> {
  _$ReadinessStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReadinessState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? answers = null, Object? showWarning = null}) {
    return _then(
      _value.copyWith(
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as List<bool?>,
            showWarning: null == showWarning
                ? _value.showWarning
                : showWarning // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReadinessStateImplCopyWith<$Res>
    implements $ReadinessStateCopyWith<$Res> {
  factory _$$ReadinessStateImplCopyWith(
    _$ReadinessStateImpl value,
    $Res Function(_$ReadinessStateImpl) then,
  ) = __$$ReadinessStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<bool?> answers, bool showWarning});
}

/// @nodoc
class __$$ReadinessStateImplCopyWithImpl<$Res>
    extends _$ReadinessStateCopyWithImpl<$Res, _$ReadinessStateImpl>
    implements _$$ReadinessStateImplCopyWith<$Res> {
  __$$ReadinessStateImplCopyWithImpl(
    _$ReadinessStateImpl _value,
    $Res Function(_$ReadinessStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReadinessState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? answers = null, Object? showWarning = null}) {
    return _then(
      _$ReadinessStateImpl(
        answers: null == answers
            ? _value._answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as List<bool?>,
        showWarning: null == showWarning
            ? _value.showWarning
            : showWarning // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ReadinessStateImpl implements _ReadinessState {
  const _$ReadinessStateImpl({
    required final List<bool?> answers,
    this.showWarning = false,
  }) : _answers = answers;

  final List<bool?> _answers;
  @override
  List<bool?> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @override
  @JsonKey()
  final bool showWarning;

  @override
  String toString() {
    return 'ReadinessState(answers: $answers, showWarning: $showWarning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadinessStateImpl &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.showWarning, showWarning) ||
                other.showWarning == showWarning));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_answers),
    showWarning,
  );

  /// Create a copy of ReadinessState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadinessStateImplCopyWith<_$ReadinessStateImpl> get copyWith =>
      __$$ReadinessStateImplCopyWithImpl<_$ReadinessStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ReadinessState implements ReadinessState {
  const factory _ReadinessState({
    required final List<bool?> answers,
    final bool showWarning,
  }) = _$ReadinessStateImpl;

  @override
  List<bool?> get answers;
  @override
  bool get showWarning;

  /// Create a copy of ReadinessState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadinessStateImplCopyWith<_$ReadinessStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
