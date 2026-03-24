// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_plan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MealPlanState {
  List<MealPlanEntry> get meals => throw _privateConstructorUsedError;
  DateTime get weekStart => throw _privateConstructorUsedError;
  Map<String, Recipe> get recipes => throw _privateConstructorUsedError;

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealPlanStateCopyWith<MealPlanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealPlanStateCopyWith<$Res> {
  factory $MealPlanStateCopyWith(
    MealPlanState value,
    $Res Function(MealPlanState) then,
  ) = _$MealPlanStateCopyWithImpl<$Res, MealPlanState>;
  @useResult
  $Res call({
    List<MealPlanEntry> meals,
    DateTime weekStart,
    Map<String, Recipe> recipes,
  });
}

/// @nodoc
class _$MealPlanStateCopyWithImpl<$Res, $Val extends MealPlanState>
    implements $MealPlanStateCopyWith<$Res> {
  _$MealPlanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meals = null,
    Object? weekStart = null,
    Object? recipes = null,
  }) {
    return _then(
      _value.copyWith(
            meals: null == meals
                ? _value.meals
                : meals // ignore: cast_nullable_to_non_nullable
                      as List<MealPlanEntry>,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            recipes: null == recipes
                ? _value.recipes
                : recipes // ignore: cast_nullable_to_non_nullable
                      as Map<String, Recipe>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealPlanStateImplCopyWith<$Res>
    implements $MealPlanStateCopyWith<$Res> {
  factory _$$MealPlanStateImplCopyWith(
    _$MealPlanStateImpl value,
    $Res Function(_$MealPlanStateImpl) then,
  ) = __$$MealPlanStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MealPlanEntry> meals,
    DateTime weekStart,
    Map<String, Recipe> recipes,
  });
}

/// @nodoc
class __$$MealPlanStateImplCopyWithImpl<$Res>
    extends _$MealPlanStateCopyWithImpl<$Res, _$MealPlanStateImpl>
    implements _$$MealPlanStateImplCopyWith<$Res> {
  __$$MealPlanStateImplCopyWithImpl(
    _$MealPlanStateImpl _value,
    $Res Function(_$MealPlanStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meals = null,
    Object? weekStart = null,
    Object? recipes = null,
  }) {
    return _then(
      _$MealPlanStateImpl(
        meals: null == meals
            ? _value._meals
            : meals // ignore: cast_nullable_to_non_nullable
                  as List<MealPlanEntry>,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        recipes: null == recipes
            ? _value._recipes
            : recipes // ignore: cast_nullable_to_non_nullable
                  as Map<String, Recipe>,
      ),
    );
  }
}

/// @nodoc

class _$MealPlanStateImpl implements _MealPlanState {
  const _$MealPlanStateImpl({
    required final List<MealPlanEntry> meals,
    required this.weekStart,
    final Map<String, Recipe> recipes = const <String, Recipe>{},
  }) : _meals = meals,
       _recipes = recipes;

  final List<MealPlanEntry> _meals;
  @override
  List<MealPlanEntry> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  final DateTime weekStart;
  final Map<String, Recipe> _recipes;
  @override
  @JsonKey()
  Map<String, Recipe> get recipes {
    if (_recipes is EqualUnmodifiableMapView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recipes);
  }

  @override
  String toString() {
    return 'MealPlanState(meals: $meals, weekStart: $weekStart, recipes: $recipes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealPlanStateImpl &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_meals),
    weekStart,
    const DeepCollectionEquality().hash(_recipes),
  );

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealPlanStateImplCopyWith<_$MealPlanStateImpl> get copyWith =>
      __$$MealPlanStateImplCopyWithImpl<_$MealPlanStateImpl>(this, _$identity);
}

abstract class _MealPlanState implements MealPlanState {
  const factory _MealPlanState({
    required final List<MealPlanEntry> meals,
    required final DateTime weekStart,
    final Map<String, Recipe> recipes,
  }) = _$MealPlanStateImpl;

  @override
  List<MealPlanEntry> get meals;
  @override
  DateTime get weekStart;
  @override
  Map<String, Recipe> get recipes;

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealPlanStateImplCopyWith<_$MealPlanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
