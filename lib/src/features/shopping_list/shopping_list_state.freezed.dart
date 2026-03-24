// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ShoppingListState {
  List<ShoppingListItem> get items => throw _privateConstructorUsedError;

  /// Create a copy of ShoppingListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShoppingListStateCopyWith<ShoppingListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoppingListStateCopyWith<$Res> {
  factory $ShoppingListStateCopyWith(
    ShoppingListState value,
    $Res Function(ShoppingListState) then,
  ) = _$ShoppingListStateCopyWithImpl<$Res, ShoppingListState>;
  @useResult
  $Res call({List<ShoppingListItem> items});
}

/// @nodoc
class _$ShoppingListStateCopyWithImpl<$Res, $Val extends ShoppingListState>
    implements $ShoppingListStateCopyWith<$Res> {
  _$ShoppingListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShoppingListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ShoppingListItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShoppingListStateImplCopyWith<$Res>
    implements $ShoppingListStateCopyWith<$Res> {
  factory _$$ShoppingListStateImplCopyWith(
    _$ShoppingListStateImpl value,
    $Res Function(_$ShoppingListStateImpl) then,
  ) = __$$ShoppingListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ShoppingListItem> items});
}

/// @nodoc
class __$$ShoppingListStateImplCopyWithImpl<$Res>
    extends _$ShoppingListStateCopyWithImpl<$Res, _$ShoppingListStateImpl>
    implements _$$ShoppingListStateImplCopyWith<$Res> {
  __$$ShoppingListStateImplCopyWithImpl(
    _$ShoppingListStateImpl _value,
    $Res Function(_$ShoppingListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShoppingListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _$ShoppingListStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ShoppingListItem>,
      ),
    );
  }
}

/// @nodoc

class _$ShoppingListStateImpl extends _ShoppingListState {
  const _$ShoppingListStateImpl({required final List<ShoppingListItem> items})
    : _items = items,
      super._();

  final List<ShoppingListItem> _items;
  @override
  List<ShoppingListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ShoppingListState(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoppingListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of ShoppingListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoppingListStateImplCopyWith<_$ShoppingListStateImpl> get copyWith =>
      __$$ShoppingListStateImplCopyWithImpl<_$ShoppingListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ShoppingListState extends ShoppingListState {
  const factory _ShoppingListState({
    required final List<ShoppingListItem> items,
  }) = _$ShoppingListStateImpl;
  const _ShoppingListState._() : super._();

  @override
  List<ShoppingListItem> get items;

  /// Create a copy of ShoppingListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShoppingListStateImplCopyWith<_$ShoppingListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
