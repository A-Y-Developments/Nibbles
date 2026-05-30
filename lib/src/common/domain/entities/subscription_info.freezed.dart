// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubscriptionInfo {
  bool get isActive => throw _privateConstructorUsedError;
  String? get planLabel => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get renewsAt => throw _privateConstructorUsedError;
  bool get isTrial => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionInfoCopyWith<$Res> {
  factory $SubscriptionInfoCopyWith(
    SubscriptionInfo value,
    $Res Function(SubscriptionInfo) then,
  ) = _$SubscriptionInfoCopyWithImpl<$Res, SubscriptionInfo>;
  @useResult
  $Res call({
    bool isActive,
    String? planLabel,
    DateTime? startedAt,
    DateTime? renewsAt,
    bool isTrial,
  });
}

/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res, $Val extends SubscriptionInfo>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? planLabel = freezed,
    Object? startedAt = freezed,
    Object? renewsAt = freezed,
    Object? isTrial = null,
  }) {
    return _then(
      _value.copyWith(
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            planLabel: freezed == planLabel
                ? _value.planLabel
                : planLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            renewsAt: freezed == renewsAt
                ? _value.renewsAt
                : renewsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isTrial: null == isTrial
                ? _value.isTrial
                : isTrial // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionInfoImplCopyWith<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  factory _$$SubscriptionInfoImplCopyWith(
    _$SubscriptionInfoImpl value,
    $Res Function(_$SubscriptionInfoImpl) then,
  ) = __$$SubscriptionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isActive,
    String? planLabel,
    DateTime? startedAt,
    DateTime? renewsAt,
    bool isTrial,
  });
}

/// @nodoc
class __$$SubscriptionInfoImplCopyWithImpl<$Res>
    extends _$SubscriptionInfoCopyWithImpl<$Res, _$SubscriptionInfoImpl>
    implements _$$SubscriptionInfoImplCopyWith<$Res> {
  __$$SubscriptionInfoImplCopyWithImpl(
    _$SubscriptionInfoImpl _value,
    $Res Function(_$SubscriptionInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? planLabel = freezed,
    Object? startedAt = freezed,
    Object? renewsAt = freezed,
    Object? isTrial = null,
  }) {
    return _then(
      _$SubscriptionInfoImpl(
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        planLabel: freezed == planLabel
            ? _value.planLabel
            : planLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        renewsAt: freezed == renewsAt
            ? _value.renewsAt
            : renewsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isTrial: null == isTrial
            ? _value.isTrial
            : isTrial // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$SubscriptionInfoImpl implements _SubscriptionInfo {
  const _$SubscriptionInfoImpl({
    required this.isActive,
    this.planLabel,
    this.startedAt,
    this.renewsAt,
    this.isTrial = false,
  });

  @override
  final bool isActive;
  @override
  final String? planLabel;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? renewsAt;
  @override
  @JsonKey()
  final bool isTrial;

  @override
  String toString() {
    return 'SubscriptionInfo(isActive: $isActive, planLabel: $planLabel, startedAt: $startedAt, renewsAt: $renewsAt, isTrial: $isTrial)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionInfoImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.planLabel, planLabel) ||
                other.planLabel == planLabel) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.renewsAt, renewsAt) ||
                other.renewsAt == renewsAt) &&
            (identical(other.isTrial, isTrial) || other.isTrial == isTrial));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isActive,
    planLabel,
    startedAt,
    renewsAt,
    isTrial,
  );

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionInfoImplCopyWith<_$SubscriptionInfoImpl> get copyWith =>
      __$$SubscriptionInfoImplCopyWithImpl<_$SubscriptionInfoImpl>(
        this,
        _$identity,
      );
}

abstract class _SubscriptionInfo implements SubscriptionInfo {
  const factory _SubscriptionInfo({
    required final bool isActive,
    final String? planLabel,
    final DateTime? startedAt,
    final DateTime? renewsAt,
    final bool isTrial,
  }) = _$SubscriptionInfoImpl;

  @override
  bool get isActive;
  @override
  String? get planLabel;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get renewsAt;
  @override
  bool get isTrial;

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionInfoImplCopyWith<_$SubscriptionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
