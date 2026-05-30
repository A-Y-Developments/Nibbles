// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_meals_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MapMealsArgs {
  List<Recipe> get pickedRecipes => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Create a copy of MapMealsArgs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapMealsArgsCopyWith<MapMealsArgs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapMealsArgsCopyWith<$Res> {
  factory $MapMealsArgsCopyWith(
    MapMealsArgs value,
    $Res Function(MapMealsArgs) then,
  ) = _$MapMealsArgsCopyWithImpl<$Res, MapMealsArgs>;
  @useResult
  $Res call({List<Recipe> pickedRecipes, DateTime startDate, DateTime endDate});
}

/// @nodoc
class _$MapMealsArgsCopyWithImpl<$Res, $Val extends MapMealsArgs>
    implements $MapMealsArgsCopyWith<$Res> {
  _$MapMealsArgsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapMealsArgs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickedRecipes = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _value.copyWith(
            pickedRecipes: null == pickedRecipes
                ? _value.pickedRecipes
                : pickedRecipes // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MapMealsArgsImplCopyWith<$Res>
    implements $MapMealsArgsCopyWith<$Res> {
  factory _$$MapMealsArgsImplCopyWith(
    _$MapMealsArgsImpl value,
    $Res Function(_$MapMealsArgsImpl) then,
  ) = __$$MapMealsArgsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Recipe> pickedRecipes, DateTime startDate, DateTime endDate});
}

/// @nodoc
class __$$MapMealsArgsImplCopyWithImpl<$Res>
    extends _$MapMealsArgsCopyWithImpl<$Res, _$MapMealsArgsImpl>
    implements _$$MapMealsArgsImplCopyWith<$Res> {
  __$$MapMealsArgsImplCopyWithImpl(
    _$MapMealsArgsImpl _value,
    $Res Function(_$MapMealsArgsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MapMealsArgs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickedRecipes = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _$MapMealsArgsImpl(
        pickedRecipes: null == pickedRecipes
            ? _value._pickedRecipes
            : pickedRecipes // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$MapMealsArgsImpl implements _MapMealsArgs {
  const _$MapMealsArgsImpl({
    required final List<Recipe> pickedRecipes,
    required this.startDate,
    required this.endDate,
  }) : _pickedRecipes = pickedRecipes;

  final List<Recipe> _pickedRecipes;
  @override
  List<Recipe> get pickedRecipes {
    if (_pickedRecipes is EqualUnmodifiableListView) return _pickedRecipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pickedRecipes);
  }

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'MapMealsArgs(pickedRecipes: $pickedRecipes, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapMealsArgsImpl &&
            const DeepCollectionEquality().equals(
              other._pickedRecipes,
              _pickedRecipes,
            ) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_pickedRecipes),
    startDate,
    endDate,
  );

  /// Create a copy of MapMealsArgs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapMealsArgsImplCopyWith<_$MapMealsArgsImpl> get copyWith =>
      __$$MapMealsArgsImplCopyWithImpl<_$MapMealsArgsImpl>(this, _$identity);
}

abstract class _MapMealsArgs implements MapMealsArgs {
  const factory _MapMealsArgs({
    required final List<Recipe> pickedRecipes,
    required final DateTime startDate,
    required final DateTime endDate,
  }) = _$MapMealsArgsImpl;

  @override
  List<Recipe> get pickedRecipes;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of MapMealsArgs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapMealsArgsImplCopyWith<_$MapMealsArgsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MapMealsState {
  List<Recipe> get pickedRecipes => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  DateTime get selectedDay => throw _privateConstructorUsedError;
  Map<String, DateTime> get assignments => throw _privateConstructorUsedError;
  bool get isCommitting => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of MapMealsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapMealsStateCopyWith<MapMealsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapMealsStateCopyWith<$Res> {
  factory $MapMealsStateCopyWith(
    MapMealsState value,
    $Res Function(MapMealsState) then,
  ) = _$MapMealsStateCopyWithImpl<$Res, MapMealsState>;
  @useResult
  $Res call({
    List<Recipe> pickedRecipes,
    DateTime startDate,
    DateTime endDate,
    DateTime selectedDay,
    Map<String, DateTime> assignments,
    bool isCommitting,
    String? errorMessage,
  });
}

/// @nodoc
class _$MapMealsStateCopyWithImpl<$Res, $Val extends MapMealsState>
    implements $MapMealsStateCopyWith<$Res> {
  _$MapMealsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapMealsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickedRecipes = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? selectedDay = null,
    Object? assignments = null,
    Object? isCommitting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            pickedRecipes: null == pickedRecipes
                ? _value.pickedRecipes
                : pickedRecipes // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            selectedDay: null == selectedDay
                ? _value.selectedDay
                : selectedDay // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            assignments: null == assignments
                ? _value.assignments
                : assignments // ignore: cast_nullable_to_non_nullable
                      as Map<String, DateTime>,
            isCommitting: null == isCommitting
                ? _value.isCommitting
                : isCommitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MapMealsStateImplCopyWith<$Res>
    implements $MapMealsStateCopyWith<$Res> {
  factory _$$MapMealsStateImplCopyWith(
    _$MapMealsStateImpl value,
    $Res Function(_$MapMealsStateImpl) then,
  ) = __$$MapMealsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Recipe> pickedRecipes,
    DateTime startDate,
    DateTime endDate,
    DateTime selectedDay,
    Map<String, DateTime> assignments,
    bool isCommitting,
    String? errorMessage,
  });
}

/// @nodoc
class __$$MapMealsStateImplCopyWithImpl<$Res>
    extends _$MapMealsStateCopyWithImpl<$Res, _$MapMealsStateImpl>
    implements _$$MapMealsStateImplCopyWith<$Res> {
  __$$MapMealsStateImplCopyWithImpl(
    _$MapMealsStateImpl _value,
    $Res Function(_$MapMealsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MapMealsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickedRecipes = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? selectedDay = null,
    Object? assignments = null,
    Object? isCommitting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$MapMealsStateImpl(
        pickedRecipes: null == pickedRecipes
            ? _value._pickedRecipes
            : pickedRecipes // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        selectedDay: null == selectedDay
            ? _value.selectedDay
            : selectedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        assignments: null == assignments
            ? _value._assignments
            : assignments // ignore: cast_nullable_to_non_nullable
                  as Map<String, DateTime>,
        isCommitting: null == isCommitting
            ? _value.isCommitting
            : isCommitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MapMealsStateImpl extends _MapMealsState {
  const _$MapMealsStateImpl({
    required final List<Recipe> pickedRecipes,
    required this.startDate,
    required this.endDate,
    required this.selectedDay,
    final Map<String, DateTime> assignments = const <String, DateTime>{},
    this.isCommitting = false,
    this.errorMessage,
  }) : _pickedRecipes = pickedRecipes,
       _assignments = assignments,
       super._();

  final List<Recipe> _pickedRecipes;
  @override
  List<Recipe> get pickedRecipes {
    if (_pickedRecipes is EqualUnmodifiableListView) return _pickedRecipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pickedRecipes);
  }

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final DateTime selectedDay;
  final Map<String, DateTime> _assignments;
  @override
  @JsonKey()
  Map<String, DateTime> get assignments {
    if (_assignments is EqualUnmodifiableMapView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_assignments);
  }

  @override
  @JsonKey()
  final bool isCommitting;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'MapMealsState(pickedRecipes: $pickedRecipes, startDate: $startDate, endDate: $endDate, selectedDay: $selectedDay, assignments: $assignments, isCommitting: $isCommitting, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapMealsStateImpl &&
            const DeepCollectionEquality().equals(
              other._pickedRecipes,
              _pickedRecipes,
            ) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.selectedDay, selectedDay) ||
                other.selectedDay == selectedDay) &&
            const DeepCollectionEquality().equals(
              other._assignments,
              _assignments,
            ) &&
            (identical(other.isCommitting, isCommitting) ||
                other.isCommitting == isCommitting) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_pickedRecipes),
    startDate,
    endDate,
    selectedDay,
    const DeepCollectionEquality().hash(_assignments),
    isCommitting,
    errorMessage,
  );

  /// Create a copy of MapMealsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapMealsStateImplCopyWith<_$MapMealsStateImpl> get copyWith =>
      __$$MapMealsStateImplCopyWithImpl<_$MapMealsStateImpl>(this, _$identity);
}

abstract class _MapMealsState extends MapMealsState {
  const factory _MapMealsState({
    required final List<Recipe> pickedRecipes,
    required final DateTime startDate,
    required final DateTime endDate,
    required final DateTime selectedDay,
    final Map<String, DateTime> assignments,
    final bool isCommitting,
    final String? errorMessage,
  }) = _$MapMealsStateImpl;
  const _MapMealsState._() : super._();

  @override
  List<Recipe> get pickedRecipes;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  DateTime get selectedDay;
  @override
  Map<String, DateTime> get assignments;
  @override
  bool get isCommitting;
  @override
  String? get errorMessage;

  /// Create a copy of MapMealsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapMealsStateImplCopyWith<_$MapMealsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
