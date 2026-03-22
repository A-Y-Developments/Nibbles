// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baby_setup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BabySetupState {
  int get step => throw _privateConstructorUsedError;
  BabyNameInput get babyName => throw _privateConstructorUsedError;
  DateTime? get dob => throw _privateConstructorUsedError;
  Gender? get gender => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of BabySetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BabySetupStateCopyWith<BabySetupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BabySetupStateCopyWith<$Res> {
  factory $BabySetupStateCopyWith(
    BabySetupState value,
    $Res Function(BabySetupState) then,
  ) = _$BabySetupStateCopyWithImpl<$Res, BabySetupState>;
  @useResult
  $Res call({
    int step,
    BabyNameInput babyName,
    DateTime? dob,
    Gender? gender,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$BabySetupStateCopyWithImpl<$Res, $Val extends BabySetupState>
    implements $BabySetupStateCopyWith<$Res> {
  _$BabySetupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BabySetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? babyName = null,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            step: null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                      as int,
            babyName: null == babyName
                ? _value.babyName
                : babyName // ignore: cast_nullable_to_non_nullable
                      as BabyNameInput,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BabySetupStateImplCopyWith<$Res>
    implements $BabySetupStateCopyWith<$Res> {
  factory _$$BabySetupStateImplCopyWith(
    _$BabySetupStateImpl value,
    $Res Function(_$BabySetupStateImpl) then,
  ) = __$$BabySetupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int step,
    BabyNameInput babyName,
    DateTime? dob,
    Gender? gender,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$BabySetupStateImplCopyWithImpl<$Res>
    extends _$BabySetupStateCopyWithImpl<$Res, _$BabySetupStateImpl>
    implements _$$BabySetupStateImplCopyWith<$Res> {
  __$$BabySetupStateImplCopyWithImpl(
    _$BabySetupStateImpl _value,
    $Res Function(_$BabySetupStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BabySetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? babyName = null,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$BabySetupStateImpl(
        step: null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as int,
        babyName: null == babyName
            ? _value.babyName
            : babyName // ignore: cast_nullable_to_non_nullable
                  as BabyNameInput,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$BabySetupStateImpl implements _BabySetupState {
  const _$BabySetupStateImpl({
    this.step = 0,
    this.babyName = const BabyNameInput.pure(),
    this.dob,
    this.gender,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final int step;
  @override
  @JsonKey()
  final BabyNameInput babyName;
  @override
  final DateTime? dob;
  @override
  final Gender? gender;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'BabySetupState(step: $step, babyName: $babyName, dob: $dob, gender: $gender, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BabySetupStateImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.babyName, babyName) ||
                other.babyName == babyName) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    step,
    babyName,
    dob,
    gender,
    isLoading,
    errorMessage,
  );

  /// Create a copy of BabySetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BabySetupStateImplCopyWith<_$BabySetupStateImpl> get copyWith =>
      __$$BabySetupStateImplCopyWithImpl<_$BabySetupStateImpl>(
        this,
        _$identity,
      );
}

abstract class _BabySetupState implements BabySetupState {
  const factory _BabySetupState({
    final int step,
    final BabyNameInput babyName,
    final DateTime? dob,
    final Gender? gender,
    final bool isLoading,
    final String? errorMessage,
  }) = _$BabySetupStateImpl;

  @override
  int get step;
  @override
  BabyNameInput get babyName;
  @override
  DateTime? get dob;
  @override
  Gender? get gender;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of BabySetupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BabySetupStateImplCopyWith<_$BabySetupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
