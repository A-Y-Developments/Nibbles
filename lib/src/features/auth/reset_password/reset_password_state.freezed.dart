// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reset_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ResetPasswordState {
  PasswordInput get password => throw _privateConstructorUsedError;
  String get confirmPassword => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;

  /// Create a copy of ResetPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResetPasswordStateCopyWith<ResetPasswordState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetPasswordStateCopyWith<$Res> {
  factory $ResetPasswordStateCopyWith(
    ResetPasswordState value,
    $Res Function(ResetPasswordState) then,
  ) = _$ResetPasswordStateCopyWithImpl<$Res, ResetPasswordState>;
  @useResult
  $Res call({
    PasswordInput password,
    String confirmPassword,
    bool isLoading,
    String? errorMessage,
    bool success,
  });
}

/// @nodoc
class _$ResetPasswordStateCopyWithImpl<$Res, $Val extends ResetPasswordState>
    implements $ResetPasswordStateCopyWith<$Res> {
  _$ResetPasswordStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResetPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? confirmPassword = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? success = null,
  }) {
    return _then(
      _value.copyWith(
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as PasswordInput,
            confirmPassword: null == confirmPassword
                ? _value.confirmPassword
                : confirmPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResetPasswordStateImplCopyWith<$Res>
    implements $ResetPasswordStateCopyWith<$Res> {
  factory _$$ResetPasswordStateImplCopyWith(
    _$ResetPasswordStateImpl value,
    $Res Function(_$ResetPasswordStateImpl) then,
  ) = __$$ResetPasswordStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PasswordInput password,
    String confirmPassword,
    bool isLoading,
    String? errorMessage,
    bool success,
  });
}

/// @nodoc
class __$$ResetPasswordStateImplCopyWithImpl<$Res>
    extends _$ResetPasswordStateCopyWithImpl<$Res, _$ResetPasswordStateImpl>
    implements _$$ResetPasswordStateImplCopyWith<$Res> {
  __$$ResetPasswordStateImplCopyWithImpl(
    _$ResetPasswordStateImpl _value,
    $Res Function(_$ResetPasswordStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResetPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? confirmPassword = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? success = null,
  }) {
    return _then(
      _$ResetPasswordStateImpl(
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as PasswordInput,
        confirmPassword: null == confirmPassword
            ? _value.confirmPassword
            : confirmPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ResetPasswordStateImpl extends _ResetPasswordState {
  const _$ResetPasswordStateImpl({
    this.password = const PasswordInput.pure(),
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  }) : super._();

  @override
  @JsonKey()
  final PasswordInput password;
  @override
  @JsonKey()
  final String confirmPassword;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool success;

  @override
  String toString() {
    return 'ResetPasswordState(password: $password, confirmPassword: $confirmPassword, isLoading: $isLoading, errorMessage: $errorMessage, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordStateImpl &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.success, success) || other.success == success));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    password,
    confirmPassword,
    isLoading,
    errorMessage,
    success,
  );

  /// Create a copy of ResetPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordStateImplCopyWith<_$ResetPasswordStateImpl> get copyWith =>
      __$$ResetPasswordStateImplCopyWithImpl<_$ResetPasswordStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ResetPasswordState extends ResetPasswordState {
  const factory _ResetPasswordState({
    final PasswordInput password,
    final String confirmPassword,
    final bool isLoading,
    final String? errorMessage,
    final bool success,
  }) = _$ResetPasswordStateImpl;
  const _ResetPasswordState._() : super._();

  @override
  PasswordInput get password;
  @override
  String get confirmPassword;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  bool get success;

  /// Create a copy of ResetPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordStateImplCopyWith<_$ResetPasswordStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
