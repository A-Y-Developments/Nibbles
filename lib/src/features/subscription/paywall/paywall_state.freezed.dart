// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paywall_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaywallState {
  PaywallPhase get phase => throw _privateConstructorUsedError;
  PaywallAction get action => throw _privateConstructorUsedError;
  SubscriptionOffering? get offering => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of PaywallState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaywallStateCopyWith<PaywallState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaywallStateCopyWith<$Res> {
  factory $PaywallStateCopyWith(
    PaywallState value,
    $Res Function(PaywallState) then,
  ) = _$PaywallStateCopyWithImpl<$Res, PaywallState>;
  @useResult
  $Res call({
    PaywallPhase phase,
    PaywallAction action,
    SubscriptionOffering? offering,
    String? errorMessage,
  });

  $SubscriptionOfferingCopyWith<$Res>? get offering;
}

/// @nodoc
class _$PaywallStateCopyWithImpl<$Res, $Val extends PaywallState>
    implements $PaywallStateCopyWith<$Res> {
  _$PaywallStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaywallState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? action = null,
    Object? offering = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as PaywallPhase,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as PaywallAction,
            offering: freezed == offering
                ? _value.offering
                : offering // ignore: cast_nullable_to_non_nullable
                      as SubscriptionOffering?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of PaywallState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionOfferingCopyWith<$Res>? get offering {
    if (_value.offering == null) {
      return null;
    }

    return $SubscriptionOfferingCopyWith<$Res>(_value.offering!, (value) {
      return _then(_value.copyWith(offering: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PaywallStateImplCopyWith<$Res>
    implements $PaywallStateCopyWith<$Res> {
  factory _$$PaywallStateImplCopyWith(
    _$PaywallStateImpl value,
    $Res Function(_$PaywallStateImpl) then,
  ) = __$$PaywallStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PaywallPhase phase,
    PaywallAction action,
    SubscriptionOffering? offering,
    String? errorMessage,
  });

  @override
  $SubscriptionOfferingCopyWith<$Res>? get offering;
}

/// @nodoc
class __$$PaywallStateImplCopyWithImpl<$Res>
    extends _$PaywallStateCopyWithImpl<$Res, _$PaywallStateImpl>
    implements _$$PaywallStateImplCopyWith<$Res> {
  __$$PaywallStateImplCopyWithImpl(
    _$PaywallStateImpl _value,
    $Res Function(_$PaywallStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaywallState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? action = null,
    Object? offering = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$PaywallStateImpl(
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as PaywallPhase,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as PaywallAction,
        offering: freezed == offering
            ? _value.offering
            : offering // ignore: cast_nullable_to_non_nullable
                  as SubscriptionOffering?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PaywallStateImpl implements _PaywallState {
  const _$PaywallStateImpl({
    required this.phase,
    required this.action,
    this.offering,
    this.errorMessage,
  });

  @override
  final PaywallPhase phase;
  @override
  final PaywallAction action;
  @override
  final SubscriptionOffering? offering;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PaywallState(phase: $phase, action: $action, offering: $offering, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaywallStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.offering, offering) ||
                other.offering == offering) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, phase, action, offering, errorMessage);

  /// Create a copy of PaywallState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaywallStateImplCopyWith<_$PaywallStateImpl> get copyWith =>
      __$$PaywallStateImplCopyWithImpl<_$PaywallStateImpl>(this, _$identity);
}

abstract class _PaywallState implements PaywallState {
  const factory _PaywallState({
    required final PaywallPhase phase,
    required final PaywallAction action,
    final SubscriptionOffering? offering,
    final String? errorMessage,
  }) = _$PaywallStateImpl;

  @override
  PaywallPhase get phase;
  @override
  PaywallAction get action;
  @override
  SubscriptionOffering? get offering;
  @override
  String? get errorMessage;

  /// Create a copy of PaywallState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaywallStateImplCopyWith<_$PaywallStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
