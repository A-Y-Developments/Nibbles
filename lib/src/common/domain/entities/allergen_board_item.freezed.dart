// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_board_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenBoardItem {
  Allergen get allergen => throw _privateConstructorUsedError;
  List<AllergenLog> get logs => throw _privateConstructorUsedError;
  AllergenStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of AllergenBoardItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenBoardItemCopyWith<AllergenBoardItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenBoardItemCopyWith<$Res> {
  factory $AllergenBoardItemCopyWith(
    AllergenBoardItem value,
    $Res Function(AllergenBoardItem) then,
  ) = _$AllergenBoardItemCopyWithImpl<$Res, AllergenBoardItem>;
  @useResult
  $Res call({Allergen allergen, List<AllergenLog> logs, AllergenStatus status});

  $AllergenCopyWith<$Res> get allergen;
}

/// @nodoc
class _$AllergenBoardItemCopyWithImpl<$Res, $Val extends AllergenBoardItem>
    implements $AllergenBoardItemCopyWith<$Res> {
  _$AllergenBoardItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenBoardItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergen = null,
    Object? logs = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            allergen: null == allergen
                ? _value.allergen
                : allergen // ignore: cast_nullable_to_non_nullable
                      as Allergen,
            logs: null == logs
                ? _value.logs
                : logs // ignore: cast_nullable_to_non_nullable
                      as List<AllergenLog>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AllergenStatus,
          )
          as $Val,
    );
  }

  /// Create a copy of AllergenBoardItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenCopyWith<$Res> get allergen {
    return $AllergenCopyWith<$Res>(_value.allergen, (value) {
      return _then(_value.copyWith(allergen: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AllergenBoardItemImplCopyWith<$Res>
    implements $AllergenBoardItemCopyWith<$Res> {
  factory _$$AllergenBoardItemImplCopyWith(
    _$AllergenBoardItemImpl value,
    $Res Function(_$AllergenBoardItemImpl) then,
  ) = __$$AllergenBoardItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Allergen allergen, List<AllergenLog> logs, AllergenStatus status});

  @override
  $AllergenCopyWith<$Res> get allergen;
}

/// @nodoc
class __$$AllergenBoardItemImplCopyWithImpl<$Res>
    extends _$AllergenBoardItemCopyWithImpl<$Res, _$AllergenBoardItemImpl>
    implements _$$AllergenBoardItemImplCopyWith<$Res> {
  __$$AllergenBoardItemImplCopyWithImpl(
    _$AllergenBoardItemImpl _value,
    $Res Function(_$AllergenBoardItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenBoardItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergen = null,
    Object? logs = null,
    Object? status = null,
  }) {
    return _then(
      _$AllergenBoardItemImpl(
        allergen: null == allergen
            ? _value.allergen
            : allergen // ignore: cast_nullable_to_non_nullable
                  as Allergen,
        logs: null == logs
            ? _value._logs
            : logs // ignore: cast_nullable_to_non_nullable
                  as List<AllergenLog>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AllergenStatus,
      ),
    );
  }
}

/// @nodoc

class _$AllergenBoardItemImpl implements _AllergenBoardItem {
  const _$AllergenBoardItemImpl({
    required this.allergen,
    required final List<AllergenLog> logs,
    required this.status,
  }) : _logs = logs;

  @override
  final Allergen allergen;
  final List<AllergenLog> _logs;
  @override
  List<AllergenLog> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  @override
  final AllergenStatus status;

  @override
  String toString() {
    return 'AllergenBoardItem(allergen: $allergen, logs: $logs, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenBoardItemImpl &&
            (identical(other.allergen, allergen) ||
                other.allergen == allergen) &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    allergen,
    const DeepCollectionEquality().hash(_logs),
    status,
  );

  /// Create a copy of AllergenBoardItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenBoardItemImplCopyWith<_$AllergenBoardItemImpl> get copyWith =>
      __$$AllergenBoardItemImplCopyWithImpl<_$AllergenBoardItemImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenBoardItem implements AllergenBoardItem {
  const factory _AllergenBoardItem({
    required final Allergen allergen,
    required final List<AllergenLog> logs,
    required final AllergenStatus status,
  }) = _$AllergenBoardItemImpl;

  @override
  Allergen get allergen;
  @override
  List<AllergenLog> get logs;
  @override
  AllergenStatus get status;

  /// Create a copy of AllergenBoardItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenBoardItemImplCopyWith<_$AllergenBoardItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
