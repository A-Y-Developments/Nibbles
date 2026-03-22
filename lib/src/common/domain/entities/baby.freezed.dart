// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baby.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Baby {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  bool get onboardingCompleted => throw _privateConstructorUsedError;

  /// Create a copy of Baby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BabyCopyWith<Baby> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BabyCopyWith<$Res> {
  factory $BabyCopyWith(Baby value, $Res Function(Baby) then) =
      _$BabyCopyWithImpl<$Res, Baby>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    DateTime dateOfBirth,
    Gender gender,
    bool onboardingCompleted,
  });
}

/// @nodoc
class _$BabyCopyWithImpl<$Res, $Val extends Baby>
    implements $BabyCopyWith<$Res> {
  _$BabyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Baby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? onboardingCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender,
            onboardingCompleted: null == onboardingCompleted
                ? _value.onboardingCompleted
                : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BabyImplCopyWith<$Res> implements $BabyCopyWith<$Res> {
  factory _$$BabyImplCopyWith(
    _$BabyImpl value,
    $Res Function(_$BabyImpl) then,
  ) = __$$BabyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    DateTime dateOfBirth,
    Gender gender,
    bool onboardingCompleted,
  });
}

/// @nodoc
class __$$BabyImplCopyWithImpl<$Res>
    extends _$BabyCopyWithImpl<$Res, _$BabyImpl>
    implements _$$BabyImplCopyWith<$Res> {
  __$$BabyImplCopyWithImpl(_$BabyImpl _value, $Res Function(_$BabyImpl) _then)
    : super(_value, _then);

  /// Create a copy of Baby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? onboardingCompleted = null,
  }) {
    return _then(
      _$BabyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender,
        onboardingCompleted: null == onboardingCompleted
            ? _value.onboardingCompleted
            : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$BabyImpl implements _Baby {
  const _$BabyImpl({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.onboardingCompleted,
  });

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final DateTime dateOfBirth;
  @override
  final Gender gender;
  @override
  final bool onboardingCompleted;

  @override
  String toString() {
    return 'Baby(id: $id, userId: $userId, name: $name, dateOfBirth: $dateOfBirth, gender: $gender, onboardingCompleted: $onboardingCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BabyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    dateOfBirth,
    gender,
    onboardingCompleted,
  );

  /// Create a copy of Baby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BabyImplCopyWith<_$BabyImpl> get copyWith =>
      __$$BabyImplCopyWithImpl<_$BabyImpl>(this, _$identity);
}

abstract class _Baby implements Baby {
  const factory _Baby({
    required final String id,
    required final String userId,
    required final String name,
    required final DateTime dateOfBirth,
    required final Gender gender,
    required final bool onboardingCompleted,
  }) = _$BabyImpl;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  DateTime get dateOfBirth;
  @override
  Gender get gender;
  @override
  bool get onboardingCompleted;

  /// Create a copy of Baby
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BabyImplCopyWith<_$BabyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
