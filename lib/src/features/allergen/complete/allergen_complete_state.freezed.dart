// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_complete_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenCompleteState {
  String get babyName => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  List<Allergen> get allergens => throw _privateConstructorUsedError;

  /// Create a copy of AllergenCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenCompleteStateCopyWith<AllergenCompleteState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenCompleteStateCopyWith<$Res> {
  factory $AllergenCompleteStateCopyWith(
    AllergenCompleteState value,
    $Res Function(AllergenCompleteState) then,
  ) = _$AllergenCompleteStateCopyWithImpl<$Res, AllergenCompleteState>;
  @useResult
  $Res call({String babyName, String babyId, List<Allergen> allergens});
}

/// @nodoc
class _$AllergenCompleteStateCopyWithImpl<
  $Res,
  $Val extends AllergenCompleteState
>
    implements $AllergenCompleteStateCopyWith<$Res> {
  _$AllergenCompleteStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? babyName = null,
    Object? babyId = null,
    Object? allergens = null,
  }) {
    return _then(
      _value.copyWith(
            babyName: null == babyName
                ? _value.babyName
                : babyName // ignore: cast_nullable_to_non_nullable
                      as String,
            babyId: null == babyId
                ? _value.babyId
                : babyId // ignore: cast_nullable_to_non_nullable
                      as String,
            allergens: null == allergens
                ? _value.allergens
                : allergens // ignore: cast_nullable_to_non_nullable
                      as List<Allergen>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllergenCompleteStateImplCopyWith<$Res>
    implements $AllergenCompleteStateCopyWith<$Res> {
  factory _$$AllergenCompleteStateImplCopyWith(
    _$AllergenCompleteStateImpl value,
    $Res Function(_$AllergenCompleteStateImpl) then,
  ) = __$$AllergenCompleteStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String babyName, String babyId, List<Allergen> allergens});
}

/// @nodoc
class __$$AllergenCompleteStateImplCopyWithImpl<$Res>
    extends
        _$AllergenCompleteStateCopyWithImpl<$Res, _$AllergenCompleteStateImpl>
    implements _$$AllergenCompleteStateImplCopyWith<$Res> {
  __$$AllergenCompleteStateImplCopyWithImpl(
    _$AllergenCompleteStateImpl _value,
    $Res Function(_$AllergenCompleteStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? babyName = null,
    Object? babyId = null,
    Object? allergens = null,
  }) {
    return _then(
      _$AllergenCompleteStateImpl(
        babyName: null == babyName
            ? _value.babyName
            : babyName // ignore: cast_nullable_to_non_nullable
                  as String,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        allergens: null == allergens
            ? _value._allergens
            : allergens // ignore: cast_nullable_to_non_nullable
                  as List<Allergen>,
      ),
    );
  }
}

/// @nodoc

class _$AllergenCompleteStateImpl implements _AllergenCompleteState {
  const _$AllergenCompleteStateImpl({
    required this.babyName,
    required this.babyId,
    required final List<Allergen> allergens,
  }) : _allergens = allergens;

  @override
  final String babyName;
  @override
  final String babyId;
  final List<Allergen> _allergens;
  @override
  List<Allergen> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  @override
  String toString() {
    return 'AllergenCompleteState(babyName: $babyName, babyId: $babyId, allergens: $allergens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenCompleteStateImpl &&
            (identical(other.babyName, babyName) ||
                other.babyName == babyName) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            const DeepCollectionEquality().equals(
              other._allergens,
              _allergens,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    babyName,
    babyId,
    const DeepCollectionEquality().hash(_allergens),
  );

  /// Create a copy of AllergenCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenCompleteStateImplCopyWith<_$AllergenCompleteStateImpl>
  get copyWith =>
      __$$AllergenCompleteStateImplCopyWithImpl<_$AllergenCompleteStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenCompleteState implements AllergenCompleteState {
  const factory _AllergenCompleteState({
    required final String babyName,
    required final String babyId,
    required final List<Allergen> allergens,
  }) = _$AllergenCompleteStateImpl;

  @override
  String get babyName;
  @override
  String get babyId;
  @override
  List<Allergen> get allergens;

  /// Create a copy of AllergenCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenCompleteStateImplCopyWith<_$AllergenCompleteStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
