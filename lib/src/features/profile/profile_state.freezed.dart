// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileState {
  Baby get baby => throw _privateConstructorUsedError;
  List<AllergenBoardItem> get safeAllergens =>
      throw _privateConstructorUsedError;
  String get subscriptionLabel => throw _privateConstructorUsedError;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
    ProfileState value,
    $Res Function(ProfileState) then,
  ) = _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call({
    Baby baby,
    List<AllergenBoardItem> safeAllergens,
    String subscriptionLabel,
  });

  $BabyCopyWith<$Res> get baby;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baby = null,
    Object? safeAllergens = null,
    Object? subscriptionLabel = null,
  }) {
    return _then(
      _value.copyWith(
            baby: null == baby
                ? _value.baby
                : baby // ignore: cast_nullable_to_non_nullable
                      as Baby,
            safeAllergens: null == safeAllergens
                ? _value.safeAllergens
                : safeAllergens // ignore: cast_nullable_to_non_nullable
                      as List<AllergenBoardItem>,
            subscriptionLabel: null == subscriptionLabel
                ? _value.subscriptionLabel
                : subscriptionLabel // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BabyCopyWith<$Res> get baby {
    return $BabyCopyWith<$Res>(_value.baby, (value) {
      return _then(_value.copyWith(baby: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
    _$ProfileStateImpl value,
    $Res Function(_$ProfileStateImpl) then,
  ) = __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Baby baby,
    List<AllergenBoardItem> safeAllergens,
    String subscriptionLabel,
  });

  @override
  $BabyCopyWith<$Res> get baby;
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
    _$ProfileStateImpl _value,
    $Res Function(_$ProfileStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baby = null,
    Object? safeAllergens = null,
    Object? subscriptionLabel = null,
  }) {
    return _then(
      _$ProfileStateImpl(
        baby: null == baby
            ? _value.baby
            : baby // ignore: cast_nullable_to_non_nullable
                  as Baby,
        safeAllergens: null == safeAllergens
            ? _value._safeAllergens
            : safeAllergens // ignore: cast_nullable_to_non_nullable
                  as List<AllergenBoardItem>,
        subscriptionLabel: null == subscriptionLabel
            ? _value.subscriptionLabel
            : subscriptionLabel // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl({
    required this.baby,
    required final List<AllergenBoardItem> safeAllergens,
    required this.subscriptionLabel,
  }) : _safeAllergens = safeAllergens;

  @override
  final Baby baby;
  final List<AllergenBoardItem> _safeAllergens;
  @override
  List<AllergenBoardItem> get safeAllergens {
    if (_safeAllergens is EqualUnmodifiableListView) return _safeAllergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_safeAllergens);
  }

  @override
  final String subscriptionLabel;

  @override
  String toString() {
    return 'ProfileState(baby: $baby, safeAllergens: $safeAllergens, subscriptionLabel: $subscriptionLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            (identical(other.baby, baby) || other.baby == baby) &&
            const DeepCollectionEquality().equals(
              other._safeAllergens,
              _safeAllergens,
            ) &&
            (identical(other.subscriptionLabel, subscriptionLabel) ||
                other.subscriptionLabel == subscriptionLabel));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baby,
    const DeepCollectionEquality().hash(_safeAllergens),
    subscriptionLabel,
  );

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState({
    required final Baby baby,
    required final List<AllergenBoardItem> safeAllergens,
    required final String subscriptionLabel,
  }) = _$ProfileStateImpl;

  @override
  Baby get baby;
  @override
  List<AllergenBoardItem> get safeAllergens;
  @override
  String get subscriptionLabel;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
