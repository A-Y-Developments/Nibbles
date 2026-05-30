// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecipeLibraryState {
  Map<String, List<Recipe>> get recipesByCategory =>
      throw _privateConstructorUsedError;
  String? get ongoingAllergenKey => throw _privateConstructorUsedError;
  Set<String> get flaggedAllergenKeys => throw _privateConstructorUsedError;
  bool get isStartingGuideSeen => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeLibraryStateCopyWith<RecipeLibraryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeLibraryStateCopyWith<$Res> {
  factory $RecipeLibraryStateCopyWith(
    RecipeLibraryState value,
    $Res Function(RecipeLibraryState) then,
  ) = _$RecipeLibraryStateCopyWithImpl<$Res, RecipeLibraryState>;
  @useResult
  $Res call({
    Map<String, List<Recipe>> recipesByCategory,
    String? ongoingAllergenKey,
    Set<String> flaggedAllergenKeys,
    bool isStartingGuideSeen,
    String searchQuery,
  });
}

/// @nodoc
class _$RecipeLibraryStateCopyWithImpl<$Res, $Val extends RecipeLibraryState>
    implements $RecipeLibraryStateCopyWith<$Res> {
  _$RecipeLibraryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipesByCategory = null,
    Object? ongoingAllergenKey = freezed,
    Object? flaggedAllergenKeys = null,
    Object? isStartingGuideSeen = null,
    Object? searchQuery = null,
  }) {
    return _then(
      _value.copyWith(
            recipesByCategory: null == recipesByCategory
                ? _value.recipesByCategory
                : recipesByCategory // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<Recipe>>,
            ongoingAllergenKey: freezed == ongoingAllergenKey
                ? _value.ongoingAllergenKey
                : ongoingAllergenKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            flaggedAllergenKeys: null == flaggedAllergenKeys
                ? _value.flaggedAllergenKeys
                : flaggedAllergenKeys // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            isStartingGuideSeen: null == isStartingGuideSeen
                ? _value.isStartingGuideSeen
                : isStartingGuideSeen // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeLibraryStateImplCopyWith<$Res>
    implements $RecipeLibraryStateCopyWith<$Res> {
  factory _$$RecipeLibraryStateImplCopyWith(
    _$RecipeLibraryStateImpl value,
    $Res Function(_$RecipeLibraryStateImpl) then,
  ) = __$$RecipeLibraryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, List<Recipe>> recipesByCategory,
    String? ongoingAllergenKey,
    Set<String> flaggedAllergenKeys,
    bool isStartingGuideSeen,
    String searchQuery,
  });
}

/// @nodoc
class __$$RecipeLibraryStateImplCopyWithImpl<$Res>
    extends _$RecipeLibraryStateCopyWithImpl<$Res, _$RecipeLibraryStateImpl>
    implements _$$RecipeLibraryStateImplCopyWith<$Res> {
  __$$RecipeLibraryStateImplCopyWithImpl(
    _$RecipeLibraryStateImpl _value,
    $Res Function(_$RecipeLibraryStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipesByCategory = null,
    Object? ongoingAllergenKey = freezed,
    Object? flaggedAllergenKeys = null,
    Object? isStartingGuideSeen = null,
    Object? searchQuery = null,
  }) {
    return _then(
      _$RecipeLibraryStateImpl(
        recipesByCategory: null == recipesByCategory
            ? _value._recipesByCategory
            : recipesByCategory // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<Recipe>>,
        ongoingAllergenKey: freezed == ongoingAllergenKey
            ? _value.ongoingAllergenKey
            : ongoingAllergenKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        flaggedAllergenKeys: null == flaggedAllergenKeys
            ? _value._flaggedAllergenKeys
            : flaggedAllergenKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        isStartingGuideSeen: null == isStartingGuideSeen
            ? _value.isStartingGuideSeen
            : isStartingGuideSeen // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RecipeLibraryStateImpl extends _RecipeLibraryState {
  const _$RecipeLibraryStateImpl({
    required final Map<String, List<Recipe>> recipesByCategory,
    this.ongoingAllergenKey,
    final Set<String> flaggedAllergenKeys = const <String>{},
    this.isStartingGuideSeen = false,
    this.searchQuery = '',
  }) : _recipesByCategory = recipesByCategory,
       _flaggedAllergenKeys = flaggedAllergenKeys,
       super._();

  final Map<String, List<Recipe>> _recipesByCategory;
  @override
  Map<String, List<Recipe>> get recipesByCategory {
    if (_recipesByCategory is EqualUnmodifiableMapView)
      return _recipesByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recipesByCategory);
  }

  @override
  final String? ongoingAllergenKey;
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
  @JsonKey()
  final bool isStartingGuideSeen;
  @override
  @JsonKey()
  final String searchQuery;

  @override
  String toString() {
    return 'RecipeLibraryState(recipesByCategory: $recipesByCategory, ongoingAllergenKey: $ongoingAllergenKey, flaggedAllergenKeys: $flaggedAllergenKeys, isStartingGuideSeen: $isStartingGuideSeen, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeLibraryStateImpl &&
            const DeepCollectionEquality().equals(
              other._recipesByCategory,
              _recipesByCategory,
            ) &&
            (identical(other.ongoingAllergenKey, ongoingAllergenKey) ||
                other.ongoingAllergenKey == ongoingAllergenKey) &&
            const DeepCollectionEquality().equals(
              other._flaggedAllergenKeys,
              _flaggedAllergenKeys,
            ) &&
            (identical(other.isStartingGuideSeen, isStartingGuideSeen) ||
                other.isStartingGuideSeen == isStartingGuideSeen) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_recipesByCategory),
    ongoingAllergenKey,
    const DeepCollectionEquality().hash(_flaggedAllergenKeys),
    isStartingGuideSeen,
    searchQuery,
  );

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeLibraryStateImplCopyWith<_$RecipeLibraryStateImpl> get copyWith =>
      __$$RecipeLibraryStateImplCopyWithImpl<_$RecipeLibraryStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RecipeLibraryState extends RecipeLibraryState {
  const factory _RecipeLibraryState({
    required final Map<String, List<Recipe>> recipesByCategory,
    final String? ongoingAllergenKey,
    final Set<String> flaggedAllergenKeys,
    final bool isStartingGuideSeen,
    final String searchQuery,
  }) = _$RecipeLibraryStateImpl;
  const _RecipeLibraryState._() : super._();

  @override
  Map<String, List<Recipe>> get recipesByCategory;
  @override
  String? get ongoingAllergenKey;
  @override
  Set<String> get flaggedAllergenKeys;
  @override
  bool get isStartingGuideSeen;
  @override
  String get searchQuery;

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeLibraryStateImplCopyWith<_$RecipeLibraryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
