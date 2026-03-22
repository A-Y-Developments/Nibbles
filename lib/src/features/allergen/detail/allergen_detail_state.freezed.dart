// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenDetailState {
  AllergenBoardItem get boardItem => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  Allergen? get nextAllergen => throw _privateConstructorUsedError;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenDetailStateCopyWith<AllergenDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenDetailStateCopyWith<$Res> {
  factory $AllergenDetailStateCopyWith(
    AllergenDetailState value,
    $Res Function(AllergenDetailState) then,
  ) = _$AllergenDetailStateCopyWithImpl<$Res, AllergenDetailState>;
  @useResult
  $Res call({
    AllergenBoardItem boardItem,
    String babyId,
    Allergen? nextAllergen,
  });

  $AllergenBoardItemCopyWith<$Res> get boardItem;
  $AllergenCopyWith<$Res>? get nextAllergen;
}

/// @nodoc
class _$AllergenDetailStateCopyWithImpl<$Res, $Val extends AllergenDetailState>
    implements $AllergenDetailStateCopyWith<$Res> {
  _$AllergenDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boardItem = null,
    Object? babyId = null,
    Object? nextAllergen = freezed,
  }) {
    return _then(
      _value.copyWith(
            boardItem: null == boardItem
                ? _value.boardItem
                : boardItem // ignore: cast_nullable_to_non_nullable
                      as AllergenBoardItem,
            babyId: null == babyId
                ? _value.babyId
                : babyId // ignore: cast_nullable_to_non_nullable
                      as String,
            nextAllergen: freezed == nextAllergen
                ? _value.nextAllergen
                : nextAllergen // ignore: cast_nullable_to_non_nullable
                      as Allergen?,
          )
          as $Val,
    );
  }

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenBoardItemCopyWith<$Res> get boardItem {
    return $AllergenBoardItemCopyWith<$Res>(_value.boardItem, (value) {
      return _then(_value.copyWith(boardItem: value) as $Val);
    });
  }

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenCopyWith<$Res>? get nextAllergen {
    if (_value.nextAllergen == null) {
      return null;
    }

    return $AllergenCopyWith<$Res>(_value.nextAllergen!, (value) {
      return _then(_value.copyWith(nextAllergen: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AllergenDetailStateImplCopyWith<$Res>
    implements $AllergenDetailStateCopyWith<$Res> {
  factory _$$AllergenDetailStateImplCopyWith(
    _$AllergenDetailStateImpl value,
    $Res Function(_$AllergenDetailStateImpl) then,
  ) = __$$AllergenDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AllergenBoardItem boardItem,
    String babyId,
    Allergen? nextAllergen,
  });

  @override
  $AllergenBoardItemCopyWith<$Res> get boardItem;
  @override
  $AllergenCopyWith<$Res>? get nextAllergen;
}

/// @nodoc
class __$$AllergenDetailStateImplCopyWithImpl<$Res>
    extends _$AllergenDetailStateCopyWithImpl<$Res, _$AllergenDetailStateImpl>
    implements _$$AllergenDetailStateImplCopyWith<$Res> {
  __$$AllergenDetailStateImplCopyWithImpl(
    _$AllergenDetailStateImpl _value,
    $Res Function(_$AllergenDetailStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boardItem = null,
    Object? babyId = null,
    Object? nextAllergen = freezed,
  }) {
    return _then(
      _$AllergenDetailStateImpl(
        boardItem: null == boardItem
            ? _value.boardItem
            : boardItem // ignore: cast_nullable_to_non_nullable
                  as AllergenBoardItem,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        nextAllergen: freezed == nextAllergen
            ? _value.nextAllergen
            : nextAllergen // ignore: cast_nullable_to_non_nullable
                  as Allergen?,
      ),
    );
  }
}

/// @nodoc

class _$AllergenDetailStateImpl implements _AllergenDetailState {
  const _$AllergenDetailStateImpl({
    required this.boardItem,
    required this.babyId,
    this.nextAllergen,
  });

  @override
  final AllergenBoardItem boardItem;
  @override
  final String babyId;
  @override
  final Allergen? nextAllergen;

  @override
  String toString() {
    return 'AllergenDetailState(boardItem: $boardItem, babyId: $babyId, nextAllergen: $nextAllergen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenDetailStateImpl &&
            (identical(other.boardItem, boardItem) ||
                other.boardItem == boardItem) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.nextAllergen, nextAllergen) ||
                other.nextAllergen == nextAllergen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, boardItem, babyId, nextAllergen);

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenDetailStateImplCopyWith<_$AllergenDetailStateImpl> get copyWith =>
      __$$AllergenDetailStateImplCopyWithImpl<_$AllergenDetailStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenDetailState implements AllergenDetailState {
  const factory _AllergenDetailState({
    required final AllergenBoardItem boardItem,
    required final String babyId,
    final Allergen? nextAllergen,
  }) = _$AllergenDetailStateImpl;

  @override
  AllergenBoardItem get boardItem;
  @override
  String get babyId;
  @override
  Allergen? get nextAllergen;

  /// Create a copy of AllergenDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenDetailStateImplCopyWith<_$AllergenDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
