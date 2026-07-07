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
  List<MealPlanEntry> get allMeals => throw _privateConstructorUsedError;
  Map<String, Recipe> get allRecipes => throw _privateConstructorUsedError;
  List<DateTime> get plannedDates => throw _privateConstructorUsedError;
  Map<String, AllergenStatus> get allergenStatuses =>
      throw _privateConstructorUsedError;
  Map<String, int> get allergenLogCounts => throw _privateConstructorUsedError;
  String? get currentAllergenKey => throw _privateConstructorUsedError;
  AllergenStatus get currentAllergenStatus =>
      throw _privateConstructorUsedError;
  List<bool> get currentAllergenReactionFlags =>
      throw _privateConstructorUsedError;

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
    List<MealPlanEntry> allMeals,
    Map<String, Recipe> allRecipes,
    List<DateTime> plannedDates,
    Map<String, AllergenStatus> allergenStatuses,
    Map<String, int> allergenLogCounts,
    String? currentAllergenKey,
    AllergenStatus currentAllergenStatus,
    List<bool> currentAllergenReactionFlags,
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
    Object? allMeals = null,
    Object? allRecipes = null,
    Object? plannedDates = null,
    Object? allergenStatuses = null,
    Object? allergenLogCounts = null,
    Object? currentAllergenKey = freezed,
    Object? currentAllergenStatus = null,
    Object? currentAllergenReactionFlags = null,
  }) {
    return _then(
      _value.copyWith(
            baby: freezed == baby
                ? _value.baby
                : baby // ignore: cast_nullable_to_non_nullable
                      as Baby?,
            allMeals: null == allMeals
                ? _value.allMeals
                : allMeals // ignore: cast_nullable_to_non_nullable
                      as List<MealPlanEntry>,
            allRecipes: null == allRecipes
                ? _value.allRecipes
                : allRecipes // ignore: cast_nullable_to_non_nullable
                      as Map<String, Recipe>,
            plannedDates: null == plannedDates
                ? _value.plannedDates
                : plannedDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            allergenStatuses: null == allergenStatuses
                ? _value.allergenStatuses
                : allergenStatuses // ignore: cast_nullable_to_non_nullable
                      as Map<String, AllergenStatus>,
            allergenLogCounts: null == allergenLogCounts
                ? _value.allergenLogCounts
                : allergenLogCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            currentAllergenKey: freezed == currentAllergenKey
                ? _value.currentAllergenKey
                : currentAllergenKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentAllergenStatus: null == currentAllergenStatus
                ? _value.currentAllergenStatus
                : currentAllergenStatus // ignore: cast_nullable_to_non_nullable
                      as AllergenStatus,
            currentAllergenReactionFlags: null == currentAllergenReactionFlags
                ? _value.currentAllergenReactionFlags
                : currentAllergenReactionFlags // ignore: cast_nullable_to_non_nullable
                      as List<bool>,
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
    List<MealPlanEntry> allMeals,
    Map<String, Recipe> allRecipes,
    List<DateTime> plannedDates,
    Map<String, AllergenStatus> allergenStatuses,
    Map<String, int> allergenLogCounts,
    String? currentAllergenKey,
    AllergenStatus currentAllergenStatus,
    List<bool> currentAllergenReactionFlags,
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
    Object? allMeals = null,
    Object? allRecipes = null,
    Object? plannedDates = null,
    Object? allergenStatuses = null,
    Object? allergenLogCounts = null,
    Object? currentAllergenKey = freezed,
    Object? currentAllergenStatus = null,
    Object? currentAllergenReactionFlags = null,
  }) {
    return _then(
      _$HomeStateImpl(
        baby: freezed == baby
            ? _value.baby
            : baby // ignore: cast_nullable_to_non_nullable
                  as Baby?,
        allMeals: null == allMeals
            ? _value._allMeals
            : allMeals // ignore: cast_nullable_to_non_nullable
                  as List<MealPlanEntry>,
        allRecipes: null == allRecipes
            ? _value._allRecipes
            : allRecipes // ignore: cast_nullable_to_non_nullable
                  as Map<String, Recipe>,
        plannedDates: null == plannedDates
            ? _value._plannedDates
            : plannedDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        allergenStatuses: null == allergenStatuses
            ? _value._allergenStatuses
            : allergenStatuses // ignore: cast_nullable_to_non_nullable
                  as Map<String, AllergenStatus>,
        allergenLogCounts: null == allergenLogCounts
            ? _value._allergenLogCounts
            : allergenLogCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        currentAllergenKey: freezed == currentAllergenKey
            ? _value.currentAllergenKey
            : currentAllergenKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentAllergenStatus: null == currentAllergenStatus
            ? _value.currentAllergenStatus
            : currentAllergenStatus // ignore: cast_nullable_to_non_nullable
                  as AllergenStatus,
        currentAllergenReactionFlags: null == currentAllergenReactionFlags
            ? _value._currentAllergenReactionFlags
            : currentAllergenReactionFlags // ignore: cast_nullable_to_non_nullable
                  as List<bool>,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl extends _HomeState {
  const _$HomeStateImpl({
    this.baby,
    final List<MealPlanEntry> allMeals = const <MealPlanEntry>[],
    final Map<String, Recipe> allRecipes = const <String, Recipe>{},
    final List<DateTime> plannedDates = const <DateTime>[],
    final Map<String, AllergenStatus> allergenStatuses =
        const <String, AllergenStatus>{},
    final Map<String, int> allergenLogCounts = const <String, int>{},
    this.currentAllergenKey,
    this.currentAllergenStatus = AllergenStatus.notStarted,
    final List<bool> currentAllergenReactionFlags = const <bool>[],
  }) : _allMeals = allMeals,
       _allRecipes = allRecipes,
       _plannedDates = plannedDates,
       _allergenStatuses = allergenStatuses,
       _allergenLogCounts = allergenLogCounts,
       _currentAllergenReactionFlags = currentAllergenReactionFlags,
       super._();

  @override
  final Baby? baby;
  final List<MealPlanEntry> _allMeals;
  @override
  @JsonKey()
  List<MealPlanEntry> get allMeals {
    if (_allMeals is EqualUnmodifiableListView) return _allMeals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allMeals);
  }

  final Map<String, Recipe> _allRecipes;
  @override
  @JsonKey()
  Map<String, Recipe> get allRecipes {
    if (_allRecipes is EqualUnmodifiableMapView) return _allRecipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_allRecipes);
  }

  final List<DateTime> _plannedDates;
  @override
  @JsonKey()
  List<DateTime> get plannedDates {
    if (_plannedDates is EqualUnmodifiableListView) return _plannedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plannedDates);
  }

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

  @override
  final String? currentAllergenKey;
  @override
  @JsonKey()
  final AllergenStatus currentAllergenStatus;
  final List<bool> _currentAllergenReactionFlags;
  @override
  @JsonKey()
  List<bool> get currentAllergenReactionFlags {
    if (_currentAllergenReactionFlags is EqualUnmodifiableListView)
      return _currentAllergenReactionFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_currentAllergenReactionFlags);
  }

  @override
  String toString() {
    return 'HomeState(baby: $baby, allMeals: $allMeals, allRecipes: $allRecipes, plannedDates: $plannedDates, allergenStatuses: $allergenStatuses, allergenLogCounts: $allergenLogCounts, currentAllergenKey: $currentAllergenKey, currentAllergenStatus: $currentAllergenStatus, currentAllergenReactionFlags: $currentAllergenReactionFlags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.baby, baby) || other.baby == baby) &&
            const DeepCollectionEquality().equals(other._allMeals, _allMeals) &&
            const DeepCollectionEquality().equals(
              other._allRecipes,
              _allRecipes,
            ) &&
            const DeepCollectionEquality().equals(
              other._plannedDates,
              _plannedDates,
            ) &&
            const DeepCollectionEquality().equals(
              other._allergenStatuses,
              _allergenStatuses,
            ) &&
            const DeepCollectionEquality().equals(
              other._allergenLogCounts,
              _allergenLogCounts,
            ) &&
            (identical(other.currentAllergenKey, currentAllergenKey) ||
                other.currentAllergenKey == currentAllergenKey) &&
            (identical(other.currentAllergenStatus, currentAllergenStatus) ||
                other.currentAllergenStatus == currentAllergenStatus) &&
            const DeepCollectionEquality().equals(
              other._currentAllergenReactionFlags,
              _currentAllergenReactionFlags,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baby,
    const DeepCollectionEquality().hash(_allMeals),
    const DeepCollectionEquality().hash(_allRecipes),
    const DeepCollectionEquality().hash(_plannedDates),
    const DeepCollectionEquality().hash(_allergenStatuses),
    const DeepCollectionEquality().hash(_allergenLogCounts),
    currentAllergenKey,
    currentAllergenStatus,
    const DeepCollectionEquality().hash(_currentAllergenReactionFlags),
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
    final List<MealPlanEntry> allMeals,
    final Map<String, Recipe> allRecipes,
    final List<DateTime> plannedDates,
    final Map<String, AllergenStatus> allergenStatuses,
    final Map<String, int> allergenLogCounts,
    final String? currentAllergenKey,
    final AllergenStatus currentAllergenStatus,
    final List<bool> currentAllergenReactionFlags,
  }) = _$HomeStateImpl;
  const _HomeState._() : super._();

  @override
  Baby? get baby;
  @override
  List<MealPlanEntry> get allMeals;
  @override
  Map<String, Recipe> get allRecipes;
  @override
  List<DateTime> get plannedDates;
  @override
  Map<String, AllergenStatus> get allergenStatuses;
  @override
  Map<String, int> get allergenLogCounts;
  @override
  String? get currentAllergenKey;
  @override
  AllergenStatus get currentAllergenStatus;
  @override
  List<bool> get currentAllergenReactionFlags;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
