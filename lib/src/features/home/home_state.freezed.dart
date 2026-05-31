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
  Baby? get baby => throw _privateConstructorUsedError;
  Map<String, AllergenStatus> get allergenStatuses =>
      throw _privateConstructorUsedError;
  Map<String, int> get allergenLogCounts => throw _privateConstructorUsedError;
  List<MealPlanEntry> get todaysMeals => throw _privateConstructorUsedError;
  Map<String, Recipe> get todaysRecipes => throw _privateConstructorUsedError;
  bool get hasAnyPlannedMeal => throw _privateConstructorUsedError;

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
    Baby? baby,
    Map<String, AllergenStatus> allergenStatuses,
    Map<String, int> allergenLogCounts,
    List<MealPlanEntry> todaysMeals,
    Map<String, Recipe> todaysRecipes,
    bool hasAnyPlannedMeal,
  });

  $BabyCopyWith<$Res>? get baby;
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
    Object? baby = freezed,
    Object? allergenStatuses = null,
    Object? allergenLogCounts = null,
    Object? todaysMeals = null,
    Object? todaysRecipes = null,
    Object? hasAnyPlannedMeal = null,
  }) {
    return _then(
      _value.copyWith(
            baby: freezed == baby
                ? _value.baby
                : baby // ignore: cast_nullable_to_non_nullable
                      as Baby?,
            allergenStatuses: null == allergenStatuses
                ? _value.allergenStatuses
                : allergenStatuses // ignore: cast_nullable_to_non_nullable
                      as Map<String, AllergenStatus>,
            allergenLogCounts: null == allergenLogCounts
                ? _value.allergenLogCounts
                : allergenLogCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            todaysMeals: null == todaysMeals
                ? _value.todaysMeals
                : todaysMeals // ignore: cast_nullable_to_non_nullable
                      as List<MealPlanEntry>,
            todaysRecipes: null == todaysRecipes
                ? _value.todaysRecipes
                : todaysRecipes // ignore: cast_nullable_to_non_nullable
                      as Map<String, Recipe>,
            hasAnyPlannedMeal: null == hasAnyPlannedMeal
                ? _value.hasAnyPlannedMeal
                : hasAnyPlannedMeal // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BabyCopyWith<$Res>? get baby {
    if (_value.baby == null) {
      return null;
    }

    return $BabyCopyWith<$Res>(_value.baby!, (value) {
      return _then(_value.copyWith(baby: value) as $Val);
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
    Baby? baby,
    Map<String, AllergenStatus> allergenStatuses,
    Map<String, int> allergenLogCounts,
    List<MealPlanEntry> todaysMeals,
    Map<String, Recipe> todaysRecipes,
    bool hasAnyPlannedMeal,
  });

  @override
  $BabyCopyWith<$Res>? get baby;
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
    Object? baby = freezed,
    Object? allergenStatuses = null,
    Object? allergenLogCounts = null,
    Object? todaysMeals = null,
    Object? todaysRecipes = null,
    Object? hasAnyPlannedMeal = null,
  }) {
    return _then(
      _$HomeStateImpl(
        baby: freezed == baby
            ? _value.baby
            : baby // ignore: cast_nullable_to_non_nullable
                  as Baby?,
        allergenStatuses: null == allergenStatuses
            ? _value._allergenStatuses
            : allergenStatuses // ignore: cast_nullable_to_non_nullable
                  as Map<String, AllergenStatus>,
        allergenLogCounts: null == allergenLogCounts
            ? _value._allergenLogCounts
            : allergenLogCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        todaysMeals: null == todaysMeals
            ? _value._todaysMeals
            : todaysMeals // ignore: cast_nullable_to_non_nullable
                  as List<MealPlanEntry>,
        todaysRecipes: null == todaysRecipes
            ? _value._todaysRecipes
            : todaysRecipes // ignore: cast_nullable_to_non_nullable
                  as Map<String, Recipe>,
        hasAnyPlannedMeal: null == hasAnyPlannedMeal
            ? _value.hasAnyPlannedMeal
            : hasAnyPlannedMeal // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl extends _HomeState {
  const _$HomeStateImpl({
    this.baby,
    final Map<String, AllergenStatus> allergenStatuses =
        const <String, AllergenStatus>{},
    final Map<String, int> allergenLogCounts = const <String, int>{},
    final List<MealPlanEntry> todaysMeals = const <MealPlanEntry>[],
    final Map<String, Recipe> todaysRecipes = const <String, Recipe>{},
    this.hasAnyPlannedMeal = false,
  }) : _allergenStatuses = allergenStatuses,
       _allergenLogCounts = allergenLogCounts,
       _todaysMeals = todaysMeals,
       _todaysRecipes = todaysRecipes,
       super._();

  @override
  final Baby? baby;
  final Map<String, AllergenStatus> _allergenStatuses;
  @override
  @JsonKey()
  Map<String, AllergenStatus> get allergenStatuses {
    if (_allergenStatuses is EqualUnmodifiableMapView) return _allergenStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_allergenStatuses);
  }

  final Map<String, int> _allergenLogCounts;
  @override
  @JsonKey()
  Map<String, int> get allergenLogCounts {
    if (_allergenLogCounts is EqualUnmodifiableMapView)
      return _allergenLogCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_allergenLogCounts);
  }

  final List<MealPlanEntry> _todaysMeals;
  @override
  @JsonKey()
  List<MealPlanEntry> get todaysMeals {
    if (_todaysMeals is EqualUnmodifiableListView) return _todaysMeals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaysMeals);
  }

  final Map<String, Recipe> _todaysRecipes;
  @override
  @JsonKey()
  Map<String, Recipe> get todaysRecipes {
    if (_todaysRecipes is EqualUnmodifiableMapView) return _todaysRecipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_todaysRecipes);
  }

  @override
  @JsonKey()
  final bool hasAnyPlannedMeal;

  @override
  String toString() {
    return 'HomeState(baby: $baby, allergenStatuses: $allergenStatuses, allergenLogCounts: $allergenLogCounts, todaysMeals: $todaysMeals, todaysRecipes: $todaysRecipes, hasAnyPlannedMeal: $hasAnyPlannedMeal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.baby, baby) || other.baby == baby) &&
            const DeepCollectionEquality().equals(
              other._allergenStatuses,
              _allergenStatuses,
            ) &&
            const DeepCollectionEquality().equals(
              other._allergenLogCounts,
              _allergenLogCounts,
            ) &&
            const DeepCollectionEquality().equals(
              other._todaysMeals,
              _todaysMeals,
            ) &&
            const DeepCollectionEquality().equals(
              other._todaysRecipes,
              _todaysRecipes,
            ) &&
            (identical(other.hasAnyPlannedMeal, hasAnyPlannedMeal) ||
                other.hasAnyPlannedMeal == hasAnyPlannedMeal));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baby,
    const DeepCollectionEquality().hash(_allergenStatuses),
    const DeepCollectionEquality().hash(_allergenLogCounts),
    const DeepCollectionEquality().hash(_todaysMeals),
    const DeepCollectionEquality().hash(_todaysRecipes),
    hasAnyPlannedMeal,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState extends HomeState {
  const factory _HomeState({
    final Baby? baby,
    final Map<String, AllergenStatus> allergenStatuses,
    final Map<String, int> allergenLogCounts,
    final List<MealPlanEntry> todaysMeals,
    final Map<String, Recipe> todaysRecipes,
    final bool hasAnyPlannedMeal,
  }) = _$HomeStateImpl;
  const _HomeState._() : super._();

  @override
  Baby? get baby;
  @override
  Map<String, AllergenStatus> get allergenStatuses;
  @override
  Map<String, int> get allergenLogCounts;
  @override
  List<MealPlanEntry> get todaysMeals;
  @override
  Map<String, Recipe> get todaysRecipes;
  @override
  bool get hasAnyPlannedMeal;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
