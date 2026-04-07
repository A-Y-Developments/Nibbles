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
  List<Recipe> get recommendations => throw _privateConstructorUsedError;
  AllergenBoardItem? get currentAllergenBoardItem =>
      throw _privateConstructorUsedError;
  List<MealPlanEntry> get todayMeals => throw _privateConstructorUsedError;
  List<Recipe> get todayRecipes => throw _privateConstructorUsedError;
  bool get isGeneralRecommendations => throw _privateConstructorUsedError;
  List<Recipe> get generalRecommendations => throw _privateConstructorUsedError;
  Set<String> get flaggedAllergenKeys => throw _privateConstructorUsedError;

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
    List<Recipe> recommendations,
    AllergenBoardItem? currentAllergenBoardItem,
    List<MealPlanEntry> todayMeals,
    List<Recipe> todayRecipes,
    bool isGeneralRecommendations,
    List<Recipe> generalRecommendations,
    Set<String> flaggedAllergenKeys,
  });

  $BabyCopyWith<$Res> get baby;
  $AllergenProgramStateCopyWith<$Res> get programState;
  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem;
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
    Object? recommendations = null,
    Object? currentAllergenBoardItem = freezed,
    Object? todayMeals = null,
    Object? todayRecipes = null,
    Object? isGeneralRecommendations = null,
    Object? generalRecommendations = null,
    Object? flaggedAllergenKeys = null,
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
            recommendations: null == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
            currentAllergenBoardItem: freezed == currentAllergenBoardItem
                ? _value.currentAllergenBoardItem
                : currentAllergenBoardItem // ignore: cast_nullable_to_non_nullable
                      as AllergenBoardItem?,
            todayMeals: null == todayMeals
                ? _value.todayMeals
                : todayMeals // ignore: cast_nullable_to_non_nullable
                      as List<MealPlanEntry>,
            todayRecipes: null == todayRecipes
                ? _value.todayRecipes
                : todayRecipes // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
            isGeneralRecommendations: null == isGeneralRecommendations
                ? _value.isGeneralRecommendations
                : isGeneralRecommendations // ignore: cast_nullable_to_non_nullable
                      as bool,
            generalRecommendations: null == generalRecommendations
                ? _value.generalRecommendations
                : generalRecommendations // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
            flaggedAllergenKeys: null == flaggedAllergenKeys
                ? _value.flaggedAllergenKeys
                : flaggedAllergenKeys // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
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
    List<Recipe> recommendations,
    AllergenBoardItem? currentAllergenBoardItem,
    List<MealPlanEntry> todayMeals,
    List<Recipe> todayRecipes,
    bool isGeneralRecommendations,
    List<Recipe> generalRecommendations,
    Set<String> flaggedAllergenKeys,
  });

  @override
  $BabyCopyWith<$Res> get baby;
  @override
  $AllergenProgramStateCopyWith<$Res> get programState;
  @override
  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem;
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
    Object? recommendations = null,
    Object? currentAllergenBoardItem = freezed,
    Object? todayMeals = null,
    Object? todayRecipes = null,
    Object? isGeneralRecommendations = null,
    Object? generalRecommendations = null,
    Object? flaggedAllergenKeys = null,
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
        recommendations: null == recommendations
            ? _value._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
        currentAllergenBoardItem: freezed == currentAllergenBoardItem
            ? _value.currentAllergenBoardItem
            : currentAllergenBoardItem // ignore: cast_nullable_to_non_nullable
                  as AllergenBoardItem?,
        todayMeals: null == todayMeals
            ? _value._todayMeals
            : todayMeals // ignore: cast_nullable_to_non_nullable
                  as List<MealPlanEntry>,
        todayRecipes: null == todayRecipes
            ? _value._todayRecipes
            : todayRecipes // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
        isGeneralRecommendations: null == isGeneralRecommendations
            ? _value.isGeneralRecommendations
            : isGeneralRecommendations // ignore: cast_nullable_to_non_nullable
                  as bool,
        generalRecommendations: null == generalRecommendations
            ? _value._generalRecommendations
            : generalRecommendations // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
        flaggedAllergenKeys: null == flaggedAllergenKeys
            ? _value._flaggedAllergenKeys
            : flaggedAllergenKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    required this.baby,
    required this.programState,
    required final List<Recipe> recommendations,
    this.currentAllergenBoardItem,
    final List<MealPlanEntry> todayMeals = const [],
    final List<Recipe> todayRecipes = const [],
    this.isGeneralRecommendations = false,
    final List<Recipe> generalRecommendations = const [],
    final Set<String> flaggedAllergenKeys = const <String>{},
  }) : _recommendations = recommendations,
       _todayMeals = todayMeals,
       _todayRecipes = todayRecipes,
       _generalRecommendations = generalRecommendations,
       _flaggedAllergenKeys = flaggedAllergenKeys;

  @override
  final Baby baby;
  @override
  final AllergenProgramState programState;
  final List<Recipe> _recommendations;
  @override
  List<Recipe> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  final AllergenBoardItem? currentAllergenBoardItem;
  final List<MealPlanEntry> _todayMeals;
  @override
  @JsonKey()
  List<MealPlanEntry> get todayMeals {
    if (_todayMeals is EqualUnmodifiableListView) return _todayMeals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todayMeals);
  }

  final List<Recipe> _todayRecipes;
  @override
  @JsonKey()
  List<Recipe> get todayRecipes {
    if (_todayRecipes is EqualUnmodifiableListView) return _todayRecipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todayRecipes);
  }

  @override
  @JsonKey()
  final bool isGeneralRecommendations;
  final List<Recipe> _generalRecommendations;
  @override
  @JsonKey()
  List<Recipe> get generalRecommendations {
    if (_generalRecommendations is EqualUnmodifiableListView)
      return _generalRecommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_generalRecommendations);
  }

  final Set<String> _flaggedAllergenKeys;
  @override
  @JsonKey()
  Set<String> get flaggedAllergenKeys {
    if (_flaggedAllergenKeys is EqualUnmodifiableSetView)
      return _flaggedAllergenKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_flaggedAllergenKeys);
  }

  @override
  String toString() {
    return 'HomeState(baby: $baby, programState: $programState, recommendations: $recommendations, currentAllergenBoardItem: $currentAllergenBoardItem, todayMeals: $todayMeals, todayRecipes: $todayRecipes, isGeneralRecommendations: $isGeneralRecommendations, generalRecommendations: $generalRecommendations, flaggedAllergenKeys: $flaggedAllergenKeys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.baby, baby) || other.baby == baby) &&
            (identical(other.programState, programState) ||
                other.programState == programState) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ) &&
            (identical(
                  other.currentAllergenBoardItem,
                  currentAllergenBoardItem,
                ) ||
                other.currentAllergenBoardItem == currentAllergenBoardItem) &&
            const DeepCollectionEquality().equals(
              other._todayMeals,
              _todayMeals,
            ) &&
            const DeepCollectionEquality().equals(
              other._todayRecipes,
              _todayRecipes,
            ) &&
            (identical(
                  other.isGeneralRecommendations,
                  isGeneralRecommendations,
                ) ||
                other.isGeneralRecommendations == isGeneralRecommendations) &&
            const DeepCollectionEquality().equals(
              other._generalRecommendations,
              _generalRecommendations,
            ) &&
            const DeepCollectionEquality().equals(
              other._flaggedAllergenKeys,
              _flaggedAllergenKeys,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baby,
    programState,
    const DeepCollectionEquality().hash(_recommendations),
    currentAllergenBoardItem,
    const DeepCollectionEquality().hash(_todayMeals),
    const DeepCollectionEquality().hash(_todayRecipes),
    isGeneralRecommendations,
    const DeepCollectionEquality().hash(_generalRecommendations),
    const DeepCollectionEquality().hash(_flaggedAllergenKeys),
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
    required final List<Recipe> recommendations,
    final AllergenBoardItem? currentAllergenBoardItem,
    final List<MealPlanEntry> todayMeals,
    final List<Recipe> todayRecipes,
    final bool isGeneralRecommendations,
    final List<Recipe> generalRecommendations,
    final Set<String> flaggedAllergenKeys,
  }) = _$HomeStateImpl;

  @override
  Baby get baby;
  @override
  AllergenProgramState get programState;
  @override
  List<Recipe> get recommendations;
  @override
  AllergenBoardItem? get currentAllergenBoardItem;
  @override
  List<MealPlanEntry> get todayMeals;
  @override
  List<Recipe> get todayRecipes;
  @override
  bool get isGeneralRecommendations;
  @override
  List<Recipe> get generalRecommendations;
  @override
  Set<String> get flaggedAllergenKeys;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
