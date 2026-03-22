// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Allergen _$AllergenFromJson(Map<String, dynamic> json) {
  return _Allergen.fromJson(json);
}

/// @nodoc
mixin _$Allergen {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sequenceOrder => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this Allergen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Allergen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenCopyWith<Allergen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenCopyWith<$Res> {
  factory $AllergenCopyWith(Allergen value, $Res Function(Allergen) then) =
      _$AllergenCopyWithImpl<$Res, Allergen>;
  @useResult
  $Res call({String key, String name, int sequenceOrder, String emoji});
}

/// @nodoc
class _$AllergenCopyWithImpl<$Res, $Val extends Allergen>
    implements $AllergenCopyWith<$Res> {
  _$AllergenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Allergen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? sequenceOrder = null,
    Object? emoji = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sequenceOrder: null == sequenceOrder
                ? _value.sequenceOrder
                : sequenceOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllergenImplCopyWith<$Res>
    implements $AllergenCopyWith<$Res> {
  factory _$$AllergenImplCopyWith(
    _$AllergenImpl value,
    $Res Function(_$AllergenImpl) then,
  ) = __$$AllergenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, int sequenceOrder, String emoji});
}

/// @nodoc
class __$$AllergenImplCopyWithImpl<$Res>
    extends _$AllergenCopyWithImpl<$Res, _$AllergenImpl>
    implements _$$AllergenImplCopyWith<$Res> {
  __$$AllergenImplCopyWithImpl(
    _$AllergenImpl _value,
    $Res Function(_$AllergenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Allergen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? sequenceOrder = null,
    Object? emoji = null,
  }) {
    return _then(
      _$AllergenImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sequenceOrder: null == sequenceOrder
            ? _value.sequenceOrder
            : sequenceOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AllergenImpl implements _Allergen {
  const _$AllergenImpl({
    required this.key,
    required this.name,
    required this.sequenceOrder,
    required this.emoji,
  });

  factory _$AllergenImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllergenImplFromJson(json);

  @override
  final String key;
  @override
  final String name;
  @override
  final int sequenceOrder;
  @override
  final String emoji;

  @override
  String toString() {
    return 'Allergen(key: $key, name: $name, sequenceOrder: $sequenceOrder, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sequenceOrder, sequenceOrder) ||
                other.sequenceOrder == sequenceOrder) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, name, sequenceOrder, emoji);

  /// Create a copy of Allergen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenImplCopyWith<_$AllergenImpl> get copyWith =>
      __$$AllergenImplCopyWithImpl<_$AllergenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllergenImplToJson(this);
  }
}

abstract class _Allergen implements Allergen {
  const factory _Allergen({
    required final String key,
    required final String name,
    required final int sequenceOrder,
    required final String emoji,
  }) = _$AllergenImpl;

  factory _Allergen.fromJson(Map<String, dynamic> json) =
      _$AllergenImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  int get sequenceOrder;
  @override
  String get emoji;

  /// Create a copy of Allergen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenImplCopyWith<_$AllergenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
