// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_day_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeDayView {
  List<MealPlanEntry> get meals => throw _privateConstructorUsedError;
  Map<String, Recipe> get recipes => throw _privateConstructorUsedError;
  int get mealCount => throw _privateConstructorUsedError;
  int get mealTarget => throw _privateConstructorUsedError;
  bool get ironRich => throw _privateConstructorUsedError;
  bool get isToday => throw _privateConstructorUsedError;
  List<GuidanceTip> get guidance => throw _privateConstructorUsedError;

  /// Create a copy of HomeDayView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeDayViewCopyWith<HomeDayView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeDayViewCopyWith<$Res> {
  factory $HomeDayViewCopyWith(
    HomeDayView value,
    $Res Function(HomeDayView) then,
  ) = _$HomeDayViewCopyWithImpl<$Res, HomeDayView>;
  @useResult
  $Res call({
    List<MealPlanEntry> meals,
    Map<String, Recipe> recipes,
    int mealCount,
    int mealTarget,
    bool ironRich,
    bool isToday,
    List<GuidanceTip> guidance,
  });
}

/// @nodoc
class _$HomeDayViewCopyWithImpl<$Res, $Val extends HomeDayView>
    implements $HomeDayViewCopyWith<$Res> {
  _$HomeDayViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeDayView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meals = null,
    Object? recipes = null,
    Object? mealCount = null,
    Object? mealTarget = null,
    Object? ironRich = null,
    Object? isToday = null,
    Object? guidance = null,
  }) {
    return _then(
      _value.copyWith(
            meals: null == meals
                ? _value.meals
                : meals // ignore: cast_nullable_to_non_nullable
                      as List<MealPlanEntry>,
            recipes: null == recipes
                ? _value.recipes
                : recipes // ignore: cast_nullable_to_non_nullable
                      as Map<String, Recipe>,
            mealCount: null == mealCount
                ? _value.mealCount
                : mealCount // ignore: cast_nullable_to_non_nullable
                      as int,
            mealTarget: null == mealTarget
                ? _value.mealTarget
                : mealTarget // ignore: cast_nullable_to_non_nullable
                      as int,
            ironRich: null == ironRich
                ? _value.ironRich
                : ironRich // ignore: cast_nullable_to_non_nullable
                      as bool,
            isToday: null == isToday
                ? _value.isToday
                : isToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            guidance: null == guidance
                ? _value.guidance
                : guidance // ignore: cast_nullable_to_non_nullable
                      as List<GuidanceTip>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HomeDayViewImplCopyWith<$Res>
    implements $HomeDayViewCopyWith<$Res> {
  factory _$$HomeDayViewImplCopyWith(
    _$HomeDayViewImpl value,
    $Res Function(_$HomeDayViewImpl) then,
  ) = __$$HomeDayViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MealPlanEntry> meals,
    Map<String, Recipe> recipes,
    int mealCount,
    int mealTarget,
    bool ironRich,
    bool isToday,
    List<GuidanceTip> guidance,
  });
}

/// @nodoc
class __$$HomeDayViewImplCopyWithImpl<$Res>
    extends _$HomeDayViewCopyWithImpl<$Res, _$HomeDayViewImpl>
    implements _$$HomeDayViewImplCopyWith<$Res> {
  __$$HomeDayViewImplCopyWithImpl(
    _$HomeDayViewImpl _value,
    $Res Function(_$HomeDayViewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeDayView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meals = null,
    Object? recipes = null,
    Object? mealCount = null,
    Object? mealTarget = null,
    Object? ironRich = null,
    Object? isToday = null,
    Object? guidance = null,
  }) {
    return _then(
      _$HomeDayViewImpl(
        meals: null == meals
            ? _value._meals
            : meals // ignore: cast_nullable_to_non_nullable
                  as List<MealPlanEntry>,
        recipes: null == recipes
            ? _value._recipes
            : recipes // ignore: cast_nullable_to_non_nullable
                  as Map<String, Recipe>,
        mealCount: null == mealCount
            ? _value.mealCount
            : mealCount // ignore: cast_nullable_to_non_nullable
                  as int,
        mealTarget: null == mealTarget
            ? _value.mealTarget
            : mealTarget // ignore: cast_nullable_to_non_nullable
                  as int,
        ironRich: null == ironRich
            ? _value.ironRich
            : ironRich // ignore: cast_nullable_to_non_nullable
                  as bool,
        isToday: null == isToday
            ? _value.isToday
            : isToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        guidance: null == guidance
            ? _value._guidance
            : guidance // ignore: cast_nullable_to_non_nullable
                  as List<GuidanceTip>,
      ),
    );
  }
}

/// @nodoc

class _$HomeDayViewImpl implements _HomeDayView {
  const _$HomeDayViewImpl({
    final List<MealPlanEntry> meals = const <MealPlanEntry>[],
    final Map<String, Recipe> recipes = const <String, Recipe>{},
    this.mealCount = 0,
    this.mealTarget = kDailyMealTarget,
    this.ironRich = false,
    this.isToday = false,
    final List<GuidanceTip> guidance = const <GuidanceTip>[],
  }) : _meals = meals,
       _recipes = recipes,
       _guidance = guidance;

  final List<MealPlanEntry> _meals;
  @override
  @JsonKey()
  List<MealPlanEntry> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  final Map<String, Recipe> _recipes;
  @override
  @JsonKey()
  Map<String, Recipe> get recipes {
    if (_recipes is EqualUnmodifiableMapView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recipes);
  }

  @override
  @JsonKey()
  final int mealCount;
  @override
  @JsonKey()
  final int mealTarget;
  @override
  @JsonKey()
  final bool ironRich;
  @override
  @JsonKey()
  final bool isToday;
  final List<GuidanceTip> _guidance;
  @override
  @JsonKey()
  List<GuidanceTip> get guidance {
    if (_guidance is EqualUnmodifiableListView) return _guidance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_guidance);
  }

  @override
  String toString() {
    return 'HomeDayView(meals: $meals, recipes: $recipes, mealCount: $mealCount, mealTarget: $mealTarget, ironRich: $ironRich, isToday: $isToday, guidance: $guidance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeDayViewImpl &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes) &&
            (identical(other.mealCount, mealCount) ||
                other.mealCount == mealCount) &&
            (identical(other.mealTarget, mealTarget) ||
                other.mealTarget == mealTarget) &&
            (identical(other.ironRich, ironRich) ||
                other.ironRich == ironRich) &&
            (identical(other.isToday, isToday) || other.isToday == isToday) &&
            const DeepCollectionEquality().equals(other._guidance, _guidance));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_meals),
    const DeepCollectionEquality().hash(_recipes),
    mealCount,
    mealTarget,
    ironRich,
    isToday,
    const DeepCollectionEquality().hash(_guidance),
  );

  /// Create a copy of HomeDayView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeDayViewImplCopyWith<_$HomeDayViewImpl> get copyWith =>
      __$$HomeDayViewImplCopyWithImpl<_$HomeDayViewImpl>(this, _$identity);
}

abstract class _HomeDayView implements HomeDayView {
  const factory _HomeDayView({
    final List<MealPlanEntry> meals,
    final Map<String, Recipe> recipes,
    final int mealCount,
    final int mealTarget,
    final bool ironRich,
    final bool isToday,
    final List<GuidanceTip> guidance,
  }) = _$HomeDayViewImpl;

  @override
  List<MealPlanEntry> get meals;
  @override
  Map<String, Recipe> get recipes;
  @override
  int get mealCount;
  @override
  int get mealTarget;
  @override
  bool get ironRich;
  @override
  bool get isToday;
  @override
  List<GuidanceTip> get guidance;

  /// Create a copy of HomeDayView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeDayViewImplCopyWith<_$HomeDayViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
