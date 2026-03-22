// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReactionDetail {
  String get id => throw _privateConstructorUsedError;
  String get logId => throw _privateConstructorUsedError;
  ReactionSeverity get severity => throw _privateConstructorUsedError;
  List<String> get symptoms => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Create a copy of ReactionDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReactionDetailCopyWith<ReactionDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReactionDetailCopyWith<$Res> {
  factory $ReactionDetailCopyWith(
    ReactionDetail value,
    $Res Function(ReactionDetail) then,
  ) = _$ReactionDetailCopyWithImpl<$Res, ReactionDetail>;
  @useResult
  $Res call({
    String id,
    String logId,
    ReactionSeverity severity,
    List<String> symptoms,
    DateTime createdAt,
    String? notes,
  });
}

/// @nodoc
class _$ReactionDetailCopyWithImpl<$Res, $Val extends ReactionDetail>
    implements $ReactionDetailCopyWith<$Res> {
  _$ReactionDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReactionDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? logId = null,
    Object? severity = null,
    Object? symptoms = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            logId: null == logId
                ? _value.logId
                : logId // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as ReactionSeverity,
            symptoms: null == symptoms
                ? _value.symptoms
                : symptoms // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReactionDetailImplCopyWith<$Res>
    implements $ReactionDetailCopyWith<$Res> {
  factory _$$ReactionDetailImplCopyWith(
    _$ReactionDetailImpl value,
    $Res Function(_$ReactionDetailImpl) then,
  ) = __$$ReactionDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String logId,
    ReactionSeverity severity,
    List<String> symptoms,
    DateTime createdAt,
    String? notes,
  });
}

/// @nodoc
class __$$ReactionDetailImplCopyWithImpl<$Res>
    extends _$ReactionDetailCopyWithImpl<$Res, _$ReactionDetailImpl>
    implements _$$ReactionDetailImplCopyWith<$Res> {
  __$$ReactionDetailImplCopyWithImpl(
    _$ReactionDetailImpl _value,
    $Res Function(_$ReactionDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReactionDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? logId = null,
    Object? severity = null,
    Object? symptoms = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$ReactionDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        logId: null == logId
            ? _value.logId
            : logId // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as ReactionSeverity,
        symptoms: null == symptoms
            ? _value._symptoms
            : symptoms // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ReactionDetailImpl implements _ReactionDetail {
  const _$ReactionDetailImpl({
    required this.id,
    required this.logId,
    required this.severity,
    required final List<String> symptoms,
    required this.createdAt,
    this.notes,
  }) : _symptoms = symptoms;

  @override
  final String id;
  @override
  final String logId;
  @override
  final ReactionSeverity severity;
  final List<String> _symptoms;
  @override
  List<String> get symptoms {
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symptoms);
  }

  @override
  final DateTime createdAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ReactionDetail(id: $id, logId: $logId, severity: $severity, symptoms: $symptoms, createdAt: $createdAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReactionDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.logId, logId) || other.logId == logId) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    logId,
    severity,
    const DeepCollectionEquality().hash(_symptoms),
    createdAt,
    notes,
  );

  /// Create a copy of ReactionDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReactionDetailImplCopyWith<_$ReactionDetailImpl> get copyWith =>
      __$$ReactionDetailImplCopyWithImpl<_$ReactionDetailImpl>(
        this,
        _$identity,
      );
}

abstract class _ReactionDetail implements ReactionDetail {
  const factory _ReactionDetail({
    required final String id,
    required final String logId,
    required final ReactionSeverity severity,
    required final List<String> symptoms,
    required final DateTime createdAt,
    final String? notes,
  }) = _$ReactionDetailImpl;

  @override
  String get id;
  @override
  String get logId;
  @override
  ReactionSeverity get severity;
  @override
  List<String> get symptoms;
  @override
  DateTime get createdAt;
  @override
  String? get notes;

  /// Create a copy of ReactionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReactionDetailImplCopyWith<_$ReactionDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
