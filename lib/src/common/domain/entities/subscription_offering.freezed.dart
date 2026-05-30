// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_offering.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubscriptionOffering {
  String get productId => throw _privateConstructorUsedError;
  String get priceString => throw _privateConstructorUsedError;
  String get periodLabel => throw _privateConstructorUsedError;
  int get trialDays => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionOffering
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionOfferingCopyWith<SubscriptionOffering> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionOfferingCopyWith<$Res> {
  factory $SubscriptionOfferingCopyWith(
    SubscriptionOffering value,
    $Res Function(SubscriptionOffering) then,
  ) = _$SubscriptionOfferingCopyWithImpl<$Res, SubscriptionOffering>;
  @useResult
  $Res call({
    String productId,
    String priceString,
    String periodLabel,
    int trialDays,
  });
}

/// @nodoc
class _$SubscriptionOfferingCopyWithImpl<
  $Res,
  $Val extends SubscriptionOffering
>
    implements $SubscriptionOfferingCopyWith<$Res> {
  _$SubscriptionOfferingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionOffering
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? priceString = null,
    Object? periodLabel = null,
    Object? trialDays = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            priceString: null == priceString
                ? _value.priceString
                : priceString // ignore: cast_nullable_to_non_nullable
                      as String,
            periodLabel: null == periodLabel
                ? _value.periodLabel
                : periodLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            trialDays: null == trialDays
                ? _value.trialDays
                : trialDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionOfferingImplCopyWith<$Res>
    implements $SubscriptionOfferingCopyWith<$Res> {
  factory _$$SubscriptionOfferingImplCopyWith(
    _$SubscriptionOfferingImpl value,
    $Res Function(_$SubscriptionOfferingImpl) then,
  ) = __$$SubscriptionOfferingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String priceString,
    String periodLabel,
    int trialDays,
  });
}

/// @nodoc
class __$$SubscriptionOfferingImplCopyWithImpl<$Res>
    extends _$SubscriptionOfferingCopyWithImpl<$Res, _$SubscriptionOfferingImpl>
    implements _$$SubscriptionOfferingImplCopyWith<$Res> {
  __$$SubscriptionOfferingImplCopyWithImpl(
    _$SubscriptionOfferingImpl _value,
    $Res Function(_$SubscriptionOfferingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionOffering
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? priceString = null,
    Object? periodLabel = null,
    Object? trialDays = null,
  }) {
    return _then(
      _$SubscriptionOfferingImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        priceString: null == priceString
            ? _value.priceString
            : priceString // ignore: cast_nullable_to_non_nullable
                  as String,
        periodLabel: null == periodLabel
            ? _value.periodLabel
            : periodLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        trialDays: null == trialDays
            ? _value.trialDays
            : trialDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SubscriptionOfferingImpl implements _SubscriptionOffering {
  const _$SubscriptionOfferingImpl({
    required this.productId,
    required this.priceString,
    required this.periodLabel,
    required this.trialDays,
  });

  @override
  final String productId;
  @override
  final String priceString;
  @override
  final String periodLabel;
  @override
  final int trialDays;

  @override
  String toString() {
    return 'SubscriptionOffering(productId: $productId, priceString: $priceString, periodLabel: $periodLabel, trialDays: $trialDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionOfferingImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.priceString, priceString) ||
                other.priceString == priceString) &&
            (identical(other.periodLabel, periodLabel) ||
                other.periodLabel == periodLabel) &&
            (identical(other.trialDays, trialDays) ||
                other.trialDays == trialDays));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, priceString, periodLabel, trialDays);

  /// Create a copy of SubscriptionOffering
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionOfferingImplCopyWith<_$SubscriptionOfferingImpl>
  get copyWith =>
      __$$SubscriptionOfferingImplCopyWithImpl<_$SubscriptionOfferingImpl>(
        this,
        _$identity,
      );
}

abstract class _SubscriptionOffering implements SubscriptionOffering {
  const factory _SubscriptionOffering({
    required final String productId,
    required final String priceString,
    required final String periodLabel,
    required final int trialDays,
  }) = _$SubscriptionOfferingImpl;

  @override
  String get productId;
  @override
  String get priceString;
  @override
  String get periodLabel;
  @override
  int get trialDays;

  /// Create a copy of SubscriptionOffering
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionOfferingImplCopyWith<_$SubscriptionOfferingImpl>
  get copyWith => throw _privateConstructorUsedError;
}
