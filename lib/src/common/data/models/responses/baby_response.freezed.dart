// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baby_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BabyResponse _$BabyResponseFromJson(Map<String, dynamic> json) {
  return _BabyResponse.fromJson(json);
}

/// @nodoc
mixin _$BabyResponse {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_of_birth')
  String get dateOfBirth => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'onboarding_completed')
  bool get onboardingCompleted => throw _privateConstructorUsedError;

  /// Serializes this BabyResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BabyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BabyResponseCopyWith<BabyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BabyResponseCopyWith<$Res> {
  factory $BabyResponseCopyWith(
    BabyResponse value,
    $Res Function(BabyResponse) then,
  ) = _$BabyResponseCopyWithImpl<$Res, BabyResponse>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    @JsonKey(name: 'date_of_birth') String dateOfBirth,
    String gender,
    @JsonKey(name: 'onboarding_completed') bool onboardingCompleted,
  });
}

/// @nodoc
class _$BabyResponseCopyWithImpl<$Res, $Val extends BabyResponse>
    implements $BabyResponseCopyWith<$Res> {
  _$BabyResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BabyResponse
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
                      as String,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$BabyResponseImplCopyWith<$Res>
    implements $BabyResponseCopyWith<$Res> {
  factory _$$BabyResponseImplCopyWith(
    _$BabyResponseImpl value,
    $Res Function(_$BabyResponseImpl) then,
  ) = __$$BabyResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    @JsonKey(name: 'date_of_birth') String dateOfBirth,
    String gender,
    @JsonKey(name: 'onboarding_completed') bool onboardingCompleted,
  });
}

/// @nodoc
class __$$BabyResponseImplCopyWithImpl<$Res>
    extends _$BabyResponseCopyWithImpl<$Res, _$BabyResponseImpl>
    implements _$$BabyResponseImplCopyWith<$Res> {
  __$$BabyResponseImplCopyWithImpl(
    _$BabyResponseImpl _value,
    $Res Function(_$BabyResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BabyResponse
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
      _$BabyResponseImpl(
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
                  as String,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        onboardingCompleted: null == onboardingCompleted
            ? _value.onboardingCompleted
            : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BabyResponseImpl implements _BabyResponse {
  const _$BabyResponseImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.name,
    @JsonKey(name: 'date_of_birth') required this.dateOfBirth,
    required this.gender,
    @JsonKey(name: 'onboarding_completed') required this.onboardingCompleted,
  });

  factory _$BabyResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BabyResponseImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth;
  @override
  final String gender;
  @override
  @JsonKey(name: 'onboarding_completed')
  final bool onboardingCompleted;

  @override
  String toString() {
    return 'BabyResponse(id: $id, userId: $userId, name: $name, dateOfBirth: $dateOfBirth, gender: $gender, onboardingCompleted: $onboardingCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BabyResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of BabyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BabyResponseImplCopyWith<_$BabyResponseImpl> get copyWith =>
      __$$BabyResponseImplCopyWithImpl<_$BabyResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BabyResponseImplToJson(this);
  }
}

abstract class _BabyResponse implements BabyResponse {
  const factory _BabyResponse({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String name,
    @JsonKey(name: 'date_of_birth') required final String dateOfBirth,
    required final String gender,
    @JsonKey(name: 'onboarding_completed')
    required final bool onboardingCompleted,
  }) = _$BabyResponseImpl;

  factory _BabyResponse.fromJson(Map<String, dynamic> json) =
      _$BabyResponseImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'date_of_birth')
  String get dateOfBirth;
  @override
  String get gender;
  @override
  @JsonKey(name: 'onboarding_completed')
  bool get onboardingCompleted;

  /// Create a copy of BabyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BabyResponseImplCopyWith<_$BabyResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
