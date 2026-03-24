// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_edit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileEditState {
  String get name => throw _privateConstructorUsedError;
  DateTime get dob => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ProfileEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileEditStateCopyWith<ProfileEditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileEditStateCopyWith<$Res> {
  factory $ProfileEditStateCopyWith(
    ProfileEditState value,
    $Res Function(ProfileEditState) then,
  ) = _$ProfileEditStateCopyWithImpl<$Res, ProfileEditState>;
  @useResult
  $Res call({
    String name,
    DateTime dob,
    Gender gender,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$ProfileEditStateCopyWithImpl<$Res, $Val extends ProfileEditState>
    implements $ProfileEditStateCopyWith<$Res> {
  _$ProfileEditStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dob = null,
    Object? gender = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dob: null == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender,
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
abstract class _$$ProfileEditStateImplCopyWith<$Res>
    implements $ProfileEditStateCopyWith<$Res> {
  factory _$$ProfileEditStateImplCopyWith(
    _$ProfileEditStateImpl value,
    $Res Function(_$ProfileEditStateImpl) then,
  ) = __$$ProfileEditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    DateTime dob,
    Gender gender,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ProfileEditStateImplCopyWithImpl<$Res>
    extends _$ProfileEditStateCopyWithImpl<$Res, _$ProfileEditStateImpl>
    implements _$$ProfileEditStateImplCopyWith<$Res> {
  __$$ProfileEditStateImplCopyWithImpl(
    _$ProfileEditStateImpl _value,
    $Res Function(_$ProfileEditStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dob = null,
    Object? gender = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ProfileEditStateImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dob: null == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender,
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

class _$ProfileEditStateImpl implements _ProfileEditState {
  const _$ProfileEditStateImpl({
    required this.name,
    required this.dob,
    required this.gender,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  final String name;
  @override
  final DateTime dob;
  @override
  final Gender gender;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ProfileEditState(name: $name, dob: $dob, gender: $gender, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileEditStateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, dob, gender, isLoading, errorMessage);

  /// Create a copy of ProfileEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileEditStateImplCopyWith<_$ProfileEditStateImpl> get copyWith =>
      __$$ProfileEditStateImplCopyWithImpl<_$ProfileEditStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileEditState implements ProfileEditState {
  const factory _ProfileEditState({
    required final String name,
    required final DateTime dob,
    required final Gender gender,
    final bool isLoading,
    final String? errorMessage,
  }) = _$ProfileEditStateImpl;

  @override
  String get name;
  @override
  DateTime get dob;
  @override
  Gender get gender;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of ProfileEditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileEditStateImplCopyWith<_$ProfileEditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
