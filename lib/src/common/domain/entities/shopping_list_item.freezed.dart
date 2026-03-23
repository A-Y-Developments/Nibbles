// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ShoppingListItem {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isChecked => throw _privateConstructorUsedError;
  ShoppingListSource get source => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShoppingListItemCopyWith<ShoppingListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoppingListItemCopyWith<$Res> {
  factory $ShoppingListItemCopyWith(
    ShoppingListItem value,
    $Res Function(ShoppingListItem) then,
  ) = _$ShoppingListItemCopyWithImpl<$Res, ShoppingListItem>;
  @useResult
  $Res call({
    String id,
    String babyId,
    String name,
    bool isChecked,
    ShoppingListSource source,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ShoppingListItemCopyWithImpl<$Res, $Val extends ShoppingListItem>
    implements $ShoppingListItemCopyWith<$Res> {
  _$ShoppingListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? name = null,
    Object? isChecked = null,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            babyId: null == babyId
                ? _value.babyId
                : babyId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            isChecked: null == isChecked
                ? _value.isChecked
                : isChecked // ignore: cast_nullable_to_non_nullable
                      as bool,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as ShoppingListSource,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShoppingListItemImplCopyWith<$Res>
    implements $ShoppingListItemCopyWith<$Res> {
  factory _$$ShoppingListItemImplCopyWith(
    _$ShoppingListItemImpl value,
    $Res Function(_$ShoppingListItemImpl) then,
  ) = __$$ShoppingListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String babyId,
    String name,
    bool isChecked,
    ShoppingListSource source,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ShoppingListItemImplCopyWithImpl<$Res>
    extends _$ShoppingListItemCopyWithImpl<$Res, _$ShoppingListItemImpl>
    implements _$$ShoppingListItemImplCopyWith<$Res> {
  __$$ShoppingListItemImplCopyWithImpl(
    _$ShoppingListItemImpl _value,
    $Res Function(_$ShoppingListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? name = null,
    Object? isChecked = null,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ShoppingListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isChecked: null == isChecked
            ? _value.isChecked
            : isChecked // ignore: cast_nullable_to_non_nullable
                  as bool,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ShoppingListSource,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ShoppingListItemImpl implements _ShoppingListItem {
  const _$ShoppingListItemImpl({
    required this.id,
    required this.babyId,
    required this.name,
    required this.isChecked,
    required this.source,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String name;
  @override
  final bool isChecked;
  @override
  final ShoppingListSource source;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ShoppingListItem(id: $id, babyId: $babyId, name: $name, isChecked: $isChecked, source: $source, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoppingListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isChecked, isChecked) ||
                other.isChecked == isChecked) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, babyId, name, isChecked, source, createdAt);

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoppingListItemImplCopyWith<_$ShoppingListItemImpl> get copyWith =>
      __$$ShoppingListItemImplCopyWithImpl<_$ShoppingListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _ShoppingListItem implements ShoppingListItem {
  const factory _ShoppingListItem({
    required final String id,
    required final String babyId,
    required final String name,
    required final bool isChecked,
    required final ShoppingListSource source,
    required final DateTime createdAt,
  }) = _$ShoppingListItemImpl;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get name;
  @override
  bool get isChecked;
  @override
  ShoppingListSource get source;
  @override
  DateTime get createdAt;

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShoppingListItemImplCopyWith<_$ShoppingListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
