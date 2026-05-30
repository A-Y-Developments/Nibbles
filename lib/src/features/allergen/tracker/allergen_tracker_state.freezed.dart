// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_tracker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenTrackerState {
  /// All 9 canonical allergens ordered by `sequenceOrder` (display order).
  List<Allergen> get allergens => throw _privateConstructorUsedError;

  /// `kAllergenKeys` → derived [AllergenStatus]. Guaranteed to contain
  /// every canonical key.
  Map<String, AllergenStatus> get statuses =>
      throw _privateConstructorUsedError;

  /// All logs for the baby, sorted oldest → newest by `createdAt`.
  /// Used to render the per-card 0/3 progress and the Reaction Log list.
  List<AllergenLog> get logs => throw _privateConstructorUsedError;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenTrackerStateCopyWith<AllergenTrackerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenTrackerStateCopyWith<$Res> {
  factory $AllergenTrackerStateCopyWith(
    AllergenTrackerState value,
    $Res Function(AllergenTrackerState) then,
  ) = _$AllergenTrackerStateCopyWithImpl<$Res, AllergenTrackerState>;
  @useResult
  $Res call({
    List<Allergen> allergens,
    Map<String, AllergenStatus> statuses,
    List<AllergenLog> logs,
  });
}

/// @nodoc
class _$AllergenTrackerStateCopyWithImpl<
  $Res,
  $Val extends AllergenTrackerState
>
    implements $AllergenTrackerStateCopyWith<$Res> {
  _$AllergenTrackerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergens = null,
    Object? statuses = null,
    Object? logs = null,
  }) {
    return _then(
      _value.copyWith(
            allergens: null == allergens
                ? _value.allergens
                : allergens // ignore: cast_nullable_to_non_nullable
                      as List<Allergen>,
            statuses: null == statuses
                ? _value.statuses
                : statuses // ignore: cast_nullable_to_non_nullable
                      as Map<String, AllergenStatus>,
            logs: null == logs
                ? _value.logs
                : logs // ignore: cast_nullable_to_non_nullable
                      as List<AllergenLog>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllergenTrackerStateImplCopyWith<$Res>
    implements $AllergenTrackerStateCopyWith<$Res> {
  factory _$$AllergenTrackerStateImplCopyWith(
    _$AllergenTrackerStateImpl value,
    $Res Function(_$AllergenTrackerStateImpl) then,
  ) = __$$AllergenTrackerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Allergen> allergens,
    Map<String, AllergenStatus> statuses,
    List<AllergenLog> logs,
  });
}

/// @nodoc
class __$$AllergenTrackerStateImplCopyWithImpl<$Res>
    extends _$AllergenTrackerStateCopyWithImpl<$Res, _$AllergenTrackerStateImpl>
    implements _$$AllergenTrackerStateImplCopyWith<$Res> {
  __$$AllergenTrackerStateImplCopyWithImpl(
    _$AllergenTrackerStateImpl _value,
    $Res Function(_$AllergenTrackerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergens = null,
    Object? statuses = null,
    Object? logs = null,
  }) {
    return _then(
      _$AllergenTrackerStateImpl(
        allergens: null == allergens
            ? _value._allergens
            : allergens // ignore: cast_nullable_to_non_nullable
                  as List<Allergen>,
        statuses: null == statuses
            ? _value._statuses
            : statuses // ignore: cast_nullable_to_non_nullable
                  as Map<String, AllergenStatus>,
        logs: null == logs
            ? _value._logs
            : logs // ignore: cast_nullable_to_non_nullable
                  as List<AllergenLog>,
      ),
    );
  }
}

/// @nodoc

class _$AllergenTrackerStateImpl implements _AllergenTrackerState {
  const _$AllergenTrackerStateImpl({
    required final List<Allergen> allergens,
    required final Map<String, AllergenStatus> statuses,
    required final List<AllergenLog> logs,
  }) : _allergens = allergens,
       _statuses = statuses,
       _logs = logs;

  /// All 9 canonical allergens ordered by `sequenceOrder` (display order).
  final List<Allergen> _allergens;

  /// All 9 canonical allergens ordered by `sequenceOrder` (display order).
  @override
  List<Allergen> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  /// `kAllergenKeys` → derived [AllergenStatus]. Guaranteed to contain
  /// every canonical key.
  final Map<String, AllergenStatus> _statuses;

  /// `kAllergenKeys` → derived [AllergenStatus]. Guaranteed to contain
  /// every canonical key.
  @override
  Map<String, AllergenStatus> get statuses {
    if (_statuses is EqualUnmodifiableMapView) return _statuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statuses);
  }

  /// All logs for the baby, sorted oldest → newest by `createdAt`.
  /// Used to render the per-card 0/3 progress and the Reaction Log list.
  final List<AllergenLog> _logs;

  /// All logs for the baby, sorted oldest → newest by `createdAt`.
  /// Used to render the per-card 0/3 progress and the Reaction Log list.
  @override
  List<AllergenLog> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  @override
  String toString() {
    return 'AllergenTrackerState(allergens: $allergens, statuses: $statuses, logs: $logs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenTrackerStateImpl &&
            const DeepCollectionEquality().equals(
              other._allergens,
              _allergens,
            ) &&
            const DeepCollectionEquality().equals(other._statuses, _statuses) &&
            const DeepCollectionEquality().equals(other._logs, _logs));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_allergens),
    const DeepCollectionEquality().hash(_statuses),
    const DeepCollectionEquality().hash(_logs),
  );

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenTrackerStateImplCopyWith<_$AllergenTrackerStateImpl>
  get copyWith =>
      __$$AllergenTrackerStateImplCopyWithImpl<_$AllergenTrackerStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenTrackerState implements AllergenTrackerState {
  const factory _AllergenTrackerState({
    required final List<Allergen> allergens,
    required final Map<String, AllergenStatus> statuses,
    required final List<AllergenLog> logs,
  }) = _$AllergenTrackerStateImpl;

  /// All 9 canonical allergens ordered by `sequenceOrder` (display order).
  @override
  List<Allergen> get allergens;

  /// `kAllergenKeys` → derived [AllergenStatus]. Guaranteed to contain
  /// every canonical key.
  @override
  Map<String, AllergenStatus> get statuses;

  /// All logs for the baby, sorted oldest → newest by `createdAt`.
  /// Used to render the per-card 0/3 progress and the Reaction Log list.
  @override
  List<AllergenLog> get logs;

  /// Create a copy of AllergenTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenTrackerStateImplCopyWith<_$AllergenTrackerStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
