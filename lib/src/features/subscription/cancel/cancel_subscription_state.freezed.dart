// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancel_subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CancelSubscriptionState {
  bool get isSubmitting => throw _privateConstructorUsedError;

  /// Create a copy of CancelSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CancelSubscriptionStateCopyWith<CancelSubscriptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancelSubscriptionStateCopyWith<$Res> {
  factory $CancelSubscriptionStateCopyWith(
    CancelSubscriptionState value,
    $Res Function(CancelSubscriptionState) then,
  ) = _$CancelSubscriptionStateCopyWithImpl<$Res, CancelSubscriptionState>;
  @useResult
  $Res call({bool isSubmitting});
}

/// @nodoc
class _$CancelSubscriptionStateCopyWithImpl<
  $Res,
  $Val extends CancelSubscriptionState
>
    implements $CancelSubscriptionStateCopyWith<$Res> {
  _$CancelSubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CancelSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isSubmitting = null}) {
    return _then(
      _value.copyWith(
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CancelSubscriptionStateImplCopyWith<$Res>
    implements $CancelSubscriptionStateCopyWith<$Res> {
  factory _$$CancelSubscriptionStateImplCopyWith(
    _$CancelSubscriptionStateImpl value,
    $Res Function(_$CancelSubscriptionStateImpl) then,
  ) = __$$CancelSubscriptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isSubmitting});
}

/// @nodoc
class __$$CancelSubscriptionStateImplCopyWithImpl<$Res>
    extends
        _$CancelSubscriptionStateCopyWithImpl<
          $Res,
          _$CancelSubscriptionStateImpl
        >
    implements _$$CancelSubscriptionStateImplCopyWith<$Res> {
  __$$CancelSubscriptionStateImplCopyWithImpl(
    _$CancelSubscriptionStateImpl _value,
    $Res Function(_$CancelSubscriptionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CancelSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isSubmitting = null}) {
    return _then(
      _$CancelSubscriptionStateImpl(
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CancelSubscriptionStateImpl implements _CancelSubscriptionState {
  const _$CancelSubscriptionStateImpl({this.isSubmitting = false});

  @override
  @JsonKey()
  final bool isSubmitting;

  @override
  String toString() {
    return 'CancelSubscriptionState(isSubmitting: $isSubmitting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancelSubscriptionStateImpl &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSubmitting);

  /// Create a copy of CancelSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CancelSubscriptionStateImplCopyWith<_$CancelSubscriptionStateImpl>
  get copyWith =>
      __$$CancelSubscriptionStateImplCopyWithImpl<
        _$CancelSubscriptionStateImpl
      >(this, _$identity);
}

abstract class _CancelSubscriptionState implements CancelSubscriptionState {
  const factory _CancelSubscriptionState({final bool isSubmitting}) =
      _$CancelSubscriptionStateImpl;

  @override
  bool get isSubmitting;

  /// Create a copy of CancelSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CancelSubscriptionStateImplCopyWith<_$CancelSubscriptionStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
