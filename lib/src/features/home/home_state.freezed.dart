// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  Baby get baby => throw _privateConstructorUsedError;
  AllergenProgramState get programState => throw _privateConstructorUsedError;
  bool get hasLoggedToday => throw _privateConstructorUsedError;
  List<Recipe> get recommendations => throw _privateConstructorUsedError;
  AllergenBoardItem? get currentAllergenBoardItem =>
      throw _privateConstructorUsedError;
  MealPlanEntry? get todayMeal => throw _privateConstructorUsedError;
  Recipe? get todayRecipe => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    Baby baby,
    AllergenProgramState programState,
    bool hasLoggedToday,
    List<Recipe> recommendations,
    AllergenBoardItem? currentAllergenBoardItem,
    MealPlanEntry? todayMeal,
    Recipe? todayRecipe,
  });

  $BabyCopyWith<$Res> get baby;
  $AllergenProgramStateCopyWith<$Res> get programState;
  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem;
  $MealPlanEntryCopyWith<$Res>? get todayMeal;
  $RecipeCopyWith<$Res>? get todayRecipe;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baby = null,
    Object? programState = null,
    Object? hasLoggedToday = null,
    Object? recommendations = null,
    Object? currentAllergenBoardItem = freezed,
    Object? todayMeal = freezed,
    Object? todayRecipe = freezed,
  }) {
    return _then(
      _value.copyWith(
            baby: null == baby
                ? _value.baby
                : baby // ignore: cast_nullable_to_non_nullable
                      as Baby,
            programState: null == programState
                ? _value.programState
                : programState // ignore: cast_nullable_to_non_nullable
                      as AllergenProgramState,
            hasLoggedToday: null == hasLoggedToday
                ? _value.hasLoggedToday
                : hasLoggedToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            recommendations: null == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
            currentAllergenBoardItem: freezed == currentAllergenBoardItem
                ? _value.currentAllergenBoardItem
                : currentAllergenBoardItem // ignore: cast_nullable_to_non_nullable
                      as AllergenBoardItem?,
            todayMeal: freezed == todayMeal
                ? _value.todayMeal
                : todayMeal // ignore: cast_nullable_to_non_nullable
                      as MealPlanEntry?,
            todayRecipe: freezed == todayRecipe
                ? _value.todayRecipe
                : todayRecipe // ignore: cast_nullable_to_non_nullable
                      as Recipe?,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BabyCopyWith<$Res> get baby {
    return $BabyCopyWith<$Res>(_value.baby, (value) {
      return _then(_value.copyWith(baby: value) as $Val);
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenProgramStateCopyWith<$Res> get programState {
    return $AllergenProgramStateCopyWith<$Res>(_value.programState, (value) {
      return _then(_value.copyWith(programState: value) as $Val);
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem {
    if (_value.currentAllergenBoardItem == null) {
      return null;
    }

    return $AllergenBoardItemCopyWith<$Res>(_value.currentAllergenBoardItem!, (
      value,
    ) {
      return _then(_value.copyWith(currentAllergenBoardItem: value) as $Val);
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealPlanEntryCopyWith<$Res>? get todayMeal {
    if (_value.todayMeal == null) {
      return null;
    }

    return $MealPlanEntryCopyWith<$Res>(_value.todayMeal!, (value) {
      return _then(_value.copyWith(todayMeal: value) as $Val);
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<$Res>? get todayRecipe {
    if (_value.todayRecipe == null) {
      return null;
    }

    return $RecipeCopyWith<$Res>(_value.todayRecipe!, (value) {
      return _then(_value.copyWith(todayRecipe: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Baby baby,
    AllergenProgramState programState,
    bool hasLoggedToday,
    List<Recipe> recommendations,
    AllergenBoardItem? currentAllergenBoardItem,
    MealPlanEntry? todayMeal,
    Recipe? todayRecipe,
  });

  @override
  $BabyCopyWith<$Res> get baby;
  @override
  $AllergenProgramStateCopyWith<$Res> get programState;
  @override
  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem;
  @override
  $MealPlanEntryCopyWith<$Res>? get todayMeal;
  @override
  $RecipeCopyWith<$Res>? get todayRecipe;
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baby = null,
    Object? programState = null,
    Object? hasLoggedToday = null,
    Object? recommendations = null,
    Object? currentAllergenBoardItem = freezed,
    Object? todayMeal = freezed,
    Object? todayRecipe = freezed,
  }) {
    return _then(
      _$HomeStateImpl(
        baby: null == baby
            ? _value.baby
            : baby // ignore: cast_nullable_to_non_nullable
                  as Baby,
        programState: null == programState
            ? _value.programState
            : programState // ignore: cast_nullable_to_non_nullable
                  as AllergenProgramState,
        hasLoggedToday: null == hasLoggedToday
            ? _value.hasLoggedToday
            : hasLoggedToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        recommendations: null == recommendations
            ? _value._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
        currentAllergenBoardItem: freezed == currentAllergenBoardItem
            ? _value.currentAllergenBoardItem
            : currentAllergenBoardItem // ignore: cast_nullable_to_non_nullable
                  as AllergenBoardItem?,
        todayMeal: freezed == todayMeal
            ? _value.todayMeal
            : todayMeal // ignore: cast_nullable_to_non_nullable
                  as MealPlanEntry?,
        todayRecipe: freezed == todayRecipe
            ? _value.todayRecipe
            : todayRecipe // ignore: cast_nullable_to_non_nullable
                  as Recipe?,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    required this.baby,
    required this.programState,
    required this.hasLoggedToday,
    required final List<Recipe> recommendations,
    this.currentAllergenBoardItem,
    this.todayMeal,
    this.todayRecipe,
  }) : _recommendations = recommendations;

  @override
  final Baby baby;
  @override
  final AllergenProgramState programState;
  @override
  final bool hasLoggedToday;
  final List<Recipe> _recommendations;
  @override
  List<Recipe> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  final AllergenBoardItem? currentAllergenBoardItem;
  @override
  final MealPlanEntry? todayMeal;
  @override
  final Recipe? todayRecipe;

  @override
  String toString() {
    return 'HomeState(baby: $baby, programState: $programState, hasLoggedToday: $hasLoggedToday, recommendations: $recommendations, currentAllergenBoardItem: $currentAllergenBoardItem, todayMeal: $todayMeal, todayRecipe: $todayRecipe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.baby, baby) || other.baby == baby) &&
            (identical(other.programState, programState) ||
                other.programState == programState) &&
            (identical(other.hasLoggedToday, hasLoggedToday) ||
                other.hasLoggedToday == hasLoggedToday) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ) &&
            (identical(
                  other.currentAllergenBoardItem,
                  currentAllergenBoardItem,
                ) ||
                other.currentAllergenBoardItem == currentAllergenBoardItem) &&
            (identical(other.todayMeal, todayMeal) ||
                other.todayMeal == todayMeal) &&
            (identical(other.todayRecipe, todayRecipe) ||
                other.todayRecipe == todayRecipe));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baby,
    programState,
    hasLoggedToday,
    const DeepCollectionEquality().hash(_recommendations),
    currentAllergenBoardItem,
    todayMeal,
    todayRecipe,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState({
    required final Baby baby,
    required final AllergenProgramState programState,
    required final bool hasLoggedToday,
    required final List<Recipe> recommendations,
    final AllergenBoardItem? currentAllergenBoardItem,
    final MealPlanEntry? todayMeal,
    final Recipe? todayRecipe,
  }) = _$HomeStateImpl;

  @override
  Baby get baby;
  @override
  AllergenProgramState get programState;
  @override
  bool get hasLoggedToday;
  @override
  List<Recipe> get recommendations;
  @override
  AllergenBoardItem? get currentAllergenBoardItem;
  @override
  MealPlanEntry? get todayMeal;
  @override
  Recipe? get todayRecipe;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
