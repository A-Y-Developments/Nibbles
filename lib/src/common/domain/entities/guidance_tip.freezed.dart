// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guidance_tip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GuidanceTip {
  String get id => throw _privateConstructorUsedError;
  String get iconKey => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;

  /// Create a copy of GuidanceTip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GuidanceTipCopyWith<GuidanceTip> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuidanceTipCopyWith<$Res> {
  factory $GuidanceTipCopyWith(
    GuidanceTip value,
    $Res Function(GuidanceTip) then,
  ) = _$GuidanceTipCopyWithImpl<$Res, GuidanceTip>;
  @useResult
  $Res call({String id, String iconKey, String title, String body});
}

/// @nodoc
class _$GuidanceTipCopyWithImpl<$Res, $Val extends GuidanceTip>
    implements $GuidanceTipCopyWith<$Res> {
  _$GuidanceTipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuidanceTip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iconKey = null,
    Object? title = null,
    Object? body = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            iconKey: null == iconKey
                ? _value.iconKey
                : iconKey // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GuidanceTipImplCopyWith<$Res>
    implements $GuidanceTipCopyWith<$Res> {
  factory _$$GuidanceTipImplCopyWith(
    _$GuidanceTipImpl value,
    $Res Function(_$GuidanceTipImpl) then,
  ) = __$$GuidanceTipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String iconKey, String title, String body});
}

/// @nodoc
class __$$GuidanceTipImplCopyWithImpl<$Res>
    extends _$GuidanceTipCopyWithImpl<$Res, _$GuidanceTipImpl>
    implements _$$GuidanceTipImplCopyWith<$Res> {
  __$$GuidanceTipImplCopyWithImpl(
    _$GuidanceTipImpl _value,
    $Res Function(_$GuidanceTipImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuidanceTip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iconKey = null,
    Object? title = null,
    Object? body = null,
  }) {
    return _then(
      _$GuidanceTipImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        iconKey: null == iconKey
            ? _value.iconKey
            : iconKey // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GuidanceTipImpl implements _GuidanceTip {
  const _$GuidanceTipImpl({
    required this.id,
    required this.iconKey,
    required this.title,
    required this.body,
  });

  @override
  final String id;
  @override
  final String iconKey;
  @override
  final String title;
  @override
  final String body;

  @override
  String toString() {
    return 'GuidanceTip(id: $id, iconKey: $iconKey, title: $title, body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuidanceTipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, iconKey, title, body);

  /// Create a copy of GuidanceTip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuidanceTipImplCopyWith<_$GuidanceTipImpl> get copyWith =>
      __$$GuidanceTipImplCopyWithImpl<_$GuidanceTipImpl>(this, _$identity);
}

abstract class _GuidanceTip implements GuidanceTip {
  const factory _GuidanceTip({
    required final String id,
    required final String iconKey,
    required final String title,
    required final String body,
  }) = _$GuidanceTipImpl;

  @override
  String get id;
  @override
  String get iconKey;
  @override
  String get title;
  @override
  String get body;

  /// Create a copy of GuidanceTip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuidanceTipImplCopyWith<_$GuidanceTipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
