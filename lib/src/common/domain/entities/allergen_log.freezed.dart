// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenLog {
  String get id => throw _privateConstructorUsedError;
  String get babyId => throw _privateConstructorUsedError;
  String get allergenKey => throw _privateConstructorUsedError;
  EmojiTaste get emojiTaste => throw _privateConstructorUsedError;
  bool get hadReaction => throw _privateConstructorUsedError;
  DateTime get logDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AllergenLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenLogCopyWith<AllergenLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenLogCopyWith<$Res> {
  factory $AllergenLogCopyWith(
    AllergenLog value,
    $Res Function(AllergenLog) then,
  ) = _$AllergenLogCopyWithImpl<$Res, AllergenLog>;
  @useResult
  $Res call({
    String id,
    String babyId,
    String allergenKey,
    EmojiTaste emojiTaste,
    bool hadReaction,
    DateTime logDate,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AllergenLogCopyWithImpl<$Res, $Val extends AllergenLog>
    implements $AllergenLogCopyWith<$Res> {
  _$AllergenLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? allergenKey = null,
    Object? emojiTaste = null,
    Object? hadReaction = null,
    Object? logDate = null,
    Object? createdAt = null,
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
            allergenKey: null == allergenKey
                ? _value.allergenKey
                : allergenKey // ignore: cast_nullable_to_non_nullable
                      as String,
            emojiTaste: null == emojiTaste
                ? _value.emojiTaste
                : emojiTaste // ignore: cast_nullable_to_non_nullable
                      as EmojiTaste,
            hadReaction: null == hadReaction
                ? _value.hadReaction
                : hadReaction // ignore: cast_nullable_to_non_nullable
                      as bool,
            logDate: null == logDate
                ? _value.logDate
                : logDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllergenLogImplCopyWith<$Res>
    implements $AllergenLogCopyWith<$Res> {
  factory _$$AllergenLogImplCopyWith(
    _$AllergenLogImpl value,
    $Res Function(_$AllergenLogImpl) then,
  ) = __$$AllergenLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String babyId,
    String allergenKey,
    EmojiTaste emojiTaste,
    bool hadReaction,
    DateTime logDate,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AllergenLogImplCopyWithImpl<$Res>
    extends _$AllergenLogCopyWithImpl<$Res, _$AllergenLogImpl>
    implements _$$AllergenLogImplCopyWith<$Res> {
  __$$AllergenLogImplCopyWithImpl(
    _$AllergenLogImpl _value,
    $Res Function(_$AllergenLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? babyId = null,
    Object? allergenKey = null,
    Object? emojiTaste = null,
    Object? hadReaction = null,
    Object? logDate = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AllergenLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        babyId: null == babyId
            ? _value.babyId
            : babyId // ignore: cast_nullable_to_non_nullable
                  as String,
        allergenKey: null == allergenKey
            ? _value.allergenKey
            : allergenKey // ignore: cast_nullable_to_non_nullable
                  as String,
        emojiTaste: null == emojiTaste
            ? _value.emojiTaste
            : emojiTaste // ignore: cast_nullable_to_non_nullable
                  as EmojiTaste,
        hadReaction: null == hadReaction
            ? _value.hadReaction
            : hadReaction // ignore: cast_nullable_to_non_nullable
                  as bool,
        logDate: null == logDate
            ? _value.logDate
            : logDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AllergenLogImpl implements _AllergenLog {
  const _$AllergenLogImpl({
    required this.id,
    required this.babyId,
    required this.allergenKey,
    required this.emojiTaste,
    required this.hadReaction,
    required this.logDate,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String babyId;
  @override
  final String allergenKey;
  @override
  final EmojiTaste emojiTaste;
  @override
  final bool hadReaction;
  @override
  final DateTime logDate;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AllergenLog(id: $id, babyId: $babyId, allergenKey: $allergenKey, emojiTaste: $emojiTaste, hadReaction: $hadReaction, logDate: $logDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.babyId, babyId) || other.babyId == babyId) &&
            (identical(other.allergenKey, allergenKey) ||
                other.allergenKey == allergenKey) &&
            (identical(other.emojiTaste, emojiTaste) ||
                other.emojiTaste == emojiTaste) &&
            (identical(other.hadReaction, hadReaction) ||
                other.hadReaction == hadReaction) &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    babyId,
    allergenKey,
    emojiTaste,
    hadReaction,
    logDate,
    createdAt,
  );

  /// Create a copy of AllergenLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenLogImplCopyWith<_$AllergenLogImpl> get copyWith =>
      __$$AllergenLogImplCopyWithImpl<_$AllergenLogImpl>(this, _$identity);
}

abstract class _AllergenLog implements AllergenLog {
  const factory _AllergenLog({
    required final String id,
    required final String babyId,
    required final String allergenKey,
    required final EmojiTaste emojiTaste,
    required final bool hadReaction,
    required final DateTime logDate,
    required final DateTime createdAt,
  }) = _$AllergenLogImpl;

  @override
  String get id;
  @override
  String get babyId;
  @override
  String get allergenKey;
  @override
  EmojiTaste get emojiTaste;
  @override
  bool get hadReaction;
  @override
  DateTime get logDate;
  @override
  DateTime get createdAt;

  /// Create a copy of AllergenLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenLogImplCopyWith<_$AllergenLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
