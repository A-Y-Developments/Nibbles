// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manage_subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ManageSubscriptionState {
  SubscriptionInfo get info => throw _privateConstructorUsedError;

  /// Create a copy of ManageSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManageSubscriptionStateCopyWith<ManageSubscriptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManageSubscriptionStateCopyWith<$Res> {
  factory $ManageSubscriptionStateCopyWith(
    ManageSubscriptionState value,
    $Res Function(ManageSubscriptionState) then,
  ) = _$ManageSubscriptionStateCopyWithImpl<$Res, ManageSubscriptionState>;
  @useResult
  $Res call({SubscriptionInfo info});

  $SubscriptionInfoCopyWith<$Res> get info;
}

/// @nodoc
class _$ManageSubscriptionStateCopyWithImpl<
  $Res,
  $Val extends ManageSubscriptionState
>
    implements $ManageSubscriptionStateCopyWith<$Res> {
  _$ManageSubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ManageSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? info = null}) {
    return _then(
      _value.copyWith(
            info: null == info
                ? _value.info
                : info // ignore: cast_nullable_to_non_nullable
                      as SubscriptionInfo,
          )
          as $Val,
    );
  }

  /// Create a copy of ManageSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionInfoCopyWith<$Res> get info {
    return $SubscriptionInfoCopyWith<$Res>(_value.info, (value) {
      return _then(_value.copyWith(info: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ManageSubscriptionStateImplCopyWith<$Res>
    implements $ManageSubscriptionStateCopyWith<$Res> {
  factory _$$ManageSubscriptionStateImplCopyWith(
    _$ManageSubscriptionStateImpl value,
    $Res Function(_$ManageSubscriptionStateImpl) then,
  ) = __$$ManageSubscriptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SubscriptionInfo info});

  @override
  $SubscriptionInfoCopyWith<$Res> get info;
}

/// @nodoc
class __$$ManageSubscriptionStateImplCopyWithImpl<$Res>
    extends
        _$ManageSubscriptionStateCopyWithImpl<
          $Res,
          _$ManageSubscriptionStateImpl
        >
    implements _$$ManageSubscriptionStateImplCopyWith<$Res> {
  __$$ManageSubscriptionStateImplCopyWithImpl(
    _$ManageSubscriptionStateImpl _value,
    $Res Function(_$ManageSubscriptionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManageSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? info = null}) {
    return _then(
      _$ManageSubscriptionStateImpl(
        info: null == info
            ? _value.info
            : info // ignore: cast_nullable_to_non_nullable
                  as SubscriptionInfo,
      ),
    );
  }
}

/// @nodoc

class _$ManageSubscriptionStateImpl implements _ManageSubscriptionState {
  const _$ManageSubscriptionStateImpl({required this.info});

  @override
  final SubscriptionInfo info;

  @override
  String toString() {
    return 'ManageSubscriptionState(info: $info)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManageSubscriptionStateImpl &&
            (identical(other.info, info) || other.info == info));
  }

  @override
  int get hashCode => Object.hash(runtimeType, info);

  /// Create a copy of ManageSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManageSubscriptionStateImplCopyWith<_$ManageSubscriptionStateImpl>
  get copyWith =>
      __$$ManageSubscriptionStateImplCopyWithImpl<
        _$ManageSubscriptionStateImpl
      >(this, _$identity);
}

abstract class _ManageSubscriptionState implements ManageSubscriptionState {
  const factory _ManageSubscriptionState({
    required final SubscriptionInfo info,
  }) = _$ManageSubscriptionStateImpl;

  @override
  SubscriptionInfo get info;

  /// Create a copy of ManageSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManageSubscriptionStateImplCopyWith<_$ManageSubscriptionStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
