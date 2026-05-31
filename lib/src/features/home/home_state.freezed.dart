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
  List<MealPlanEntry> get todaysMeals => throw _privateConstructorUsedError;
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
    List<MealPlanEntry> todaysMeals,
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
    Object? todaysMeals = null,
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
            todaysMeals: null == todaysMeals
                ? _value.todaysMeals
                : todaysMeals // ignore: cast_nullable_to_non_nullable
                      as List<MealPlanEntry>,
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
    List<MealPlanEntry> todaysMeals,
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
    Object? todaysMeals = null,
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
        todaysMeals: null == todaysMeals
            ? _value._todaysMeals
            : todaysMeals // ignore: cast_nullable_to_non_nullable
                  as List<MealPlanEntry>,
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
    final List<MealPlanEntry> todaysMeals = const <MealPlanEntry>[],
    this.hasAnyPlannedMeal = false,
  }) : _allergenStatuses = allergenStatuses,
       _todaysMeals = todaysMeals,
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

  final List<MealPlanEntry> _todaysMeals;
  @override
  @JsonKey()
  List<MealPlanEntry> get todaysMeals {
    if (_todaysMeals is EqualUnmodifiableListView) return _todaysMeals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaysMeals);
  }

  @override
  @JsonKey()
  final bool hasAnyPlannedMeal;

  @override
  String toString() {
    return 'HomeState(baby: $baby, allergenStatuses: $allergenStatuses, todaysMeals: $todaysMeals, hasAnyPlannedMeal: $hasAnyPlannedMeal)';
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
              other._todaysMeals,
              _todaysMeals,
            ) &&
            (identical(other.hasAnyPlannedMeal, hasAnyPlannedMeal) ||
                other.hasAnyPlannedMeal == hasAnyPlannedMeal));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baby,
    const DeepCollectionEquality().hash(_allergenStatuses),
    const DeepCollectionEquality().hash(_todaysMeals),
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
    final List<MealPlanEntry> todaysMeals,
    final bool hasAnyPlannedMeal,
  }) = _$HomeStateImpl;
  const _HomeState._() : super._();

  @override
  Baby? get baby;
  @override
  Map<String, AllergenStatus> get allergenStatuses;
  @override
  List<MealPlanEntry> get todaysMeals;
  @override
  bool get hasAnyPlannedMeal;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
