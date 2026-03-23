// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_plan_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MealPlanEntry {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get recipeId => throw _privateConstructorUsedError;
  DateTime get planDate => throw _privateConstructorUsedError;

  /// Optional meal time stored as "HH:mm".
  String? get mealTime => throw _privateConstructorUsedError;

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealPlanEntryCopyWith<MealPlanEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealPlanEntryCopyWith<$Res> {
  factory $MealPlanEntryCopyWith(
    MealPlanEntry value,
    $Res Function(MealPlanEntry) then,
  ) = _$MealPlanEntryCopyWithImpl<$Res, MealPlanEntry>;
  @useResult
  $Res call({
    String id,
    String babyId,
    String recipeId,
    DateTime planDate,
    String? mealTime,
  });
}

/// @nodoc
class _$MealPlanEntryCopyWithImpl<$Res, $Val extends MealPlanEntry>
    implements $MealPlanEntryCopyWith<$Res> {
  _$MealPlanEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? recipeId = null,
    Object? planDate = null,
    Object? mealTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            babyId: null == babyId
                ? _value.babyId
                : babyId // ignore: cast_nullable_to_non_nullable
                      as String,
            recipeId: null == recipeId
                ? _value.recipeId
                : recipeId // ignore: cast_nullable_to_non_nullable
                      as String,
            planDate: null == planDate
                ? _value.planDate
                : planDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            mealTime: freezed == mealTime
                ? _value.mealTime
                : mealTime // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealPlanEntryImplCopyWith<$Res>
    implements $MealPlanEntryCopyWith<$Res> {
  factory _$$MealPlanEntryImplCopyWith(
    _$MealPlanEntryImpl value,
    $Res Function(_$MealPlanEntryImpl) then,
  ) = __$$MealPlanEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String babyId,
    String recipeId,
    DateTime planDate,
    String? mealTime,
  });
}

/// @nodoc
class __$$MealPlanEntryImplCopyWithImpl<$Res>
    extends _$MealPlanEntryCopyWithImpl<$Res, _$MealPlanEntryImpl>
    implements _$$MealPlanEntryImplCopyWith<$Res> {
  __$$MealPlanEntryImplCopyWithImpl(
    _$MealPlanEntryImpl _value,
    $Res Function(_$MealPlanEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? recipeId = null,
    Object? planDate = null,
    Object? mealTime = freezed,
  }) {
    return _then(
      _$MealPlanEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        recipeId: null == recipeId
            ? _value.recipeId
            : recipeId // ignore: cast_nullable_to_non_nullable
                  as String,
        planDate: null == planDate
            ? _value.planDate
            : planDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        mealTime: freezed == mealTime
            ? _value.mealTime
            : mealTime // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MealPlanEntryImpl implements _MealPlanEntry {
  const _$MealPlanEntryImpl({
    required this.id,
    required this.babyId,
    required this.recipeId,
    required this.planDate,
    this.mealTime,
  });

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String recipeId;
  @override
  final DateTime planDate;

  /// Optional meal time stored as "HH:mm".
  @override
  final String? mealTime;

  @override
  String toString() {
    return 'MealPlanEntry(id: $id, babyId: $babyId, recipeId: $recipeId, planDate: $planDate, mealTime: $mealTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealPlanEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.recipeId, recipeId) ||
                other.recipeId == recipeId) &&
            (identical(other.planDate, planDate) ||
                other.planDate == planDate) &&
            (identical(other.mealTime, mealTime) ||
                other.mealTime == mealTime));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, babyId, recipeId, planDate, mealTime);

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealPlanEntryImplCopyWith<_$MealPlanEntryImpl> get copyWith =>
      __$$MealPlanEntryImplCopyWithImpl<_$MealPlanEntryImpl>(this, _$identity);
}

abstract class _MealPlanEntry implements MealPlanEntry {
  const factory _MealPlanEntry({
    required final String id,
    required final String babyId,
    required final String recipeId,
    required final DateTime planDate,
    final String? mealTime,
  }) = _$MealPlanEntryImpl;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get recipeId;
  @override
  DateTime get planDate;

  /// Optional meal time stored as "HH:mm".
  @override
  String? get mealTime;

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealPlanEntryImplCopyWith<_$MealPlanEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
