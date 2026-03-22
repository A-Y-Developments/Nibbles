// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ForgotPasswordState {
  EmailInput get email => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get sent => throw _privateConstructorUsedError;

  /// Create a copy of ForgotPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgotPasswordStateCopyWith<ForgotPasswordState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgotPasswordStateCopyWith<$Res> {
  factory $ForgotPasswordStateCopyWith(
    ForgotPasswordState value,
    $Res Function(ForgotPasswordState) then,
  ) = _$ForgotPasswordStateCopyWithImpl<$Res, ForgotPasswordState>;
  @useResult
  $Res call({
    EmailInput email,
    bool isLoading,
    String? errorMessage,
    bool sent,
  });
}

/// @nodoc
class _$ForgotPasswordStateCopyWithImpl<$Res, $Val extends ForgotPasswordState>
    implements $ForgotPasswordStateCopyWith<$Res> {
  _$ForgotPasswordStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgotPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? sent = null,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as EmailInput,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            sent: null == sent
                ? _value.sent
                : sent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ForgotPasswordStateImplCopyWith<$Res>
    implements $ForgotPasswordStateCopyWith<$Res> {
  factory _$$ForgotPasswordStateImplCopyWith(
    _$ForgotPasswordStateImpl value,
    $Res Function(_$ForgotPasswordStateImpl) then,
  ) = __$$ForgotPasswordStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    EmailInput email,
    bool isLoading,
    String? errorMessage,
    bool sent,
  });
}

/// @nodoc
class __$$ForgotPasswordStateImplCopyWithImpl<$Res>
    extends _$ForgotPasswordStateCopyWithImpl<$Res, _$ForgotPasswordStateImpl>
    implements _$$ForgotPasswordStateImplCopyWith<$Res> {
  __$$ForgotPasswordStateImplCopyWithImpl(
    _$ForgotPasswordStateImpl _value,
    $Res Function(_$ForgotPasswordStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ForgotPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? sent = null,
  }) {
    return _then(
      _$ForgotPasswordStateImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as EmailInput,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        sent: null == sent
            ? _value.sent
            : sent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ForgotPasswordStateImpl implements _ForgotPasswordState {
  const _$ForgotPasswordStateImpl({
    this.email = const EmailInput.pure(),
    this.isLoading = false,
    this.errorMessage,
    this.sent = false,
  });

  @override
  @JsonKey()
  final EmailInput email;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool sent;

  @override
  String toString() {
    return 'ForgotPasswordState(email: $email, isLoading: $isLoading, errorMessage: $errorMessage, sent: $sent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgotPasswordStateImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.sent, sent) || other.sent == sent));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, email, isLoading, errorMessage, sent);

  /// Create a copy of ForgotPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgotPasswordStateImplCopyWith<_$ForgotPasswordStateImpl> get copyWith =>
      __$$ForgotPasswordStateImplCopyWithImpl<_$ForgotPasswordStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ForgotPasswordState implements ForgotPasswordState {
  const factory _ForgotPasswordState({
    final EmailInput email,
    final bool isLoading,
    final String? errorMessage,
    final bool sent,
  }) = _$ForgotPasswordStateImpl;

  @override
  EmailInput get email;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  bool get sent;

  /// Create a copy of ForgotPasswordState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgotPasswordStateImplCopyWith<_$ForgotPasswordStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
