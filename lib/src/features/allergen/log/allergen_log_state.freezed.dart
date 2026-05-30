// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergen_log_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AllergenLogState {
  EmojiTaste? get taste => throw _privateConstructorUsedError;
  bool get hadReaction => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get attachmentTitle => throw _privateConstructorUsedError;
  String? get attachmentDescription => throw _privateConstructorUsedError;
  String? get photoPath => throw _privateConstructorUsedError;

  /// Existing storage path of the photo when editing an existing log. Used
  /// to drive best-effort deletion when the user re-takes the photo.
  String? get existingPhotoPath => throw _privateConstructorUsedError;

  /// When set the controller is in EDIT mode; `null` for CREATE mode.
  String? get logId => throw _privateConstructorUsedError;

  /// Whether existing-log hydration has completed (EDIT mode only). Always
  /// `true` for CREATE mode.
  bool get hydrated => throw _privateConstructorUsedError;

  /// Date the food was given. Defaults to "now" at construction time and
  /// is editable via a date picker.
  DateTime? get logDate => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaved => throw _privateConstructorUsedError;
  bool get photoUploadFailed => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AllergenLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergenLogStateCopyWith<AllergenLogState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergenLogStateCopyWith<$Res> {
  factory $AllergenLogStateCopyWith(
    AllergenLogState value,
    $Res Function(AllergenLogState) then,
  ) = _$AllergenLogStateCopyWithImpl<$Res, AllergenLogState>;
  @useResult
  $Res call({
    EmojiTaste? taste,
    bool hadReaction,
    String? notes,
    String? attachmentTitle,
    String? attachmentDescription,
    String? photoPath,
    String? existingPhotoPath,
    String? logId,
    bool hydrated,
    DateTime? logDate,
    bool isLoading,
    bool isSaved,
    bool photoUploadFailed,
    String? errorMessage,
  });
}

/// @nodoc
class _$AllergenLogStateCopyWithImpl<$Res, $Val extends AllergenLogState>
    implements $AllergenLogStateCopyWith<$Res> {
  _$AllergenLogStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergenLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taste = freezed,
    Object? hadReaction = null,
    Object? notes = freezed,
    Object? attachmentTitle = freezed,
    Object? attachmentDescription = freezed,
    Object? photoPath = freezed,
    Object? existingPhotoPath = freezed,
    Object? logId = freezed,
    Object? hydrated = null,
    Object? logDate = freezed,
    Object? isLoading = null,
    Object? isSaved = null,
    Object? photoUploadFailed = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            taste: freezed == taste
                ? _value.taste
                : taste // ignore: cast_nullable_to_non_nullable
                      as EmojiTaste?,
            hadReaction: null == hadReaction
                ? _value.hadReaction
                : hadReaction // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachmentTitle: freezed == attachmentTitle
                ? _value.attachmentTitle
                : attachmentTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachmentDescription: freezed == attachmentDescription
                ? _value.attachmentDescription
                : attachmentDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoPath: freezed == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            existingPhotoPath: freezed == existingPhotoPath
                ? _value.existingPhotoPath
                : existingPhotoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            logId: freezed == logId
                ? _value.logId
                : logId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hydrated: null == hydrated
                ? _value.hydrated
                : hydrated // ignore: cast_nullable_to_non_nullable
                      as bool,
            logDate: freezed == logDate
                ? _value.logDate
                : logDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSaved: null == isSaved
                ? _value.isSaved
                : isSaved // ignore: cast_nullable_to_non_nullable
                      as bool,
            photoUploadFailed: null == photoUploadFailed
                ? _value.photoUploadFailed
                : photoUploadFailed // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AllergenLogStateImplCopyWith<$Res>
    implements $AllergenLogStateCopyWith<$Res> {
  factory _$$AllergenLogStateImplCopyWith(
    _$AllergenLogStateImpl value,
    $Res Function(_$AllergenLogStateImpl) then,
  ) = __$$AllergenLogStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    EmojiTaste? taste,
    bool hadReaction,
    String? notes,
    String? attachmentTitle,
    String? attachmentDescription,
    String? photoPath,
    String? existingPhotoPath,
    String? logId,
    bool hydrated,
    DateTime? logDate,
    bool isLoading,
    bool isSaved,
    bool photoUploadFailed,
    String? errorMessage,
  });
}

/// @nodoc
class __$$AllergenLogStateImplCopyWithImpl<$Res>
    extends _$AllergenLogStateCopyWithImpl<$Res, _$AllergenLogStateImpl>
    implements _$$AllergenLogStateImplCopyWith<$Res> {
  __$$AllergenLogStateImplCopyWithImpl(
    _$AllergenLogStateImpl _value,
    $Res Function(_$AllergenLogStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergenLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taste = freezed,
    Object? hadReaction = null,
    Object? notes = freezed,
    Object? attachmentTitle = freezed,
    Object? attachmentDescription = freezed,
    Object? photoPath = freezed,
    Object? existingPhotoPath = freezed,
    Object? logId = freezed,
    Object? hydrated = null,
    Object? logDate = freezed,
    Object? isLoading = null,
    Object? isSaved = null,
    Object? photoUploadFailed = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$AllergenLogStateImpl(
        taste: freezed == taste
            ? _value.taste
            : taste // ignore: cast_nullable_to_non_nullable
                  as EmojiTaste?,
        hadReaction: null == hadReaction
            ? _value.hadReaction
            : hadReaction // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachmentTitle: freezed == attachmentTitle
            ? _value.attachmentTitle
            : attachmentTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachmentDescription: freezed == attachmentDescription
            ? _value.attachmentDescription
            : attachmentDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoPath: freezed == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        existingPhotoPath: freezed == existingPhotoPath
            ? _value.existingPhotoPath
            : existingPhotoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        logId: freezed == logId
            ? _value.logId
            : logId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hydrated: null == hydrated
            ? _value.hydrated
            : hydrated // ignore: cast_nullable_to_non_nullable
                  as bool,
        logDate: freezed == logDate
            ? _value.logDate
            : logDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSaved: null == isSaved
            ? _value.isSaved
            : isSaved // ignore: cast_nullable_to_non_nullable
                  as bool,
        photoUploadFailed: null == photoUploadFailed
            ? _value.photoUploadFailed
            : photoUploadFailed // ignore: cast_nullable_to_non_nullable
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

class _$AllergenLogStateImpl implements _AllergenLogState {
  const _$AllergenLogStateImpl({
    this.taste,
    this.hadReaction = false,
    this.notes,
    this.attachmentTitle,
    this.attachmentDescription,
    this.photoPath,
    this.existingPhotoPath,
    this.logId,
    this.hydrated = false,
    this.logDate,
    this.isLoading = false,
    this.isSaved = false,
    this.photoUploadFailed = false,
    this.errorMessage,
  });

  @override
  final EmojiTaste? taste;
  @override
  @JsonKey()
  final bool hadReaction;
  @override
  final String? notes;
  @override
  final String? attachmentTitle;
  @override
  final String? attachmentDescription;
  @override
  final String? photoPath;

  /// Existing storage path of the photo when editing an existing log. Used
  /// to drive best-effort deletion when the user re-takes the photo.
  @override
  final String? existingPhotoPath;

  /// When set the controller is in EDIT mode; `null` for CREATE mode.
  @override
  final String? logId;

  /// Whether existing-log hydration has completed (EDIT mode only). Always
  /// `true` for CREATE mode.
  @override
  @JsonKey()
  final bool hydrated;

  /// Date the food was given. Defaults to "now" at construction time and
  /// is editable via a date picker.
  @override
  final DateTime? logDate;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaved;
  @override
  @JsonKey()
  final bool photoUploadFailed;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AllergenLogState(taste: $taste, hadReaction: $hadReaction, notes: $notes, attachmentTitle: $attachmentTitle, attachmentDescription: $attachmentDescription, photoPath: $photoPath, existingPhotoPath: $existingPhotoPath, logId: $logId, hydrated: $hydrated, logDate: $logDate, isLoading: $isLoading, isSaved: $isSaved, photoUploadFailed: $photoUploadFailed, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergenLogStateImpl &&
            (identical(other.taste, taste) || other.taste == taste) &&
            (identical(other.hadReaction, hadReaction) ||
                other.hadReaction == hadReaction) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.attachmentTitle, attachmentTitle) ||
                other.attachmentTitle == attachmentTitle) &&
            (identical(other.attachmentDescription, attachmentDescription) ||
                other.attachmentDescription == attachmentDescription) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.existingPhotoPath, existingPhotoPath) ||
                other.existingPhotoPath == existingPhotoPath) &&
            (identical(other.logId, logId) || other.logId == logId) &&
            (identical(other.hydrated, hydrated) ||
                other.hydrated == hydrated) &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.photoUploadFailed, photoUploadFailed) ||
                other.photoUploadFailed == photoUploadFailed) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    taste,
    hadReaction,
    notes,
    attachmentTitle,
    attachmentDescription,
    photoPath,
    existingPhotoPath,
    logId,
    hydrated,
    logDate,
    isLoading,
    isSaved,
    photoUploadFailed,
    errorMessage,
  );

  /// Create a copy of AllergenLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergenLogStateImplCopyWith<_$AllergenLogStateImpl> get copyWith =>
      __$$AllergenLogStateImplCopyWithImpl<_$AllergenLogStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AllergenLogState implements AllergenLogState {
  const factory _AllergenLogState({
    final EmojiTaste? taste,
    final bool hadReaction,
    final String? notes,
    final String? attachmentTitle,
    final String? attachmentDescription,
    final String? photoPath,
    final String? existingPhotoPath,
    final String? logId,
    final bool hydrated,
    final DateTime? logDate,
    final bool isLoading,
    final bool isSaved,
    final bool photoUploadFailed,
    final String? errorMessage,
  }) = _$AllergenLogStateImpl;

  @override
  EmojiTaste? get taste;
  @override
  bool get hadReaction;
  @override
  String? get notes;
  @override
  String? get attachmentTitle;
  @override
  String? get attachmentDescription;
  @override
  String? get photoPath;

  /// Existing storage path of the photo when editing an existing log. Used
  /// to drive best-effort deletion when the user re-takes the photo.
  @override
  String? get existingPhotoPath;

  /// When set the controller is in EDIT mode; `null` for CREATE mode.
  @override
  String? get logId;

  /// Whether existing-log hydration has completed (EDIT mode only). Always
  /// `true` for CREATE mode.
  @override
  bool get hydrated;

  /// Date the food was given. Defaults to "now" at construction time and
  /// is editable via a date picker.
  @override
  DateTime? get logDate;
  @override
  bool get isLoading;
  @override
  bool get isSaved;
  @override
  bool get photoUploadFailed;
  @override
  String? get errorMessage;

  /// Create a copy of AllergenLogState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergenLogStateImplCopyWith<_$AllergenLogStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
