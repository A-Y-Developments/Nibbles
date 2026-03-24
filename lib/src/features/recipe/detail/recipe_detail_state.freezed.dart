// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecipeDetailState {
  Recipe get recipe => throw _privateConstructorUsedError;
  String get currentAllergenKey => throw _privateConstructorUsedError;
  Map<String, AllergenStatus> get allergenStatuses =>
      throw _privateConstructorUsedError;
  bool get isAddingToMealPlan => throw _privateConstructorUsedError;
  bool get isAddingToShoppingList => throw _privateConstructorUsedError;

  /// Create a copy of RecipeDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeDetailStateCopyWith<RecipeDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeDetailStateCopyWith<$Res> {
  factory $RecipeDetailStateCopyWith(
    RecipeDetailState value,
    $Res Function(RecipeDetailState) then,
  ) = _$RecipeDetailStateCopyWithImpl<$Res, RecipeDetailState>;
  @useResult
  $Res call({
    Recipe recipe,
    String currentAllergenKey,
    Map<String, AllergenStatus> allergenStatuses,
    bool isAddingToMealPlan,
    bool isAddingToShoppingList,
  });

  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class _$RecipeDetailStateCopyWithImpl<$Res, $Val extends RecipeDetailState>
    implements $RecipeDetailStateCopyWith<$Res> {
  _$RecipeDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? currentAllergenKey = null,
    Object? allergenStatuses = null,
    Object? isAddingToMealPlan = null,
    Object? isAddingToShoppingList = null,
  }) {
    return _then(
      _value.copyWith(
            recipe: null == recipe
                ? _value.recipe
                : recipe // ignore: cast_nullable_to_non_nullable
                      as Recipe,
            currentAllergenKey: null == currentAllergenKey
                ? _value.currentAllergenKey
                : currentAllergenKey // ignore: cast_nullable_to_non_nullable
                      as String,
            allergenStatuses: null == allergenStatuses
                ? _value.allergenStatuses
                : allergenStatuses // ignore: cast_nullable_to_non_nullable
                      as Map<String, AllergenStatus>,
            isAddingToMealPlan: null == isAddingToMealPlan
                ? _value.isAddingToMealPlan
                : isAddingToMealPlan // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAddingToShoppingList: null == isAddingToShoppingList
                ? _value.isAddingToShoppingList
                : isAddingToShoppingList // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of RecipeDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<$Res> get recipe {
    return $RecipeCopyWith<$Res>(_value.recipe, (value) {
      return _then(_value.copyWith(recipe: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecipeDetailStateImplCopyWith<$Res>
    implements $RecipeDetailStateCopyWith<$Res> {
  factory _$$RecipeDetailStateImplCopyWith(
    _$RecipeDetailStateImpl value,
    $Res Function(_$RecipeDetailStateImpl) then,
  ) = __$$RecipeDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Recipe recipe,
    String currentAllergenKey,
    Map<String, AllergenStatus> allergenStatuses,
    bool isAddingToMealPlan,
    bool isAddingToShoppingList,
  });

  @override
  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class __$$RecipeDetailStateImplCopyWithImpl<$Res>
    extends _$RecipeDetailStateCopyWithImpl<$Res, _$RecipeDetailStateImpl>
    implements _$$RecipeDetailStateImplCopyWith<$Res> {
  __$$RecipeDetailStateImplCopyWithImpl(
    _$RecipeDetailStateImpl _value,
    $Res Function(_$RecipeDetailStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? currentAllergenKey = null,
    Object? allergenStatuses = null,
    Object? isAddingToMealPlan = null,
    Object? isAddingToShoppingList = null,
  }) {
    return _then(
      _$RecipeDetailStateImpl(
        recipe: null == recipe
            ? _value.recipe
            : recipe // ignore: cast_nullable_to_non_nullable
                  as Recipe,
        currentAllergenKey: null == currentAllergenKey
            ? _value.currentAllergenKey
            : currentAllergenKey // ignore: cast_nullable_to_non_nullable
                  as String,
        allergenStatuses: null == allergenStatuses
            ? _value._allergenStatuses
            : allergenStatuses // ignore: cast_nullable_to_non_nullable
                  as Map<String, AllergenStatus>,
        isAddingToMealPlan: null == isAddingToMealPlan
            ? _value.isAddingToMealPlan
            : isAddingToMealPlan // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAddingToShoppingList: null == isAddingToShoppingList
            ? _value.isAddingToShoppingList
            : isAddingToShoppingList // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$RecipeDetailStateImpl implements _RecipeDetailState {
  const _$RecipeDetailStateImpl({
    required this.recipe,
    required this.currentAllergenKey,
    final Map<String, AllergenStatus> allergenStatuses =
        const <String, AllergenStatus>{},
    this.isAddingToMealPlan = false,
    this.isAddingToShoppingList = false,
  }) : _allergenStatuses = allergenStatuses;

  @override
  final Recipe recipe;
  @override
  final String currentAllergenKey;
  final Map<String, AllergenStatus> _allergenStatuses;
  @override
  @JsonKey()
  Map<String, AllergenStatus> get allergenStatuses {
    if (_allergenStatuses is EqualUnmodifiableMapView) return _allergenStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_allergenStatuses);
  }

  @override
  @JsonKey()
  final bool isAddingToMealPlan;
  @override
  @JsonKey()
  final bool isAddingToShoppingList;

  @override
  String toString() {
    return 'RecipeDetailState(recipe: $recipe, currentAllergenKey: $currentAllergenKey, allergenStatuses: $allergenStatuses, isAddingToMealPlan: $isAddingToMealPlan, isAddingToShoppingList: $isAddingToShoppingList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeDetailStateImpl &&
            (identical(other.recipe, recipe) || other.recipe == recipe) &&
            (identical(other.currentAllergenKey, currentAllergenKey) ||
                other.currentAllergenKey == currentAllergenKey) &&
            const DeepCollectionEquality().equals(
              other._allergenStatuses,
              _allergenStatuses,
            ) &&
            (identical(other.isAddingToMealPlan, isAddingToMealPlan) ||
                other.isAddingToMealPlan == isAddingToMealPlan) &&
            (identical(other.isAddingToShoppingList, isAddingToShoppingList) ||
                other.isAddingToShoppingList == isAddingToShoppingList));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    recipe,
    currentAllergenKey,
    const DeepCollectionEquality().hash(_allergenStatuses),
    isAddingToMealPlan,
    isAddingToShoppingList,
  );

  /// Create a copy of RecipeDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeDetailStateImplCopyWith<_$RecipeDetailStateImpl> get copyWith =>
      __$$RecipeDetailStateImplCopyWithImpl<_$RecipeDetailStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RecipeDetailState implements RecipeDetailState {
  const factory _RecipeDetailState({
    required final Recipe recipe,
    required final String currentAllergenKey,
    final Map<String, AllergenStatus> allergenStatuses,
    final bool isAddingToMealPlan,
    final bool isAddingToShoppingList,
  }) = _$RecipeDetailStateImpl;

  @override
  Recipe get recipe;
  @override
  String get currentAllergenKey;
  @override
  Map<String, AllergenStatus> get allergenStatuses;
  @override
  bool get isAddingToMealPlan;
  @override
  bool get isAddingToShoppingList;

  /// Create a copy of RecipeDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeDetailStateImplCopyWith<_$RecipeDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
