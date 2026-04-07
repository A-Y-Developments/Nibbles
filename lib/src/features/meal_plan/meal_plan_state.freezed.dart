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
  DateTime get selectedDate => throw _privateConstructorUsedError;
  bool get calendarExpanded => throw _privateConstructorUsedError;
  Map<String, Recipe> get recipes => throw _privateConstructorUsedError;
  Set<String> get flaggedAllergenKeys => throw _privateConstructorUsedError;
  AllergenBoardItem? get currentAllergenBoardItem =>
      throw _privateConstructorUsedError;
  AllergenProgramState? get programState => throw _privateConstructorUsedError;

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
    DateTime selectedDate,
    bool calendarExpanded,
    Map<String, Recipe> recipes,
    Set<String> flaggedAllergenKeys,
    AllergenBoardItem? currentAllergenBoardItem,
    AllergenProgramState? programState,
  });

  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem;
  $AllergenProgramStateCopyWith<$Res>? get programState;
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
    Object? selectedDate = null,
    Object? calendarExpanded = null,
    Object? recipes = null,
    Object? flaggedAllergenKeys = null,
    Object? currentAllergenBoardItem = freezed,
    Object? programState = freezed,
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
            selectedDate: null == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            calendarExpanded: null == calendarExpanded
                ? _value.calendarExpanded
                : calendarExpanded // ignore: cast_nullable_to_non_nullable
                      as bool,
            recipes: null == recipes
                ? _value.recipes
                : recipes // ignore: cast_nullable_to_non_nullable
                      as Map<String, Recipe>,
            flaggedAllergenKeys: null == flaggedAllergenKeys
                ? _value.flaggedAllergenKeys
                : flaggedAllergenKeys // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            currentAllergenBoardItem: freezed == currentAllergenBoardItem
                ? _value.currentAllergenBoardItem
                : currentAllergenBoardItem // ignore: cast_nullable_to_non_nullable
                      as AllergenBoardItem?,
            programState: freezed == programState
                ? _value.programState
                : programState // ignore: cast_nullable_to_non_nullable
                      as AllergenProgramState?,
          )
          as $Val,
    );
  }

  /// Create a copy of MealPlanState
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

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllergenProgramStateCopyWith<$Res>? get programState {
    if (_value.programState == null) {
      return null;
    }

    return $AllergenProgramStateCopyWith<$Res>(_value.programState!, (value) {
      return _then(_value.copyWith(programState: value) as $Val);
    });
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
    DateTime selectedDate,
    bool calendarExpanded,
    Map<String, Recipe> recipes,
    Set<String> flaggedAllergenKeys,
    AllergenBoardItem? currentAllergenBoardItem,
    AllergenProgramState? programState,
  });

  @override
  $AllergenBoardItemCopyWith<$Res>? get currentAllergenBoardItem;
  @override
  $AllergenProgramStateCopyWith<$Res>? get programState;
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
    Object? selectedDate = null,
    Object? calendarExpanded = null,
    Object? recipes = null,
    Object? flaggedAllergenKeys = null,
    Object? currentAllergenBoardItem = freezed,
    Object? programState = freezed,
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
        selectedDate: null == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        calendarExpanded: null == calendarExpanded
            ? _value.calendarExpanded
            : calendarExpanded // ignore: cast_nullable_to_non_nullable
                  as bool,
        recipes: null == recipes
            ? _value._recipes
            : recipes // ignore: cast_nullable_to_non_nullable
                  as Map<String, Recipe>,
        flaggedAllergenKeys: null == flaggedAllergenKeys
            ? _value._flaggedAllergenKeys
            : flaggedAllergenKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        currentAllergenBoardItem: freezed == currentAllergenBoardItem
            ? _value.currentAllergenBoardItem
            : currentAllergenBoardItem // ignore: cast_nullable_to_non_nullable
                  as AllergenBoardItem?,
        programState: freezed == programState
            ? _value.programState
            : programState // ignore: cast_nullable_to_non_nullable
                  as AllergenProgramState?,
      ),
    );
  }
}

/// @nodoc

class _$MealPlanStateImpl implements _MealPlanState {
  const _$MealPlanStateImpl({
    required final List<MealPlanEntry> meals,
    required this.weekStart,
    required this.selectedDate,
    this.calendarExpanded = false,
    final Map<String, Recipe> recipes = const <String, Recipe>{},
    final Set<String> flaggedAllergenKeys = const <String>{},
    this.currentAllergenBoardItem,
    this.programState,
  }) : _meals = meals,
       _recipes = recipes,
       _flaggedAllergenKeys = flaggedAllergenKeys;

  final List<MealPlanEntry> _meals;
  @override
  List<MealPlanEntry> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  final DateTime weekStart;
  @override
  final DateTime selectedDate;
  @override
  @JsonKey()
  final bool calendarExpanded;
  final Map<String, Recipe> _recipes;
  @override
  @JsonKey()
  Map<String, Recipe> get recipes {
    if (_recipes is EqualUnmodifiableMapView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recipes);
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
  final AllergenBoardItem? currentAllergenBoardItem;
  @override
  final AllergenProgramState? programState;

  @override
  String toString() {
    return 'MealPlanState(meals: $meals, weekStart: $weekStart, selectedDate: $selectedDate, calendarExpanded: $calendarExpanded, recipes: $recipes, flaggedAllergenKeys: $flaggedAllergenKeys, currentAllergenBoardItem: $currentAllergenBoardItem, programState: $programState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealPlanStateImpl &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.calendarExpanded, calendarExpanded) ||
                other.calendarExpanded == calendarExpanded) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes) &&
            const DeepCollectionEquality().equals(
              other._flaggedAllergenKeys,
              _flaggedAllergenKeys,
            ) &&
            (identical(
                  other.currentAllergenBoardItem,
                  currentAllergenBoardItem,
                ) ||
                other.currentAllergenBoardItem == currentAllergenBoardItem) &&
            (identical(other.programState, programState) ||
                other.programState == programState));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_meals),
    weekStart,
    selectedDate,
    calendarExpanded,
    const DeepCollectionEquality().hash(_recipes),
    const DeepCollectionEquality().hash(_flaggedAllergenKeys),
    currentAllergenBoardItem,
    programState,
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
    required final DateTime selectedDate,
    final bool calendarExpanded,
    final Map<String, Recipe> recipes,
    final Set<String> flaggedAllergenKeys,
    final AllergenBoardItem? currentAllergenBoardItem,
    final AllergenProgramState? programState,
  }) = _$MealPlanStateImpl;

  @override
  List<MealPlanEntry> get meals;
  @override
  DateTime get weekStart;
  @override
  DateTime get selectedDate;
  @override
  bool get calendarExpanded;
  @override
  Map<String, Recipe> get recipes;
  @override
  Set<String> get flaggedAllergenKeys;
  @override
  AllergenBoardItem? get currentAllergenBoardItem;
  @override
  AllergenProgramState? get programState;

  /// Create a copy of MealPlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealPlanStateImplCopyWith<_$MealPlanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
